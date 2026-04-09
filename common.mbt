///|
fn[X] wrap(f : () -> X raise @raw.Errno) -> X raise Errno {
  f() catch {
    e => raise Errno::from_raw(e)
  }
}
