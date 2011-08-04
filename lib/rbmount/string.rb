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
  module OptionString
    class << self
      def append_option (optstr=nil, name, value)
        sptr = optstr.is_a?(::String) ? FFI::MemoryPointer.from_string(optstr) : FFI::MemoryPointer.new(:string)
        ptr = FFI::MemoryPointer.new(:pointer).write_pointer(sptr)

        raise unless Mount::C.mnt_optstr_append_option(ptr, name, value)
        ptr.read_pointer.read_string
      end

      def apply_flags (optstr=nil, flags, map)
        sptr = optstr.is_a?(::String) ? FFI::MemoryPointer.from_string(optstr) : FFI::MemoryPointer.new(:string)
        ptr = FFI::MemoryPointer.new(:pointer).write_pointer(sptr)

        raise unless Mount::C.mnt_optstr_apply_flags(ptr, flags, FFI::MemoryPointer.from_array_of_libmnt_optmap(map))
        ptr.read_pointer.read_string
      end

      def flags (optstr, map)
        optstr = FFI::MemoryPointer.new(:string).write_string(optstr)
        ptr = FFI::MemoryPointer.new(:ulong)

        raise unless Mount::C.mnt_optstr_get_flags(optstr, ptr, FFI::MemoryPointer.from_array_of_libmnt_optmap(map))
        ptr.read_ulong
      end

      def option (optstr, name)
        ptr = FFI::MemoryPointer.new(:pointer)
        ol = FFI::MemoryPointer.new(:ulong)

        raise unless Mount::C.mnt_optstr_get_option(optstr, name, ptr, ol)
        ptr.read_pointer.read_string[0, ol.read_ulong]
      end

      def options (optstr, map, ignore=0)
        ptr = FFI::MemoryPointer.new(:pointer)

        raise unless Mount::C.mnt_optstr_get_options(optstr, ptr, FFI::MemoryPointer.from_array_of_libmnt_optmap(map), ignore)
        ptr.read_pointer.read_string
      end

      def each_option (optstr)
        optstr = FFI::MemoryPointer.new(:pointer).write_pointer(FFI::MemoryPointer.from_string(optstr))

        Enumerator.new {|y|
          loop {
            res = Mount::String.next_option(optstr)
            break unless res
            y << res
          }
        }.each {|args|
          yield *args if block_given?
        }
      end

      def prepend_option (optstr=nil, name, value)
        sptr = optstr.is_a?(::String) ? FFI::MemoryPointer.from_string(optstr) : FFI::MemoryPointer.new(:string)
        ptr = FFI::MemoryPointer.new(:pointer).write_pointer(sptr)

        raise unless Mount::C.mnt_optstr_prepend_option(ptr, name, value)
        ptr.read_pointer.read_string
      end

      def remove_option (optstr=nil, name)
        sptr = optstr.is_a?(::String) ? FFI::MemoryPointer.from_string(optstr) : FFI::MemoryPointer.new(:string)
        ptr = FFI::MemoryPointer.new(:pointer).write_pointer(sptr)

        raise unless Mount::C.mnt_optstr_remove_option(ptr, name)
        ptr.read_pointer.read_string
      end

      def set_option (optstr, name, value=nil)
        sptr = optstr.is_a?(::String) ? FFI::MemoryPointer.from_string(optstr) : FFI::MemoryPointer.new(:string)
        ptr = FFI::MemoryPointer.new(:pointer).write_pointer(sptr)

        raise unless Mount::C.mnt_optstr_set_option(ptr, name, value)
        ptr.read_pointer.read_string
      end

      def split_optstr (optstr, ignore_user=0, ignore_vfs=0)
        pi = (1..3).map { FFI::MemoryPointer.new(:pointer).write_pointer(FFI::MemoryPointer.new(:string)) }
        raise unless Mount::C.mnt_split_optstr(optstr, *pi, ignore_user, ignore_vfs)
        pi.map {|x| x.read_pointer.read_string }
      end

      protected
      def next_option (optstr)
        name = FFI::MemoryPointer.new(:pointer)
        ns = FFI::MemoryPointer.new(:ulong)
        value = FFI::MemoryPointer.new(:pointer)
        vs = FFI::MemoryPointer.new(:ulong)

        case Mount::C.mnt_optstr_next_option(optstr, name, ns, value, vs)
        when true
          [[name, ns], [value, vs]].map {|x, i| x.read_pointer.read_string[0, i.read_ulong] }
        when false
          raise
        else
          nil
        end
      end
    end

    def append_option (name, value)
      self.replace(Mount::OptionString.append_option(self, name, value))
    end

    def apply_flags (flags, map)
      self.replace(Mount::OptionString.apply_flags(self, flags, map))
    end

    def flags (map)
      Mount::OptionString.flags(self, map)
    end

    def option (name)
      Mount::OptionString.option(self, name)
    end

    def options (map, ignore=0)
      Mount::OptionString.options(self, map, ignore)
    end

    def each_option (&blk)
      Mount::OptionString.each_option(self, &blk)
    end

    def prepend_option (name, value)
      self.replace(Mount::OptionString.prepend_option(self, name, value))
    end

    def remove_option (name)
      self.replace(Mount::OptionString.remove_option(self, name))
    end

    def set_option (name, value=nil)
      self.replace(Mount::OptionString.set_option(self, name, value))
    end

    def split_optstr (ignore_user=0, ignore_vfs=0)
      Mount::OptionString.split_optstr(self, ignore_user, ignore_vfs)
    end
  end
end
