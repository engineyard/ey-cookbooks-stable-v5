require "net/http"
require "open-uri"
require "uri"
require "timeout"

# EC2 Instance Metadata Service (IMDS) helper.
#
# Instances with EC2 HttpTokens=required (IMDSv2 enforced) reject a plain
# unauthenticated IMDSv1 GET with 401 Unauthorized. So we try the IMDSv2 token
# handshake first (PUT a session token, then GET with the token header) and
# fall back to a plain unauthenticated GET only when the token PUT fails, so
# this works whether HttpTokens is required or optional.
#
# Mirrors the Stack v8 helper (ey-lib/libraries/imds.rb) and the enzyme fix,
# but this stack runs Chef 12 on Ruby 2.2, so `URI.open` (Ruby 2.5+) is not
# available. `OpenURI.open_uri` is used instead; unlike `Kernel#open` it only
# performs an HTTP fetch and never runs its argument as a subprocess.
module EY
  module IMDS
    # IMDS is only reachable over plain HTTP on the link-local 169.254.169.254
    # address; AWS provides no HTTPS endpoint for it, so http:// here is by
    # design, not a downgrade.
    BASE = "http://169.254.169.254".freeze
    TOKEN_TTL = "21600".freeze # 6h, matches the v8 helper
    TIMEOUT = 5

    module_function

    # Fetch a metadata value at `path` (e.g. "latest/meta-data/instance-type").
    # Uses an IMDSv2 token when one can be acquired, otherwise falls back to a
    # plain IMDSv1 GET. Raises on a genuine fetch failure (loud, as before) so
    # callers that relied on the previous fail-loud behaviour are unchanged.
    #
    # Timeout.timeout bounds the whole fetch, including connect, so a dropped
    # route to the metadata address cannot hang the chef run.
    def get(path)
      token = token()
      headers = token ? { "X-aws-ec2-metadata-token" => token } : {}
      headers[:read_timeout] = TIMEOUT
      Timeout.timeout(TIMEOUT) do
        OpenURI.open_uri("#{BASE}/#{path}", headers) { |io| io.read }
      end
    end

    # Request an IMDSv2 session token. Returns the token string, or nil if the
    # PUT fails (network error / genuinely IMDSv1-only environment) so the
    # caller can fall back to an unauthenticated GET.
    def token
      uri = URI("#{BASE}/latest/api/token")
      req = Net::HTTP::Put.new(uri.request_uri)
      req["X-aws-ec2-metadata-token-ttl-seconds"] = TOKEN_TTL
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = TIMEOUT
      http.read_timeout = TIMEOUT
      res = http.start { |connection| connection.request(req) }
      # An empty body would be truthy and produce an empty token header.
      return nil unless res.is_a?(Net::HTTPSuccess)
      body = res.body
      (body.nil? || body.empty?) ? nil : body
    rescue StandardError
      nil
    end
  end
end
