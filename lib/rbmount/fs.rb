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

module Mount
  class FS
    def initialize (ptr=nil)
      @pointer= ptr
      @pointer = Mount::C.mnt_new_fs unless @pointer
      raise if @pointer.null?

      ObjectSpace.define_finalizer(self, method(:finalize))
    end

    def append_attributes (optstr)
      Mount::C.mnt_fs_append_attributes(@pointer, optstr)
    end

    def append_options (optstr)
      Mount::C.mnt_fs_append_options(@pointer, optstr)
    end

    def attribute (key)
      ptr = FFI::MemoryPointer.new(:pointer).write_pointer(FFI::MemoryPointer.new(:string))
      plen = FFI::MemoryPointer.new(:ulong)

      raise unless Mount::C.mnt_fs_get_attribute(@pointer, key, ptr, plen)
      ptr.read_pointer.read_string[0, plen.read_ulong]
    end

    def attributes
      Mount::C.mnt_fs_get_attributes(@pointer)
    end

    def bindsrc
      Mount::C.mnt_fs_get_bindsrc(@pointer)
    end

    def devno
      Mount::C.mnt_fs_get_devno(@pointer)
    end

    def freq
      Mount::C.mnt_fs_get_freq(@pointer)
    end

    def fs_options
      Mount::C.mnt_fs_get_fs_options(@pointer)
    end

    def fstype
      Mount::C.mnt_fs_get_fstype(@pointer)
    end

    def id
      Mount::C.mnt_fs_get_id(@pointer)
    end

    def option (key)
      ptr = FFI::MemoryPointer.new(:pointer).write_pointer(FFI::MemoryPointer.new(:string))
      plen = FFI::MemoryPointer.new(:ulong)

      raise unless Mount::C.mnt_fs_get_option(@pointer, key, ptr, plen)
      ptr.read_pointer.read_string[0, plen.read_ulong]
    end

    def options
      Mount::C.mnt_fs_get_options(@pointer)
    end

    def parent_id
      Mount::C.mnt_fs_get_parent_id(@pointer)
    end

    def passno
      Mount::C.mnt_fs_get_passno(@pointer)
    end

    def root
      Mount::C.mnt_fs_get_root(@pointer)
    end

    def source
      Mount::C.mnt_fs_get_source(@pointer)
    end

    def srcpath
      Mount::C.mnt_fs_get_srcpath(@pointer)
    end

    def tag
      name = FFI::MemoryPointer.new(:pointer).write_pointer(FFI::MemoryPointer.new(:string))
      value = FFI::MemoryPointer.new(:pointer).write_pointer(FFI::MemoryPointer.new(:string))

      raise unless Mount::C.mnt_fs_get_tag(@pointer, name, value)
      [name.read_pointer.read_string, value.read_pointer.read_string]
    end

    def target
      Mount::C.mnt_fs_get_target(@pointer)
    end

    def userdata
      Mount::C.mnt_fs_get_userdata(@pointer)
    end

    def user_options
      Mount::C.mnt_fs_get_user_options(@pointer)
    end

    def vfs_options
      Mount::C.mnt_fs_get_vfs_options(@pointer)
    end

    def kernel?
      Mount::C.mnt_fs_is_kernel(@pointer)
    end

    def match_fstype (types)
      Mount::C.mnt_fs_match_fstype(@pointer, types)
    end

    def match_options (options)
      Mount::C.mnt_fs_match_options(@pointer, options)
    end

    def match_source (source=nil, cache=nil)
      Mount::C.mnt_fs_match_source(@pointer, source, (cache ? cache.to_c : cache))
    end

    def match_target (source=nil, cache=nil)
      Mount::C.mnt_fs_match_target(@pointer, source, (cache ? cache.to_c : cache))
    end

    def prepend_attributes (optstr)
      Mount::C.mnt_fs_prepend_attributes(@pointer, optstr)
    end

    def prepend_options (optstr)
      Mount::C.mnt_fs_prepend_options(@pointer, optstr)
    end

    def print_debug (io)
      Mount::C.mnt_fs_print_debug(@pointer, io)
    end

    def attributes= (optstr)
      Mount::C.mnt_fs_set_attributes(@pointer, optstr)
    end

    def bindsrc= (src)
      Mount::C.mnt_fs_set_bindsrc(@pointer, src)
    end

    def freq= (f)
      Mount::C.mnt_fs_set_freq(@pointer, f)
    end

    def fstype= (type)
      Mount::C.mnt_fs_set_fstype(@pointer, type)
    end

    def options= (optstr)
      Mount::C.mnt_fs_set_options(@pointer, optstr)
    end

    def passno= (passn)
      Mount::C.mnt_fs_set_passno(@pointer, passn)
    end

    def root= (path)
      Mount::C.mnt_fs_set_root(@pointer, path)
    end

    def source= (src)
      Mount::C.mnt_fs_set_source(@pointer, src)
    end

    def target= (targ)
      Mount::C.mnt_fs_set_target(@pointer, targ)
    end

    def userdata= (data)
      Mount::C.mnt_fs_set_userdata(@pointer, data)
    end

    def options_dup
      Mount::C.mnt_fs_strdup_options(@pointer)
    end

    def to_mntent
      ptr = FFI::MemoryPointer.new(:pointer).write_pointer(FFI::MemoryPointer.new(:pointer))

      raise unless Mount::C.mnt_fs_to_mntent(@pointer, ptr)

      Mount::C::MntEnt.new(ptr.read_pointer)
    end

    def reset!
      Mount::C.mnt_reset_fs(@pointer)
    end

    def finalize
      Mount::C.mnt_free_fs(@pointer)
    end

    def dup
      Mount::FS.new.tap {|d|
        Mount::C.mnt_copy_fs(d.to_c, self.to_c)
      }
    end

    def to_c
      @pointer
    end
  end
end
