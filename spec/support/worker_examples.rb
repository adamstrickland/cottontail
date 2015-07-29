shared_examples_for "a good little worker" do
  let(:klass) { self.described_class }
  let(:instantiate!) { klass.new(options) }
  let(:key) { "foo" }
  let(:base_options) { { key: key } }
  let(:options) { base_options }
  let(:instance) { instantiate! }

  subject { instance }

  it { should respond_to :start! }

  describe 'when initialized' do
    subject { instantiate! }

    describe 'by default' do
      its(:consumer) { should be_kind_of Cottontail::Consumer }
      its(:name) { should match %r{cottontail\-worker} }
    end

    describe 'with a consumer' do
      let(:options) { base_options.merge(consumer: consumer) }
      let(:consumer) { double }
      its(:consumer) { should eq consumer }
    end

    describe 'without any keys' do
      let(:options) { {} }
      subject { nil }
      specify{ expect{ instantiate! }.to raise_error }
    end
  end

  describe 'when activated' do
    let(:options) { base_options.merge(consumer: consumer) }
    let(:consumer) { double(handle_message: nil) }

    let(:action!) { instance.start! }
    subject { action! }

    describe 'a queue is created' do
      let(:queue) { double(bind: double(subscribe:nil)) }
      before { expect(instance.channel).to receive(:queue).with(kind_of(String), kind_of(Hash)).and_return(queue) }
      it { should eq [key] }
    end

    describe 'and the consumer is bound to each key' do
      let(:bound_queue) { double }
      let(:queue) { double }
      before do
        allow(instance.channel).to receive(:queue).once.and_return(queue)
        expect(queue).to receive(:bind).with(instance.exchange, hash_including(routing_key: key)).and_return(bound_queue)
        expect(bound_queue).to receive(:subscribe)
      end
      it { should eq [key] }
    end

    describe 'the consumer is decorated with some hook methods' do
      subject { instance.consumer }
      let(:options) { base_options }

      before { action! }

      it { should respond_to :publish }
      it { should respond_to :notify }
    end
  end
end

