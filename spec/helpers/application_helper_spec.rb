require "rails_helper"
require "support/user_sessions.rb"

RSpec.describe ApplicationHelper, type: :helper do
  include Devise::Test::ControllerHelpers

  describe "#logged_in?" do
    let(:user) { create(:user) }

    it "returns false with empty session" do
      expect(helper.logged_in?).to be false
    end

    it "returns true for valid session" do
      sign_in user
      expect(helper.logged_in?).to be true
    end
  end

  describe "#canonical_name" do
    it "returns nil if name is nil" do
      expect(helper.canonical_name(nil)).to be_nil
    end

    it "returns parametrized name" do
      expect(helper.canonical_name("Liberal Democrats"))
        .to eq("liberal_democrats")
    end
  end

  describe "#mobile_verified?" do
    context "when logged out" do
      # This should never happen, but let's be safe

      it "returns false" do
        expect(helper.mobile_verified?).to be_falsey
      end
    end

    context "when logged in", logged_in: true do
      it "with no mobile phone returns false" do
        expect(helper.mobile_verified?).to be_falsey
      end

      context "with mobile phone" do
        before do
          phone = create(:mobile_phone, user: user)
          user.mobile_phone = phone
          user.save
        end

        it "returns false when not verified" do
          expect(helper.mobile_verified?).to be_falsey
        end

        it "returns true when verified" do
          # Note that here we have to set verified = true on the
          # MobilePhone instance returned from current_user, since the
          # user local variable from let() is a different User
          # instance representing the same user, so setting verified =
          # true on that would not get picked up by the helper which
          # reads it from current_user.
          user.mobile_phone.verified = true
          user.mobile_phone.save

          expect(helper.mobile_verified?).to be_truthy
        end
      end
    end
  end

  describe "#mobile_set_but_not_verified?" do
    context "when logged out" do
      # This should never happen, but let's be safe

      it "returns false" do
        expect(helper.mobile_set_but_not_verified?).to be_falsey
      end
    end

    context "when logged in", logged_in: true do
      context "with no mobile phone" do
        it "returns false" do
          expect(helper.mobile_set_but_not_verified?).to be_falsey
        end
      end

      context "with mobile phone" do
        before do
          phone = create(:mobile_phone, user: user)
          user.mobile_phone = phone
          user.save
        end

        it "returns true when not verified" do
          expect(helper.mobile_set_but_not_verified?).to be_truthy
        end

        it "returns false when verified" do
          # Note that here we have to set verified = true on the
          # MobilePhone instance returned from current_user, since the
          # user local variable from let() is a different User
          # instance representing the same user, so setting verified =
          # true on that would not get picked up by the helper which
          # reads it from current_user.
          user.mobile_phone.verified = true
          user.mobile_phone.save

          expect(helper.mobile_set_but_not_verified?).to be_falsey
        end
      end
    end
  end

  describe ".swapping_open?" do
    before do
      allow(ENV).to receive(:[]).with("SWAPMYVOTE_MODE").and_return(app_mode)
    end

    %w[ closed-warm-up closed-and-voting closed-wind-down ].each do |value|
      context "when SWAPMYVOTE_MODE is #{value.inspect}" do
        let(:app_mode) { value }
        specify { expect(helper.swapping_open?).to be_falsey }
      end
    end

    %w[ open open-and-voting ].each do |value|
      context "when SWAPMYVOTE_MODE is #{value.inspect}" do
        let(:app_mode) { value }
        specify { expect(helper.swapping_open?).to be_truthy }
      end
    end
  end

  describe ".voting_open?" do
    before do
      allow(ENV).to receive(:[]).with("SWAPMYVOTE_MODE").and_return(app_mode)
    end

    %w[ closed-warm-up open closed-wind-down ].each do |value|
      context "when SWAPMYVOTE_MODE is #{value.inspect}" do
        let(:app_mode) { value }
        specify { expect(helper.voting_open?).to be_falsey }
      end
    end

    %w[ open-and-voting closed-and-voting ].each do |value|
      context "when SWAPMYVOTE_MODE is #{value.inspect}" do
        let(:app_mode) { value }
        specify { expect(helper.voting_open?).to be_truthy }
      end
    end
  end
end
