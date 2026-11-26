require_relative '../libraries/imds'
require 'stringio'

# Unit coverage for the IMDSv2 helper. Stubs the Net::HTTP / OpenURI seam, so
# it needs no metadata endpoint and no Chef run.
describe EY::IMDS do
  let(:path) { 'latest/meta-data/instance-type' }
  let(:url)  { "http://169.254.169.254/#{path}" }

  def stub_token_response(response)
    http = double('Net::HTTP')
    allow(http).to receive(:open_timeout=)
    allow(http).to receive(:read_timeout=)
    allow(http).to receive(:start).and_return(response)
    allow(Net::HTTP).to receive(:new).with('169.254.169.254', 80).and_return(http)
  end

  context 'when the token PUT succeeds (HttpTokens=required or optional)' do
    it 'sends the token on the metadata GET' do
      ok = Net::HTTPOK.new('1.1', '200', 'OK')
      allow(ok).to receive(:body).and_return('TOKEN==')
      stub_token_response(ok)
      io = double('io', :read => 'm5.large')
      expect(OpenURI).to receive(:open_uri)
        .with(url, { 'X-aws-ec2-metadata-token' => 'TOKEN==', :read_timeout => 5 })
        .and_yield(io).and_return('m5.large')
      expect(EY::IMDS.get(path)).to eq('m5.large')
    end
  end

  context 'when the token PUT fails' do
    it 'falls back to a plain GET with no token header' do
      allow(Net::HTTP).to receive(:new).and_raise(Errno::ECONNREFUSED)
      io = double('io', :read => 'm5.large')
      expect(OpenURI).to receive(:open_uri)
        .with(url, { :read_timeout => 5 })
        .and_yield(io).and_return('m5.large')
      expect(EY::IMDS.get(path)).to eq('m5.large')
    end

    it 'treats an empty token body as no token' do
      ok = Net::HTTPOK.new('1.1', '200', 'OK')
      allow(ok).to receive(:body).and_return('')
      stub_token_response(ok)
      expect(EY::IMDS.token).to be_nil
    end

    it 'treats a non-2xx token response as no token' do
      stub_token_response(Net::HTTPForbidden.new('1.1', '403', 'Forbidden'))
      expect(EY::IMDS.token).to be_nil
    end
  end

  context 'when the metadata GET is refused' do
    it 'raises rather than returning the error body' do
      allow(EY::IMDS).to receive(:token).and_return(nil)
      allow(OpenURI).to receive(:open_uri)
        .and_raise(OpenURI::HTTPError.new('401 Unauthorized', StringIO.new))
      expect { EY::IMDS.get(path) }.to raise_error(OpenURI::HTTPError)
    end
  end
end
