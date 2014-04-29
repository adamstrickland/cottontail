require 'active_support/inflector'

shared_context "module" do
  let(:mixin)    { self.described_class }
  let(:instance) { klass.new }
  let(:klass)    { Class.new(Object) do; end }

  before { klass.send(:include, mixin) }
end

