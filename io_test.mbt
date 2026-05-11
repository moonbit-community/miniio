///|
test "file implements io reader and writer" {
  let dir = "minimum_test_io"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer ignore(try? @miniio.rmdir(dir, recursive=true))

  let path = dir + "/sample.txt"
  let writer = @miniio.create(path)
  writer.write("hello")
  writer.write(", moonbit")
  writer.close()

  let reader = @miniio.open(path)
  let dst = FixedArray::make(4, b'\x00')
  let n = reader.read(dst, max_len=2)
  inspect(n, content="2")
  debug_inspect(reader.read_until(", "), content="Some(\"llo\")")
  inspect(reader.read_all().text(), content="moonbit")
  reader.close()
}

///|
test "write_reader copies file content" {
  let dir = "minimum_test_copy"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer ignore(try? @miniio.rmdir(dir, recursive=true))

  let src_path = dir + "/src.txt"
  let dst_path = dir + "/dst.txt"

  let src_writer = @miniio.create(src_path)
  src_writer.write("copy me")
  src_writer.close()

  let src = @miniio.open(src_path)
  let dst = @miniio.create(dst_path)
  dst.write_reader(src)
  src.close()
  dst.close()

  let copied = @miniio.open(dst_path)
  inspect(copied.read_all().text(), content="copy me")
  copied.close()
}
