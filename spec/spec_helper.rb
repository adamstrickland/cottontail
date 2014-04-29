require 'pry'
require 'database_cleaner'
Dir.glob(File.join(__dir__, 'support/**/*.rb'), &method(:require))
Dir.glob(File.join(File.dirname(__FILE__), '../lib/**/*.rb'), &method(:require))

ENV['RACK_ENV'] = 'test'

RSpec.configure do |config|
  # config.include RSpecMixin

  config.before :each do
    # DatabaseCleaner.strategy = :truncation
  end

  config.after :each do
    # DatabaseCleaner.clean
  end
end
