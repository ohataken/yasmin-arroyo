# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module YasminArroyoGetProjectActivities
  module_function

  def handle(event:, context:)
    parent_project_id = event["pathParameters"]["project_id"]
    api_token = event["queryStringParameters"]["api_token"]

    uri = activities_url_by_parent_project_id(parent_project_id: parent_project_id)
    request = build_request(parent_project_id: parent_project_id, api_token: api_token)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(request)
    end

    {
      statusCode: response.code.to_i,
      headers: {
        'Content-Type' => 'application/json'
      },
      body: response.body
    }
  end

  def build_request(parent_project_id:, api_token:)
    uri = activities_url_by_parent_project_id(parent_project_id)
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = bearer_token(api_token)
    request
  end

  def activities_url_by_parent_project_id(parent_project_id)
    uri = URI('https://api.todoist.com/api/v1/activities')
    uri.query = URI.encode_www_form({ parent_project_id: })
    uri
  end

  def bearer_token(api_token)
    "Bearer #{api_token}"
  end
end
