require 'pry'
require 'database_cleaner'
Dir.glob(File.join(__dir__, 'support/**/*.rb'), &method(:require))
Dir.glob(File.join(File.dirname(__FILE__), '../lib/**/*.rb'), &method(:require))

ENV['RACK_ENV'] = 'test'

class NullLogger < Logger
  def initialize(*args); end
  def add(*args, &block); end
end

RSpec.configure do |config|
  config.before :each do
    # comment this out for talky output
    Cottontail.configuration.logger = NullLogger.new
  end

  config.after :each do
  end
end
