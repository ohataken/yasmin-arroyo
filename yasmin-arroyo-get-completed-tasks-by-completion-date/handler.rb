# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'openssl'

module YasminArroyoGetCompletedTasksByCompletionDate
  module_function

  def handle(event:, context:)
    project_id = event["pathParameters"]["project_id"]
    api_token = event["queryStringParameters"]["api_token"]

    uri = completed_tasks_by_completion_date_url(project_id)
    request = build_request(project_id:, api_token:)

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

  def build_request(project_id:, api_token:)
    uri = completed_tasks_by_completion_date_url(project_id)
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = bearer_token(api_token)
    request
  end

  def completed_tasks_by_completion_date_url(project_id)
    uri = URI('https://api.todoist.com/api/v1/tasks/completed/by_completion_date')
    uri.query = URI.encode_www_form({ project_id:, since: since_query_parameter.iso8601, until: until_query_parameter.iso8601 })
    uri
  end

  def until_query_parameter
    Time.now.utc
  end

  def since_query_parameter
    Time.now.utc - (60 * 60 * 24 * 7 * 4)
  end

  def bearer_token(api_token)
    "Bearer #{api_token}"
  end
end
