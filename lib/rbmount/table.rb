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
require 'rbmount/iterator'
require 'rbmount/cache'
require 'rbmount/fs'

module Mount
  class Table
    DIRECTION = Hash.new {|*|
      :forward
    }.merge({
      forward:      Mount::MNT_ITER_FORWARD,
      'forward' =>  Mount::MNT_ITER_FORWARD,
      backward:     Mount::MNT_ITER_BACKWARD,
      'backward' => Mount::MNT_ITER_BACKWARD,

      Mount::MNT_ITER_FORWARD   => Mount::MNT_ITER_FORWARD,
      Mount::MNT_ITER_BACKWARD  => Mount::MNT_ITER_BACKWARD,
    }).freeze

    def initialize (path=nil)
      @pointer = Mount::C.mnt_new_table unless path
      if File.directory?(path)
        @pointer = Mount::C.mnt_new_table_from_dir(path)
      elsif File.file?(path)
        @pointer = Mount::C.mnt_new_table_from_file(path)
      else
        raise ArgumentError
      end

      raise if !@pointer or @pointer.null?

      ObjectSpace.define_finalizer(self, method(:finalize))
    end

    def add_fs (fs)
      Mount::C.mnt_table_add_fs(@pointer, fs.to_c)
    end

    def next_fs (direction=:forward)
      Mount::FS.new.tap {|fs|
        ptr = FFI::MemoryPointer.new(:pointer).write_pointer(fs.to_c)

        res = Mount::C.mnt_table_next_fs(@pointer, Mount::Iter.new(DIRECTION[direction]).to_c, ptr)
        raise unless res
        break nil if res == 1
      }
    end

    def each_fs (direction=:forward, &blk)
      Enumerator.new {|y|
        loop {
          res = next_fs(direction)
          break unless res
          y << res
        }
      }.each(&blk)
    end

    def find_pair (source, target, direction=:forward)
      Mount::FS.new(Mount::C.mnt_table_find_pair(@pointer, source, target, DIRECTION[direction]))
    end

    def find_source (source, direction=:forward)
      Mount::FS.new(Mount::C.mnt_table_find_source(@pointer, source, DIRECTION[direction]))
    end

    def find_srcpath (path, direction=:forward)
      Mount::FS.new(Mount::C.mnt_table_find_srcpath(@pointer, source, DIRECTION[direction]))
    end

    def find_tag (tag, val, direction=:forward)
      Mount::FS.new(Mount::C.mnt_table_find_tag(@pointer, tag, val, DIRECTION[direction]))
    end

    def find_target (path, direction=:forward)
      Mount::FS.new(Mount::C.mnt_table_find_target(@pointer, path, DIRECTION[direction]))
    end

    def cache
      Mount::Cache.new(Mount::C.mnt_table_get_cache(@pointer))
    end

    def name
      Mount::C.mnt_table_get_name(@pointer)
    end

    def nents
      Mount::C.mnt_table_get_nents(@pointer)
    end

    def root_fs
      Mount::FS.new.tap {|fs|
        ptr = FFI::MemoryPointer.new(:pointer).write_pointer(fs.to_c)
        raise unless Mount::C.mnt_table_get_root_fs(@pointer, ptr)
      }
    end

    def fs_mounted?(fstab_fs)
      Mount::C.mnt_table_is_fs_mounted(@pointer, fstab_fs.to_c)
    end

    def next_child_fs (parent, direction=:forward)
      Mount::FS.new.tap {|fs|
        ptr = FFI::MemoryPointer.new(:pointer).write_pointer(fs.to_c)

        res = Mount::C.mnt_table_next_child_fs(@pointer, Mount::Iter.new(DIRECTION[direction]).to_c,
                                              parent.to_c, ptr)
        raise unless res
        break nil if res == 1
      }
    end

    def each_child_fs (parent, direction=:forward, &blk)
      Enumerator.new {|y|
        loop {
          res = next_child_fs(parent, direction)
          break unless res
          y << res
        }
      }.each(&blk)
    end

    def parse_file (path)
      Mount::C.mnt_table_parse_file(@pointer, path)
    end

    def parse_fstab (path=nil)
      Mount::C.mnt_table_parse_fstab(@pointer, path)
    end

    def parse_mtab (path=nil)
      Mount::C.mnt_table_parse_mtab(@pointer, path)
    end

    def parse_stream (io, filename)
      Mount::C.mnt_table_parse_stream(@pointer, io, filename)
    end

    def remove_fs (fs)
      Mount::C.mnt_table_remove_fs(@pointer, fs.to_c)
    end

    def cache= (mpc)
      Mount::C.mnt_table_set_cache(@pointer, mpc.to_c)
    end

    def set_iter (fs, direction=:forward)
      Mount::C.mnt_table_set_iter(@pointer, Mount::Iter.new(DIRECTION[direction]).to_c, fs.to_c)
    end

    def on_error (&blk)
      if blk.arity == 3
        Mount::C.mnt_table_set_iter(@pointer, blk)
        true
      else
        false
      end
    end

    def reset!
      raise unless Mount::C.mnt_reset_table(@pointer)
      self
    end

    def finalize
      Mount::C.mnt_free_table(@pointer)
    end
  end
end
