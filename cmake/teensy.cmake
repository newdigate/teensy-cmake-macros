cmake_minimum_required(VERSION 3.10)
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_CXX_STANDARD 14)
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
set(CMAKE_C_COMPILER ${COMPILERPATH}arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER ${COMPILERPATH}arm-none-eabi-g++)
# * you will need to define the following properies: (frmo https://github.com/newdigate/teensy-cmake-macros)
#set(TEENSY_VERSION 41 CACHE STRING "Set to the Teensy version corresponding to your board (40 or 41 allowed)" FORCE)
#set(CPU_CORE_SPEED 600000000 CACHE STRING "Set to 24000000, 48000000, 72000000 or 96000000 to set CPU core speed" FORCE) # Derived variables
#set(COMPILERPATH "/opt/gcc-arm-none-eabi-9-2019-q4-major/bin/")
#set(DEPSPATH "/home/runner/work/teensy-variable-playback/teensy-variable-playback/deps")
# * core path will be set as below by default. you can change if necessary 
#set(COREPATH "${DEPSPATH}/cores/teensy4/")
if (APPLE)
    set(CMAKE_OSX_SYSROOT "")
endif()

# static configuration
set(runtime_ide_version 153)
set(arduino_ide_version 10813)
set(build_command_gcc arm-none-eabi-gcc)
set(build_command_g++ arm-none-eabi-g++)
set(build_command_ar arm-none-eabi-gcc-ar)
set(build_command_objcopy arm-none-eabi-objcopy)
set(build_command_objdump arm-none-eabi-objdump)
set(build_command_linker arm-none-eabi-gcc)
set(build_command_size arm-none-eabi-size)

function(teensy_set_dynamic_properties)
    message(STATUS "teensy_set_dynamic_properties()")
    
    message(CHECK_START "identify root dependency path")
    if (NOT DEFINED DEPSPATH)
        message(FATAL_ERROR "DEPSPATH is UNDEFINED")
    else()
        message(STATUS "DEPSPATH: ${DEPSPATH}")    
    endif()
    message(CHECK_PASS "identified")

    if (NOT DEFINED COREPATH)
        set(COREPATH "${DEPSPATH}/cores/teensy4/")
        set(COREPATH ${COREPATH} PARENT_SCOPE)
        message(STATUS "COREPATH: ${COREPATH}")
    else()
        message(STATUS "COREPATH: ${COREPATH}")    
    endif()

    if (NOT DEFINED CPU_CORE_SPEED)
        message(FATAL_ERROR "CPU_CORE_SPEED is UNDEFINED")
    else()
        message(STATUS "CPU_CORE_SPEED: ${CPU_CORE_SPEED}") 
    endif()

    set(build_fcpu ${CPU_CORE_SPEED})
    
    if (NOT DEFINED COMPILERPATH)
        message(FATAL_ERROR "COMPILERPATH is UNDEFINED")
    else()
        message(STATUS "COMPILERPATH: ${COMPILERPATH}") 
    endif()
    
    set(build_toolchain ${COMPILERPATH}) 

    if (NOT DEFINED ${build_usbtype})
        set(build_usbtype USB_SERIAL)
        set(build_usbtype ${build_usbtype} PARENT_SCOPE)
        message(STATUS "build_usbtype: ${build_usbtype}" )
    endif()

    if (NOT DEFINED ${build_usbtype})
        set(build_keylayout US_ENGLISH)
        set(build_keylayout ${build_keylayout} PARENT_SCOPE)
        message(STATUS "build_keylayout: ${build_keylayout}" )
    endif()

    if(TEENSY_VERSION EQUAL 40)
        set(CPU_DEFINE __IMXRT1062__)
        set(LINKER_FILE ${COREPATH}imxrt1062.ld)
        set(build_flags_ld "-Wl,--gc-sections,--relax ")
        set(build_core teensy4)
        set(build_mcu imxrt1062)
        set(build_warn_data_percentage 99)
        set(build_flags_common "-g -Wall -ffunction-sections -fdata-sections")
        set(build_flags_dep "-MMD")
        set(build_flags_optimize "-Os")
        set(build_flags_cpu "-mthumb -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16")
        set(build_flags_defs "-D${CPU_DEFINE} -DTEENSYDUINO=153 ")
        set(build_flags_cpp "-fno-exceptions -fpermissive -fno-rtti -fno-threadsafe-statics -felide-constructors -Wno-error=narrowing" PARENT_SCOPE)
        set(build_flags_c "")
        set(build_flags_S "-x assembler-with-cpp")
        set(build_flags_libs "-lm --specs=nano.specs -lstdc++")
    elseif(TEENSY_VERSION EQUAL 41)
        message(STATUS "building for teensy 4.1")
        set(CPU_DEFINE __IMXRT1062__)
        set(LINKER_FILE ${COREPATH}imxrt1062_t41.ld)
        set(build_board TEENSY41)
        set(build_flags_ld "-Wl,--gc-sections,--relax ")
        set(build_core teensy4)
        set(build_mcu imxrt1062)
        set(build_warn_data_percentage 99)
        set(build_flags_common "-g -Wall -ffunction-sections -fdata-sections")
        set(build_flags_dep "-MMD")
        set(build_flags_optimize "-O2")
        set(build_flags_cpu "-mthumb -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16")
        set(build_flags_defs "-D${CPU_DEFINE} -DTEENSYDUINO=153")
        set(build_flags_cpp "-fno-exceptions -fpermissive -fno-rtti -fno-threadsafe-statics -felide-constructors -Wno-error=narrowing")
        set(build_flags_c "")
        set(build_flags_S "-x assembler-with-cpp")
        #set(build_flags_libs "-larm_cortexM7lfsp_math -lm -lstdc++")
        set(build_flags_libs "-lm --specs=nano.specs -lstdc++")
    else()
        message(FATAL_ERROR "Teensy version not defined")    
    endif()

    # search for programs in the build host directories
    set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER PARENT_SCOPE)

    # for libraries and headers in the target directories
    set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY PARENT_SCOPE)
    set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY PARENT_SCOPE)
    set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY PARENT_SCOPE)

    set(CPP_COMPILE_FLAGS   "${build_flags_optimize} ${build_flags_common} ${build_flags_dep} ${build_flags_cpp} ${build_flags_cpu} ${build_flags_defs} -DARDUINO=${arduino_ide_version} -DARDUINO_${build_board} -DF_CPU=${build_fcpu} -D${build_usbtype} -DLAYOUT_${build_keylayout}")
    set(C_COMPILE_FLAGS     "${build_flags_optimize} ${build_flags_common} ${build_flags_dep} ${build_flags_c} ${build_flags_cpu} ${build_flags_defs} -DARDUINO=${arduino_ide_version} -DARDUINO_${build_board} -DF_CPU=${build_fcpu} -D${build_usbtype} -DLAYOUT_${build_keylayout}")
    set(S_COMPILE_FLAGS     "${build_flags_optimize} ${build_flags_common} ${build_flags_dep} ${build_flags_s} ${build_flags_cpu} ${build_flags_defs} -DARDUINO=${arduino_ide_version} -DARDUINO_${build_board} -DF_CPU=${build_fcpu} -D${build_usbtype} -DLAYOUT_${build_keylayout}")
    set(LINK_FLAGS          "${build_flags_optimize} ${build_flags_ld} ${build_flags_ldspecs} ${build_flags_cpu} -T${LINKER_FILE} ${build_flags_libs}")

    set(CPP_COMPILE_FLAGS   ${CPP_COMPILE_FLAGS} PARENT_SCOPE)
    set(C_COMPILE_FLAGS     ${C_COMPILE_FLAGS}   PARENT_SCOPE)
    set(S_COMPILE_FLAGS     ${S_COMPILE_FLAGS}   PARENT_SCOPE)
    set(LINK_FLAGS          ${LINK_FLAGS}        PARENT_SCOPE)

    #message(STATUS "CPP_COMPILE_FLAGS: ${CPP_COMPILE_FLAGS}")
endfunction()

function(import_teensy_cores)
    message(STATUS "import_teensy_cores()")

    file(GLOB_RECURSE TEENSY_C_FILES ABSOLUTE ${COREPATH}**.c)
    foreach(SOURCE_C ${TEENSY_C_FILES})
        set_source_files_properties(${SOURCE_C} PROPERTIES COMPILE_FLAGS "${C_COMPILE_FLAGS}")
        #message(STATUS "     .c:   ${SOURCE_C}  ${C_COMPILE_FLAGS}")
    endforeach(SOURCE_C ${SOURCES_C})

    file(GLOB_RECURSE TEENSY_CPP_FILES ${COREPATH}**.cpp)
    foreach(SOURCE_CPP ${TEENSY_CPP_FILES})
        set_source_files_properties(${SOURCE_CPP} PROPERTIES COMPILE_FLAGS "${CPP_COMPILE_FLAGS}")
        #message(STATUS "     .cpp: ${SOURCE_CPP} ${CPP_COMPILE_FLAGS}")
    endforeach(SOURCE_CPP ${SOURCES_CPP})

    set(TEENSY_SOURCES ${TEENSY_C_FILES} ${TEENSY_CPP_FILES} PARENT_SCOPE)
endfunction()

# Macros to wrap add_[executable|library] for seamless Teensy integration
function(teensy_add_executable TARGET)

    message(STATUS "teensy_add_executable(${TARGET} ${ARGN})")

    teensy_set_dynamic_properties()
    import_teensy_cores()
    
    set(ELFTARGET ${TARGET}.o)
    foreach(arg IN LISTS ARGN)
        file(GLOB TEST_SOURCE RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${arg})
        list(FILTER TEST_SOURCE INCLUDE REGEX ".cpp")
        set(TEENSY_LIB_CPP_SOURCES ${TEENSY_LIB_CPP_SOURCES} ${TEST_SOURCE}) 
        message(STATUS ${TEST_SOURCE})
    endforeach()

    foreach(SOURCE_CPP ${TEENSY_LIB_CPP_SOURCES})
        set_source_files_properties(${SOURCE_CPP} PROPERTIES COMPILE_FLAGS "${CPP_COMPILE_FLAGS} ${INCLUDE_DIRECTORIES}")
    endforeach(SOURCE_CPP ${SOURCES_CPP})

    foreach(SOURCE_C ${TEENSY_LIB_C_SOURCES})
        set_source_files_properties(${SOURCE_C} PROPERTIES COMPILE_FLAGS "${C_COMPILE_FLAGS} ${INCLUDE_DIRECTORIES}")
    endforeach(SOURCE_C ${SOURCES_C})

    foreach(SOURCE_S ${TEENSY_LIB_S_SOURCES})
        set_property(SOURCE ${SOURCE_S} PROPERTY LANGUAGE C)
        set_source_files_properties(${SOURCE_S} PROPERTIES COMPILE_FLAGS "${S_COMPILE_FLAGS} ${INCLUDE_DIRECTORIES}")
    endforeach(SOURCE_S ${SOURCES_S})

    add_executable(${ELFTARGET} ${ARGN} ${TEENSY_SOURCES} ${TEENSY_LIB_CPP_SOURCES} ${TEENSY_LIB_C_SOURCES} ${TEENSY_LIB_S_SOURCES})

    set_target_properties(${ELFTARGET} PROPERTIES INCLUDE_DIRECTORIES "${COREPATH}")
    set_target_properties(${ELFTARGET} PROPERTIES LINK_FLAGS "${LINK_FLAGS}")
    
    add_custom_command(OUTPUT ${TARGET}.hex
            COMMAND ${COMPILERPATH}arm-none-eabi-size ${ELFTARGET}
            COMMAND ${COMPILERPATH}arm-none-eabi-objcopy -O ihex -R .eeprom ${ELFTARGET} ${TARGET}.hex
            DEPENDS ${ELFTARGET}
            COMMENT "Creating HEX file for ${ELFTARGET}")

    add_custom_target(${TARGET}_hex ALL DEPENDS ${TARGET}.hex)
endfunction()

function(teensy_add_library TARGET)
    message(STATUS "teensy_add_library(${TARGET} ${ARGN})")

    teensy_set_dynamic_properties()
    import_teensy_cores()

    set(ELFTARGET ${TARGET}.o)

    foreach(arg IN LISTS ARGN)
        file(GLOB TEST_SOURCE RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${arg})
        list(FILTER TEST_SOURCE INCLUDE REGEX ".cpp")
        set(TEENSY_LIB_CPP_SOURCES ${TEENSY_LIB_CPP_SOURCES} ${TEST_SOURCE}) 
        message(STATUS ${TEST_SOURCE})
    endforeach()
    
    foreach(SOURCE_CPP ${TEENSY_LIB_CPP_SOURCES})
        set_source_files_properties(${SOURCE_CPP} PROPERTIES COMPILE_FLAGS "${CPP_COMPILE_FLAGS} ${INCLUDE_DIRECTORIES}")
    endforeach(SOURCE_CPP ${SOURCES_CPP})

    foreach(SOURCE_C ${TEENSY_LIB_C_SOURCES})
        set_source_files_properties(${SOURCE_C} PROPERTIES COMPILE_FLAGS "${C_COMPILE_FLAGS} ${INCLUDE_DIRECTORIES}")
    endforeach(SOURCE_C ${SOURCES_C})

    foreach(SOURCE_S ${TEENSY_LIB_S_SOURCES})
        set_property(SOURCE ${SOURCE_S} PROPERTY LANGUAGE C)
        set_source_files_properties(${SOURCE_S} PROPERTIES COMPILE_FLAGS "${S_COMPILE_FLAGS} ${INCLUDE_DIRECTORIES}")
    endforeach(SOURCE_S ${SOURCES_S})

    add_library(${ELFTARGET} STATIC ${ARGN} ${TEENSY_SOURCES} ${TEENSY_LIB_CPP_SOURCES} ${TEENSY_LIB_C_SOURCES} ${TEENSY_LIB_S_SOURCES})
    set_target_properties(${ELFTARGET} PROPERTIES INCLUDE_DIRECTORIES ${COREPATH})
    set_target_properties(${ELFTARGET} PROPERTIES LINK_FLAGS "${LINK_FLAGS}")
endfunction()

macro(import_arduino_library LIB_ROOT LIB_NAME)
    # Check if we can find the library.
    if(NOT EXISTS ${LIB_ROOT})
        message(FATAL_ERROR "Could not find the Arduino library directory ${LIB_ROOT}")
    endif(NOT EXISTS ${LIB_ROOT})
    set(LIB_DIR "${LIB_ROOT}/${LIB_NAME}")
    import_arduino_library_absolute(${LIB_DIR})
endmacro(import_arduino_library)

macro(import_arduino_library_absolute LIB_DIR)
    
    message(STATUS "import_arduino_library_absolute(${LIB_DIR})")
    
    if(NOT EXISTS "${LIB_DIR}")
        message(FATAL_ERROR "Could not find the directory for library '${LIB_DIR}'")
    endif(NOT EXISTS "${LIB_DIR}")

    include_directories("${LIB_DIR}")
    set(INCLUDE_DIRECTORIES "${INCLUDE_DIRECTORIES} -I${LIB_DIR} ")

    # Mark source files to be built along with the sketch code.
    file(GLOB SOURCES_CPP ABSOLUTE "${LIB_DIR}/*.cpp")
    foreach(SOURCE_CPP ${SOURCES_CPP})
        set(TEENSY_LIB_CPP_SOURCES ${TEENSY_LIB_CPP_SOURCES} ${SOURCE_CPP})
        #message(STATUS "     .cpp: ${SOURCE_CPP}  ${CPP_COMPILE_FLAGS}")
    endforeach(SOURCE_CPP ${SOURCES_CPP})

    file(GLOB SOURCES_C ABSOLUTE "${LIB_DIR}/*.c")
    foreach(SOURCE_C ${SOURCES_C})
        set(TEENSY_LIB_C_SOURCES ${TEENSY_LIB_C_SOURCES} ${SOURCE_C})
        #message(STATUS "     .c:   ${SOURCE_C}  ${C_COMPILE_FLAGS}")
    endforeach(SOURCE_C ${SOURCES_C})

    file(GLOB SOURCES_S ABSOLUTE "${LIB_DIR}/*.S")
    foreach(SOURCE_S ${SOURCES_S})
        set(TEENSY_LIB_S_SOURCES ${TEENSY_LIB_S_SOURCES} ${SOURCE_S})
        #message(STATUS "     .s:   ${SOURCE_S}  ${S_COMPILE_FLAGS}")
    endforeach(SOURCE_S ${SOURCES_S})
endmacro(import_arduino_library_absolute)

macro(teensy_remove_sources LIB_DIR)
    file(GLOB_RECURSE FILES_TO_REMOVE ABSOLUTE "${LIB_DIR}/**.*")
    foreach(FILE_TO_REMOVE ${FILES_TO_REMOVE})
        list(REMOVE_ITEM TEENSY_LIB_SOURCES ${FILE_TO_REMOVE})
        message("REMOVED ${FILE_TO_REMOVE}")
    endforeach(FILE_TO_REMOVE ${FILES_TO_REMOVE})
endmacro(teensy_remove_sources)