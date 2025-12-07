# frozen_string_literal: true

require_relative '../../yasmin-arroyo-get-project-activities/handler'

RSpec.describe YasminArroyoGetProjectActivities do
  include YasminArroyoGetProjectActivities

  describe '#activities_url_by_parent_project_id' do
    it 'returns a valid URI with the parent_project_id parameter' do
      parent_project_id = 'ffff'

      uri = activities_url_by_parent_project_id(parent_project_id)

      expect(uri).to be_a(URI::HTTPS)
      expect(uri.to_s).to eq('https://api.todoist.com/api/v1/activities?parent_project_id=ffff')
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
      parent_project_id = 'test_project_123'
      api_token = 'test_api_token_12345'

      request = build_request(parent_project_id: parent_project_id, api_token: api_token)

      expect(request).to be_a(Net::HTTP::Get)
      expect(request['Authorization']).to eq('Bearer test_api_token_12345')
    end
  end

  describe '.handle (as module function)' do
    it 'can be called as a module function' do
      event = {
        "pathParameters" => { "project_id" => "test_project_123" },
        "queryStringParameters" => { "api_token" => "test_api_token_12345" }
      }
      context = {}

      # Mock the HTTP request to avoid making actual API calls
      allow(Net::HTTP).to receive(:start).and_return(
        double('response', code: '200', body: '{"result": "success"}')
      )

      result = YasminArroyoGetProjectActivities.handle(event: event, context: context)

      expect(result).to be_a(Hash)
      expect(result[:statusCode]).to eq(200)
      expect(result[:headers]).to eq({ 'Content-Type' => 'application/json' })
      expect(result[:body]).to eq('{"result": "success"}')
    end
  end
end
