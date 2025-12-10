# frozen_string_literal: true

require_relative '../../yasmin-arroyo-get-completed-tasks-by-completion-date/handler'

RSpec.describe YasminArroyoGetCompletedTasksByCompletionDate do
  include YasminArroyoGetCompletedTasksByCompletionDate

  describe '#completed_tasks_url_by_completion_date' do
    it 'returns a valid URI with the since parameter' do
      completion_date = '2025-12-01T00:00:00'

      uri = completed_tasks_url_by_completion_date(completion_date)

      expect(uri).to be_a(URI::HTTPS)
      expect(uri.to_s).to eq('https://api.todoist.com/sync/v9/completed/get_all?since=2025-12-01T00%3A00%3A00')
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
      completion_date = '2025-12-01T00:00:00'
      api_token = 'test_api_token_12345'

      request = build_request(completion_date: completion_date, api_token: api_token)

      expect(request).to be_a(Net::HTTP::Get)
      expect(request['Authorization']).to eq('Bearer test_api_token_12345')
    end
  end
end
