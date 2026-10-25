# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, 'devise' do
  include ActiveSupport::Testing::TimeHelpers

  describe 'validatable' do
    it 'requires a password of at least 12 characters' do
      user = User.new(email: 'short@example.com', password: 'elevenchars')

      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 12 characters)')
    end

    it 'accepts a 12 character password' do
      expect(User.new(email: 'ok@example.com', password: 'twelve-chars')).to be_valid
    end

    it 'requires a well-formed email' do
      user = User.new(email: 'not-an-email', password: 'a-long-test-password')

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('is invalid')
    end

    it 'rejects an email that differs only in case from an existing one' do
      FactoryBot.create(:user, email: 'taken@example.com')
      user = User.new(email: 'Taken@Example.com', password: 'a-long-test-password')

      expect(user).not_to be_valid
      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'does not re-check the password when other attributes change' do
      user = FactoryBot.create(:user)
      user.update_column(:encrypted_password, Devise::Encryptor.digest(User, 'short'))

      expect(user.reload.update(role: 'editor')).to be true
    end
  end

  describe 'lockable' do
    it 'locks the account after 10 failed sign-in attempts' do
      user = FactoryBot.create(:user)

      9.times { user.valid_for_authentication? { false } }
      expect(user.reload).not_to be_access_locked

      user.valid_for_authentication? { false }
      expect(user.reload).to be_access_locked
    end

    it 'unlocks automatically after an hour' do
      user = FactoryBot.create(:user)
      user.lock_access!(send_instructions: false)

      travel_to(61.minutes.from_now) do
        expect(user.reload).not_to be_access_locked
      end
    end
  end
end
