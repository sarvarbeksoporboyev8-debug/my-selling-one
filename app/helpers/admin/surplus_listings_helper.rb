# frozen_string_literal: true

module Admin
  module SurplusListingsHelper
    def status_badge_class(status)
      case status
      when 'draft' then 'secondary'
      when 'active' then 'success'
      when 'reserved' then 'warning'
      when 'sold_out' then 'info'
      when 'expired' then 'danger'
      when 'cancelled' then 'dark'
      else 'secondary'
      end
    end

    def reservation_badge_class(status)
      case status
      when 'active' then 'success'
      when 'expired' then 'warning'
      when 'cancelled' then 'danger'
      when 'converted' then 'info'
      else 'secondary'
      end
    end

    def offer_badge_class(status)
      case status
      when 'pending' then 'warning'
      when 'accepted' then 'success'
      when 'rejected' then 'danger'
      when 'cancelled' then 'dark'
      when 'expired' then 'secondary'
      else 'secondary'
      end
    end
  end
end
