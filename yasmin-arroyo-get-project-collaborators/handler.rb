# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'openssl'

module YasminArroyoGetProjectCollaborators
  module_function

  def handle(event:, context:)
    project_id = event["pathParameters"]["project_id"]
    api_token = event["queryStringParameters"]["api_token"]

    uri = collaborators_url_by_project_id(project_id: project_id)
    request = build_request(project_id: project_id, api_token: api_token)

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
    uri = collaborators_url_by_project_id(project_id)
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = bearer_token(api_token)
    request
  end

  def collaborators_url_by_project_id(project_id)
    URI("https://api.todoist.com/api/v1/projects/#{project_id}/collaborators")
  end

  def bearer_token(api_token)
    "Bearer #{api_token}"
  end
end
