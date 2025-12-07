# frozen_string_literal: true

require 'net/http'
require 'uri'

module YasminArroyoGetActivities
  def handle(event:, context:)
    parent_project_id = event["pathParameters"]["project_id"]
    api_token = event["queryStringParameters"]["api_token"]
  end

  def build_request(parent_project_id:, api_token:)
    uri = activities_url_by_parent_project_id(parent_project_id)
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = bearer_token(api_token)
    request
  end

  private

  def activities_url_by_parent_project_id(parent_project_id)
    uri = URI('https://api.todoist.com/api/v1/activities')
    uri.query = URI.encode_www_form({ parent_project_id: })
    uri
  end

  def bearer_token(api_token)
    "Bearer #{api_token}"
  end
end
