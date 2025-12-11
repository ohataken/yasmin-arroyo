# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'
require 'openssl'
require 'time'
require 'bundler/setup'
Bundler.require

module YasminArroyoGetProjectActivitiesRss
  module_function

  def handle(event:, context:)
    project_id = event["pathParameters"]["project_id"]
    api_token = event["queryStringParameters"]["api_token"]

    # Fetch collaborators
    collaborators_data = fetch_collaborators(project_id: project_id, api_token: api_token)
    collaborators_map = build_collaborators_map(collaborators_data)

    # Fetch activities
    activities_data = fetch_activities(project_id: project_id, api_token: api_token)

    # Generate RSS
    rss_content = generate_rss(
      project_id: project_id,
      activities: activities_data['results'] || [],
      collaborators_map: collaborators_map
    )

    {
      statusCode: 200,
      headers: {
        'Content-Type' => 'application/rss+xml; charset=utf-8'
      },
      body: rss_content
    }
  rescue StandardError => e
    {
      statusCode: 500,
      headers: {
        'Content-Type' => 'application/json; charset=utf-8'
      },
      body: JSON.generate({ error: e.message })
    }
  end

  def cdn_hostname
    ENV['CDN_HOSTNAME'] || 'xxxxxxxxxxxx.cloudfront.net'
  end

  def fetch_collaborators(project_id:, api_token:)
    uri = URI("https://#{cdn_hostname}/projects/#{project_id}/collaborators")
    uri.query = URI.encode_www_form({ api_token: api_token })

    request = Net::HTTP::Get.new(uri)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.request(request)
    end

    JSON.parse(response.body)
  end

  def fetch_activities(project_id:, api_token:)
    uri = URI("https://#{cdn_hostname}/projects/#{project_id}/activities")
    uri.query = URI.encode_www_form({ api_token: api_token })

    request = Net::HTTP::Get.new(uri)

    response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      http.request(request)
    end

    JSON.parse(response.body)
  end

  def build_collaborators_map(collaborators_data)
    results = collaborators_data['results'] || []
    results.each_with_object({}) do |collaborator, map|
      map[collaborator['id']] = collaborator['name']
    end
  end

  def generate_rss(project_id:, activities:, collaborators_map:)
    rss = RSS::Maker.make('2.0') do |maker|
      maker.channel.title = "Todoist Project Activities - #{project_id}"
      maker.channel.link = "https://todoist.com/app/project/#{project_id}"
      maker.channel.description = "Activity feed for Todoist project #{project_id}"
      maker.channel.updated = Time.now.to_s

      activities.each do |activity|
        maker.items.new_item do |item|
          extra_data = activity['extra_data'] || {}
          content = extra_data['content'] || 'No content'
          event_type = activity['event_type'] || 'unknown'
          initiator_id = activity['initiator_id']
          initiator_name = collaborators_map[initiator_id] || "User #{initiator_id}"

          item.title = "#{event_type}: #{content}"
          item.link = "https://todoist.com/app/task/#{activity['object_id']}"
          item.description = build_item_description(activity, initiator_name)
          item.pubDate = Time.parse(activity['event_date']) if activity['event_date']
          item.guid.content = activity['id'].to_s
          item.guid.isPermaLink = false
          item.author = initiator_name
        end
      end
    end

    rss.to_s
  end

  def build_item_description(activity, initiator_name)
    extra_data = activity['extra_data'] || {}
    parts = []

    parts << "Event: #{activity['event_type']}"
    parts << "Initiator: #{initiator_name}"
    parts << "Content: #{extra_data['content']}" if extra_data['content']
    parts << "Due Date: #{extra_data['due_date']}" if extra_data['due_date']
    parts << "Is Recurring: #{extra_data['is_recurring']}" if extra_data.key?('is_recurring')
    parts << "Client: #{extra_data['client']}" if extra_data['client']
    parts << "Note Count: #{extra_data['note_count']}" if extra_data.key?('note_count')

    parts.join("\n")
  end
end
