# frozen_string_literal: true

require_relative '../../yasmin-arroyo-get-user/handler'

RSpec.describe YasminArroyoGetUser do
  include YasminArroyoGetUser

  describe '#user_url' do
    it 'returns a valid URI for the Todoist user endpoint' do
      uri = user_url

      expect(uri).to be_a(URI::HTTPS)
      expect(uri.to_s).to eq('https://api.todoist.com/sync/v9/sync?sync_token=*&resource_types=[%22user%22]')
    end
  end

  describe '#bearer_token' do
    it 'returns a bearer token string without errors' do
      api_token = 'test_api_token_12345'

      result = bearer_token(api_token)

      expect(result).to eq('Bearer test_api_token_12345')
    end
  end

  describe '#build_request' do
    it 'returns a Net::HTTP::Get request without errors' do
      api_token = 'test_api_token_12345'

      request = build_request(api_token: api_token)

      expect(request).to be_a(Net::HTTP::Get)
      expect(request['Authorization']).to eq('Bearer test_api_token_12345')
    end
  end
end
