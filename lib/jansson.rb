
require_relative 'jansson/ffi'
require_relative 'jansson/ffi/ext'

module Jansson
  class DumpError < RuntimeError; end
  
  def self.dump(value)
    res = Jansson::FFI::Entity.from(value)
    raise Jansson::DumpError, "can't encode #{value}" unless res
    string = res.to_s
    res.free!
    string
  end
  
  class LoadError < RuntimeError; end
  
  def self.load(string)
    res = Jansson::FFI::Entity.from_s(string)
    case res
    when Jansson::FFI::Entity
      value = res.to_ruby
      res.free!
      value
    when Jansson::FFI::Error
      raise Jansson::LoadError, res.description(string)
    else
      raise Jansson::LoadError
    end
  end
  
end
