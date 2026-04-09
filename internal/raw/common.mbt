///|
fn check_errno(code : UInt) -> Unit raise Errno {
  let errno = Errno::from_value(code).unwrap()
  if errno != Success {
    raise errno
  }
}
