require 'spec_helper'

describe "Inter-Worker Communications" do
  BASE_TOPIC_KEY = "inter.woker.communication"
  FIRST_QUEUE = "#{BASE_TOPIC_KEY}.first"
  SECOND_QUEUE = "#{BASE_TOPIC_KEY}.second"

  module TestResult
    def self.inc!
      @_count.reset! if @_count.nil?
      @_count += 1
    end

    def self.value
      @_count ||= 0
    end
    
    def self.reset!
      @_count = 0
    end
  end

  let(:first_handler) do
    Class.new(::Cottontail::Consumer) do
      def handle_message(delivery_info, metadata, payload)
        notify({}, SECOND_QUEUE, { persistent: false })
      end
    end
  end
  let(:second_handler) do
    Class.new(::Cottontail::Consumer) do
      def handle_message(delivery_info, metadata, payload)
        TestResult.inc!
      end
    end
  end
  let(:queue_options) { { queue_options: { auto_delete: true, durable: false } } }

  before do
    TestResult.reset!
    Cottontail.configure do |c|
      c.verbose = true
    end
    Cottontail.subscribe(FIRST_QUEUE, first_handler, queue_options)
    Cottontail.subscribe(SECOND_QUEUE, second_handler, queue_options)
  end

  it "publishes messages across workers" do
    expect do 
      ::Cottontail.publish({}, FIRST_QUEUE, { persistent: false }) 
      sleep(1)
    end.to change{ TestResult.value }.from(0).to(1)
  end
end
