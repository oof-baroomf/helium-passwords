# helium-passwords

Password manager and autofill restoration overlay for
[Helium Browser](https://github.com/imputnet/helium).

This is no longer a Linux packaging fork. The repo only keeps the password
patches plus a small wrapper that clones the official Helium platform repo,
injects the overlay, removes Helium's upstream password-disable patch, and runs
that platform's native build.

## Targets

The GitHub Actions build matrix covers the official desktop OS/architecture
set:

| OS | Architectures |
| --- | --- |
| Linux | `x86_64`, `arm64` |
| macOS | `x86_64`, `arm64` |
| Windows | `x86_64`, `arm64` |

## Local Build

Builds must run on the matching host OS. Chromium builds are large, so expect a
long run and significant disk usage.

```bash
bash scripts/build.sh linux x86_64
bash scripts/build.sh linux arm64
bash scripts/build.sh macos x86_64
bash scripts/build.sh macos arm64
bash scripts/build.sh windows x86_64
bash scripts/build.sh windows arm64
```

The wrapper clones platform repos under `build/platforms/` by default. Override
repo URLs, clone ref, or the work directory in `helium-passwords.conf` or by
exporting the same variables before running a script.

## Patch Flow

`patches/series` is the canonical overlay list. During platform preparation,
each listed patch is copied into the platform repo as `patches/helium/passwords/`
and appended to that platform's `patches/series`.

The wrapper also removes `helium/hop/disable-password-manager.patch` from the
cloned `helium-chromium` submodule before the platform build applies patches.

## License

All code, patches, modified portions of imported code or patches, and any other
content that is unique to this repo is licensed under GPL-3.0. See
[LICENSE](LICENSE). Imported content keeps its original license.
