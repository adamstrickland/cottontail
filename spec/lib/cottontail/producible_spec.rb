require 'spec_helper'

describe Cottontail::Producible do
  include_context "module"

  describe :instance do
    subject { instance }
    it { should be_kind_of Cottontail::Leporine }
  end
end
