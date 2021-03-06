# frozen_string_literal: true

require 'vcr'
require 'simpleokta/users'

RSpec.describe Simpleokta::Client::Users do
  let(:bradens_id) { '00uxf5kx9MpPC2jpb5d6' }
  let(:profile_object) do
    profile_object = {
      profile: {
        firstName: 'Isaac',
        lastName: 'Brock',
        email: 'isaac.brock@example.com',
        login: 'isaac.brock@example.com',
        mobilePhone: '555-415-1337'
      }
    }
  end
  describe '#users' do
    it 'returns a list of users' do
      VCR.use_cassette('users/all_users', match_requests_on: [:path]) do
        response = client.users
        expect(response.class).to be(Array)
        expect(response).not_to be(nil)
      end
    end
  end
  describe '#user' do
    it 'returns a single user when passed a valid id' do
      VCR.use_cassette('users/single_user', match_requests_on: [:path]) do
        response = client.user(bradens_id)
        expect(response['id']).to eq(bradens_id)
        expect(response['created']).to eq('2021-06-10T15:04:48.000Z')
      end
    end
    it 'returns an error hash when passed an invalid id' do
      VCR.use_cassette('users/invalid_user', match_requests_on: [:path]) do
        response = client.user('asdfasdfsadfsadf')
        expect(response['errorCode']).to eq('E0000007')
        expect(response['errorSummary']).to eq('Not found: Resource not found: asdfasdfsadfsadf (User)')
      end
    end
  end
  describe '#user_from_login' do
    it 'returns a single user when passed a valid login email' do
      VCR.use_cassette('users/user_from_login', match_requests_on: [:path]) do
        response = client.user('bradenrshipley@gmail.com')
        expect(response['id']).to eq(bradens_id)
        expect(response['created']).to eq('2021-06-10T15:04:48.000Z')
      end
    end
    it 'returns an error hash when passed an invalid login email' do
      VCR.use_cassette('users/invalid_user_from_login', match_requests_on: [:path]) do
        response = client.user('auserthatdoesnotexist@domain.com')
        expect(response['errorCode']).to eq('E0000007')
        expect(response['errorSummary']).to eq('Not found: Resource not found: auserthatdoesnotexist@domain.com (User)')
      end
    end
  end
  describe '#create_user' do
    it 'creates a user when passed valid profile object' do
      VCR.use_cassette('users/create_user', match_requests_on: [:path]) do
        response = client.create_user(profile_object)
        expect(response['id']).to eq('00u10onqttoutdqBf5d7')
        expect(response['profile']['firstName']).to eq('Isaac')
        expect(response['profile']['lastName']).to eq('Brock')
      end
    end
    it 'returns an error hash when passing invalid parameters' do
      VCR.use_cassette('users/invalid_create_user', match_requests_on: [:path]) do
        response = client.create_user({ boop: 'bap' })
        expect(response['errorCode']).to eq('E0000003')
        expect(response['errorSummary']).to eq('The request body was not well-formed.')
      end
    end
  end
  describe '#create_and_activate_user' do
    it 'creates an active user when passed a valid profile object' do
      VCR.use_cassette('users/create_and_activate_user', match_requests_on: [:path]) do
        response = client.create_and_activate_user(profile_object)
        expect(response['status']).to eq('PROVISIONED')
        expect(response['activated']).not_to eq(nil)
        expect(response['profile']['firstName']).to eq('Isaac')
        expect(response['profile']['lastName']).to eq('Brock')
      end
    end
    it 'returns an error hash when passing invalid parameters' do
      VCR.use_cassette('users/invalid_create_and_activate', match_requests_on: [:path]) do
        response = client.create_and_activate_user({ boop: 'bap' })
        expect(response['errorCode']).to eq('E0000003')
        expect(response['errorSummary']).to eq('The request body was not well-formed.')
      end
    end
  end
  describe '#create_user_in_group' do
    it 'creates a user in a given group when passed valid parameters' do
      VCR.use_cassette('users/create_user_in_group', match_requests_on: [:path]) do
        response = client.create_user_in_group(profile_object, ['00g10pnp6v3Brgwlx5d7'])
        expect(response['id']).to eq('00u10pwwcjHUTNRmU5d7')
        expect(response['profile']['firstName']).to eq('Isaac')
        expect(response['profile']['lastName']).to eq('Brock')
      end
    end
    it 'returns an error hash when passed invalid parameters' do
      VCR.use_cassette('users/invalid_create_user_in_group', match_requests_on: [:path]) do
        response = client.create_user_in_group({ boop: 'bap' }, ['00g10pnp6v3Brgwlx5d7'])
        expect(response['errorCode']).to eq('E0000003')
        expect(response['errorSummary']).to eq('The request body was not well-formed.')
      end
    end
    it 'returns an error when passed an invalid group_id' do
      VCR.use_cassette('users/invalid_group_create_user_in_group', match_requests_on: [:path]) do
        response = client.create_user_in_group(profile_object, ['12345678901011'])
        expect(response['errorCode']).to eq('E0000007')
        expect(response['errorSummary']).to eq('Not found: Resource not found: 12345678901011 (UserGroup)')
      end
    end
  end
  describe '#delete_user' do
    it 'deletes a user when the user has a status of DEPROVISIONED' do
      VCR.use_cassette('users/delete_user', match_requests_on: [:path]) do
        response = client.delete_user('00u10q3ie478QZVxc5d7')
        expect(response.code).to eq(204)
      end
    end
    it 'sets a user status to DEACTIVATED when called on a user whose status != DEACTIVATED' do
      VCR.use_cassette('users/delete_user_active', match_requests_on: [:path]) do
        client.delete_user('00u10ribsoVWUttmX5d7')
        response = client.user('00u10ribsoVWUttmX5d7')
        expect(response['status']).to eq('DEPROVISIONED')
      end
    end
    it 'returns a 404 when passed an invalid user_id' do
      VCR.use_cassette('users/invalid_delete_user', match_requests_on: [:path]) do
        response = client.delete_user('somethingfake')
        expect(response.code).to eq(404)
      end
    end
  end
  describe '#update_user' do
    it 'returns an error hash when passed invalid parameters' do
      VCR.use_cassette('users/invalid_update_user', match_requests_on: [:path]) do
        new_profile_data = {
          profile: {
            mobilePhone: '555-415-1337'
          }
        }
        response = client.update_user('00u10ribsoVWUttmX5d7', new_profile_data)
        expect(response['errorCode']).to eq('E0000001')
        expect(response['errorCauses'].count).to eq(5)
      end
    end
    it 'updates a user when passed valid parameters' do
      VCR.use_cassette('users/update_user', match_requests_on: [:path]) do
        new_profile_data = {
          profile: {
            firstName: 'Isaac2',
            lastName: 'Brock2',
            email: 'isaac.brock2@example.com',
            login: 'isaac.brock@example.com',
            mobilePhone: '555-415-1337'
          }
        }
        response = client.update_user('00u10ribsoVWUttmX5d7', new_profile_data)
        expect(response['profile']['firstName']).to eq('Isaac2')
        expect(response['profile']['lastName']).to eq('Brock2')
        expect(response['profile']['mobilePhone']).to eq('555-415-1337')
      end
    end
    it 'returns an error when passed an invalid user_id' do
      VCR.use_cassette('users/invalid_id_update_user', match_requests_on: [:path]) do
        profile_data = {
          profile: {
            firstName: 'David',
            lastName: 'David',
            email: 'david.david@example.com',
            login: 'david.david@example.com',
            mobilePhone: '555-415-1337'
          }
        }
        response = client.update_user('fakeuserid', profile_data)
        expect(response['errorCode']).to eq('E0000007')
        expect(response['errorSummary']).to eq('Not found: Resource not found: fakeuserid (User)')
      end
    end
  end
  describe '#activate_user' do
    it 'activates a user when the given user is deactivated', match_requests_on: [:path] do
      VCR.use_cassette('users/activate_user', match_requests_on: [:path]) do
        response = client.activate_user('00u10q2zmvugkWr7d5d7', false)
        expect(response).not_to be(nil)
      end
    end
    it 'returns a 403 error code when the given user is already active' do
      VCR.use_cassette('users/invalid_activate_user', match_requests_on: [:path]) do
        response = client.activate_user('00u10q2zmvugkWr7d5d7', false)
        expect(response['errorCode']).to eq('E0000016')
        expect(response['errorSummary']).to eq('Activation failed because the user is already active')
      end
    end
    it 'returns an error when passed an invalid user_id' do
      VCR.use_cassette('users/invalid_id_activate_user', match_requests_on: [:path]) do
        response = client.activate_user('fakeuserid', false)
        expect(response['errorCode']).to eq('E0000007')
        expect(response['errorSummary']).to eq('Not found: Resource not found: fakeuserid (User)')
      end
    end
    it 'returns the expected body' do
      VCR.use_cassette('users/activate_user', match_requests_on: [:path]) do
        response = client.activate_user('00u10q2zmvugkWr7d5d7', false)
        expect(response.keys).to eq(%w[activationUrl activationToken])
      end
    end
  end
  describe '#reactivate_user' do
    it 'reactivates a user when their status is PROVISIONED' do
      VCR.use_cassette('users/reactivate_user', match_requests_on: [:path]) do
        response = client.reactivate_user('00u10ribsoVWUttmX5d7', false)
        expect(response['activationToken']).not_to be(nil)
      end
    end
    it 'returns an error hash when the given user is already active' do
      VCR.use_cassette('users/reactivate_user_already_active', match_requests_on: [:path]) do
        response = client.reactivate_user(bradens_id, false)
        expect(response['errorCode']).to eq('E0000038')
        expect(response['errorSummary']).to eq('This operation is not allowed in the user\'s current status.')
      end
    end
    it 'returns an error when passed an invalid user_id' do
      VCR.use_cassette('users/invalid_reactivate_user', match_requests_on: [:path]) do
        response = client.reactivate_user('fakeuserid', false)
        expect(response['errorCode']).to eq('E0000007')
        expect(response['errorSummary']).to eq('Not found: Resource not found: fakeuserid (User)')
      end
    end
    it 'returns the expected body' do
      VCR.use_cassette('users/reactivate_user', match_requests_on: [:path]) do
        response = client.reactivate_user('00u10ribsoVWUttmX5d7', false)
        expect(response.keys).to eq(%w[activationUrl activationToken])
      end
    end
  end
  describe '#deactivate_user' do
    it 'deactivates a user when the given user is active' do
      VCR.use_cassette('users/deactivate_user', match_requests_on: [:path]) do
        response = client.deactivate_user('00u10ribsoVWUttmX5d7', false)
        expect(response).to eq({})
      end
    end
    it 'returns an error when passed an invalid user_id' do
      VCR.use_cassette('users/invalid_deactivate_user', match_requests_on: [:path]) do
        response = client.deactivate_user('fakeuserid', false)
        expect(response['errorCode']).to eq('E0000007')
        expect(response['errorSummary']).to eq('Not found: Resource not found: fakeuserid (User)')
      end
    end
  end
  describe '#suspend_user' do
    it 'suspends a user when passed a valid user_id' do
      VCR.use_cassette('users/suspend_user', match_requests_on: [:path]) do
        response = client.suspend_user('00u10x5qqh0j0yTHK5d7')
        expect(response.code).to eq(200)
      end
    end
    it 'returns an error when passed an invalid user_id' do
      VCR.use_cassette('users/invalid_suspend_user', match_requests_on: [:path]) do
        response = client.suspend_user('fakeuserid')
        expect(JSON.parse(response.body)['errorCode']).to eq('E0000007')
        expect(JSON.parse(response.body)['errorSummary']).to eq('Not found: Resource not found: fakeuserid (User)')
      end
    end
    it 'returns an error when user does not have a status of ACTIVE' do
      VCR.use_cassette('users/suspend_user_active', match_requests_on: [:path]) do
        response = client.suspend_user('00u10x5qqh0j0yTHK5d7')
        expect(response.code).to eq(400)
        expect(JSON.parse(response.body)['errorCode']).to eq('E0000001')
        expect(JSON.parse(response.body)['errorSummary']).to eq('Api validation failed: suspendUser')
      end
    end
    it 'returns a status code of 200' do
      VCR.use_cassette('users/suspend_user', match_requests_on: [:path]) do
        response = client.suspend_user('00u10x5qqh0j0yTHK5d7')
        expect(response.code).to eq(200)
      end
    end
  end
  describe '#unsuspend_user' do
    it 'unsuspends a user when passed a valid user_id' do
      VCR.use_cassette('users/unsuspend_user', match_requests_on: [:path]) do
        response = client.unsuspend_user('00u10x5qqh0j0yTHK5d7')
        user = client.user('00u10x5qqh0j0yTHK5d7')
        expect(response.code).to eq(200)
        expect(user['status']).to eq('PASSWORD_EXPIRED')
      end
    end
    it 'returns an error when passed an invalid user_id' do
      VCR.use_cassette('users/invalid_unsuspend_user', match_requests_on: [:path]) do
        response = client.unsuspend_user('fakeuserid')
        expect(response.code).to eq(404)
        expect(JSON.parse(response.body)['errorCode']).to eq('E0000007')
        expect(JSON.parse(response.body)['errorSummary']).to eq('Not found: Resource not found: fakeuserid (User)')
      end
    end
  end
  describe '#unlock_user' do
    it 'unlocks a user whose status == LOCKED_OUT' do
      VCR.use_cassette('users/unlock_user', match_requests_on: [:path]) do
        response = client.unlock_user('00u10x5qqh0j0yTHK5d7')
        expect(response.code).to eq(200)
      end
    end
    it 'user is no longer LOCKED_OUT after invoking method' do
      VCR.use_cassette('users/unlocked_user', match_requests_on: [:path]) do
        response = client.user('00u10x5qqh0j0yTHK5d7')
        expect(response['status']).not_to eq('LOCKED_OUT')
      end
    end
  end
end
