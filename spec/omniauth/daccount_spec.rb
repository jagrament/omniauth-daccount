require "spec_helper"

RSpec.describe OmniAuth::Daccount do

  let(:access_token) { instance_double('AccessToken', :options => {}) }
  let(:parsed_response) { instance_double('ParsedResponse') }
  let(:response) { instance_double('Response', :parsed => parsed_response) }

  let(:enterprise_site)          { 'https://conf.uw.docomo.ne.jp' }
  let(:enterprise_authorize_url) { 'https://id.smt.docomo.ne.jp/cgi8/oidc/authorize' }
  let(:enterprise_token_url)     { 'https://conf.uw.docomo.ne.jp/common/token' }
  let(:enterprise) do
    OmniAuth::Strategies::Daccount.new('D_ACCOUNT_KEY', 'D_ACCOUNT_SECRET',
        {
            :client_options => {
                :site => enterprise_site,
                :authorize_url => enterprise_authorize_url,
                :token_url => enterprise_token_url
            }
        }
    )
  end
  subject do
    OmniAuth::Strategies::Daccount.new({})
  end

  before(:each) do
    allow(subject).to receive(:access_token).and_return(access_token)
  end

  context 'client options' do
    it 'should have correct site' do
      expect(subject.options.client_options.site).to eq('https://conf.uw.docomo.ne.jp')
    end

    it 'should have correct authorize url' do
      expect(subject.options.client_options.authorize_url).to eq('https://id.smt.docomo.ne.jp/cgi8/oidc/authorize')
    end

    it 'should have correct token url' do
      expect(subject.options.client_options.token_url).to eq('https://conf.uw.docomo.ne.jp/common/token')
    end

    describe 'should be overrideable' do
      it 'for site' do
        expect(enterprise.options.client_options.site).to eq(enterprise_site)
      end

      it 'for authorize url' do
        expect(enterprise.options.client_options.authorize_url).to eq(enterprise_authorize_url)
      end

      it 'for token url' do
        expect(enterprise.options.client_options.token_url).to eq(enterprise_token_url)
      end
    end
  end

  context '#raw_info' do
    it 'should use relative paths' do
      expect(access_token).to receive(:get).with('/common/userinfo').and_return(response)
      expect(subject.raw_info).to eq(parsed_response)
    end
  end
  context '#info.urls' do
    it 'should use html_url from raw_info' do
      allow(subject).to receive(:raw_info).and_return({ 'sub' => '248289761001', 'iss' => 'http://server.example.com' })
      expect(subject.info[:sub]).to eq('248289761001')
      expect(subject.info[:iss]).to eq('http://server.example.com')
    end
  end

  describe '#callback_url' do
    it 'is a combination of host, script name, and callback path' do
      allow(subject).to receive(:full_host).and_return('https://example.com')
      allow(subject).to receive(:script_name).and_return('/sub_uri')

      expect(subject.callback_url).to eq('https://example.com/sub_uri/login/docomo_callback')
    end
  end


end
