# frozen_string_literal: true

class SurplusMailer < Spree::BaseMailer
  include I18nHelper

  # Sent to seller when a reservation is created
  def reservation_created_to_seller(reservation)
    @reservation = reservation
    @listing = reservation.surplus_listing
    @buyer = reservation.buyer
    @enterprise = @listing.enterprise

    I18n.with_locale valid_locale(@enterprise.owner) do
      subject = t('surplus_mailer.reservation_created.subject',
                  quantity: format_quantity(@reservation.quantity, @listing.unit),
                  product: @listing.variant&.name_to_display)

      mail(
        to: @enterprise.contact&.email || @enterprise.owner&.email,
        from: from_address,
        subject: subject
      )
    end
  end

  # Sent to seller when an offer is created
  def offer_created_to_seller(offer)
    @offer = offer
    @listing = offer.surplus_listing
    @buyer = offer.buyer
    @enterprise = @listing.enterprise

    I18n.with_locale valid_locale(@enterprise.owner) do
      subject = t('surplus_mailer.offer_created.subject',
                  quantity: format_quantity(@offer.offered_quantity, @listing.unit),
                  product: @listing.variant&.name_to_display)

      mail(
        to: @enterprise.contact&.email || @enterprise.owner&.email,
        from: from_address,
        subject: subject
      )
    end
  end

  # Sent to buyer when their offer is accepted
  def offer_accepted_to_buyer(offer)
    @offer = offer
    @listing = offer.surplus_listing
    @reservation = offer.surplus_reservation
    @enterprise = @listing.enterprise

    I18n.with_locale valid_locale(@offer.buyer) do
      subject = t('surplus_mailer.offer_accepted.subject',
                  enterprise: @enterprise.name,
                  product: @listing.variant&.name_to_display)

      mail(
        to: @offer.buyer.email,
        from: from_address,
        subject: subject
      )
    end
  end

  # Sent to buyer when their offer is rejected
  def offer_rejected_to_buyer(offer)
    @offer = offer
    @listing = offer.surplus_listing
    @enterprise = @listing.enterprise

    I18n.with_locale valid_locale(@offer.buyer) do
      subject = t('surplus_mailer.offer_rejected.subject',
                  enterprise: @enterprise.name,
                  product: @listing.variant&.name_to_display)

      mail(
        to: @offer.buyer.email,
        from: from_address,
        subject: subject
      )
    end
  end

  # Sent to seller when their listing expires
  def listing_expired_to_seller(listing)
    @listing = listing
    @enterprise = listing.enterprise

    I18n.with_locale valid_locale(@enterprise.owner) do
      subject = t('surplus_mailer.listing_expired.subject',
                  product: @listing.variant&.name_to_display)

      mail(
        to: @enterprise.contact&.email || @enterprise.owner&.email,
        from: from_address,
        subject: subject
      )
    end
  end

  # Sent to buyer when a listing they reserved expires
  def listing_expired_to_buyer(reservation)
    @reservation = reservation
    @listing = reservation.surplus_listing
    @enterprise = @listing.enterprise

    I18n.with_locale valid_locale(@reservation.buyer) do
      subject = t('surplus_mailer.listing_expired_buyer.subject',
                  enterprise: @enterprise.name,
                  product: @listing.variant&.name_to_display)

      mail(
        to: @reservation.buyer.email,
        from: from_address,
        subject: subject
      )
    end
  end

  # Sent to watchers when a matching listing is published
  def listing_matches_watch(watch, listing)
    @watch = watch
    @listing = listing
    @enterprise = listing.enterprise
    @buyer = watch.buyer

    I18n.with_locale valid_locale(@buyer) do
      subject = t('surplus_mailer.listing_matches_watch.subject',
                  product: @listing.variant&.name_to_display,
                  enterprise: @enterprise.name)

      mail(
        to: @buyer.email,
        from: from_address,
        subject: subject
      )
    end
  end

  private

  def format_quantity(quantity, unit)
    "#{number_with_precision(quantity, precision: 2)} #{unit}"
  end

  def number_with_precision(number, options = {})
    ActionController::Base.helpers.number_with_precision(number, options)
  end
end
