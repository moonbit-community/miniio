---
name: miniio-quick-eval
description: Prototype small MoonBit WASIp1 stdin/stdout filters with moon run -c and moonbit-community/miniio, especially jq-style JSON transforms, without creating a package.
---

# MiniIO Quick Eval

Use this when the user wants a quick one-off MoonBit WASIp1 script with
`moon run -c`, especially for stdin/stdout filters, JSON inspection, or
small miniio API experiments that do not deserve a full package.

## Pattern

- Use MoonBit's single-file import header at the top of the `-c` source.
- Import `moonbit-community/miniio/io` when using reader, writer, or data
  extension methods such as `read_all()`, `write()`, and `.text()`.
- Prefer `stdin.read_all().text()` for UTF-8 stdin text.
- Write normal output to `@miniio.stdout`; write diagnostics to `@miniio.stderr`
  and exit nonzero with `@miniio.exit(1)`.
- Keep these scripts small. If the source grows beyond one screen or needs
  files/assets/tests, create a normal package instead.

## JSON Filter Example

```sh
printf '{"name":"miniio","ok":true}' | moon run -c 'import {
  "moonbit-community/miniio" @miniio,
  "moonbit-community/miniio/io",
  "moonbitlang/core/json" @json,
}

fn main {
  try {
    let input = @miniio.stdin.read_all().text()
    let value = @json.parse(input)
    @miniio.stdout.write_text(value.stringify(indent=2) + "\n")
  } catch {
    e => {
      @miniio.stderr.write_text("jq failed: \{e}\n") catch { _ => () }
      @miniio.exit(1)
    }
  }
}'
```

Expected output:

```json
{
  "name": "miniio",
  "ok": true
}
```

## Validation

For syntax-only examples, test the same shape with a registry-resolvable package
or a temporary local package. For released miniio usage, the command itself is
the validation.
