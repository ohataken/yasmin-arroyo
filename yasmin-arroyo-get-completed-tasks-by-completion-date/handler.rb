# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'openssl'

module YasminArroyoGetCompletedTasksByCompletionDate
  module_function

  def handle(event:, context:)
    completion_date = event["pathParameters"]["completion_date"]
    api_token = event["queryStringParameters"]["api_token"]

    uri = completed_tasks_url_by_completion_date(completion_date: completion_date)
    request = build_request(completion_date: completion_date, api_token: api_token)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.request(request)
    end

    {
      statusCode: response.code.to_i,
      headers: {
        'Content-Type' => 'application/json; charset=utf-8'
      },
      body: JSON.generate(JSON.parse(response.body))
    }
  end

  def build_request(completion_date:, api_token:)
    uri = completed_tasks_url_by_completion_date(completion_date)
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = bearer_token(api_token)
    request
  end

  def completed_tasks_url_by_completion_date(completion_date)
    uri = URI('https://api.todoist.com/sync/v9/completed/get_all')
    uri.query = URI.encode_www_form({ since: completion_date })
    uri
  end

  def bearer_token(api_token)
    "Bearer #{api_token}"
  end
end
