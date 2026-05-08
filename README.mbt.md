# miniwasi examples

## Copy text between files

```moonbit check
///|
test "copy text between files" {
  let dir = "readme_copy_text"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)
  defer ignore(try? @miniwasi.rmdir(dir, recursive=true))

  @miniwasi.write_text_file(dir + "/input.txt", "hello\n")
  @miniwasi.copy_file(dir + "/input.txt", dir + "/output.txt")
  inspect(@miniwasi.read_text_file(dir + "/output.txt"), content="hello\n")
}
```

## Append a log file

```moonbit check
///|
test "append log file" {
  let dir = "readme_append_log"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)
  defer ignore(try? @miniwasi.rmdir(dir, recursive=true))

  let path = dir + "/tool.log"
  @miniwasi.write_text_file(path, "start\n")
  @miniwasi.write_text_file(path, "done\n", append=true)
  inspect(@miniwasi.read_text_file(path), content="start\ndone\n")
}
```

## Read and write JSON

```moonbit check
///|
test "read and write json" {
  let dir = "readme_json"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)
  defer ignore(try? @miniwasi.rmdir(dir, recursive=true))

  let path = dir + "/manifest.json"
  @miniwasi.write_json_file(path, { "name": "miniwasi", "portable": true })
  inspect(
    @miniwasi.read_json_file(path).stringify(),
    content="{\"name\":\"miniwasi\",\"portable\":true}",
  )
}
```

## List and remove directories

```moonbit check
///|
test "list and remove directories" {
  let dir = "readme_list_remove"
  @miniwasi.remove(dir) catch {
    Noent => ()
    Notempty => @miniwasi.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniwasi.mkdir(dir)

  @miniwasi.write_text_file(dir + "/b.txt", "b")
  @miniwasi.write_text_file(dir + "/a.txt", "a")
  inspect(@miniwasi.readdir(dir, sort=true), content="[\"a.txt\", \"b.txt\"]")

  @miniwasi.rmdir(dir, recursive=true)
  inspect(@miniwasi.exists(dir), content="false")
}
```
