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

# Usage
* add a toolchain cmake file `cmake\toolchains\teensy41.cmake`
  * update ```COMPILERPATH``` to [arm-none-eabi-gcc](https://developer.arm.com/downloads/-/gnu-rm/10-3-2021-10) bin folder
   ```cmake
   set(TEENSY_VERSION 41 CACHE STRING "Set to the Teensy version corresponding to your board (30 or 31 allowed)" FORCE)
   set(CPU_CORE_SPEED 600000000 CACHE STRING "Set to 24000000, 48000000, 72000000 or 96000000 to set CPU core speed" FORCE) # Derived variables
   set(CMAKE_EXE_LINKER_FLAGS "--specs=nosys.specs" CACHE INTERNAL "")
   # set(CMAKE_EXE_LINKER_FLAGS "--specs=nano.specs" CACHE INTERNAL "") # if you plan on using std 

   #teensy compiler options
   set(COMPILERPATH "/Applications/ARM/bin/")
   
   set(BUILD_FOR_TEENSY ON)
   set(CMAKE_SYSTEM_NAME Generic)
   set(CMAKE_SYSTEM_PROCESSOR arm)
   set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
   set(CMAKE_C_COMPILER ${COMPILERPATH}arm-none-eabi-gcc)
   set(CMAKE_CXX_COMPILER ${COMPILERPATH}arm-none-eabi-g++)
   set(CMAKE_CXX_LINK_EXECUTABLE "${CMAKE_C_COMPILER} <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
   ``` 
  * add include in your CMakeLists.txt file
    ```cmake
    include(FetchContent)
    FetchContent_Declare(teensy_cmake_macros
        GIT_REPOSITORY https://github.com/newdigate/teensy-cmake-macros
        GIT_TAG        main
    )
    FetchContent_MakeAvailable(teensy_cmake_macros)
    include(${teensy_cmake_macros_SOURCE_DIR}/CMakeLists.include.txt)
    ```
* specify toolchain file in cmake configuration stage
    ```shell
    > cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE:FILEPATH="../cmake/toolchains/teensy41.cmake`
    ```

# install build dependencies

 * [arm-none-eabi-gcc](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-rm/downloads)
 * [cmake](https://cmake.org/)

# add CMakeLists.txt to your project root
  * create a ```CMakeLists.txt``` file in the root directory of your project
  ```cmake
    cmake_minimum_required(VERSION 3.5)
    project(midi_smf_reader C CXX)

    include(FetchContent)
    FetchContent_Declare(teensy_cmake_macros
            GIT_REPOSITORY https://github.com/newdigate/teensy-cmake-macros
            GIT_TAG        main
    )
    FetchContent_MakeAvailable(teensy_cmake_macros)
    include(${teensy_cmake_macros_SOURCE_DIR}/CMakeLists.include.txt)

    import_arduino_library(cores ${teensy_cores_SOURCE_DIR}/teensy4 avr util)
    
    import_arduino_library_git(SPI https://github.com/PaulStoffregen/SPI.git master "")
    import_arduino_library_git(SdFat https://github.com/PaulStoffregen/SdFat.git master "src" common DigitalIO ExFatLib FatLib FsLib iostream SdCard SpiDriver)
    import_arduino_library_git(SD https://github.com/PaulStoffregen/SD.git Juse_Use_SdFat src)
    import_arduino_library_git(Encoder https://github.com/PaulStoffregen/Encoder.git master "")
    import_arduino_library_git(Bounce2 https://github.com/PaulStoffregen/Bounce2.git master src)
    import_arduino_library_git(SerialFlash https://github.com/PaulStoffregen/SerialFlash.git master "" util)
    import_arduino_library_git(Wire https://github.com/PaulStoffregen/Wire.git master "" utility)
    import_arduino_library_git(arm_math https://github.com/PaulStoffregen/arm_math.git master src)
    import_arduino_library_git(TeensyGFX https://github.com/newdigate/teensy-gfx.git noinstall src)

    # add custom library
    teensy_add_library(my_teensy_library my_teensy_library.cpp)

    # add custom executable
    teensy_add_executable(my_firmware sketch.ino)
    teensy_target_link_libraries(my_firmware my_teensy_library SD SdFat SPI cores) # order is IMPORTANT because we are garbage collecting symbols --gc-collect
    
    # if you need to link to std library (using <Vector>, etc) 
    set(CMAKE_EXE_LINKER_FLAGS "--specs=nano.specs" CACHE INTERNAL "")
    target_link_libraries(my_firmware.elf stdc++)
  ```

# build
  * run from a terminal in your repository root directory 
 
  ```shell
  > mkdir cmake-build-debug
  > cd cmake-build-debug
  > cmake .. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE:FILEPATH="../cmake/toolchains/teensy41.toolchain.cmake" 
  > make       
  ```

## detail 
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
  import_arduino_library(cores ${COREPATH} avr util)
  import_arduino_library(SPI ${DEPSPATH}/SPI)        # SPI@Juse_Use_SdFat
  import_arduino_library(SdFat ${DEPSPATH}/SdFat/src common DigitalIO ExFatLib FatLib FsLib iostream SdCard SpiDriver)
  import_arduino_library(SD ${DEPSPATH}/SD/src)  
  ```
* ```teensy_target_link_libraries``` ( ```TARGET``` ```libraries...```) 
```
  teensy_target_link_libraries(my_firmware mylibrary SD SdFat SPI cores)
```

* ```import_arduino_library_git``` ( ```LibraryName``` ```LibraryUrl``` ```Branch``` ```SourcePath``` ```additionalRelativeSourceFolders```)
  ```cmake 
    import_arduino_library_git(SPI https://github.com/PaulStoffregen/SPI.git master "")
    import_arduino_library_git(SdFat https://github.com/PaulStoffregen/SdFat.git master "src" common DigitalIO ExFatLib FatLib FsLib iostream SdCard SpiDriver)
    import_arduino_library_git(SD https://github.com/PaulStoffregen/SD.git Juse_Use_SdFat src)
    import_arduino_library_git(Encoder https://github.com/PaulStoffregen/Encoder.git master "")
    import_arduino_library_git(Bounce2 https://github.com/PaulStoffregen/Bounce2.git master src)
    import_arduino_library_git(SerialFlash https://github.com/PaulStoffregen/SerialFlash.git master "" util)
    import_arduino_library_git(Wire https://github.com/PaulStoffregen/Wire.git master "" utility)
    import_arduino_library_git(arm_math https://github.com/PaulStoffregen/arm_math.git master src)
    import_arduino_library_git(TeensyGFX https://github.com/newdigate/teensy-gfx.git noinstall src)
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
