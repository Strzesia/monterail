# frozen_string_literal: true

RSpec.describe TicketPayment do
  describe '.call' do
    let(:ticket) { create(:ticket) }

    context 'when tickets are available' do
      subject { TicketPayment.call(ticket, 'token', 1) }
      it 'should call payment adapter' do
        expect(Adapters::Payment::Gateway).to receive(:charge)
        subject
      end

      it 'should update available tickets count' do
        expect { subject }.to change(ticket, :available).by(-1)
      end
    end

    context 'when tickets are not available' do
      subject { TicketPayment.call(ticket, 'token', ticket.available + 1) }

      it 'should raise error' do
        expect { subject }.to raise_error(TicketPayment::NotEnoughTicketsError)
      end
    end
  end
end
