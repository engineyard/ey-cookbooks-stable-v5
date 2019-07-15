require 'base64'
require 'openssl'

module EnvVars
  module Helper
    def encrypt(value, secret)
      MessageCipher.new(secret).encrypt(value)
    end

    def decrypt(value, secret)
      MessageCipher.new(secret).decrypt(value)
    end

    def fetch_environment_variables(app_data)
      metadata = app_data['components'].find {|component| component['key'] == 'app_metadata'}
      return [] unless metadata && metadata['environment_variables']

      variables = metadata['environment_variables'].map do |var_hash|
        if variable_validator(var_hash[:name])
          { :name => var_hash['name'], :value => escape_variable_value(::Base64.strict_decode64(var_hash['value'])).delete!("\n") }
        else
          Chef::Log.error('[COOKBOOK ENV_VARS] Variable name is not valid')
        end
      end
    end

    # Function for variable name validation
    def variable_validator(name)
        !!name.match(/\A[a-zA-Z]\w*\z/)
    end

    # Escapes the value of variable to be correctly enclosed in double quotes. Enclosing characters
    # in double quotes (") preserves the literal value of all characters within the quotes, with the
    # exception of $, `, \, and, when history expansion is enabled, !.
    def escape_variable_value(value)
      value.gsub(/[`$"\\]/) { |x| "\\#{x}" }
    end

    class MessageCipher
      DEFAULT_DIGEST = 'SHA1'
      DEFAULT_CIPHER = 'aes-256-cbc'

      class InvalidSignature < StandardError; end
      class InvalidMessage < StandardError; end

      attr_reader :message, :secret

      def initialize(secret, options = {})
        @secret = secret

        @serializer = options[:serializer] || Marshal
        @digest = OpenSSL::Digest.const_get(options[:digest] || DEFAULT_DIGEST).new
        @cipher = options[:cipher] || DEFAULT_CIPHER
      end

      def encrypt(message)
        encode_and_sign(_encrypt(message))
      end

      def decrypt(message)
        _decrypt(verify_and_decode(message))
      end

      private

      def encode_and_sign(value)
        data = encode(value)
        "#{data}--#{sign(data)}"
      end

      def verify_and_decode(message)
        data, signature = message.split("--")

        if !data.empty? && !signature.empty? && signature == sign(data)
          begin
            decode(data)
          rescue ArgumentError => argument_error
            raise InvalidSignature if argument_error.message =~ %r{invalid base64}
            raise
          end
        else
          raise InvalidSignature
        end
      end

      def sign(data)
        OpenSSL::HMAC.hexdigest(@digest, secret, data)
      end

      def encode(data)
        ::Base64.strict_encode64(data)
      end

      def decode(data)
        ::Base64.strict_decode64(data)
      end

      def new_cipher
        OpenSSL::Cipher::Cipher.new(@cipher)
      end

      def _encrypt(value)
        cipher = new_cipher
        cipher.encrypt
        cipher.key = @secret

        # Rely on OpenSSL for the initialization vector
        iv = cipher.random_iv

        encrypted_data = cipher.update(@serializer.dump(value))
        encrypted_data << cipher.final

        [encrypted_data, iv].map! { |v| encode(v) }.join('--')
      end

      def _decrypt(encrypted_message)
        cipher = new_cipher
        encrypted_data, iv = encrypted_message.split("--").map { |v| decode(v) }

        cipher.decrypt
        cipher.key = secret
        cipher.iv  = iv

        decrypted_data = cipher.update(encrypted_data)
        decrypted_data << cipher.final

        @serializer.load(decrypted_data)
      rescue OpenSSLCipherError, TypeError, ArgumentError
        raise InvalidMessage
      end
    end
  end
end

Chef::Recipe.send(:include, EnvVars::Helper)
Chef::Resource.send(:include, EnvVars::Helper)
