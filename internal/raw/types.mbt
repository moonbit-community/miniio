///|
pub(all) enum SeekFrom {
  Start
  Current
  End
} derive(Eq, Debug)

///|
pub(all) enum EntryKind {
  Unknown
  Regular
  Directory
  SymLink
  Socket
  BlockDevice
  CharDevice
} derive(Eq, Debug)

///|
pub(all) enum Mode {
  ReadOnly
  WriteOnly
  ReadWrite
} derive(Eq, Debug)

///|
pub(all) suberror Errno {
  Success
  TooBig
  Acces
  Addrinuse
  Addrnotavail
  Afnosupport
  Again
  Already
  Badf
  Badmsg
  Busy
  Canceled
  Child
  Connaborted
  Connrefused
  Connreset
  Deadlock
  Destaddrreq
  Dom
  Dquot
  Exist
  Fault
  Fbig
  Hostunreach
  Idrm
  Ilseq
  Inprogress
  Intr
  Inval
  IO
  Isconn
  Isdir
  Loop
  Mfile
  Mlink
  Msgsize
  Multihop
  Nametoolong
  Netdown
  Netreset
  Netunreach
  Nfile
  Nobufs
  Nodev
  Noent
  Noexec
  Nolck
  Nolink
  Nomem
  Nomsg
  Noprotoopt
  Nospc
  Nosys
  Notconn
  Notdir
  Notempty
  Notrecoverable
  Notsock
  Notsup
  Notty
  Nxio
  Overflow
  Ownerdead
  Perm
  Pipe
  Proto
  Protonosupport
  Prototype
  Range
  Rofs
  Spipe
  Srch
  Stale
  Timedout
  Txtbsy
  Xdev
  Notcapable
} derive(Eq, Debug)

///|
fn Errno::from_value(value : UInt) -> Errno? {
  match value {
    0 => Some(Success)
    1 => Some(TooBig)
    2 => Some(Acces)
    3 => Some(Addrinuse)
    4 => Some(Addrnotavail)
    5 => Some(Afnosupport)
    6 => Some(Again)
    7 => Some(Already)
    8 => Some(Badf)
    9 => Some(Badmsg)
    10 => Some(Busy)
    11 => Some(Canceled)
    12 => Some(Child)
    13 => Some(Connaborted)
    14 => Some(Connrefused)
    15 => Some(Connreset)
    16 => Some(Deadlock)
    17 => Some(Destaddrreq)
    18 => Some(Dom)
    19 => Some(Dquot)
    20 => Some(Exist)
    21 => Some(Fault)
    22 => Some(Fbig)
    23 => Some(Hostunreach)
    24 => Some(Idrm)
    25 => Some(Ilseq)
    26 => Some(Inprogress)
    27 => Some(Intr)
    28 => Some(Inval)
    29 => Some(IO)
    30 => Some(Isconn)
    31 => Some(Isdir)
    32 => Some(Loop)
    33 => Some(Mfile)
    34 => Some(Mlink)
    35 => Some(Msgsize)
    36 => Some(Multihop)
    37 => Some(Nametoolong)
    38 => Some(Netdown)
    39 => Some(Netreset)
    40 => Some(Netunreach)
    41 => Some(Nfile)
    42 => Some(Nobufs)
    43 => Some(Nodev)
    44 => Some(Noent)
    45 => Some(Noexec)
    46 => Some(Nolck)
    47 => Some(Nolink)
    48 => Some(Nomem)
    49 => Some(Nomsg)
    50 => Some(Noprotoopt)
    51 => Some(Nospc)
    52 => Some(Nosys)
    53 => Some(Notconn)
    54 => Some(Notdir)
    55 => Some(Notempty)
    56 => Some(Notrecoverable)
    57 => Some(Notsock)
    58 => Some(Notsup)
    59 => Some(Notty)
    60 => Some(Nxio)
    61 => Some(Overflow)
    62 => Some(Ownerdead)
    63 => Some(Perm)
    64 => Some(Pipe)
    65 => Some(Proto)
    66 => Some(Protonosupport)
    67 => Some(Prototype)
    68 => Some(Range)
    69 => Some(Rofs)
    70 => Some(Spipe)
    71 => Some(Srch)
    72 => Some(Stale)
    73 => Some(Timedout)
    74 => Some(Txtbsy)
    75 => Some(Xdev)
    76 => Some(Notcapable)
    _ => None
  }
}

///|
struct Size(UInt) derive(Eq, Debug)

///|
struct FileSize(UInt64) derive(Eq, Debug)

///|
struct FileDelta(Int64) derive(Eq, Debug)

///|
struct DirCookie(UInt64) derive(Eq, Debug)

///|
struct DirNamlen(UInt) derive(Eq, Debug)

///|
struct Inode(UInt64) derive(Eq, Debug)

///|
struct Rights(UInt64) derive(Eq, Debug)

///|
fn Rights::new() -> Rights {
  0
}

///|
enum Right {
  Fd_read
  Fd_seek
  Fd_tell
  Fd_write
  Fd_readdir
  Fd_filestat_set_size
} derive(Eq, Debug)

///|
fn Right::value(self : Right) -> UInt64 {
  match self {
    Fd_read => 1UL << 1
    Fd_seek => 1UL << 2
    Fd_tell => 1UL << 5
    Fd_write => 1UL << 6
    Fd_readdir => 1UL << 14
    Fd_filestat_set_size => 1UL << 22
  }
}

///|
fn Rights::set(self : Rights, right : Right) -> Rights {
  self.0 | right.value()
}

///|
struct Fd(Int) derive(Eq, Debug)

///|
struct File {
  fd : Fd
}

///|
pub let stdin : File = { fd: Fd(0) }

///|
pub let stdout : File = { fd: Fd(1) }

///|
pub let stderr : File = { fd: Fd(2) }

///|
enum Whence {
  Set
  Cur
  End
} derive(Eq, Debug)

///|
fn Whence::value(self : Whence) -> UInt {
  match self {
    Set => 0
    Cur => 1
    End => 2
  }
}

///|
fn SeekFrom::to_whence(self : SeekFrom) -> Whence {
  match self {
    Start => Set
    Current => Cur
    End => End
  }
}

///|
enum FileType {
  Unknown
  Block_device
  Character_device
  Directory
  Regular_file
  Socket_dgram
  Socket_stream
  Symbolic_link
} derive(Eq, Debug)

///|
fn FileType::from_value(value : Int) -> FileType? {
  match value {
    0 => Some(Unknown)
    1 => Some(Block_device)
    2 => Some(Character_device)
    3 => Some(Directory)
    4 => Some(Regular_file)
    5 => Some(Socket_dgram)
    6 => Some(Socket_stream)
    7 => Some(Symbolic_link)
    _ => None
  }
}

///|
fn FileType::to_entry_kind(self : FileType) -> EntryKind {
  match self {
    Unknown => EntryKind::Unknown
    Block_device => EntryKind::BlockDevice
    Character_device => EntryKind::CharDevice
    Directory => EntryKind::Directory
    Regular_file => EntryKind::Regular
    Socket_dgram => EntryKind::Socket
    Socket_stream => EntryKind::Socket
    Symbolic_link => EntryKind::SymLink
  }
}

///|
struct DirEnt {
  d_next : DirCookie
  d_ino : Inode
  d_namlen : DirNamlen
  d_type : FileType
} derive(Eq, Debug)

///|
struct DirEntry {
  name : String
  kind : EntryKind
} derive(Eq, Debug)

///|
pub fn DirEntry::name(self : DirEntry) -> String {
  self.name
}

///|
pub fn DirEntry::kind(self : DirEntry) -> EntryKind {
  self.kind
}

///|
struct FdFlags(UInt) derive(Eq, Debug)

///|
fn FdFlags::new() -> FdFlags {
  0
}

///|
enum FdFlag {
  Append
} derive(Eq, Debug)

///|
fn FdFlag::value(self : FdFlag) -> UInt {
  match self {
    Append => 1
  }
}

///|
fn FdFlags::set(self : FdFlags, flag : FdFlag) -> FdFlags {
  self.0 | flag.value()
}

///|
struct LookupFlags(UInt) derive(Eq, Debug)

///|
fn LookupFlags::new() -> LookupFlags {
  0
}

///|
struct OpenFlags(UInt) derive(Eq, Debug)

///|
fn OpenFlags::new() -> OpenFlags {
  0
}

///|
enum OpenFlag {
  Create
  Directory
  Excl
  Trunc
} derive(Eq, Debug)

///|
fn OpenFlag::value(self : OpenFlag) -> UInt {
  match self {
    Create => 1
    Directory => 2
    Excl => 4
    Trunc => 8
  }
}

///|
fn OpenFlags::set(self : OpenFlags, flag : OpenFlag) -> OpenFlags {
  self.0 | flag.value()
}

///|
pub(all) enum CreateMode {
  OpenExisting
  TruncateExisting
  OpenOrCreate
  CreateOrTruncate
  CreateNew
} derive(Eq, Debug)

///|
fn CreateMode::to_open_flags(self : CreateMode) -> OpenFlags {
  match self {
    OpenExisting => OpenFlags::new()
    TruncateExisting => OpenFlags::new() |> OpenFlags::set(Trunc)
    OpenOrCreate => OpenFlags::new() |> OpenFlags::set(Create)
    CreateOrTruncate =>
      OpenFlags::new() |> OpenFlags::set(Create) |> OpenFlags::set(Trunc)
    CreateNew =>
      OpenFlags::new() |> OpenFlags::set(Create) |> OpenFlags::set(Excl)
  }
}

///|
struct PreStat_dir {
  pr_name_len : Size
} derive(Eq, Debug)

///|
enum PreStat {
  Dir(PreStat_dir)
} derive(Eq, Debug)
