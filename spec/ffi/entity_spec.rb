
require 'spec_helper'


describe Jansson::FFI::Entity do
  let(:subject_class) { Jansson::FFI::Entity }
  
  describe "from nil" do
    subject { subject_class.from(nil) }
    
    its(:type)    { should be :null }
    its(:to_ruby) { should eq nil }
    its(:to_s)    { should eq "null" }
  end
  
  describe "from true" do
    subject { subject_class.from(true) }
    
    its(:type)    { should be :true }
    its(:to_ruby) { should eq true }
    its(:to_s)    { should eq "true" }
  end
  
  describe "from false" do
    subject { subject_class.from(false) }
    
    its(:type)    { should be :false }
    its(:to_ruby) { should eq false }
    its(:to_s)    { should eq "false" }
  end
  
  describe "from a positive Integer" do
    subject { subject_class.from(88) }
    
    its(:type)    { should be :integer }
    its(:to_ruby) { should eq 88 }
    its(:to_s)    { should eq "88" }
  end
  
  describe "from a negative Integer" do
    subject { subject_class.from(-99) }
    
    its(:type)    { should be :integer }
    its(:to_ruby) { should eq -99 }
    its(:to_s)    { should eq "-99" }
  end
  
  describe "from a Float" do
    subject { subject_class.from(88.8) }
    
    its(:type)        { should be :real }
    its(:to_ruby)     { should be_within(0.1).of 88.8 }
    its(:"to_s.to_f") { should be_within(0.1).of 88.8 }
  end
  
  describe "from a String" do
    subject { subject_class.from('foo') }
    
    its(:type)    { should be :string }
    its(:to_ruby) { should eq 'foo' }
    its(:to_s)    { should eq '"foo"' }
  end
  
  describe "from a Symbol" do
    subject { subject_class.from(:bar) }
    
    its(:type)    { should be :string }
    its(:to_ruby) { should eq 'bar' }
    its(:to_s)    { should eq '"bar"' }
  end
  
  describe "from an Array" do
    subject { subject_class.from([1, 2, 3]) }
    
    its(:type)    { should be :array }
    its(:to_ruby) { should eq [1, 2, 3] }
    its(:to_s)    { should eq '[1, 2, 3]' }
  end
  
  describe "from a Hash with String keys" do
    subject { subject_class.from({ 'foo'=>88, 'bar'=>99 }) }
    
    its(:type)    { should be :object }
    its(:to_ruby) { should eq({ 'foo'=>88, 'bar'=>99 }) }
    its(:to_s)    { should eq '{"foo": 88, "bar": 99}' }
  end
end
