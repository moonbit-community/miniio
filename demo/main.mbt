///|
fn main {
  try {
    @minimum.stdout.write_text("args:\n")
    for arg in @minimum.args_get() {
      @minimum.stdout.write_text("- \{arg}\n")
    }

    @minimum.stdout.write_text("env:\n")
    for env in @minimum.environ_get() {
      let (key, value) = env
      @minimum.stdout.write_text("- \{key}=\{value}\n")
    }
  } catch {
    e => try! @minimum.stderr.write_text("demo failed: \{e}\n")
  }
}
