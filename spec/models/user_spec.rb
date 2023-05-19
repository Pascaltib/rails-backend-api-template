# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Rspec/InstanceVariable
RSpec.describe User do
  let(:user_email) { create_user }
  let(:user_phone) { create_user_with_phone_number }

  describe 'validations' do
    context 'when auth_method is nil' do
      before { user_email.auth_method = nil }

      it 'is not valid' do
        expect(user_email).not_to be_valid
      end

      it 'provides the correct error message' do
        user_email.valid?
        expect(user_email.errors[:auth_method]).to include("can't be blank")
      end
    end

    # rubocop:disable RSpec/NestedGroups
    context 'when auth_method is email' do
      context 'when email is nil' do
        before { user_email.email = nil }

        it 'is not valid' do
          expect(user_email).not_to be_valid
        end

        it 'provides the correct error message' do
          user_email.valid?
          expect(user_email.errors[:email]).to include("can't be blank")
        end
      end

      context 'when email format is invalid' do
        before { user_email.email = 'invalid email' }

        it 'is not valid' do
          expect(user_email).not_to be_valid
        end

        it 'provides the correct error message' do
          user_email.valid?
          expect(user_email.errors[:email]).to include('is invalid')
        end
      end

      context 'when email is not unique' do
        before do
          user_email.save
          @duplicate_user = described_class.new(email: user_email.email, password: 'password')
        end

        it 'is not valid' do
          expect(@duplicate_user).not_to be_valid
        end

        it 'provides the correct error message' do
          @duplicate_user.valid?
          expect(@duplicate_user.errors[:email]).to include('has already been taken')
        end
      end
    end

    context 'when auth_method is phone_number' do
      context 'when phone_number is nil' do
        before { user_phone.phone_number = nil }

        it 'is not valid' do
          expect(user_phone).not_to be_valid
        end

        it 'provides the correct error message' do
          user_phone.valid?
          expect(user_phone.errors[:phone_number]).to include('must be present when authentication method is phone number')
        end
      end

      context 'when phone_number format is invalid' do
        before { user_phone.phone_number = 'invalid phone_number' }

        it 'is not valid' do
          expect(user_phone).not_to be_valid
        end

        it 'provides the correct error message' do
          user_phone.valid?
          expect(user_phone.errors[:phone_number]).to include('is invalid')
        end
      end

      context 'when phone_number is not unique' do
        before do
          user_phone.save
          @duplicate_user = described_class.new(phone_number: user_phone.phone_number, password: 'password')
        end

        it 'is not valid' do
          expect(@duplicate_user).not_to be_valid
        end

        it 'provides the correct error message' do
          @duplicate_user.valid?
          expect(@duplicate_user.errors[:phone_number]).to include('has already been taken')
        end
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups

  describe '#email_required?' do
    context 'when auth_method is email' do
      it 'returns true' do
        expect(user_email.email_required?).to be true
      end
    end

    context 'when auth_method is phone_number' do
      it 'returns false' do
        expect(user_phone.email_required?).to be false
      end
    end
  end

  describe '#phone_required?' do
    context 'when auth_method is email' do
      it 'returns false' do
        expect(user_email.phone_required?).to be false
      end
    end

    context 'when auth_method is phone_number' do
      it 'returns true' do
        expect(user_phone.phone_required?).to be true
      end
    end
  end

  describe '.find_for_database_authentication' do
    before do
      user_email.save
      user_phone.save
    end

    context 'when auth_method is email' do
      it 'returns the user with the correct email' do
        expect(described_class.find_for_database_authentication(login: user_email.email,
                                                                auth_method: 0)).to eq(user_email)
      end
    end

    context 'when auth_method is phone_number' do
      it 'returns the user with the correct phone_number' do
        expect(described_class.find_for_database_authentication(login: user_phone.phone_number,
                                                                auth_method: 1)).to eq(user_phone)
      end
    end
  end
end
# rubocop:enable Rspec/InstanceVariable
