# teensy cmake macros 

[![audio-test](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/audio-test.yml/badge.svg)](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/audio-test.yml)
[![basic-test](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/basic-test.yml/badge.svg)](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/basic-test.yml)
[![vector-test](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/vector.yml/badge.svg)](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/vector.yml)
[![eeprom-test](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/eeprom-test.yml/badge.svg)](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/eeprom-test.yml)
[![spi-test](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/spi-test.yml/badge.svg)](https://github.com/newdigate/teensy-cmake-macros/actions/workflows/spi-test.yml)

 minimal dependency cmake toolchain to easily compile your teensy sketches and libraries, and optionally link with c++ std libraries. 
* custom teensy toolchain using ```cmake``` and ```arm-none-eabi-gcc```
* based on [ronj/teensy-cmake-template](https://github.com/ronj/teensy-cmake-template)
* targetting Teensy 4.x, tested on Teensy 4.1 (should be easy to extend for 3.x)
* compiles library code to .a archive files to avoid unnecessary recompiling

 * add a toolchain cmake file `cmake\toolchains\teensy41.cmake`
```cmake
set(TEENSY_VERSION 41 CACHE STRING "Set to the Teensy version corresponding to your board (30 or 31 allowed)" FORCE)
set(CPU_CORE_SPEED 600000000 CACHE STRING "Set to 24000000, 48000000, 72000000 or 96000000 to set CPU core speed" FORCE) # Derived variables
set(CMAKE_EXE_LINKER_FLAGS "--specs=nano.specs" CACHE INTERNAL "")
#teensy compiler options
set(COMPILERPATH "/Applications/ARM/bin/")

add_definitions(-DTEENSY_VERSION=${TEENSY_VERSION})
include(FetchContent)

FetchContent_Declare(teensy_cores
        GIT_REPOSITORY https://github.com/PaulStoffregen/cores
        GIT_TAG        master
)
FetchContent_MakeAvailable(teensy_cores)

FetchContent_Declare(teensy_cmake_macros
        GIT_REPOSITORY https://github.com/newdigate/teensy-cmake-macros
        GIT_TAG        noinstall
)
FetchContent_MakeAvailable(teensy_cmake_macros)
include(${teensy_cmake_macros_SOURCE_DIR}/CMakeLists.txt)
set(BUILD_FOR_TEENSY ON)
```
## TL/DR
<details>
  <summary>install build dependencies (click to expand) </summary>

 * [arm-none-eabi-gcc](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads)
 * [cmake](https://cmake.org/)
 * teensy-cmake-macros
   ```shell
   > git clone https://github.com/newdigate/teensy-cmake-macros.git
   > cd teensy-cmake-macros
   > mkdir cmake-build-debug
   > cd cmake-build-debug
   > cmake ..
   > sudo make install        
   ``` 
</details>

<details>
  <summary>clone runtime dependencies (click to expand) </summary>

  * clone necessary dependencies to a chosen location `${DEPSPATH}`

  ```shell
   > cd /home/nic/midi-smf-reader/deps
   > git clone https://github.com/PaulStoffregen/cores.git
   > git clone https://github.com/PaulStoffregen/Audio.git
   > git clone -b Juse_Use_SdFat https://github.com/PaulStoffregen/SD.git 
   > git clone https://github.com/PaulStoffregen/Wire.git
   > git clone https://github.com/PaulStoffregen/SPI.git
   > git clone https://github.com/PaulStoffregen/SerialFlash.git
   > git clone https://github.com/PaulStoffregen/arm_math.git
   > git clone https://github.com/greiman/SdFat.git
  ```
</details> 


<details>
  <summary>custom cmake toolchain (click to expand) </summary>

  * add a custom cmake toolchain file to your project `cmake/toolchains/teensy41.toolchain.cmake`

  ```cmake 
  set(TEENSY_VERSION 41 CACHE STRING "Set to the Teensy version corresponding to your board (40 or 41 allowed)" FORCE)
  set(CPU_CORE_SPEED 600000000 CACHE STRING "Set to 600000000, 24000000, 48000000, 72000000 or 96000000 to set CPU core speed" FORCE) # Derived variables
  set(COMPILERPATH "/opt/gcc-arm-none-eabi-9-2019-q4-major/bin/") 
  set(DEPSPATH "/home/nic/midi-smf-reader/deps")
  set(COREPATH "${DEPSPATH}/cores/teensy4/")
  find_package(teensy_cmake_macros)
  ``` 

  * update ```DEPSPATH```, ```COMPILERPATH``` and ```COREPATH``` to your dependencies folder, arm-none-eabi-gcc bin folder and path to teensy4 cores

</details>

<details>
  <summary>add CMakeLists.txt (click to expand) </summary>

  * create a ```CMakeLists.txt``` file in the root directory of your project
 
  ```cmake
  cmake_minimum_required(VERSION 3.5)
  project(midi_smf_reader C CXX)
  import_arduino_library(cores ${COREPATH})
  import_arduino_library(SPI ${DEPSPATH}/SPI)
  import_arduino_library(SdFat ${DEPSPATH}/SdFat/src common DigitalIO ExFatLib FatLib FsLib iostream SdCard SpiDriver)
  import_arduino_library(SD ${DEPSPATH}/SD/src)

  # add custom library
  teensy_add_library(my_teensy_library my_teensy_library.cpp)

  teensy_add_executable(my_firmware sketch.ino)
  teensy_target_link_libraries(my_firmware my_teensy_library SD SdFat SPI cores) # order is IMPORTANT because we are garbage collecting symbols --gc-collect

  # if you need to link to std library (using <Vector>, etc) 
  set(CMAKE_EXE_LINKER_FLAGS "--specs=nano.specs" CACHE INTERNAL "")
  target_link_libraries(my_firmware.elf stdc++)
  ```
 
</details>
 
<details>
  <summary>build (click to expand) </summary>
 
  * run from a terminal in your repository root directory 
 
  ```shell
  > mkdir cmake-build-debug
  > cd cmake-build-debug
  > cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE:FILEPATH="../cmake/toolchains/teensy41.toolchain.cmake" 
  > make       
  ```
</details>

## usage 
* ```teensy_add_executable``` ( ```TARGET``` ```files...``` )
  ```cmake 
  teensy_add_executable(myapplication midiread.cpp)
  ``` 
* ```teensy_add_library``` ( ```TARGET``` ```files...``` )
  ```cmake 
  teensy_add_library(mylibrary library1.cpp)
  ``` 
  
* ```import_arduino_library``` ( ```LibraryName``` ```LibraryPath``` ```additionalRelativeSourceFolders```)
  ```cmake 
  import_arduino_library(cores ${COREPATH})
  import_arduino_library(SPI ${DEPSPATH}/SPI)        # SPI@Juse_Use_SdFat
  import_arduino_library(SdFat ${DEPSPATH}/SdFat/src common DigitalIO ExFatLib FatLib FsLib iostream SdCard SpiDriver)
  import_arduino_library(SD ${DEPSPATH}/SD/src)  
  ```
* ```teensy_target_link_libraries``` ( ```TARGET``` ```libraries...```) 
```
  teensy_target_link_libraries(my_firmware mylibrary SD SdFat SPI cores)
```

* link to std library
``` 
   set(CMAKE_EXE_LINKER_FLAGS "--specs=nano.specs" CACHE INTERNAL "")
   target_link_libraries(my_firmware.elf stdc++)
```
 * ```teensy_include_directories``` ( ```paths...```)
 ``` 
   teensy_include_directories(../../src)
 ```

## used in
* [midi-smf-reader](https://github.com/newdigate/midi-smf-reader)
* [teensy-quencer](https://github.com/newdigate/teensy-quencer)
