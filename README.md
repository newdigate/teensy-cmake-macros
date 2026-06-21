# teensy cmake macros

[![audio-test](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/audio-test.yml/badge.svg)](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/audio-test.yml)
[![basic-test](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/basic-test.yml/badge.svg)](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/basic-test.yml)
[![vector-test](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/vector.yml/badge.svg)](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/vector.yml)
[![eeprom-test](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/eeprom-test.yml/badge.svg)](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/eeprom-test.yml)
[![spi-test](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/spi-test.yml/badge.svg)](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/spi-test.yml)

A minimal CMake toolchain + macros for cross-compiling **Teensy 4.x** firmware and libraries with `arm-none-eabi-gcc` — no Arduino IDE required.

- builds with `cmake` + `arm-none-eabi-gcc`
- Teensy 4.0 / 4.1 (tested on 4.1) and the NXP **RT1060-EVKB** dev board; should be easy to extend to 3.x
- pulls Arduino libraries straight from git, with an optional shared cache (see [Dependency caching](#dependency-caching))
- compiles library code to `.a` archives to avoid unnecessary recompiles, and can link the C++ std library
- based on [ronj/teensy-cmake-template](https://github.com/ronj/teensy-cmake-template)

## Requirements

- [arm-none-eabi-gcc](https://developer.arm.com/downloads/-/gnu-rm)
- [CMake](https://cmake.org/) ≥ 3.24 — the macros use the `$<LINK_GROUP>` generator expression

## Quick start

### 1. Toolchain file

Create `cmake/toolchain/teensy41.cmake` and point `COMPILERPATH` at your `arm-none-eabi-gcc` `bin/` folder:

```cmake
set(TEENSY_VERSION 41 CACHE STRING "Teensy version: 40, 41, or 42 (RT1060-EVKB)" FORCE)
set(CPU_CORE_SPEED 600000000 CACHE STRING "CPU core speed in Hz" FORCE)
set(CMAKE_EXE_LINKER_FLAGS "--specs=nano.specs" CACHE INTERNAL "")   # needed if you link the C++ std lib
set(COMPILERPATH "/Applications/ARM_10/bin/")                        # <-- edit for your machine

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
set(CMAKE_C_COMPILER   ${COMPILERPATH}arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER ${COMPILERPATH}arm-none-eabi-g++)
set(CMAKE_CXX_LINK_EXECUTABLE "${CMAKE_C_COMPILER} <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
```

### 2. `CMakeLists.txt`

The macros — and the Teensy 4 core — are pulled in with `FetchContent`; you don't clone anything by hand:

```cmake
cmake_minimum_required(VERSION 3.24)
project(my_firmware C CXX)

include(FetchContent)
FetchContent_Declare(teensy_cmake_macros
        GIT_REPOSITORY https://github.com/newdigate/teensy-cmake-macros
        GIT_TAG        main)
FetchContent_MakeAvailable(teensy_cmake_macros)
include(${teensy_cmake_macros_SOURCE_DIR}/CMakeLists.include.txt)

# the Teensy 4 core (fetched automatically into ${teensy_cores_SOURCE_DIR})
import_arduino_library(cores ${teensy_cores_SOURCE_DIR}/teensy4 avr util)

# Arduino libraries, straight from git (see "Dependency caching" below)
import_arduino_library_git(SPI https://github.com/PaulStoffregen/SPI.git master "")

# your own code
teensy_add_library(my_lib my_lib.cpp)                       # optional
teensy_add_executable(my_firmware sketch.ino)               # .ino, .cpp and .c all work
teensy_target_link_libraries(my_firmware my_lib SPI cores)  # link order does not matter
```

### 3. Build

```shell
mkdir build && cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../cmake/toolchain/teensy41.cmake
make
```

You get `my_firmware.elf` and `my_firmware.hex`, ready to flash. A passing build means it compiles and links — there is no on-device check.

## Macros

| macro | what it does |
|---|---|
| `teensy_add_executable(TARGET srcs…)` | builds `TARGET.elf` and a `TARGET.hex`. Sources may be `.ino`/`.cpp` (compiled as C++) or `.c`. |
| `teensy_add_library(TARGET srcs…)` | builds a static library, target named `TARGET.o`. |
| `import_arduino_library(NAME ROOT [subdirs…])` | adds a library from a **local** path and builds it. |
| `import_arduino_library_git(NAME URL BRANCH PATH [subdirs…])` | fetches a library from **git** (via CPM) and builds it. `PATH` is the source subdir (`""` = repo root); extra `subdirs` are added as well. |
| `teensy_target_link_libraries(TARGET libs…)` | links libraries into `TARGET.elf`. **Order does not matter** — the libraries are wrapped in a linker group that re-scans until every cross-reference resolves (circular deps included). |
| `teensy_include_directories(paths…)` | adds extra include directories. |

<details>
<summary>Example: common PaulStoffregen libraries (repo / branch / source path)</summary>

```cmake
import_arduino_library_git(SPI         https://github.com/PaulStoffregen/SPI.git         master "")
import_arduino_library_git(SdFat       https://github.com/PaulStoffregen/SdFat.git       master "src" common DigitalIO ExFatLib FatLib FsLib iostream SdCard SpiDriver)
import_arduino_library_git(SD          https://github.com/PaulStoffregen/SD.git          Juse_Use_SdFat src)
import_arduino_library_git(Encoder     https://github.com/PaulStoffregen/Encoder.git     master "")
import_arduino_library_git(Bounce2     https://github.com/PaulStoffregen/Bounce2.git     master src)
import_arduino_library_git(SerialFlash https://github.com/PaulStoffregen/SerialFlash.git master "" util)
import_arduino_library_git(Wire        https://github.com/PaulStoffregen/Wire.git        master "" utility)
import_arduino_library_git(arm_math    https://github.com/PaulStoffregen/arm_math.git    master src)
import_arduino_library_git(TeensyGFX   https://github.com/newdigate/teensy-gfx.git       main src)
```
</details>

## Dependency caching

Git libraries (`import_arduino_library_git`) are fetched with [CPM.cmake](https://github.com/cpm-cmake/CPM.cmake), bootstrapped automatically the first time you use one. By default each build directory clones its own copy. Set the `CPM_SOURCE_CACHE` environment variable to clone each `(repo, branch)` **once** and share it across every project and build directory:

```shell
export CPM_SOURCE_CACHE=$HOME/.cache/CPM
```

The cache is keyed by repo + branch, so different branches of the same library coexist without clobbering each other, while identical pins are downloaded only once. Projects that use only `import_arduino_library` (local paths) never download CPM.

## Linking the C++ standard library

If your sketch uses `<vector>`, `<string>`, and friends:

```cmake
set(CMAKE_EXE_LINKER_FLAGS "--specs=nano.specs" CACHE INTERNAL "")
target_link_libraries(my_firmware.elf stdc++)
```

Note the `.elf` suffix and the plain `target_link_libraries` (not the `teensy_` wrapper).

## Used in

* [midi-smf-reader](https://github.com/newdigate/midi-smf-reader)
* [teensy-quencer](https://github.com/newdigate/teensy-quencer)
