///|
fn main {
  try {
    @miniio.stdout.write_text("args:\n")
    for arg in @miniio.args_get() {
      @miniio.stdout.write_text("- \{arg}\n")
    }

    @miniio.stdout.write_text("env:\n")
    for env in @miniio.environ_get() {
      let (key, value) = env
      @miniio.stdout.write_text("- \{key}=\{value}\n")
    }
  } catch {
    e => try! @miniio.stderr.write_text("demo failed: \{e}\n")
  }
}
