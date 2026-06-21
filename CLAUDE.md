# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A minimal CMake toolchain + macro package for cross-compiling Teensy 4.x (4.0/4.1) firmware and libraries with `arm-none-eabi-gcc`, without the Arduino IDE. It targets Teensy 4.1 (tested) and the NXP **i.MX RT1060-EVKB** evaluation board (`TEENSY_VERSION 42`), and can be extended for 3.x. Library code is compiled to `.a` archives to avoid unnecessary recompilation. Based on [ronj/teensy-cmake-template](https://github.com/ronj/teensy-cmake-template).

**The entire product is one file: `CMakeLists.include.txt`.** Everything else (`cmake/`, `tests/`) exists to configure or exercise it. When changing macro behavior, you are almost always editing `CMakeLists.include.txt`.

**Requires CMake ≥ 3.24** — `teensy_target_link_libraries` uses the `$<LINK_GROUP>` generator expression.

## Boards

`TEENSY_VERSION` (set in the consumer toolchain file) selects the target board:

- `40` / `41` — Teensy 4.0 / 4.1 — `-DARDUINO_TEENSY40` / `-DARDUINO_TEENSY41`, linker script `imxrt1062.ld` / `imxrt1062_t41.ld`.
- `42` — NXP **i.MX RT1060-EVKB** evaluation board — `-DARDUINO_MIMXRT1060_EVKB`, linker script `imxrt1060_evkb.ld`, boots from QSPI flash (entry `0x60001000`). Its pin tables and linker script live in the `newdigate/teensy-cores` fork.

All three are the same `__IMXRT1062__` MCU (Cortex-M7, hard-float `fpv5-d16`); the board-specific flags are assembled in `teensy_set_dynamic_properties()`.

## Architecture

There is no installer and no build step for the package itself — `CMakeLists.include.txt` is consumed directly. There is no root `CMakeLists.txt`, no `find_package`, and nothing to `make install`.

1. **Consumer projects** (everything under `tests/`) pull the macros in with `FetchContent`, then `include()` the file:
   ```cmake
   include(FetchContent)
   FetchContent_Declare(teensy_cmake_macros
       GIT_REPOSITORY https://github.com/newdigate/teensy-cmake-macros
       GIT_TAG        main)
   FetchContent_MakeAvailable(teensy_cmake_macros)
   include(${teensy_cmake_macros_SOURCE_DIR}/CMakeLists.include.txt)
   ```
   They then call the macros from their own `CMakeLists.txt`, configured with a Teensy toolchain file.
2. **The macros file fetches the Teensy 4 core itself.** On `include()` it `FetchContent`s `newdigate/teensy-cores` (a fork of `PaulStoffregen/cores` that adds the RT1060-EVKB board) and defaults `COREPATH` to `${teensy_cores_SOURCE_DIR}/teensy4/`. Consumers do not have to clone the core. Individual Arduino libraries are fetched per-library (see `import_arduino_library_git`).

**Critical workflow consequence:** consumers pin `GIT_TAG main`, so they fetch the macros from GitHub, *not* from your local working tree. To test local edits to `CMakeLists.include.txt` against a consumer build, redirect FetchContent at your checkout:
```shell
cmake .. -DFETCHCONTENT_SOURCE_DIR_TEENSY_CMAKE_MACROS=/path/to/teensy-cmake-macros
```
Otherwise your changes are only seen after they are pushed to `main`.

### The macros (all defined in `CMakeLists.include.txt`)

- `teensy_set_dynamic_properties()` — builds the per-language compile flags and link flags from `TEENSY_VERSION` (40, 41, or 42), `CPU_CORE_SPEED`, `COMPILERPATH`, `COREPATH` and hangs them on a single `teensy_flags` **INTERFACE** target (compile options via `$<COMPILE_LANGUAGE:…>` genexprs, include dirs via `target_include_directories`) that every `teensy_add_*`/imported library links — so flags propagate as CMake usage requirements instead of being stamped onto each source. Runs once per configure; the guard is just `if(NOT TARGET teensy_flags)`, which self-resets each configure (no cache var or global property that a half-done run could poison). FATAL if `CPU_CORE_SPEED` or `COMPILERPATH` is unset, or `TEENSY_VERSION` is not 40/41/42. Hardcodes `TEENSYDUINO=159`, `ARDUINO=10607`, `-std=gnu++17`, `-fno-exceptions -fno-rtti`. Called automatically by `teensy_add_executable`/`teensy_add_library`.
- `import_teensy_cores()` — globs the core `.c/.cpp` under `COREPATH` and returns them in `TEENSY_SOURCES` (they pick up the flags from `teensy_flags` once a library folds them in). Optional: `teensy_add_library` folds `TEENSY_SOURCES` into every library, so calling this compiles the core into your libs instead of linking it as a separate `cores.o`. The tests don't use it — they build the core as a library via `import_arduino_library(cores ...)`.
- `teensy_add_executable(TARGET srcs...)` — creates target **`TARGET.elf`** plus a `TARGET_hex` custom target that runs `arm-none-eabi-objcopy` to emit `TARGET.hex`. Accepts `.ino`/`.cpp` (compiled as C++) and `.c`. Only the listed sources go into the elf; the core and libraries are linked in separately via `teensy_target_link_libraries`.
- `teensy_add_library(TARGET srcs...)` — creates a STATIC library target named **`TARGET.o`** (the `.o` suffix is part of the CMake target name, not a file). A library with no sources (header-only) is skipped with a warning.
- `import_arduino_library(NAME ROOT [subdirs...])` — globs `.cpp/.c/.S` from a **local** `ROOT` (and each listed subdir), adds include dirs, and calls `teensy_add_library(NAME ...)`. Idempotent (tracked in `Arduino_libraries_List`). Missing `ROOT` is a warning (ignored); a missing named subdir is a fatal error.
- `import_arduino_library_git(NAME URL BRANCH PATH [subdirs...])` — fetches a library from a git URL via **CPM.cmake** (`CPMAddPackage(... DOWNLOAD_ONLY YES)`; CPM is bootstrapped lazily on first use — pinned version + SHA256 — so projects that only call `import_arduino_library` never download it), then imports it via `import_arduino_library` from `<fetched>/PATH` (e.g. `PATH=src`, or `""` for the repo root). Set the `CPM_SOURCE_CACHE` env var to clone each `(repo, branch)` once and share it across all projects/build dirs (otherwise CPM clones per build dir, like plain FetchContent). This is how the tests pull in `SPI`, `SD`, `Audio`, etc.
- `teensy_target_link_libraries(TARGET libs...)` — links each `lib.o` into `TARGET.elf`, **wrapped in a linker group** (`$<LINK_GROUP:RESCAN,...>` → `--start-group/--end-group`). The linker re-scans the group until every cross-reference resolves, so **the order you list libraries does not matter** (circular deps included). The `RESCAN` feature is defined in this file because CMake does not predefine it for `CMAKE_SYSTEM_NAME Generic`.
- `teensy_include_directories(paths...)`.
- `idf_component_register()` — a no-op stub so the file can be `include()`d from an ESP-IDF component context without error.

Compile flags and include dirs are carried on a single `teensy_flags` `INTERFACE` library that every executable and library links; CMake propagates them as usage requirements (no global `-I` string, no per-source `COMPILE_FLAGS` stamping). Link flags are the exception — they stay exe-targeted (stored on a `teensy_flags` property, applied in `teensy_add_executable`) so they cannot propagate transitively and duplicate the linker script. `target_link_libraries` is kept in the **plain** (non-keyword) form so consumer code like `target_link_libraries(app.elf stdc++)` still composes.

## Required variables (set in the consumer toolchain file)

`TEENSY_VERSION` (40, 41, or 42 for the RT1060-EVKB), `CPU_CORE_SPEED`, `COMPILERPATH` (arm-none-eabi bin dir, trailing slash). `COREPATH` defaults to the fetched core and only needs overriding if you supply your own. Consumers normally write their own toolchain file (see the README quick-start); the repo ships one example:

- `tests/teensy41.toolchain.cmake` — `TEENSY_VERSION 41`, `--specs=nosys.specs`, `COMPILERPATH` hardcoded to the CI path `/opt/gcc-arm-none-eabi-9-2019-q4-major/bin/` (a macOS `/Applications/ARM/bin/` alternative is commented out). Edit `COMPILERPATH` for your machine.

## Build commands

Nothing to install. Build a test/consumer project by configuring it with a Teensy toolchain file, then `make`. Example (`tests/spi`):

```shell
cd tests/spi
mkdir -p cmake-build-debug && cd cmake-build-debug
cmake -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=../../teensy41.toolchain.cmake ..
make
```

To exercise local macro edits, add `-DFETCHCONTENT_SOURCE_DIR_TEENSY_CMAKE_MACROS=<repo-root>` to the `cmake` line (see Architecture). A "build passing" means it compiles and links — there is no on-device runtime check.

## Tests & CI

Each subdir of `tests/` (`basic`, `spi`, `audio`, `eeprom`, `vector`) is an independent consumer project with its own `CMakeLists.txt`, exercising a different dependency set; each fetches the macros, the core, and its libraries via `FetchContent`.

GitHub Actions has one workflow per test in `.github/workflows/` (`audio-test`, `basic-test`, `eeprom-test`, `spi-test`, `vector`). Each checks out the repo, downloads the ARM 9-2019-q4 toolchain to `/opt`, then configures+builds that one test with a toolchain file. Dependencies come from `FetchContent`, not a manual `deps/` clone.

`tests/vector` is the reference for linking the C++ std library: set `CMAKE_EXE_LINKER_FLAGS "--specs=nano.specs"` and `target_link_libraries(<target>.elf stdc++)` (note the `.elf` suffix and raw `target_link_libraries`, not the `teensy_` wrapper).

## Runtime dependencies

Consumer firmware needs the Teensy 4 core (fetched automatically) plus whatever PaulStoffregen Arduino libraries the sketch uses — pulled in per-library with `import_arduino_library_git` (from a git URL) or `import_arduino_library` (from a local path). Commonly: `Audio`, `SD` (branch `Juse_Use_SdFat`), `Wire`, `SPI`, `SerialFlash`, `arm_math`, `greiman/SdFat`. See each test's `CMakeLists.txt` for the exact repo/branch it uses. These git libraries are fetched via CPM.cmake; set the `CPM_SOURCE_CACHE` env var (e.g. `~/.cache/CPM`) to share one clone of each `(repo, branch)` across all projects and build dirs instead of re-cloning per build dir.
