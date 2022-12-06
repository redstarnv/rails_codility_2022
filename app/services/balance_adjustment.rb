# frozen_string_literal: true

class BalanceAdjustment
  def self.call(player, amount, currency)
    transfer = Transfer.create!(
      player: player,
      amount: amount,
      currency: currency
    )
    new(transfer).execute
  end

  attr_accessor :transfer

  def initialize(transfer)
    @transfer = transfer
  end

  delegate :transition_to!, :player, :amount, :currency, to: :transfer
  delegate :currency, to: :player, prefix: true

  def execute
    Transfer.transaction do
      transition_to! :completed
      transfer_money
    end
  end

  private

  def transfer_money
    TnxAPI.transfer(
      player_login: player.login,
      currency: player_currency,
      amount: player_amount
    )
  end

  def player_amount
    if player_currency == currency
      amount
    else
      Currency::Amount.new(currency: currency, amount: amount).in(player.currency)
    end
  end
end
