# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'openssl'

module YasminArroyoGetUser
  module_function

  def handle(event:, context:)
    api_token = event["queryStringParameters"]["api_token"]

    uri = user_url
    request = build_request(api_token: api_token)

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

  def build_request(api_token:)
    uri = user_url
    request = Net::HTTP::Get.new(uri)
    request['Authorization'] = bearer_token(api_token)
    request
  end

  def user_url
    URI('https://api.todoist.com/sync/v9/sync?sync_token=*&resource_types=["user"]')
  end

  def bearer_token(api_token)
    "Bearer #{api_token}"
  end
end
