require 'pry'
require 'database_cleaner'
require 'rspec/its'
require 'rspec/collection_matchers'
Dir.glob(File.join(__dir__, 'support/**/*.rb'), &method(:require))
Dir.glob(File.join(File.dirname(__FILE__), '../lib/**/*.rb'), &method(:require))

ENV['RACK_ENV'] = 'test'

class NullLogger < Logger
  def initialize(*args); end
  def add(*args, &block); end
end

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end

  config.before :each do
    Cottontail.configure do |c|
      c.url = ENV['AMQP_URL'] if ENV['AMQP_URL'].present?

      # comment this out for talky output
      c.logger = NullLogger.new
    end
  end

  config.after :each do
  end
end
