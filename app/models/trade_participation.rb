# frozen_string_literal: true

class TradeParticipation
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :other_user
  attribute :given
  attribute :received
  attribute :confirmed_at, :datetime
end
