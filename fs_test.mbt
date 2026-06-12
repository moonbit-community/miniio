// Copyright 2026 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

///|
test "write_file supports create append and truncate" {
  let dir = "miniio_test_dir_write_file"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer (@miniio.rmdir(dir, recursive=true) catch { _ => () })

  let path = dir + "/sample.txt"
  @miniio.write_file(path, b"hello")
  inspect(@miniio.read_file(path).text(), content="hello")

  @miniio.write_file(path, b" moonbit", append=true)
  inspect(@miniio.read_file(path).text(), content="hello moonbit")

  @miniio.write_file(path, b"reset", create_mode=TruncateExisting)
  inspect(@miniio.read_file(path).text(), content="reset")
}

///|
test "create modes distinguish existing files" {
  let dir = "miniio_test_dir_create_mode"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer (@miniio.rmdir(dir, recursive=true) catch { _ => () })

  let path = dir + "/sample.txt"
  @miniio.write_text_file(path, "first", create_mode=CreateNew)
  inspect(@miniio.read_text_file(path), content="first")

  try @miniio.write_text_file(path, "second", create_mode=CreateNew) catch {
    e => debug_inspect(e, content="Exist")
  } noraise {
    _ => abort("expected CreateNew to reject an existing file")
  }

  @miniio.write_text_file(path, "second", create_mode=CreateOrTruncate)
  inspect(@miniio.read_text_file(path), content="second")
}

///|
test "readdir sorts and filters hidden entries" {
  let dir = "miniio_test_dir_readdir"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer (@miniio.rmdir(dir, recursive=true) catch { _ => () })

  @miniio.write_file(dir + "/b.txt", b"b")
  @miniio.write_file(dir + "/a.txt", b"a")
  @miniio.write_file(dir + "/.hidden", b"h")

  debug_inspect(
    @miniio.readdir(dir, include_hidden=false, sort=true),
    content="[\"a.txt\", \"b.txt\"]",
  )
  debug_inspect(
    @miniio.readdir(dir, include_hidden=true, sort=true),
    content="[\"a.txt\", \"b.txt\", \".hidden\"]",
  )
}

///|
test "open follows symlink by default and can reject symlink" {
  let target = "miniio_test_symlink_target.txt"
  let link = "testdata/symlinks/file-link"
  @miniio.remove(target) catch {
    Noent => ()
    e => raise e
  }
  defer (@miniio.remove(target) catch { _ => () })

  @miniio.write_text_file(target, "target")
  try @miniio.read_text_file(link) catch {
    Noent => ()
    e => raise e
  } noraise {
    content =>
      // Windows checkouts may materialize symlink fixtures as plain text files.
      if content == "target" {
        let file = @miniio.create(link)
        file.write_text("created through link")
        file.close()
        inspect(@miniio.read_text_file(target), content="created through link")

        try {
          let file = @miniio.open(link, follow_symlink=false)
          file.close()
          abort("expected opening a symlink with follow_symlink=false to fail")
        } catch {
          _ => ()
        }
      }
  }
}

///|
test "readdir follows directory symlink by default and can reject symlink" {
  let dir = "miniio_test_symlink_target_dir"
  let link = "testdata/symlinks/dir-link"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer (@miniio.rmdir(dir, recursive=true) catch { _ => () })

  @miniio.write_text_file(dir + "/visible.txt", "visible")
  @miniio.write_text_file(dir + "/.hidden", "hidden")

  try @miniio.readdir(link, include_hidden=false, sort=true) catch {
    Noent | Notdir => ()
    e => raise e
  } noraise {
    entries => {
      debug_inspect(entries, content="[\"visible.txt\"]")
      try {
        ignore(@miniio.readdir(link, follow_symlink=false))
        abort("expected reading a symlink with follow_symlink=false to fail")
      } catch {
        _ => ()
      }
    }
  }
}

///|
test "exists and kind classify file and directory" {
  let dir = "miniio_test_dir_kind"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer (@miniio.rmdir(dir, recursive=true) catch { _ => () })

  let path = dir + "/sample.txt"
  @miniio.write_file(path, b"sample")

  assert_true(@miniio.exists(dir))
  assert_true(@miniio.exists(path))
  assert_false(@miniio.exists(dir + "/missing.txt"))

  assert_true(@miniio.kind(dir) is Directory)
  assert_true(@miniio.kind(path) is Regular)

  assert_true(@miniio.is_dir(dir))
  assert_false(@miniio.is_dir(path))
  assert_true(@miniio.is_file(path))
  assert_false(@miniio.is_file(dir))
}

///|
test "read_file returns io data" {
  let dir = "miniio_test_dir_read_file"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer (@miniio.rmdir(dir, recursive=true) catch { _ => () })

  let path = dir + "/sample.txt"
  @miniio.write_text_file(path, "hello")

  let data = @miniio.read_file(path)
  inspect(@miniio.read_text_file(path), content="hello")
  assert_eq(data.binary(), b"hello")
}

///|
test "copy_file copies through reader and writer" {
  let dir = "miniio_test_dir_copy_file"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer (@miniio.rmdir(dir, recursive=true) catch { _ => () })

  let src = dir + "/src.txt"
  let dst = dir + "/dst.txt"
  @miniio.write_text_file(src, "copy me")
  @miniio.copy_file(src, dst)
  inspect(@miniio.read_text_file(dst), content="copy me")
}

///|
test "json file helpers read and write json" {
  let dir = "miniio_test_dir_json_file"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer (@miniio.rmdir(dir, recursive=true) catch { _ => () })

  let path = dir + "/config.json"
  @miniio.write_json_file(path, { "name": "miniio", "ok": true })
  inspect(
    @miniio.read_json_file(path).stringify(),
    content="{\"name\":\"miniio\",\"ok\":true}",
  )
}

///|
test "remove and recursive rmdir delete created paths" {
  let dir = "miniio_test_dir_remove"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer (@miniio.rmdir(dir, recursive=true) catch { _ => () })

  let file_path = dir + "/sample.txt"
  let nested_dir = dir + "/nested"
  @miniio.write_file(file_path, b"sample")
  @miniio.mkdir(nested_dir)
  @miniio.write_file(nested_dir + "/child.txt", b"child")
  @miniio.write_file(nested_dir + "/.hidden", b"hidden")

  @miniio.remove_file(file_path)
  try @miniio.remove(file_path) catch {
    e => debug_inspect(e, content="Noent")
  } noraise {
    _ => abort("expected removing a missing file to fail")
  }

  @miniio.rmdir(dir, recursive=true)
  try @miniio.rmdir(dir) catch {
    e => debug_inspect(e, content="Noent")
  } noraise {
    _ => abort("expected removing a missing directory to fail")
  }
}

///|
test "recursive rmdir does not follow symlink root" {
  let dir = "miniio_test_symlink_rmdir_target_dir"
  let link = "testdata/symlinks/rmdir-dir-link"
  @miniio.remove(dir) catch {
    Noent => ()
    Notempty => @miniio.rmdir(dir, recursive=true)
    e => raise e
  }
  @miniio.mkdir(dir)
  defer (@miniio.rmdir(dir, recursive=true) catch { _ => () })

  @miniio.write_text_file(dir + "/target.txt", "keep")
  try @miniio.readdir(link, include_hidden=false, sort=true) catch {
    Noent | Notdir => ()
    e => raise e
  } noraise {
    _ => {
      try @miniio.rmdir(link, recursive=true) catch {
        _ => ()
      } noraise {
        _ => abort("expected recursive rmdir on a symlink root to fail")
      }
      inspect(@miniio.read_text_file(dir + "/target.txt"), content="keep")
    }
  }
}
