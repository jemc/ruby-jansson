
module Jansson
  module FFI
    class Entity
      
      EntityType.symbol_map.each do |name, number|
        const_set(name.upcase, number)
      end
      
      def self.ptr_free!(ptr)
        FFI.json_delete(ptr) if 0 >= (ptr_set_refcount(ptr, ptr_refcount(ptr) - 1))
      end
      
      def self.ptr_to_s(ptr, flags = DUMP_ENCODE_ANY | DUMP_PRESERVE_ORDER)
        str_ptr = FFI.json_dumps(ptr, flags)
        string  = str_ptr.read_string
        FFI.free(str_ptr)
        string
      end
      
      def self.ptr_from_s(string, flags = LOAD_DECODE_ANY | LOAD_ALLOW_NUL)
        error = FFI::Error.new
        ptr   = FFI.json_loads(string, flags, error)
        ptr.null? ? error : ptr
      end
      
      class Struct < ::FFI::Struct
        layout :type,     EntityType,
               :refcount, :size_t
      end
      
      member_info = {
        type: {
          native_type: Jansson::FFI::EntityType.native_type.inspect[/(?<=Builtin:)\w+/].downcase,
          offset:      Struct.layout.offset_of(:type),
        },
        refcount: {
          native_type: ::FFI::TypeDefs[:size_t].inspect[/(?<=Builtin:)\w+/].downcase,
          offset:      Struct.layout.offset_of(:refcount),
        },
      }
      
      member_info.keys.each do |member|
        eval <<-RUBY
          def self.ptr_#{member}(ptr)
            (ptr + #{member_info[member][:offset]}).read_#{member_info[member][:native_type]}
          end
          
          def self.ptr_set_#{member}(ptr, value)
            (ptr + #{member_info[member][:offset]}).write_#{member_info[member][:native_type]}(value)
            value
          end
        RUBY
      end
      
      def self.ptr_to_ruby(ptr)
        case ptr_type(ptr)
        when NULL
          nil
        when TRUE
          true
        when FALSE
          false
        when INTEGER
          FFI.json_integer_value(ptr)
        when REAL
          FFI.json_real_value(ptr)
        when STRING
          FFI.json_string_value(ptr).read_string(FFI.json_string_length(ptr))
        when ARRAY
          FFI.json_array_size(ptr).times.map do |index|
            ptr_to_ruby(FFI.json_array_get(ptr, index))
          end
        when OBJECT
          object = {}
          iter = FFI.json_object_iter(ptr)
          while (key = FFI.json_object_iter_key(iter)) && \
              (value = FFI.json_object_iter_value(iter))
            object[key] = ptr_to_ruby(value)
            iter = FFI.json_object_iter_next(ptr, iter)
          end
          object
        else raise NotImplementedError
        end
      end
      
      def self.ptr_from(value)
        case value
        when NilClass
          FFI.json_null
        when TrueClass
          FFI.json_true
        when FalseClass
          FFI.json_false
        when Integer
          FFI.json_integer(value)
        when Float
          FFI.json_real(value)
        when String
          value = value.force_encoding(Encoding::UTF_8)
          FFI.json_stringn_nocheck(value, value.bytesize)
        when Symbol
          value = value.to_s.force_encoding(Encoding::UTF_8)
          FFI.json_stringn_nocheck(value, value.bytesize)
        when Array
          array = FFI.json_array
          value.each do |item|
            FFI.json_array_append_new(array, ptr_from(item))
          end
          array
        when Hash
          object = FFI.json_object
          value.each do |key, value|
            FFI.json_object_set_new(object, key.to_s, ptr_from(value))
          end
          object
        end
      end
      
    end
  end
end
