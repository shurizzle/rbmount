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
  class Cache
    def initialize (ptr=nil)
      @pointer= ptr
      @pointer = Mount::C.mnt_new_fs unless @pointer
      raise if @pointer.null?

      ObjectSpace.define_finalizer(self, method(:finalize))
    end

    def has_tag? (devname, token, value)
      Mount::C.mnt_cache_device_has_tag(@pointer, devname, token, value)
    end
    alias tag? has_tag?

    def tag (devname, token)
      Mount::C.mnt_cache_find_tag_value(@pointer, devname, token)
    end

    def read_tags (devname)
      Mount::C.mnt_cache_read_tags(@pointer, devname)
    end

    def fs_type (devname, amb=false)
      ambi = amb ? FFI::MemoryPointer.new(:int) : nil
      fs = Mount::C.mnt_get_fstype(devname, ambi, @pointer)

      amb ? [fs, ambi.read_int] : fs
    end

    def pretty_path (devname)
      Mount::C.mnt_pretty_path(devname, @pointer)
    end

    def resolve_path (path)
      Mount::C.mnt_resolve_path(path, @pointer)
    end

    def resolve_spec (spec)
      Mount::C.mnt_resolve_spec(spec, @pointer)
    end

    def resolve_tag (token, value)
      Mount::C.mnt_resolve_tag(token, value, @pointer)
    end

    def finalize (id=nil)
      Mount::C.mnt_free_cache(@pointer)
    end

    def to_c
      @pointer
    end
  end
end
