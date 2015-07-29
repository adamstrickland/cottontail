require 'spec_helper'

describe Cottontail::Model do
  include_context "module"

  matcher :be_numeric do
    match do |actual|
      actual.to_s =~ /\d+(?:\.\d+)?/
    end
  end

  class Foo; end
  let(:klass) { Foo }

  subject { instance }

  it { should respond_to :notify_created }
  it { should respond_to :notify_updated }
  it { should respond_to :notify_destroyed }
  it { should respond_to :identifier }
  it { should respond_to :key_base }
  it { should respond_to :notify_event }

  describe 'by default' do
    it { instance.identifier.should be_numeric }
    it { instance.key_base.should eq "foo" }
  end

  describe 'when notifying' do
    subject { instance.notify_event(event) }

    let(:event) { "created" }

    before do
      expect(Cottontail).to receive(:publish).with(hash_including(identifier: instance.identifier), %r{#{event}}).and_return(true)
    end

    it { should be_truthy }
  end

  describe "macros" do
    subject { klass }
    it { should respond_to :notify_on_all }
    it { should respond_to :notify_on}
    it { should respond_to :notify_using }
  end

  describe "using the macros" do
    class Foo
      include Cottontail::Model

      class << self
        def after_create(cb); end
        def after_update(cb); end
        def after_destroy(cb); end
      end
    end

    before do
      klass.should respond_to :after_create
      klass.should respond_to :after_update
      klass.should respond_to :after_destroy
    end

    describe 'notify_on_all activates all of the callbacks' do
      subject { klass.notify_on_all }
      before do
        expect(klass).to receive(:after_create).with(:notify_created)
        expect(klass).to receive(:after_update).with(:notify_updated)
        expect(klass).to receive(:after_destroy).with(:notify_destroyed)
      end
      it { should be_a Hash }
    end

    describe 'notify_on activates callbacks for the supplied events' do
      subject { klass.notify_on :when_complete, :after_sleep }
      before do
        expect(klass).to receive(:when_complete).with(:notify_when_completed)
        expect(klass).to receive(:after_sleep).with(:notify_slept)
      end
      it { should be_a Hash }
    end

    describe 'notify_using activates a custom callback' do
      subject { klass.notify_using(map) }
      let(:map) { { ask_yourself: :is_this_my_beautiful_life } }
      before do
        expect(klass).to receive(:ask_yourself).with(:is_this_my_beautiful_life)
      end
      it { should be_a Hash }
    end
  end
end
