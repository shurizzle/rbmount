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
  MNT_MS_COMMENT    = (1 << 8)
  MNT_MS_GROUP      = (1 << 6)
  MNT_MS_HELPER     = (1 << 12)
  MNT_MS_LOOP       = (1 << 9)
  MNT_MS_NETDEV     = (1 << 7)
  MNT_MS_NOAUTO     = (1 << 2)
  MNT_MS_NOFAIL     = (1 << 10)
  MNT_MS_OFFSET     = (1 << 14)
  MNT_MS_OWNER      = (1 << 5)
  MNT_MS_SIZELIMIT  = (1 << 15)
  MNT_MS_UHELPER    = (1 << 11)
  MNT_MS_USER       = (1 << 3)
  MNT_MS_USERS      = (1 << 4)
  MNT_MS_XCOMMENT   = (1 << 13)
  MS_BIND           = 0x1000
  MS_DIRSYNC        = 128
  MS_I_VERSION      = (1<<23)
  MS_MANDLOCK       = 64
  MS_MGC_MSK        = 0xffff0000
  MS_MGC_VAL        = 0xC0ED0000
  MS_MOVE           = 0x2000
  MS_NOATIME        = 0x400
  MS_NODEV          = 4
  MS_NODIRATIME     = 0x800
  MS_NOEXEC         = 8
  MS_NOSUID         = 2
  MS_PRIVATE        = (1<<18)
  MS_SHARED         = (1<<20)
  MS_RDONLY         = 1
  MS_REC            = 0x4000
  MS_RELATIME       = 0x200000
  MS_REMOUNT        = 32
  MS_SILENT         = 0x8000
  MS_SLAVE          = (1<<19)
  MS_STRICTATIME    = (1<<24)
  MS_SYNCHRONOUS    = 16
  MS_UNBINDABLE     = (1<<17)
  MS_PROPAGATION    = (MS_SHARED|MS_SLAVE|MS_UNBINDABLE|MS_PRIVATE)
  MS_SECURE         = (MS_NOEXEC|MS_NOSUID|MS_NODEV)
  MS_OWNERSECURE    = (MS_NOSUID|MS_NODEV)

  MNT_INVERT        = (1 << 1)
  MNT_NOMTAB        = (1 << 2)
  MNT_PREFIX        = (1 << 3)

  MNT_ITER_FORWARD  = 0
  MNT_ITER_BACKWARD = 1

  VERSION           = "2.19.0"

  class OptMap < Struct.new(:name, :id, :mask)
  end


  def self.fs_type (devname, amb=false)
    ambi = amb ? FFI::MemoryPointer.new(:int) : nil
    fs = Mount::C.mnt_get_fstype(devname, ambi, nil)

    amb ? [fs, ambi.read_int] : fs
  end

  def self.pretty_path (devname)
    Mount::C.mnt_pretty_path(devname, nil)
  end

  def self.resolve_path (path)
    Mount::C.mnt_resolve_path(path, nil)
  end

  def self.resolve_tag (token, value)
    Mount::C.mnt_resolve_tag(token, value, nil)
  end

  def self.init_debug (mask)
    Mount::C.mnt_init_debug(mask)
  end

  def self.builtin_optmap (id)
    Mount::C.mnt_get_builtin_optmap(1).read_array_of_libmnt_optmap
  end
end
