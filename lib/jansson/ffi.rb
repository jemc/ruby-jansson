
require 'ffi'


module Jansson
  
  # Bindings and wrappers for the native functions and structures exposed by
  # the libjansson C library. This module is for internal use only so that
  # all dependencies on the implementation of the C library are abstracted.
  # @api private
  module FFI
    extend ::FFI::Library
    
    libfile = "libjansson.#{::FFI::Platform::LIBSUFFIX}"
    
    ffi_lib ::FFI::Library::LIBC
    ffi_lib \
      File.expand_path("../../ext/jansson/#{libfile}", File.dirname(__FILE__))
    
    opts = {
      blocking: true  # only necessary on MRI to deal with the GIL.
    }
    
    attach_function :free,   [:pointer], :void,    **opts
    attach_function :malloc, [:size_t],  :pointer, **opts
    
    EntityType = enum [
      :object,
      :array,
      :string,
      :integer,
      :real,
      :true,
      :false,
      :null,
    ]
    
    class Entity < ::FFI::Struct
      layout :type,     EntityType,
             :refcount, :size_t
    end
    
    INTEGER_IS_LONG_LONG = true
    typedef (INTEGER_IS_LONG_LONG ? :long_long : :long), :json_int
    
    ##
    # Construction, destruction, reference counting
    
    attach_function :json_object,          [],                 Entity.ptr, **opts
    attach_function :json_array,           [],                 Entity.ptr, **opts
    attach_function :json_string,          [:string],          Entity.ptr, **opts
    attach_function :json_stringn,         [:string, :size_t], Entity.ptr, **opts
    attach_function :json_string_nocheck,  [:string],          Entity.ptr, **opts
    attach_function :json_stringn_nocheck, [:string, :size_t], Entity.ptr, **opts
    attach_function :json_integer,         [:json_int],        Entity.ptr, **opts
    attach_function :json_real,            [:double],          Entity.ptr, **opts
    attach_function :json_true,            [],                 Entity.ptr, **opts
    attach_function :json_false,           [],                 Entity.ptr, **opts
    attach_function :json_null,            [],                 Entity.ptr, **opts
    
    attach_function :json_delete, [Entity.ptr], :void, **opts
    
    ##
    # Error reporting
    
    ERROR_SOURCE_LENGTH = 160
    ERROR_TEXT_LENGTH   =  80
    
    class Error < ::FFI::Struct
      layout :line,     :int,
             :column,   :int,
             :position, :int,
             :source,  [:char, ERROR_SOURCE_LENGTH],
             :text,    [:char, ERROR_TEXT_LENGTH]
    end
    
    ##
    # Getters, setters, manipulation
    
    attach_function :json_object_seed,            [:size_t],                          :void,      **opts
    attach_function :json_object_size,            [Entity.ptr],                       :size_t,    **opts
    attach_function :json_object_get,             [Entity.ptr, :string],              Entity.ptr, **opts
    attach_function :json_object_set_new,         [Entity.ptr, :string, Entity.ptr],  :int,       **opts
    attach_function :json_object_set_new_nocheck, [Entity.ptr, :string, Entity.ptr],  :int,       **opts
    attach_function :json_object_del,             [Entity.ptr, :string],              :int,       **opts
    attach_function :json_object_clear,           [Entity.ptr],                       :int,       **opts
    attach_function :json_object_update,          [Entity.ptr, Entity.ptr],           :int,       **opts
    attach_function :json_object_update_existing, [Entity.ptr, Entity.ptr],           :int,       **opts
    attach_function :json_object_update_missing,  [Entity.ptr, Entity.ptr],           :int,       **opts
    attach_function :json_object_iter,            [Entity.ptr],                       :pointer,   **opts
    attach_function :json_object_iter_at,         [Entity.ptr, :string],              :pointer,   **opts
    attach_function :json_object_key_to_iter,     [:string],                          :pointer,   **opts
    attach_function :json_object_iter_next,       [Entity.ptr, :pointer],             :pointer,   **opts
    attach_function :json_object_iter_key,        [:pointer],                         :string,    **opts
    attach_function :json_object_iter_value,      [:pointer],                         Entity.ptr, **opts
    attach_function :json_object_iter_set_new,    [Entity.ptr, :pointer, Entity.ptr], :int,       **opts
    
    attach_function :json_array_size,       [Entity.ptr],                      :size_t,    **opts
    attach_function :json_array_get,        [Entity.ptr, :size_t],             Entity.ptr, **opts
    attach_function :json_array_set_new,    [Entity.ptr, :size_t, Entity.ptr], :int,       **opts
    attach_function :json_array_append_new, [Entity.ptr, Entity.ptr],          :int,       **opts
    attach_function :json_array_insert_new, [Entity.ptr, :size_t, Entity.ptr], :int,       **opts
    attach_function :json_array_remove,     [Entity.ptr, :size_t],             :int,       **opts
    attach_function :json_array_clear,      [Entity.ptr],                      :int,       **opts
    attach_function :json_array_extend,     [Entity.ptr, Entity.ptr],          :int,       **opts
    
    attach_function :json_string_value,  [Entity.ptr], :pointer,  **opts
    attach_function :json_string_length, [Entity.ptr], :size_t,   **opts
    attach_function :json_integer_value, [Entity.ptr], :json_int, **opts
    attach_function :json_real_value,    [Entity.ptr], :double,   **opts
    attach_function :json_number_value,  [Entity.ptr], :double,   **opts
    
    attach_function :json_string_set,          [Entity.ptr, :string],           :int, **opts
    attach_function :json_string_setn,         [Entity.ptr, :pointer, :size_t], :int, **opts
    attach_function :json_string_set_nocheck,  [Entity.ptr, :string],           :int, **opts
    attach_function :json_string_setn_nocheck, [Entity.ptr, :pointer, :size_t], :int, **opts
    attach_function :json_integer_set,         [Entity.ptr, :json_int],         :int, **opts
    attach_function :json_real_set,            [Entity.ptr, :double],           :int, **opts
    
    ##
    # Pack, unpack
    
    PACK_VALIDATE_ONLY = 0x1
    PACK_STRICT        = 0x2
    
    attach_function :json_pack,     [:string, :varargs],                     Entity.ptr, **opts
    attach_function :json_pack_ex,  [Error.ptr, :size_t, :string, :varargs], Entity.ptr, **opts
    
    attach_function :json_unpack,    [Entity.ptr, :string, :varargs],                     :int, **opts
    attach_function :json_unpack_ex, [Entity.ptr, Error.ptr, :size_t, :string, :varargs], :int, **opts
    
    ##
    # Equality
    
    attach_function :json_equal, [Entity.ptr, Entity.ptr], :int
    
    ##
    # Copying
    
    attach_function :json_copy,      [Entity.ptr], Entity.ptr
    attach_function :json_deep_copy, [Entity.ptr], Entity.ptr
    
    ##
    # Decoding
    
    LOAD_REJECT_DUPLICATES  = 0x1
    LOAD_DISABLE_EOF_CHECK  = 0x2
    LOAD_DECODE_ANY         = 0x4
    LOAD_DECODE_INT_AS_REAL = 0x8
    LOAD_ALLOW_NUL          = 0x10
    
    attach_function :json_loads, [:string, :size_t, Error.ptr], Entity.ptr
    
    ##
    # Encoding
    
    def self.DUMP_INDENT(n)          n & 0x1F end
    DUMP_COMPACT                       = 0x20
    DUMP_ENSURE_ASCII                  = 0x40
    DUMP_SORT_KEYS                     = 0x80
    DUMP_PRESERVE_ORDER                = 0x100
    DUMP_ENCODE_ANY                    = 0x200
    DUMP_ESCAPE_SLASH                  = 0x400
    def self.DUMP_REAL_PRECISION(n) (n & 0x1F) << 11 end
    
    attach_function :json_dumps, [Entity.ptr, :size_t], :pointer
    
  end
end
