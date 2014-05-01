require 'spec_helper'

describe Cottontail::Leporine do
  include_context "module"

  describe :instance do
    subject { instance }

    it { should respond_to :handle_channel_exception }
    it { should respond_to :publish }
    it { should respond_to :_create_channel }
    it { should respond_to :_create_connection }

    describe 'when initializing' do
      let(:action!) { klass.new(options) }
      subject { action! }

      context 'with no options' do
        let(:options) { {} }
        its(:connection) { should be_a Bunny::Session }
        its(:channel) { should be_a Bunny::Channel }
        its(:exchange) { should be_a Bunny::Exchange }

        context 'and the exchange' do
          subject { action!.exchange }
          its(:name) { should eq Cottontail::DEFAULT_TOPIC }
          its(:type) { should eq :topic }
        end
      end

      context 'with an established connection' do
        let(:options) { {connection: double(create_channel: double(on_error: nil, topic: double))} }
        it { should_not be_nil }
      end
    end

    describe 'when publishing' do
      let(:options)  { {connection: session, channel: channel} }
      let(:session)  { double }
      let(:channel)  { double(on_error: nil, topic: exchange) }
      let(:exchange) { double }

      let(:message)  { {} }
      let(:key)      { "foo" }

      subject { klass.new(options).publish(message, key) }

      before { exchange.should_receive(:publish).with(kind_of(String), hash_including(persistent: true, routing_key: key)).and_return(true) }

      it { should be_true }
    end
  end
end
