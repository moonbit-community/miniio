///|
pub(all) enum SeekFrom {
  Start
  Current
  End
} derive(Eq, Debug)

///|
pub(all) enum FileKind {
  Unknown
  Regular
  Directory
  SymLink
  Socket
  BlockDevice
  CharDevice
} derive(Eq, Debug)

///|
fn SeekFrom::to_raw(self : SeekFrom) -> @raw.SeekFrom {
  match self {
    Start => @raw.Start
    Current => @raw.Current
    End => @raw.End
  }
}

///|
pub(all) enum Mode {
  ReadOnly
  WriteOnly
  ReadWrite
} derive(Eq, Debug)

///|
fn Mode::to_raw(self : Mode) -> @raw.Mode {
  match self {
    ReadOnly => @raw.ReadOnly
    WriteOnly => @raw.WriteOnly
    ReadWrite => @raw.ReadWrite
  }
}

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
pub impl Show for Errno with to_string(self) {
  match self {
    Success => "Success"
    TooBig => "TooBig"
    Acces => "Acces"
    Addrinuse => "Addrinuse"
    Addrnotavail => "Addrnotavail"
    Afnosupport => "Afnosupport"
    Again => "Again"
    Already => "Already"
    Badf => "Badf"
    Badmsg => "Badmsg"
    Busy => "Busy"
    Canceled => "Canceled"
    Child => "Child"
    Connaborted => "Connaborted"
    Connrefused => "Connrefused"
    Connreset => "Connreset"
    Deadlock => "Deadlock"
    Destaddrreq => "Destaddrreq"
    Dom => "Dom"
    Dquot => "Dquot"
    Exist => "Exist"
    Fault => "Fault"
    Fbig => "Fbig"
    Hostunreach => "Hostunreach"
    Idrm => "Idrm"
    Ilseq => "Ilseq"
    Inprogress => "Inprogress"
    Intr => "Intr"
    Inval => "Inval"
    IO => "IO"
    Isconn => "Isconn"
    Isdir => "Isdir"
    Loop => "Loop"
    Mfile => "Mfile"
    Mlink => "Mlink"
    Msgsize => "Msgsize"
    Multihop => "Multihop"
    Nametoolong => "Nametoolong"
    Netdown => "Netdown"
    Netreset => "Netreset"
    Netunreach => "Netunreach"
    Nfile => "Nfile"
    Nobufs => "Nobufs"
    Nodev => "Nodev"
    Noent => "Noent"
    Noexec => "Noexec"
    Nolck => "Nolck"
    Nolink => "Nolink"
    Nomem => "Nomem"
    Nomsg => "Nomsg"
    Noprotoopt => "Noprotoopt"
    Nospc => "Nospc"
    Nosys => "Nosys"
    Notconn => "Notconn"
    Notdir => "Notdir"
    Notempty => "Notempty"
    Notrecoverable => "Notrecoverable"
    Notsock => "Notsock"
    Notsup => "Notsup"
    Notty => "Notty"
    Nxio => "Nxio"
    Overflow => "Overflow"
    Ownerdead => "Ownerdead"
    Perm => "Perm"
    Pipe => "Pipe"
    Proto => "Proto"
    Protonosupport => "Protonosupport"
    Prototype => "Prototype"
    Range => "Range"
    Rofs => "Rofs"
    Spipe => "Spipe"
    Srch => "Srch"
    Stale => "Stale"
    Timedout => "Timedout"
    Txtbsy => "Txtbsy"
    Xdev => "Xdev"
    Notcapable => "Notcapable"
  }
}

///|
pub impl Show for Errno with output(self, logger) {
  logger.write_string(self.to_string())
}

///|
fn Errno::from_raw(errno : @raw.Errno) -> Errno {
  match errno {
    @raw.Success => Success
    @raw.TooBig => TooBig
    @raw.Acces => Acces
    @raw.Addrinuse => Addrinuse
    @raw.Addrnotavail => Addrnotavail
    @raw.Afnosupport => Afnosupport
    @raw.Again => Again
    @raw.Already => Already
    @raw.Badf => Badf
    @raw.Badmsg => Badmsg
    @raw.Busy => Busy
    @raw.Canceled => Canceled
    @raw.Child => Child
    @raw.Connaborted => Connaborted
    @raw.Connrefused => Connrefused
    @raw.Connreset => Connreset
    @raw.Deadlock => Deadlock
    @raw.Destaddrreq => Destaddrreq
    @raw.Dom => Dom
    @raw.Dquot => Dquot
    @raw.Exist => Exist
    @raw.Fault => Fault
    @raw.Fbig => Fbig
    @raw.Hostunreach => Hostunreach
    @raw.Idrm => Idrm
    @raw.Ilseq => Ilseq
    @raw.Inprogress => Inprogress
    @raw.Intr => Intr
    @raw.Inval => Inval
    @raw.IO => IO
    @raw.Isconn => Isconn
    @raw.Isdir => Isdir
    @raw.Loop => Loop
    @raw.Mfile => Mfile
    @raw.Mlink => Mlink
    @raw.Msgsize => Msgsize
    @raw.Multihop => Multihop
    @raw.Nametoolong => Nametoolong
    @raw.Netdown => Netdown
    @raw.Netreset => Netreset
    @raw.Netunreach => Netunreach
    @raw.Nfile => Nfile
    @raw.Nobufs => Nobufs
    @raw.Nodev => Nodev
    @raw.Noent => Noent
    @raw.Noexec => Noexec
    @raw.Nolck => Nolck
    @raw.Nolink => Nolink
    @raw.Nomem => Nomem
    @raw.Nomsg => Nomsg
    @raw.Noprotoopt => Noprotoopt
    @raw.Nospc => Nospc
    @raw.Nosys => Nosys
    @raw.Notconn => Notconn
    @raw.Notdir => Notdir
    @raw.Notempty => Notempty
    @raw.Notrecoverable => Notrecoverable
    @raw.Notsock => Notsock
    @raw.Notsup => Notsup
    @raw.Notty => Notty
    @raw.Nxio => Nxio
    @raw.Overflow => Overflow
    @raw.Ownerdead => Ownerdead
    @raw.Perm => Perm
    @raw.Pipe => Pipe
    @raw.Proto => Proto
    @raw.Protonosupport => Protonosupport
    @raw.Prototype => Prototype
    @raw.Range => Range
    @raw.Rofs => Rofs
    @raw.Spipe => Spipe
    @raw.Srch => Srch
    @raw.Stale => Stale
    @raw.Timedout => Timedout
    @raw.Txtbsy => Txtbsy
    @raw.Xdev => Xdev
    @raw.Notcapable => Notcapable
  }
}

///|
struct File {
  raw : @raw.File
  read_buf : @io.ReaderBuffer
}

///|
pub let stdin : File = { raw: @raw.stdin, read_buf: @io.ReaderBuffer::new() }

///|
pub let stdout : File = { raw: @raw.stdout, read_buf: @io.ReaderBuffer::new() }

///|
pub let stderr : File = { raw: @raw.stderr, read_buf: @io.ReaderBuffer::new() }
