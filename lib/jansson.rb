
require_relative 'jansson/ffi'
require_relative 'jansson/ffi/ext'

module Jansson
  class DumpError < RuntimeError; end
  
  def self.dump(value)
    res = Jansson::FFI::Entity.ptr_from(value)
    raise Jansson::DumpError, "can't encode #{value}" unless res
    string = Jansson::FFI::Entity.ptr_to_s(res)
    Jansson::FFI::Entity.ptr_free!(res)
    string
  end
  
  class LoadError < RuntimeError; end
  
  def self.load(string)
    res = Jansson::FFI::Entity.ptr_from_s(string)
    case res
    when ::FFI::Pointer
      value = Jansson::FFI::Entity.ptr_to_ruby(res)
      Jansson::FFI::Entity.ptr_free!(res)
      value
    when Jansson::FFI::Error
      raise Jansson::LoadError, res.description(string)
    else
      raise Jansson::LoadError
    end
  end
  
end
