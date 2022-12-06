# frozen_string_literal: true

class Transfer < ActiveRecord::Base
  belongs_to :player

  delegate :can_transition_to?,
           :transition_to!,
           :transition_to,
           :current_state,
           :last_transition,
           to: :state_machine

  def state_machine
    @state_machine ||= TransferStateMachine.instance(self)
  end
end
