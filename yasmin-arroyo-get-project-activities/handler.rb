# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

module YasminArroyoGetProjectActivities
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
  module_function :handle

  def build_request(parent_project_id:, api_token:)
    uri = activities_url_by_parent_project_id(parent_project_id)
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = bearer_token(api_token)
    request
  end
  module_function :build_request

  def activities_url_by_parent_project_id(parent_project_id)
    uri = URI('https://api.todoist.com/api/v1/activities')
    uri.query = URI.encode_www_form({ parent_project_id: })
    uri
  end
  module_function :activities_url_by_parent_project_id

  def bearer_token(api_token)
    "Bearer #{api_token}"
  end
  module_function :bearer_token

  private :activities_url_by_parent_project_id, :bearer_token
end
