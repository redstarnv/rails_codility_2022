# frozen_string_literal: true

class TransferStateMachine
  module_function

  def self.instance(transfer)
    new transfer
  end

  include Statesman::Machine

  state :created, initial: true
  state :sent
  state :failed
  state :completed

  transition from: :created, to: %i[prepared sent failed completed]
  transition from: :sent, to: %i[failed completed cancelled]
  transition from: :completed, to: %i[failed cancelled]
end
