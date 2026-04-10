///|
test "file implements io reader and writer" {
  let dir = "minimum_test_io"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)
  defer ignore(try? @miniwasi.rmdir(dir, recursive=true))

  let path = dir + "/sample.txt"
  let writer = @miniwasi.create(path)
  writer.write_sync("hello")
  writer.write_sync(", moonbit")
  writer.close()

  let reader = @miniwasi.open(path)
  let dst = FixedArray::make(4, b'\x00')
  let n = reader.read_sync(dst, max_len=2)
  inspect(n, content="2")
  inspect(reader.read_until_sync(", "), content="Some(\"llo\")")
  inspect(reader.read_all_sync().text(), content="moonbit")
  reader.close()
}

///|
test "write_reader_sync copies file content" {
  let dir = "minimum_test_copy"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)
  defer ignore(try? @miniwasi.rmdir(dir, recursive=true))

  let src_path = dir + "/src.txt"
  let dst_path = dir + "/dst.txt"

  let src_writer = @miniwasi.create(src_path)
  src_writer.write_sync("copy me")
  src_writer.close()

  let src = @miniwasi.open(src_path)
  let dst = @miniwasi.create(dst_path)
  dst.write_reader_sync(src)
  src.close()
  dst.close()

  let copied = @miniwasi.open(dst_path)
  inspect(copied.read_all_sync().text(), content="copy me")
  copied.close()
}
