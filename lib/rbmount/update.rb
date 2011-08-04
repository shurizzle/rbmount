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

module Mount
  class Update
    def initialize
      @pointer = Mount::C.mnt_new_update
      raise unless @pointer

      ObjectSpace.define_finalizer(self, method(:finalize))
    end

    def read_only= (is_read_only)
      Mount::C.mnt_update_force_rdonly(@pointer, !!is_read_only)
    end

    def filename
      Mount::C.mnt_update_get_filename(@pointer)
    end

    def fs
      Mount::C.mnt_update_get_fs(@pointer).tap {|fsp|
        break Mount::FS.allocate.tap {|f| f.instance_eval {
          @pointer = fsp
          ObjectSpace.define_finalizer(self, method(:finalize))
        }}
      }
    end

    def mflags
      Mount::C.mnt_update_get_mflags(@pointer)
    end

    def ready?
      Mount::C.mnt_update_is_ready(@pointer)
    end

    def fs= (mountflags, target, fsp=nil)
      Mount::C.mnt_update_set_fs(@pointer, mountflags, target, (fsp ? fsp.to_c : fsp))
    end

    def table (lc=nil)
      Mount::C.mnt_update_table(@pointer, (lc ? lc.to_c : lc))
    end

    def finalize
      Mount::C.mnt_free_update(@pointer)
    end

    def to_c
      @pointer
    end
  end
end
