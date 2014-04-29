require 'spec_helper'

describe Cottontail::Consumer do
  let(:klass) { self.described_class } 
  let(:instance) { klass.new }
  
  subject { instance }

  it { should be_kind_of Cottontail::Consumable }
end
