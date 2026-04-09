///|
test "file implements io reader and writer" {
  let dir = "minimum_test_io"
  ignore(try? @minimum.rmdir(dir, recursive=true))
  ignore(try? @minimum.remove(dir))
  @minimum.mkdir(dir)
  defer ignore(try? @minimum.rmdir(dir, recursive=true))

  let path = dir + "/sample.txt"
  let writer = @minimum.create(path)
  writer.write_sync("hello")
  writer.write_sync(", moonbit")
  writer.close()

  let reader = @minimum.open(path)
  defer ignore(try? reader.close())

  let dst = FixedArray::make(4, b'\x00')
  let n = reader.read_sync(dst, max_len=2)
  inspect(n, content="2")
  inspect(reader.read_until_sync(", "), content="Some(\"llo\")")
  inspect(reader.read_all_sync().text(), content="moonbit")
}

///|
test "write_reader_sync copies file content" {
  let dir = "minimum_test_copy"
  ignore(try? @minimum.rmdir(dir, recursive=true))
  ignore(try? @minimum.remove(dir))
  @minimum.mkdir(dir)
  defer ignore(try? @minimum.rmdir(dir, recursive=true))

  let src_path = dir + "/src.txt"
  let dst_path = dir + "/dst.txt"

  let src_writer = @minimum.create(src_path)
  src_writer.write_sync("copy me")
  src_writer.close()

  let src = @minimum.open(src_path)
  defer ignore(try? src.close())
  let dst = @minimum.create(dst_path)
  dst.write_reader_sync(src)
  dst.close()

  let copied = @minimum.open(dst_path)
  defer ignore(try? copied.close())
  inspect(copied.read_all_sync().text(), content="copy me")
}
