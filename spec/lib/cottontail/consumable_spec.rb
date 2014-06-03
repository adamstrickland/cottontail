require 'spec_helper'

describe Cottontail::Consumable do
  include_context "module"

  subject { instance }

  it { should respond_to :handle_message }
  # it { should respond_to :notify }
end
