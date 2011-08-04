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
  class Iterator
    def initialize (direction)
      @pointer = Mount::C.mnt_new_iter(direction)
      raise if @pointer.null?

      ObjectSpace.define_finalizer(self, method(:finalize))
    end

    def direction
      Mount::C.mnt_iter_get_direction(@pointer)
    end

    def reset
      Mount::C.mnt_reset_iter(@pointer)
      self
    end

    def finalize (id=nil)
      Mount::C.mnt_free_iter(@pointer)
    end

    def to_c
      @pointer
    end
  end
end
