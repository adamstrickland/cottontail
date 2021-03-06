require 'spec_helper'

describe Cottontail do
  let(:klass) { self.described_class }

  it { should respond_to :configure }
  it { should respond_to :configuration }
  it { should respond_to :publish }

  describe 'when calling publish standalone' do
    let(:payload) { {} }
    let(:key)     { "foo" }

    subject { klass.publish(payload, key) }

    before do
      producer = double
      expect(Cottontail::Producer).to receive(:new).and_return(producer)
      expect(producer).to receive(:publish).with(payload, key, kind_of(Hash)).and_return(true)
    end

    it { should be_truthy }
  end

  describe 'creates a worker using ::subscribe' do
    let(:key) { "foo.bar" }

    before do
      worker = double
      expect(::Cottontail::Worker).to receive(:new).with(hash_including(key: key, consumer: kind_of(::Cottontail::Consumer))){ worker }
      expect(worker).to receive(:start!){ true }
    end

    context 'when the supplied handler is a class' do
      class TestConsumer < ::Cottontail::Consumer
        def handle_message(di, m, p); end
      end

      it "should start the worker" do
        expect( klass.subscribe(key, TestConsumer) ).to be_truthy
      end
    end

    context 'when the supplied handler is a block' do
      it "should start the worker" do
        expect( klass.subscribe(key) { |_,_,_| nil } ).to be_truthy
      end
    end
  end

  describe 'creates a handler using ::consumer' do
    subject { klass.handlerify{ |_,_,_| nil } }
    it { expect(subject).to be_a Class }
    it { expect(subject.new).to respond_to :handle_message } # defined in method
    it { expect(subject.new).to respond_to :handle_payload } # from Consumable
  end
end

describe Cottontail::Configuration do
  let(:klass) { self.described_class }
  let(:instance) { klass.new }

  subject { instance }

  it { should respond_to :user }
  it { should respond_to :user= }
  it { should respond_to :password }
  it { should respond_to :password= }
  it { should respond_to :host }
  it { should respond_to :host= }
  it { should respond_to :port }
  it { should respond_to :port= }
  it { should respond_to :vhost }
  it { should respond_to :vhost= }
  it { should respond_to :scheme }
  it { should respond_to :topic }
  it { should respond_to :topic= }
  it { should respond_to :url }
  it { should respond_to :url= }

  describe "by default" do
    its(:user) { should eq "guest" }
    its(:password) { should eq "guest" }
    its(:host) { should eq "localhost" }
    its(:port) { should eq 5672 }
    its(:vhost) { should eq "%2f" }
    its(:scheme) { should eq "amqp" }
    its(:url) { should eq "amqp://guest:guest@localhost:5672/%2f" }
    its(:topic) { should eq Cottontail::DEFAULT_TOPIC }
  end

  describe 'when setting the url' do
    before { instance.url = url }

    shared_examples_for "parsed host, port and scheme" do
      its(:host) { should eq "rabbitmq.molecule.io" }
      its(:port) { should eq 5672 }
      its(:scheme) { should eq "amqp" }
    end

    context 'without a username and password' do
      let(:url) { "amqp://rabbitmq.molecule.io" }
      its(:user) { should eq "guest" }
      its(:password) { should eq "guest" }
    end

    context 'with a username and password' do
      let(:url) { "amqp://peter:flopsymopsy@rabbitmq.molecule.io/burrow" }
      its(:user) { should eq "peter" }
      its(:password) { should eq "flopsymopsy" }
    end

    context 'without a virtual host' do
      let(:url) { "amqp://peter:flopsymopsy@rabbitmq.molecule.io" }
      its(:vhost) { should eq "%2f" }
    end

    context 'with a virtual host' do
      let(:url) { "amqp://peter:flopsymopsy@rabbitmq.molecule.io/burrow" }
      its(:vhost) { should eq "burrow" }
    end

    context 'with a virtual host with an embedded, encoded slash' do
      let(:url) { "amqp://peter:flopsymopsy@rabbitmq.molecule.io/%2fburrow" }
      its(:vhost) { should eq "%2fburrow" }
    end
  end
end
