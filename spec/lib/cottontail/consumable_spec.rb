require 'spec_helper'

describe Cottontail::Consumable do
  include_context "module"

  subject { instance }

  it { should respond_to :handle_message }
  it { should respond_to :handle_payload }


  describe '#handle_message' do
    let(:payload) { double }

    before { expect(instance).to receive(:handle_payload).with(payload) { nil } }

    subject { instance.handle_message(double, double, payload) }

    it { should be_nil }
  end
end
