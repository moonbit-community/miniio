# Lottie Manifest Example

This workspace member uses `cg-zhou/moon_lottie@0.3.0` and
`moonbit-community/miniwasi` through versioned dependencies. It does not use a
local path dependency.

The example intentionally uses the `moon_lottie` parser package, not the
renderer package. `moon_lottie@0.3.0` is `wasm-gc`-preferred, and its renderer
package does not compile on this repo's supported plain `wasm` backend.

```bash
moon run example/lottie_manifest --target wasm animation.json manifest.txt
```
