# frozen_string_literal: true

require 'uri'

module YasminArroyoGetActivities
  def handle
    # TODO: Implement handler logic
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
