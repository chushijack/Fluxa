# Licenses

Fluxa is based on [FlClash](https://github.com/chen08209/FlClash) and is distributed under the same **GNU GPL v3.0** as the root [LICENSE](../LICENSE).

## Files in this directory

| File | Description |
|------|-------------|
| [FLCLASH.md](FLCLASH.md) | Upstream FlClash / GPL relationship |
| [MIHOMO.md](MIHOMO.md) | `core/Clash.Meta` submodule (mihomo) |
| `third_party_pub_licenses.txt` | Optional: output of `flutter pub licenses` (generate locally; not committed until reviewed) |

## Mihomo (Clash.Meta)

The proxy core is vendored as the Git submodule `core/Clash.Meta` (fork branch `FlClash`). After `git submodule update --init`, read the license file inside that submodule and add a short notice here if required for releases.

## In-repo plugins

- `plugins/code_forge` — MIT (see `plugins/code_forge/LICENSE`).
- Other `plugins/*` — check each `LICENSE` before release; some placeholders may need to be completed.

Do not guess licenses; verify each dependency before distribution.
