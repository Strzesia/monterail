# frozen_string_literal: true

RSpec.describe 'Events', type: :request do
  shared_examples 'event not found' do
    it 'should render error' do
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(response).to have_http_status(:not_found)
      expect(response_json).to eq({ error: "Couldn't find Event with 'id'=incorrect" })
    end
  end

  before do
    create_list(:event, 5, :with_ticket)
  end

  describe 'GET events#index' do
    it 'should render all events' do
      get '/events'
      expect(response.content_type).to eq('application/json; charset=utf-8')
      expect(response).to have_http_status(:ok)
      expect(response_json[:events].size).to eq(5)
    end
  end

  describe 'GET events#show' do
    context 'event exists' do
      let(:event) { Event.first }

      it 'should render event' do
        get "/events/#{event.id}"
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response).to have_http_status(:ok)
        expect(response_json.size).to eq(1)
        expect(response_json).to include(
          event: hash_including(
            id: event.id,
            name: event.name,
            formatted_time: event.formatted_time
          )
        )
      end
    end

    context 'event does not exist' do
      before { get '/events/incorrect' }
      it_behaves_like 'event not found'
    end
  end

  describe 'GET events#tickets' do
    context 'event exists' do
      let(:event) { Event.first }
      let(:ticket) { event.ticket }

      it 'should render event' do
        get "/events/#{event.id}/tickets"
        expect(response.content_type).to eq('application/json; charset=utf-8')
        expect(response).to have_http_status(:ok)
        expect(response_json.size).to eq(1)
        expect(response_json).to include(
          tickets: hash_including(
            available: ticket.available,
            price: ticket.price.to_s,
            event: hash_including(
              id: event.id,
              name: event.name,
              formatted_time: event.formatted_time
            )
          )
        )
      end
    end

    context 'event does not exist' do
      before { get '/events/incorrect/tickets' }
      it_behaves_like 'event not found'
    end
  end

  describe 'POST events#buy_ticket' do
    let(:valid_params) { { token: 'token', tickets_count: '1' } }

    context 'event exists' do
      let(:event) { Event.first }
      let(:ticket) { event.ticket }
      let(:card_error) { { token: 'card_error', tickets_count: '1' } }
      let(:payment_error) { { token: 'payment_error', tickets_count: '1' } }
      let(:not_enough_tickets) { { token: 'token', tickets_count: ticket.available + 1 } }

      context 'valid params' do
        it 'should render success message' do
          post "/events/#{event.id}/buy_ticket", params: valid_params
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(response).to have_http_status(:ok)
          expect(response_json).to eq({ success: 'Payment succeeded.' })
        end
      end

      context 'card error' do
        it 'should render success message' do
          post "/events/#{event.id}/buy_ticket", params: card_error
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(response).to have_http_status(402)
          expect(response_json).to eq({ error: 'Your card has been declined.' })
        end
      end

      context 'payment error' do
        it 'should render success message' do
          post "/events/#{event.id}/buy_ticket", params: payment_error
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(response).to have_http_status(402)
          expect(response_json).to eq({ error: 'Something went wrong with your transaction.' })
        end
      end

      context 'not enough tickets left' do
        it 'should render success message' do
          post "/events/#{event.id}/buy_ticket", params: not_enough_tickets
          expect(response.content_type).to eq('application/json; charset=utf-8')
          expect(response).to have_http_status(404)
          expect(response_json).to eq({ error: 'Not enough tickets left.' })
        end
      end
    end

    context 'event does not exist' do
      before { post '/events/incorrect/buy_ticket', params: valid_params }
      it_behaves_like 'event not found'
    end
  end
end

def response_json
  JSON.parse(response.body).deep_symbolize_keys
end
