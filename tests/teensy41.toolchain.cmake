set(TEENSY_VERSION 41 CACHE STRING "Set to the Teensy version corresponding to your board (30 or 31 allowed)" FORCE)
set(CPU_CORE_SPEED 600000000 CACHE STRING "Set to 24000000, 48000000, 72000000 or 96000000 to set CPU core speed" FORCE) # Derived variables
#set(CMAKE_EXE_LINKER_FLAGS "--specs=nosys.specs" CACHE INTERNAL "")
#teensy compiler options
#set(COMPILERPATH "/opt/gcc-arm-none-eabi-9-2019-q4-major/bin/")
set(COMPILERPATH "/Applications/ARM/bin/")
#set(DEPSPATH "/home/runner/work/teensy-variable-playback/teensy-variable-playback/deps")
set(DEPSPATH "/Users/nicholasnewdigate/Development/github/newdigate/temp_dep")
set(COREPATH "${DEPSPATH}/cores/teensy4/")

find_package(teensy_cmake_macros)  # use installed teensy_cmake_macros cmake package

#if (NOT DEFINED teensy_toolchain_init_executed)
#    set(teensy_toolchain_init_executed 1 CACHE INTERNAL "teensy_set_dynamic_properties_has_executed")

#endif()
