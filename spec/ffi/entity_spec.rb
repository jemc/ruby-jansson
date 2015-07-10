
require 'spec_helper'


describe Jansson::FFI::Entity do
  subject { Jansson::FFI::Entity }
  
  describe "from nil" do
    let(:ptr) { subject.ptr_from(nil) }
    
    specify { subject.ptr_type(ptr)   .should be Jansson::FFI::Entity::NULL }
    specify { subject.ptr_to_ruby(ptr).should eq nil }
    specify { subject.ptr_to_s(ptr)   .should eq "null" }
  end
  
  describe "from true" do
    let(:ptr) { subject.ptr_from(true) }
    
    specify { subject.ptr_type(ptr)   .should be Jansson::FFI::Entity::TRUE }
    specify { subject.ptr_to_ruby(ptr).should eq true }
    specify { subject.ptr_to_s(ptr)   .should eq "true" }
  end
  
  describe "from false" do
    let(:ptr) { subject.ptr_from(false) }
    
    specify { subject.ptr_type(ptr)   .should be Jansson::FFI::Entity::FALSE }
    specify { subject.ptr_to_ruby(ptr).should eq false }
    specify { subject.ptr_to_s(ptr)   .should eq "false" }
  end
  
  describe "from a positive Integer" do
    let(:ptr) { subject.ptr_from(88) }
    
    specify { subject.ptr_type(ptr)   .should be Jansson::FFI::Entity::INTEGER }
    specify { subject.ptr_to_ruby(ptr).should eq 88 }
    specify { subject.ptr_to_s(ptr)   .should eq "88" }
  end
  
  describe "from a negative Integer" do
    let(:ptr) { subject.ptr_from(-99) }
    
    specify { subject.ptr_type(ptr)   .should be Jansson::FFI::Entity::INTEGER }
    specify { subject.ptr_to_ruby(ptr).should eq -99 }
    specify { subject.ptr_to_s(ptr)   .should eq "-99" }
  end
  
  describe "from a Float" do
    let(:ptr) { subject.ptr_from(88.8) }
    
    specify { subject.ptr_type(ptr)     .should be Jansson::FFI::Entity::REAL }
    specify { subject.ptr_to_ruby(ptr)  .should be_within(0.1).of 88.8 }
    specify { subject.ptr_to_s(ptr).to_f.should be_within(0.1).of 88.8 }
  end
  
  describe "from a String" do
    let(:ptr) { subject.ptr_from('foo') }
    
    specify { subject.ptr_type(ptr)   .should be Jansson::FFI::Entity::STRING }
    specify { subject.ptr_to_ruby(ptr).should eq 'foo' }
    specify { subject.ptr_to_s(ptr)   .should eq '"foo"' }
  end
  
  describe "from a Symbol" do
    let(:ptr) { subject.ptr_from(:bar) }
    
    specify { subject.ptr_type(ptr)   .should be Jansson::FFI::Entity::STRING }
    specify { subject.ptr_to_ruby(ptr).should eq 'bar' }
    specify { subject.ptr_to_s(ptr)   .should eq '"bar"' }
  end
  
  describe "from an Array" do
    let(:ptr) { subject.ptr_from([1, 2, 3]) }
    
    specify { subject.ptr_type(ptr)   .should be Jansson::FFI::Entity::ARRAY }
    specify { subject.ptr_to_ruby(ptr).should eq [1, 2, 3] }
    specify { subject.ptr_to_s(ptr)   .should eq '[1, 2, 3]' }
  end
  
  describe "from a Hash with String keys" do
    let(:ptr) { subject.ptr_from({ 'foo'=>88, 'bar'=>99 }) }
    
    specify { subject.ptr_type(ptr)   .should be Jansson::FFI::Entity::OBJECT }
    specify { subject.ptr_to_ruby(ptr).should eq({ 'foo'=>88, 'bar'=>99 }) }
    specify { subject.ptr_to_s(ptr)   .should eq '{"foo": 88, "bar": 99}' }
  end
end
