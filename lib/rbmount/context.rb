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

require 'rbmount/c'
require 'rbmount/fs'
require 'rbmount/lock'
require 'rbmount/cache'
require 'rbmount/table'

module Mount
  class Context
    def finalize
      Mount::C.mnt_free_context(@pointer)
    end

    def initialize
      @pointer = Mount::C.mnt_new_context
      raise if @pointer.null?

      ObjectSpace.define_finalizer(self, method(:finalize))
    end

    def reset!
      return false unless Mount::C.mnt_reset_context(@pointer)
      self
    end

    def append_options (optstr)
      Mount::C.mnt_context_append_options(@pointer, optstr)
    end

    def apply_fstab
      Mount::C.mnt_context_apply_fstab(@pointer)
    end

    def canonicalize= (ok)
      Mount::C.mnt_context_disable_canonicalize(@pointer, !ok)
    end

    def helpers= (ok)
      Mount::C.mnt_context_disable_helpers(@pointer, !ok)
    end

    def mtab= (ok)
      Mount::C.mnt_context_disable_mtab(@pointer, !ok)
    end

    def fake= (ok)
      Mount::C.mnt_context_enable_fake(@pointer, !!ok)
    end

    def force= (ok)
      Mount::C.mnt_context_enable_force(@pointer, !!ok)
    end

    def lazy= (ok)
      Mount::C.mnt_context_enable_lazy(@pointer, !!ok)
    end

    def loopdel= (ok)
      Mount::C.mnt_context_enable_loopdel(@pointer, !!ok)
    end

    def rdonly_umount= (ok)
      Mount::C.mnt_context_enable_rdonly_umount(@pointer, !!ok)
    end

    def sloppy= (ok)
      Mount::C.mnt_context_enable_sloppy(@pointer, !!ok)
    end

    def verbose= (ok)
      Mount::C.mnt_context_enable_verbose(@pointer, !!ok)
    end

    def cache
      Mount::Cache.new(Mount::C.mnt_context_get_cache(@pointer))
    end

    def fs
      Mount::FS.new(Mount::C.mnt_context_get_fs(@pointer))
    end

    def fstab
      Mount::Table.new.tap {|tab|
        ptr = FFI::MemoryPointer.new(:pointer).write_pointer(tab.to_c)
        raise unless Mount::C.mnt_context_get_fstab(@pointer, ptr)
      }
    end

    def fstype
      Mount::C.mnt_context_get_fstype(@pointer)
    end

    def lock
      lk = Mount::C.mnt_context_get_lock(@pointer)
      raise if lk.null?

      Mount::Lock.allocate.tap {|lck|
        lck.instance_eval {
          @pointer = lk

          ObjectSpace.define_finalizer(self, self.method(:finalize))
        }
      }
    end

    def mflags
      ptr = FFI::MemoryPointer.new(:ulong)
      raise unless Mount::C.mnt_context_get_mflags(@pointer, ptr)

      ptr.read_ulong
    end

    def mtab
      Mount::Table.new.tap {|tab|
        ptr = FFI::MemoryPointer.new(:pointer).write_pointer(tab.to_c)
        raise unless Mount::C.mnt_context_get_mtab(@pointer, ptr)
      }
    end

    def optsmode
      Mount::C.mnt_context_get_optsmode(@pointer)
    end

    def source
      Mount::C.mnt_context_get_source(@pointer)
    end

    def status
      Mount::C.mnt_context_get_status(@pointer)
    end

    def table (filename)
      Mount::Table.new.tap {|tab|
        ptr = FFI::MemoryPointer.new(:pointer).write_pointer(tab.to_c)
        raise unless Mount::C.mnt_context_get_table(@pointer, filename, ptr)
      }
    end

    def target
      Mount::C.mnt_context_get_target(@pointer)
    end

    def user_mflags
      ptr = FFI::MemoryPointer.new(:ulong)
      raise unless Mount::C.mnt_context_get_user_mflags(@pointer, ptr)

      ptr.read_ulong
    end

    def helper_setopt (c, arg)
      Mount::C.mnt_context_helper_setopt(@pointer, c, arg)
    end

    def init_helper (action, flags=0)
      Mount::C.mnt_context_init_helper(@pointer, action, flags)
    end

    def fake?
      Mount::C.mnt_context_is_fake(@pointer)
    end

    def force?
      Mount::C.mnt_context_is_force(@pointer)
    end

    def fs_mounted? (fs)
      ptr = FFI::MemoryPointer.new(:int)
      Mount::C.mnt_context_is_fs_mounted(@pointer, fs.to_c, ptr)

      !ptr.read_int.zero?
    end

    def lazy?
      Mount::C.mnt_context_is_lazy(@pointer)
    end

    def mtab?
      !Mount::C.mnt_context_is_nomtab(@pointer)
    end

    def rdonly_umount?
      Mount::C.mnt_context_is_rdonly_umount(@pointer)
    end

    def restricted?
      Mount::C.mnt_context_is_restricted(@pointer)
    end

    def sloppy?
      Mount::C.mnt_context_is_sloppy(@pointer)
    end

    def verbose?
      Mount::C.mnt_context_is_verbose(@pointer)
    end

    def cache= (cache)
      Mount::C.mnt_context_set_cache(@pointer, cache.to_c)
    end

    def fs= (fs)
      Mount::C.mnt_context_set_fs(@pointer, fs.to_c)
    end

    def fstab= (tb)
      Mount::C.mnt_context_set_fstab(@pointer, tb.to_c)
    end

    def fstype= (fstype)
      Mount::C.mnt_context_set_fstype(@pointer, fstype)
    end

    def fstype_pattern= (pattern)
      Mount::C.mnt_context_set_fstype_pattern(@pointer, pattern)
    end

    def mflags= (flags)
      Mount::C.mnt_context_set_mflags(@pointer, flags)
    end

    def mountdata= (data)
      Mount::C.mnt_context_set_mountdata(@pointer, data)
    end

    def options= (optstr)
      Mount::C.mnt_context_set_options(@pointer, optstr)
    end

    def options_pattern= (pattern)
      Mount::C.mnt_context_set_options_pattern(@pointer, pattern)
    end

    def optsmode= (mode)
      Mount::C.mnt_context_set_optsmode(@pointer, mode)
    end

    def source= (src)
      Mount::C.mnt_context_set_source(@pointer, src)
    end

    def syscall_status= (status)
      Mount::C.mnt_context_set_syscall_status(@pointer, status)
    end

    def on_error (&blk)
      if blk.arity == 3
        Mount::C.mnt_context_set_tables_errcb(@pointer, blk)
        true
      else
        false
      end
    end

    def target= (target)
      Mount::C.mnt_context_set_target(@pointer, target)
    end

    def user_mflags (flags)
      Mount::C.mnt_context_set_user_mflags(@pointer, flags)
    end

    def strerror
      ''
    end

    def do_mount
      Mount::C.mnt_context_do_mount(@pointer)
    end

    def finalize_mount
      Mount::C.mnt_context_finalize_mount(@pointer)
    end

    def mount
      Mount::C.mnt_context_mount(@pointer)
    end

    def next_mount (direction=:forward)
      fs = Mount::FS.new
      fsptr = FFI::MemoryPointer.new(:pointer).write_pointer(fs.to_c)
      rcptr = FFI::MemoryPointer.new(:int)
      iptr = FFI::MemoryPointer.new(:int)

      res = Mount::C.mnt_context_next_mount(@pointer, Mount::Iterator.new(Mount::Table::DIRECTION[direction]).to_c,
                                            fsptr, rcptr, iptr)

      return nil if res == 1
      raise unless res

      [fs, rcptr.read_int, iptr.read_int]
    end

    def each_mount
      Enumerator.new {|y|
        loop {
          res = next_mount
          break unless res
          y << res
        }.each {|args|
          yield *args if block_given?
        }
      }
    end

    def prepare_mount
      Mount::C.mnt_context_prepare_mount(@pointer)
    end

    def do_umount
      Mount::C.mnt_context_do_umount(@pointer)
    end

    def finalize_umount
      Mount::C.mnt_context_finalize_umount(@pointer)
    end

    def prepare_umount
      Mount::C.mnt_context_prepare_umount(@pointer)
    end

    def umount
      Mount::C.mnt_context_umount(@pointer)
    end
  end
end
