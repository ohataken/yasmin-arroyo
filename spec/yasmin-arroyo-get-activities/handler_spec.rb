# frozen_string_literal: true

require_relative '../../yasmin-arroyo-get-activities/handler'

RSpec.describe YasminArroyoGetActivities do
  include YasminArroyoGetActivities

  describe '#activities_url_by_parent_project_id' do
    it 'returns a valid URI with the parent_project_id parameter' do
      parent_project_id = 'ffff'

      uri = activities_url_by_parent_project_id(parent_project_id)

      expect(uri).to be_a(URI::HTTPS)
      expect(uri.to_s).to eq('https://api.todoist.com/api/v1/activities?parent_project_id=ffff')
    end
  end
end
