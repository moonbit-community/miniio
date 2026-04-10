///|
fn main {
  try {
    @miniwasi.stdout.write_text("args:\n")
    for arg in @miniwasi.args_get() {
      @miniwasi.stdout.write_text("- \{arg}\n")
    }

    @miniwasi.stdout.write_text("env:\n")
    for env in @miniwasi.environ_get() {
      let (key, value) = env
      @miniwasi.stdout.write_text("- \{key}=\{value}\n")
    }
  } catch {
    e => try! @miniwasi.stderr.write_text("demo failed: \{e}\n")
  }
}
