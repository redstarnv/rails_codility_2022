# frozen_string_literal: true

class Currency < ActiveRecord::Base
  scope :code, ->(s) { where(code: s) }

  def self.latest(s)
    code(s).last
  end

  def self.on_date(date, s)
    report_timestamp = code(s).where('reported_at <= ?', date.end_of_day).maximum(:reported_at)
    code(s).where(reported_at: report_timestamp).last ||
      raise(NoRateError, "No rate for #{s} on #{date}")
  end

  class Amount < Dry::Struct
    attribute :amount, Types::Coercible::Float
    attribute :currency, Types::Strict::String.constrained(size: 3)

    delegate :latest, :on_date, to: Currency

    def in(xe, fee: 0.0, round: 6, date: nil)
      xe_rate = date ? rate_on_date(date, xe, currency) : latest_rate(xe, currency)
      rate = xe == currency ? 1.0 : xe_rate
      (rate * amount * (1.0 - fee)).round(round)
    end

    private

    def latest_rate(xe, currency)
      xe == currency ? 1.0 : latest(xe).rate / latest(currency).rate
    end

    def rate_on_date(date, xe, currency)
      xe == currency ? 1.0 : on_date(date, xe).rate / on_date(date, currency).rate
    end
  end
end