require 'spec_helper'

describe Cottontail::Consumable do
  include_context "module"

  describe :instance do
    subject { instance }

    it { should respond_to :handle_message }
    it { should respond_to :notify }
  end
end
