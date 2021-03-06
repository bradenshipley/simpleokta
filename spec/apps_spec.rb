# frozen_string_literal: true

require 'vcr'
require 'simpleokta/apps'

RSpec.describe Simpleokta::Client::Apps do
  describe '#apps' do
    it 'returns a list of applications' do
      VCR.use_cassette('apps/all_apps', match_requests_on: [:path]) do
        response = client.apps
        expect(response.count).to eq(4)
        expect(response.first['id']).to eq('0oaxf5krmAOlBwXdS5d6')
      end
    end
  end
  describe '#app' do
    it 'returns a single application when passed an id' do
      VCR.use_cassette('apps/single_app', match_requests_on: [:path]) do
        response = client.app('0oaxf5krmAOlBwXdS5d6')
        expect(response['label']).to eq('Okta Admin Console')
        expect(response['name']).to eq('saasure')
        expect(response['created']).to eq('2021-06-10T15:04:42.000Z')
      end
    end
  end
  describe '#users_assigned_to_application' do
    it 'returns the users assigned to the app' do
      VCR.use_cassette('apps/app_users', match_requests_on: [:path]) do
        response = client.users_assigned_to_application('0oaxf5krmAOlBwXdS5d6')
        expect(response.first['id']).to eq('00uxf5kx9MpPC2jpb5d6')
      end
    end
  end
  describe '#create_app' do
    it 'creates an application when passed a valid request body' do
      VCR.use_cassette('apps/create_app', match_requests_on: [:path]) do
        app_data = {
          "name": 'template_basic_auth',
          "label": 'A New Application',
          "signOnMode": 'BASIC_AUTH',
          "settings": {
            "app": {
              "url": 'https://example.com/login.html',
              "authURL": 'https://example.com/auth.html'
            }
          }
        }
        response = client.create_app(app_data)
        expect(response['id']).to eq('0oa10ggguzH2JBB0I5d7')
        expect(response['label']).to eq('A New Application')
      end
    end
  end
  describe '#update_app' do
    it 'updates an app when passed a valid app_data object' do
      VCR.use_cassette('apps/update_app', match_requests_on: [:path]) do
        app_data = {
          "name": 'template_basic_auth',
          "label": 'A New Application: Electric Boogaloo',
          "signOnMode": 'BASIC_AUTH',
          "settings": {
            "app": {
              "url": 'https://example.com/login.html',
              "authURL": 'https://example.com/auth.html'
            }
          }
        }
        response = client.update_app('0oa10ggguzH2JBB0I5d7', app_data)
        expect(response['id']).to eq('0oa10ggguzH2JBB0I5d7')
        expect(response['label']).to eq('A New Application: Electric Boogaloo')
      end
    end
  end
  describe '#activate_app' do
    it 'activates an app when passed a valid id' do
      VCR.use_cassette('apps/activate_app', match_requests_on: [:path]) do
        response = client.activate_app('0oa10ggguzH2JBB0I5d7')
        expect(response).to eq('Application with id: 0oa10ggguzH2JBB0I5d7 activated')
      end
    end
  end
  describe '#deactivate_app' do
    it 'deactivates an app when passed a valid id' do
      VCR.use_cassette('apps/deactivate_app', match_requests_on: [:path]) do
        response = client.deactivate_app('0oa10ggguzH2JBB0I5d7')
        expect(response).to eq('Application with id: 0oa10ggguzH2JBB0I5d7 deactivated')
      end
    end
  end
  describe '#delete_app' do
    it 'deletes an app when passed a valid id' do
      VCR.use_cassette('apps/delete_app', match_requests_on: [:path]) do
        response = client.delete_app('0oa10ggguzH2JBB0I5d7')
        expect(response.code).to eq(204)
      end
    end
  end
end
