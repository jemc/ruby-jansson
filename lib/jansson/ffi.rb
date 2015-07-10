
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
    
    INTEGER_IS_LONG_LONG = true
    typedef (INTEGER_IS_LONG_LONG ? :long_long : :long), :json_int
    
    ##
    # Construction, destruction, reference counting
    
    attach_function :json_object,          [],                 :pointer, **opts
    attach_function :json_array,           [],                 :pointer, **opts
    attach_function :json_string,          [:string],          :pointer, **opts
    attach_function :json_stringn,         [:string, :size_t], :pointer, **opts
    attach_function :json_string_nocheck,  [:string],          :pointer, **opts
    attach_function :json_stringn_nocheck, [:string, :size_t], :pointer, **opts
    attach_function :json_integer,         [:json_int],        :pointer, **opts
    attach_function :json_real,            [:double],          :pointer, **opts
    attach_function :json_true,            [],                 :pointer, **opts
    attach_function :json_false,           [],                 :pointer, **opts
    attach_function :json_null,            [],                 :pointer, **opts
    
    attach_function :json_delete, [:pointer], :void, **opts
    
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
    attach_function :json_object_size,            [:pointer],                       :size_t,    **opts
    attach_function :json_object_get,             [:pointer, :string],              :pointer, **opts
    attach_function :json_object_set_new,         [:pointer, :string, :pointer],  :int,       **opts
    attach_function :json_object_set_new_nocheck, [:pointer, :string, :pointer],  :int,       **opts
    attach_function :json_object_del,             [:pointer, :string],              :int,       **opts
    attach_function :json_object_clear,           [:pointer],                       :int,       **opts
    attach_function :json_object_update,          [:pointer, :pointer],           :int,       **opts
    attach_function :json_object_update_existing, [:pointer, :pointer],           :int,       **opts
    attach_function :json_object_update_missing,  [:pointer, :pointer],           :int,       **opts
    attach_function :json_object_iter,            [:pointer],                       :pointer,   **opts
    attach_function :json_object_iter_at,         [:pointer, :string],              :pointer,   **opts
    attach_function :json_object_key_to_iter,     [:string],                          :pointer,   **opts
    attach_function :json_object_iter_next,       [:pointer, :pointer],             :pointer,   **opts
    attach_function :json_object_iter_key,        [:pointer],                         :string,    **opts
    attach_function :json_object_iter_value,      [:pointer],                         :pointer, **opts
    attach_function :json_object_iter_set_new,    [:pointer, :pointer, :pointer], :int,       **opts
    
    attach_function :json_array_size,       [:pointer],                      :size_t,    **opts
    attach_function :json_array_get,        [:pointer, :size_t],             :pointer, **opts
    attach_function :json_array_set_new,    [:pointer, :size_t, :pointer], :int,       **opts
    attach_function :json_array_append_new, [:pointer, :pointer],          :int,       **opts
    attach_function :json_array_insert_new, [:pointer, :size_t, :pointer], :int,       **opts
    attach_function :json_array_remove,     [:pointer, :size_t],             :int,       **opts
    attach_function :json_array_clear,      [:pointer],                      :int,       **opts
    attach_function :json_array_extend,     [:pointer, :pointer],          :int,       **opts
    
    attach_function :json_string_value,  [:pointer], :pointer,  **opts
    attach_function :json_string_length, [:pointer], :size_t,   **opts
    attach_function :json_integer_value, [:pointer], :json_int, **opts
    attach_function :json_real_value,    [:pointer], :double,   **opts
    attach_function :json_number_value,  [:pointer], :double,   **opts
    
    attach_function :json_string_set,          [:pointer, :string],           :int, **opts
    attach_function :json_string_setn,         [:pointer, :pointer, :size_t], :int, **opts
    attach_function :json_string_set_nocheck,  [:pointer, :string],           :int, **opts
    attach_function :json_string_setn_nocheck, [:pointer, :pointer, :size_t], :int, **opts
    attach_function :json_integer_set,         [:pointer, :json_int],         :int, **opts
    attach_function :json_real_set,            [:pointer, :double],           :int, **opts
    
    ##
    # Pack, unpack
    
    PACK_VALIDATE_ONLY = 0x1
    PACK_STRICT        = 0x2
    
    attach_function :json_pack,     [:string, :varargs],                     :pointer, **opts
    attach_function :json_pack_ex,  [Error.ptr, :size_t, :string, :varargs], :pointer, **opts
    
    attach_function :json_unpack,    [:pointer, :string, :varargs],                     :int, **opts
    attach_function :json_unpack_ex, [:pointer, Error.ptr, :size_t, :string, :varargs], :int, **opts
    
    ##
    # Equality
    
    attach_function :json_equal, [:pointer, :pointer], :int
    
    ##
    # Copying
    
    attach_function :json_copy,      [:pointer], :pointer
    attach_function :json_deep_copy, [:pointer], :pointer
    
    ##
    # Decoding
    
    LOAD_REJECT_DUPLICATES  = 0x1
    LOAD_DISABLE_EOF_CHECK  = 0x2
    LOAD_DECODE_ANY         = 0x4
    LOAD_DECODE_INT_AS_REAL = 0x8
    LOAD_ALLOW_NUL          = 0x10
    
    attach_function :json_loads, [:string, :size_t, Error.ptr], :pointer
    
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
    
    attach_function :json_dumps, [:pointer, :size_t], :pointer
    
  end
end
