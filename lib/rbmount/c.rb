#--
# Copyleft shura. [ shura1991@gmail.com ]
#
# This file is part of rbmount.
#
# rbmount is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# rbmount is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with rbmount. If not, see <http://www.gnu.org/licenses/>.
#++

require 'ffi'

module FFI
  class Pointer
    def get_libmnt_optmap (where)
      Mount::C::OptMap.new(self + where).tap {|map|
        break Mount::OptMap.new(*[:name, :id, :mask].map {|a| map[a] })
      }
    end
    def read_libmnt_optmap
      get_libmnt_optmap(0)
    end

    def put_libmnt_optmap (optmap, where)
      put_string(where, [optmap.name, optmap.id, optmap.mask].pack('Pi!i!'))
      self
    end
    def write_libmnt_optmap (optmap)
      put_libmnt_optmap(optmap, 0)
      self
    end

    def read_array_of_libmnt_optmap
      map, offset = [], 0

      begin
        map << get_libmnt_optmap(offset)
        offset += Mount::C::OptMap.size
      end until map.last.instance_eval { [name, id, mask] } == [nil, 0, 0]

      map.tap(&:pop)
    end

    def write_array_of_libmnt_optmap (optmap)
      optmap.each_with_index {|opt, i|
        put_libmnt_optmap(opt, i * Mount::C::OptMap.size)
      }
      put_libmnt_optmap(Mount::OptMap.new(nil, 0, 0), optmap.size * Mount::C::OptMap.size)
      self
    end

    def self.from_array_of_libmnt_optmap (optmap)
      self.new(:pointer, (optmap.size + 1) * Mount::C::OptMap.size).write_array_of_libmnt_optmap(optmap)
    end
  end
end

module Mount
  module C
    module Bool
      extend FFI::DataConverter
      native_type FFI::Type::UCHAR

      def self.to_native(value, ctx)
        [0, false, nil].include?(value) ? 0 : 1
      end

      def self.from_native(value, ctx)
        !value.zero?
      end
    end

    module MntBool
      extend FFI::DataConverter
      native_type FFI::Type::UCHAR

      def self.to_native (value, ctx)
        [0, false, nil].include?(value) ? 1 : 0
      end

      def self.from_native (value, ctx)
        value.zero?
      end
    end

    module MntCC
      extend FFI::DataConverter
      native_type FFI::Type::UCHAR

      def self.to_native (value, ctx)
        return 1 if value == nil
        [0, false].include?(value) ? 1 : 0
      end

      def self.from_native (value, ctx)
        return 1 if value == 1
        value.zero?
      end
    end

    module IO
      extend FFI::DataConverter
      native_type FFI::Type::POINTER

      module CFunc
        extend FFI::Library
        ffi_lib FFI::Library::LIBC

        attach_function :fdopen, [:int, :string], :pointer
        attach_function :fileno, [:pointer], :int
      end

      def self.to_native (value, ctx)
        Mount::C::IO::CFunc.fdopen(value.fileno, 'r+')
      end

      def self.from_native (value, ctx)
        ::IO.for_fd(Mount::C::IO::CFunc.fileno(value), 'r+')
      end
    end

    extend FFI::Library
    FFI.typedef(Bool, :bool)
    FFI.typedef(MntBool, :mnt_bool)
    FFI.typedef(MntCC, :mntcc)
    FFI.typedef(Mount::C::IO, :io)

    callback :errcb, [:pointer, :string, :int], :int
    callback :match_func, [:pointer, :pointer, :pointer], :int

    class OptMap < FFI::Struct
      layout \
        :name,  :string,
        :id,    :int,
        :mask,  :int
    end

    class MntEnt < FFI::Struct
      layout \
        :fsname,  :string,
        :dir,     :string,
        :type,    :string,
        :opts,    :string,
        :freq,    :int,
        :passno,  :int
    end

    ffi_lib 'mount'

    # context {{{
    attach_function :mnt_free_context, [:pointer], :void
    attach_function :mnt_new_context, [], :pointer
    attach_function :mnt_reset_context, [:pointer], :mnt_bool
    attach_function :mnt_context_append_options, [:pointer, :string], :mnt_bool
    attach_function :mnt_context_apply_fstab, [:pointer], :mnt_bool
    attach_function :mnt_context_disable_canonicalize, [:pointer, :bool], :mnt_bool
    attach_function :mnt_context_disable_helpers, [:pointer, :bool], :mnt_bool
    attach_function :mnt_context_disable_mtab, [:pointer, :bool], :mnt_bool
    attach_function :mnt_context_enable_fake, [:pointer, :bool], :mnt_bool
    attach_function :mnt_context_enable_force, [:pointer, :bool], :mnt_bool
    attach_function :mnt_context_enable_lazy, [:pointer, :bool], :mnt_bool
    attach_function :mnt_context_enable_loopdel, [:pointer, :bool], :mnt_bool
    attach_function :mnt_context_enable_rdonly_umount, [:pointer, :bool], :mnt_bool
    attach_function :mnt_context_enable_sloppy, [:pointer, :bool], :mnt_bool
    attach_function :mnt_context_enable_verbose, [:pointer, :bool], :mnt_bool
    attach_function :mnt_context_get_cache, [:pointer], :pointer
    attach_function :mnt_context_get_fs, [:pointer], :pointer
    attach_function :mnt_context_get_fstab, [:pointer, :pointer], :mnt_bool
    attach_function :mnt_context_get_fstype, [:pointer], :string
    attach_function :mnt_context_get_lock, [:pointer], :pointer
    attach_function :mnt_context_get_mflags, [:pointer, :pointer], :mnt_bool
    attach_function :mnt_context_get_mtab, [:pointer, :pointer], :mnt_bool
    attach_function :mnt_context_get_optsmode, [:pointer], :int
    attach_function :mnt_context_get_source, [:pointer], :string
    attach_function :mnt_context_get_status, [:pointer], :int
    #attach_function :mnt_context_get_table, [:pointer, :string, :pointer], :mnt_bool
    attach_function :mnt_context_get_target, [:pointer], :string
    attach_function :mnt_context_get_user_mflags, [:pointer, :pointer], :mnt_bool
    attach_function :mnt_context_helper_setopt, [:pointer, :int, :string], :mnt_bool
    attach_function :mnt_context_init_helper, [:pointer, :int, :int], :mnt_bool
    attach_function :mnt_context_is_fake, [:pointer], :bool
    attach_function :mnt_context_is_force, [:pointer], :bool
    #attach_function :mnt_context_is_fs_mounted, [:pointer, :pointer, :pointer], :mnt_bool
    attach_function :mnt_context_is_lazy, [:pointer], :bool
    attach_function :mnt_context_is_nomtab, [:pointer], :bool
    attach_function :mnt_context_is_rdonly_umount, [:pointer], :bool
    attach_function :mnt_context_is_restricted, [:pointer], :bool
    attach_function :mnt_context_is_sloppy, [:pointer], :bool
    attach_function :mnt_context_is_verbose, [:pointer], :bool
    attach_function :mnt_context_set_cache, [:pointer, :pointer], :mnt_bool
    attach_function :mnt_context_set_fs, [:pointer, :pointer], :mnt_bool
    attach_function :mnt_context_set_fstab, [:pointer, :pointer], :mnt_bool
    attach_function :mnt_context_set_fstype, [:pointer, :string], :mnt_bool
    attach_function :mnt_context_set_fstype_pattern, [:pointer, :string], :mnt_bool
    attach_function :mnt_context_set_mflags, [:pointer, :ulong], :mnt_bool
    attach_function :mnt_context_set_mountdata, [:pointer, :pointer], :mnt_bool
    attach_function :mnt_context_set_options, [:pointer, :string], :mnt_bool
    attach_function :mnt_context_set_options_pattern, [:pointer, :string], :mnt_bool
    attach_function :mnt_context_set_optsmode, [:pointer, :int], :mnt_bool
    attach_function :mnt_context_set_source, [:pointer, :string], :mnt_bool
    attach_function :mnt_context_set_syscall_status, [:pointer, :int], :mnt_bool
    #attach_function :mnt_context_set_tables_errcb, [:pointer, :errcb], :mnt_bool
    attach_function :mnt_context_set_target, [:pointer, :string], :mnt_bool
    attach_function :mnt_context_set_user_mflags, [:pointer, :ulong], :mnt_bool
    attach_function :mnt_context_strerror, [:pointer, :pointer, :int], :mnt_bool

    #   mount context {{{
    attach_function :mnt_context_do_mount, [:pointer], :mnt_bool
    attach_function :mnt_context_finalize_mount, [:pointer], :mnt_bool
    attach_function :mnt_context_mount, [:pointer], :mnt_bool
    #attach_function :mnt_context_next_mount, [:pointer, :pointer, :pointer, :pointer, :pointer], :mntcc
    attach_function :mnt_context_prepare_mount, [:pointer], :mnt_bool
    #   }}}

    #   umount context {{{
    attach_function :mnt_context_do_umount, [:pointer], :mnt_bool
    attach_function :mnt_context_finalize_umount, [:pointer], :mnt_bool
    attach_function :mnt_context_prepare_umount, [:pointer], :mnt_bool
    attach_function :mnt_context_umount, [:pointer], :mnt_bool
    #   }}}
    # }}}

    # table {{{
    attach_function :mnt_free_table, [:pointer], :void
    attach_function :mnt_new_table, [], :pointer
    #attach_function :mnt_reset_table, [:pointer], :mnt_bool
    attach_function :mnt_new_table_from_dir, [:string], :pointer
    attach_function :mnt_new_table_from_file, [:string], :pointer
    attach_function :mnt_table_add_fs, [:pointer, :pointer], :mnt_bool
    attach_function :mnt_table_find_next_fs, [:pointer, :pointer, :match_func, :pointer, :pointer], :mnt_bool
    attach_function :mnt_table_find_pair, [:pointer, :string, :string, :int], :pointer
    attach_function :mnt_table_find_source, [:pointer, :string, :int], :pointer
    attach_function :mnt_table_find_srcpath, [:pointer, :string, :int], :pointer
    attach_function :mnt_table_find_tag, [:pointer, :string, :string, :int], :pointer
    attach_function :mnt_table_find_target, [:pointer, :string, :int], :pointer
    attach_function :mnt_table_get_cache, [:pointer], :pointer
    #attach_function :mnt_table_get_name, [:pointer], :string
    attach_function :mnt_table_get_nents, [:pointer], :int
    attach_function :mnt_table_get_root_fs, [:pointer, :pointer], :mnt_bool
    #attach_function :mnt_table_is_fs_mounted, [:pointer, :pointer], :bool
    attach_function :mnt_table_next_child_fs, [:pointer, :pointer, :pointer, :pointer], :mnt_bool
    attach_function :mnt_table_next_fs, [:pointer, :pointer, :pointer], :mnt_bool
    attach_function :mnt_table_parse_file, [:pointer, :string], :mnt_bool
    attach_function :mnt_table_parse_fstab, [:pointer, :string], :mnt_bool
    attach_function :mnt_table_parse_mtab, [:pointer, :string], :mnt_bool
    attach_function :mnt_table_parse_stream, [:pointer, :io, :string], :mnt_bool
    attach_function :mnt_table_remove_fs, [:pointer, :pointer], :mnt_bool
    attach_function :mnt_table_set_cache, [:pointer, :pointer], :mnt_bool
    attach_function :mnt_table_set_iter, [:pointer, :pointer, :pointer], :mnt_bool
    attach_function :mnt_table_set_parser_errcb, [:pointer, :errcb], :mnt_bool
    # }}}

    # filesystem {{{
    attach_function :mnt_copy_fs, [:pointer, :pointer], :pointer
    attach_function :mnt_free_fs, [:pointer], :void
    attach_function :mnt_free_mntent, [:pointer], :void
    attach_function :mnt_fs_append_attributes, [:pointer, :string], :mnt_bool
    attach_function :mnt_fs_append_options, [:pointer, :string], :mnt_bool
    attach_function :mnt_fs_get_attribute, [:pointer, :string, :pointer, :pointer], :mnt_bool
    attach_function :mnt_fs_get_attributes, [:pointer], :string
    attach_function :mnt_fs_get_bindsrc, [:pointer], :string
    attach_function :mnt_fs_get_devno, [:pointer], :dev_t
    attach_function :mnt_fs_get_freq, [:pointer], :int
    attach_function :mnt_fs_get_fs_options, [:pointer], :string
    attach_function :mnt_fs_get_fstype, [:pointer], :string
    attach_function :mnt_fs_get_id, [:pointer], :int
    attach_function :mnt_fs_get_option, [:pointer, :pointer, :pointer, :pointer], :mnt_bool
    #attach_function :mnt_fs_get_options, [:pointer], :string
    attach_function :mnt_fs_get_parent_id, [:pointer], :int
    attach_function :mnt_fs_get_passno, [:pointer], :int
    attach_function :mnt_fs_get_root, [:pointer], :string
    attach_function :mnt_fs_get_source, [:pointer], :string
    attach_function :mnt_fs_get_srcpath, [:pointer], :string
    attach_function :mnt_fs_get_tag, [:pointer, :pointer, :pointer], :mnt_bool
    attach_function :mnt_fs_get_target, [:pointer], :string
    attach_function :mnt_fs_get_userdata, [:pointer], :pointer
    attach_function :mnt_fs_get_user_options, [:pointer], :string
    attach_function :mnt_fs_get_vfs_options, [:pointer], :string
    attach_function :mnt_fs_is_kernel, [:pointer], :mnt_bool
    attach_function :mnt_fs_match_fstype, [:pointer, :string], :bool
    attach_function :mnt_fs_match_options, [:pointer, :string], :bool
    attach_function :mnt_fs_match_source, [:pointer, :string, :pointer], :bool
    attach_function :mnt_fs_match_target, [:pointer, :string, :pointer], :bool
    attach_function :mnt_fs_prepend_attributes, [:pointer, :string], :mnt_bool
    attach_function :mnt_fs_prepend_options, [:pointer, :string], :mnt_bool
    attach_function :mnt_fs_print_debug, [:pointer, :io], :mnt_bool
    attach_function :mnt_fs_set_attributes, [:pointer, :string], :mnt_bool
    attach_function :mnt_fs_set_bindsrc, [:pointer, :string], :mnt_bool
    attach_function :mnt_fs_set_freq, [:pointer, :int], :mnt_bool
    attach_function :mnt_fs_set_fstype, [:pointer, :string], :mnt_bool
    attach_function :mnt_fs_set_options, [:pointer, :string], :mnt_bool
    attach_function :mnt_fs_set_passno, [:pointer, :int], :mnt_bool
    attach_function :mnt_fs_set_root, [:pointer, :string], :mnt_bool
    attach_function :mnt_fs_set_source, [:pointer, :string], :mnt_bool
    attach_function :mnt_fs_set_target, [:pointer, :string], :mnt_bool
    attach_function :mnt_fs_set_userdata, [:pointer, :pointer], :mnt_bool
    attach_function :mnt_fs_strdup_options, [:pointer], :string
    attach_function :mnt_fs_to_mntent, [:pointer, :pointer], :mnt_bool
    attach_function :mnt_new_fs, [], :pointer
    attach_function :mnt_reset_fs, [:pointer], :void
    # }}}

    # locking {{{
    attach_function :mnt_free_lock, [:pointer], :void
    attach_function :mnt_lock_file, [:pointer], :mnt_bool
    attach_function :mnt_new_lock, [:string, :pid_t], :pointer
    attach_function :mnt_unlock_file, [:pointer], :void
    attach_function :mnt_lock_block_signals, [:pointer, :bool], :mnt_bool
    # }}}

    # tables update {{{
    attach_function :mnt_free_update, [:pointer], :void
    attach_function :mnt_new_update, [], :pointer
    attach_function :mnt_update_force_rdonly, [:pointer, :bool], :mnt_bool
    attach_function :mnt_update_get_filename, [:pointer], :string
    attach_function :mnt_update_get_fs, [:pointer], :pointer
    attach_function :mnt_update_get_mflags, [:pointer], :ulong
    attach_function :mnt_update_is_ready, [:pointer], :bool
    attach_function :mnt_update_set_fs, [:pointer, :ulong, :string, :pointer], :mnt_bool
    attach_function :mnt_update_table, [:pointer, :pointer], :mnt_bool
    # }}}

    # monitor mountinfo changes {{{
    #attach_function :mnt_new_tabdiff, [], :pointer
    #attach_function :mnt_free_tabdiff, [:pointer], :void
    #attach_function :mnt_tabdiff_next_change, [:pointer, :pointer, :pointer, :pointer, :pointer], :mnt_bool
    #attach_function :mnt_diff_tables, [:pointer, :pointer, :pointer], :int
    # }}}

    # option string {{{
    attach_function :mnt_optstr_append_option, [:pointer, :string, :string], :mnt_bool
    attach_function :mnt_optstr_apply_flags, [:pointer, :ulong, :pointer], :mnt_bool
    attach_function :mnt_optstr_get_flags, [:string, :pointer, :pointer], :mnt_bool
    attach_function :mnt_optstr_get_option, [:string, :string, :pointer, :pointer], :mnt_bool
    attach_function :mnt_optstr_get_options, [:string, :pointer, :pointer, :int], :mnt_bool
    attach_function :mnt_optstr_next_option, [:pointer, :pointer, :pointer, :pointer, :pointer], :mntcc
    attach_function :mnt_optstr_prepend_option, [:pointer, :string, :string], :mnt_bool
    attach_function :mnt_optstr_remove_option, [:pointer, :string], :mnt_bool
    attach_function :mnt_optstr_set_option, [:pointer, :string, :string], :mnt_bool
    attach_function :mnt_split_optstr, [:string, :pointer, :pointer, :pointer, :int, :int], :mnt_bool
    # }}}

    # option maps {{{
    attach_function :mnt_get_builtin_optmap, [:int], :pointer
    # }}}

    # initialization {{{
    attach_function :mnt_init_debug, [:int], :void
    # }}}

    # cache {{{
    attach_function :mnt_new_cache, [], :pointer
    attach_function :mnt_free_cache, [:pointer], :void
    attach_function :mnt_cache_device_has_tag, [:pointer, :string, :string, :string], :bool
    attach_function :mnt_cache_find_tag_value, [:pointer, :string, :string], :string
    attach_function :mnt_cache_read_tags, [:pointer, :string], :mnt_bool
    attach_function :mnt_get_fstype, [:string, :pointer, :pointer], :string
    #attach_function :mnt_pretty_path, [:string, :pointer], :string
    attach_function :mnt_resolve_path, [:string, :pointer], :string
    attach_function :mnt_resolve_spec, [:string, :pointer], :string
    attach_function :mnt_resolve_tag, [:string, :string, :pointer], :string
    # }}}

    # iterator {{{
    attach_function :mnt_free_iter, [:pointer], :void
    attach_function :mnt_iter_get_direction, [:pointer], :int
    attach_function :mnt_new_iter, [:int], :pointer
    attach_function :mnt_reset_iter, [:pointer, :int], :void
    # }}}

    # utils {{{
    attach_function :mnt_fstype_is_netfs, [:string], :bool
    attach_function :mnt_fstype_is_pseudofs, [:string], :bool
    attach_function :mnt_get_fstab_path, [], :string
    attach_function :mnt_get_fstype, [:string, :pointer, :pointer], :string
    attach_function :mnt_get_library_version, [:pointer], :int
    attach_function :mnt_get_mtab_path, [], :string
    attach_function :mnt_has_regular_mtab, [:pointer, :pointer], :bool
    attach_function :mnt_mangle, [:string], :string
    attach_function :mnt_match_fstype, [:string, :string], :bool
    attach_function :mnt_match_options, [:string, :string], :bool
    attach_function :mnt_unmangle, [:string], :string
    # }}}

    # version {{{
    attach_function :mnt_parse_version_string, [:string], :int
    attach_function :mnt_get_library_version, [:pointer], :int
    # }}}
  end
end
