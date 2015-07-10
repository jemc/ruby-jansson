
module Jansson
  module FFI
    class Entity
      
      def free!
        FFI.json_delete(self) if 0 >= (self[:refcount] -= 1)
      end
      
      def to_s(flags = DUMP_ENCODE_ANY | DUMP_PRESERVE_ORDER)
        ptr = FFI.json_dumps(self, flags)
        str = ptr.read_string
        FFI.free(ptr)
        str
      end
      
      def self.from_s(string, flags = LOAD_DECODE_ANY | LOAD_ALLOW_NUL)
        error  = FFI::Error.new
        entity = FFI.json_loads(string, flags, error)
        entity.pointer.null? ? error : entity
      end
      
      def type
        self[:type]
      end
      
      def to_ruby
        case type
        when :null
          nil
        when :true
          true
        when :false
          false
        when :integer
          FFI.json_integer_value(self)
        when :real
          FFI.json_real_value(self)
        when :string
          FFI.json_string_value(self).read_string(FFI.json_string_length(self))
        when :array
          FFI.json_array_size(self).times.map do |index|
            FFI.json_array_get(self, index).to_ruby
          end
        when :object
          object = {}
          iter = FFI.json_object_iter(self)
          while (key = FFI.json_object_iter_key(iter)) && \
              (value = FFI.json_object_iter_value(iter))
            object[key] = value.to_ruby
            iter = FFI.json_object_iter_next(self, iter)
          end
          object
        else raise NotImplementedError
        end
      end
      
      def self.from(value)
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
            FFI.json_array_append_new(array, from(item))
          end
          array
        when Hash
          object = FFI.json_object
          value.each do |key, value|
            FFI.json_object_set_new(object, key.to_s, from(value))
          end
          object
        end
      end
      
    end
  end
end
