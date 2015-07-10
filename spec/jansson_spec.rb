
require 'spec_helper'


describe Jansson do
  subject { Jansson }
  
  describe "dump" do
    it "encodes an array" do
      subject.dump([1, 2, 3]).should eq '[1, 2, 3]'
    end
    
    it "encodes an object" do
      subject.dump({'foo'=>88, 'bar'=>99}).should eq '{"foo": 88, "bar": 99}'
    end
    
    it "raises a Jansson::DumpError when given bad input" do
      input = Object.new
      expect { subject.dump(input) }.to raise_error Jansson::DumpError,
        /can't encode #<Object/
    end
  end
  
  describe "load" do
    it "decodes an array" do
      subject.load('[1, 2, 3]').should eq [1, 2, 3]
    end
    
    it "decodes an object" do
      subject.load('{"foo": 88, "bar": 99}').should eq({'foo'=>88, 'bar'=>99})
    end
    
    it "raises a Jansson::LoadError when given bad input" do
      input = "[\n[{[{,{]{}\n]"
      expect { subject.load(input) }.to raise_error Jansson::LoadError,
        "near line: 2, column: 3: \n"\
        "[{[{,{]{}\n"\
        "  ^"
    end
    
    it "truncates the shown Jansson::LoadError line when given a lot of data" do
      input = "[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,"\
              "!,"\
              "21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40]"
      expect { subject.load(input) }.to raise_error Jansson::LoadError,
        "near line: 1, column: 53: \n"\
        "... ,15,16,17,18,19,20,!,21,22,23,24,25,26,2 ...\n"\
        "                       ^"
    end
  end
end
