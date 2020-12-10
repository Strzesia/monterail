# frozen_string_literal: true

class EventsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, TicketPayment::NotEnoughTicketsError, with: :not_found_error
  rescue_from Adapters::Payment::Gateway::CardError, Adapters::Payment::Gateway::PaymentError,
              with: :payment_failed_error

  before_action :set_event, except: :index
  before_action :set_ticket, only: %i[tickets buy_ticket]

  def index
    @events = Event.all
  end

  def show
    render :show
  end

  def tickets
    render :tickets
  end

  def buy_ticket
    payment_token = params[:token]
    tickets_count = params[:tickets_count].to_i
    TicketPayment.call(@ticket, payment_token, tickets_count)
    render json: { success: 'Payment succeeded.' }
  end

  private

  def set_event
    @event = Event.find(params[:id])
  end

  def set_ticket
    @ticket = @event.ticket
  end

  def not_found_error(error)
    render json: { error: error.message }, status: :not_found
  end

  def payment_failed_error(error)
    render json: { error: error.message }, status: :payment_required
  end
end
