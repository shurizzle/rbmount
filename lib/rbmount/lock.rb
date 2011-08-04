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
  class Lock
    def initialize (datafile, id)
      @pointer = Mount::C.mnt_new_lock(datafile, id)
      raise unless @pointer

      ObjectSpace.define_finalizer(self, method(:finalize))
    end

    def lock_file
      Mount::C.mnt_lock_file(@pointer)
    end

    def unlock_file
      Mount::C.mnt_unlock_file(@pointer)
    end

    def block_signals
      Mount::C.mnt_lock_block_signals(@pointer)
    end

    def finalize
      Mount::C.mnt_free_lock(@pointer)
    end

    def to_c
      @pointer
    end
  end
end
