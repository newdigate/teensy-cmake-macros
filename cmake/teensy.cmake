cmake_minimum_required(VERSION 3.10)
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")
set(CMAKE_C_COMPILER ${COMPILERPATH}arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER ${COMPILERPATH}arm-none-eabi-g++)
#set(CMAKE_LINKER ${COMPILERPATH}arm-none-eabi-gcc)
set(CMAKE_CXX_LINK_EXECUTABLE "${CMAKE_C_COMPILER} <FLAGS> <CMAKE_CXX_LINK_FLAGS> <LINK_FLAGS> <OBJECTS> -o <TARGET> <LINK_LIBRARIES>")
#SET (CMAKE_C_COMPILER_WORKS 1)
#SET (CMAKE_CXX_COMPILER_WORKS 1)
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
set(CMAKE_SYSTEM_NAME Generic)
SET(CMAKE_CXX_ARCHIVE_CREATE "${COMPILERPATH}/${build_command_ar} rcs <TARGET> <LINK_FLAGS> <OBJECTS>")
SET(CMAKE_C_ARCHIVE_CREATE "${COMPILERPATH}/${build_command_ar} rcs <TARGET> <LINK_FLAGS> <OBJECTS>")

function(teensy_set_dynamic_properties)
    if (NOT DEFINED teensy_set_dynamic_properties_has_executed)
        set(teensy_set_dynamic_properties_has_executed 1 CACHE INTERNAL "teensy_set_dynamic_properties_has_executed")
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
            set(COREPATH ${COREPATH} CACHE INTERNAL "COREPATH")
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
            set(build_usbtype ${build_usbtype}  CACHE INTERNAL "build_usbtype")
            message(STATUS "build_usbtype: ${build_usbtype}" )
        endif()

        if (NOT DEFINED ${build_usbtype})
            set(build_keylayout US_ENGLISH)
            set(build_keylayout ${build_keylayout}  CACHE INTERNAL "build_keylayout")
            message(STATUS "build_keylayout: ${build_keylayout}" )
        endif()

        if(TEENSY_VERSION EQUAL 40)
            set(CPU_DEFINE __IMXRT1062__)
            set(LINKER_FILE ${COREPATH}imxrt1062.ld)
            set(build_flags_ld "-nostdlib -Wl,--gc-sections,--relax ")
            set(build_core teensy4)
            set(build_mcu imxrt1062)
            set(build_warn_data_percentage 99)
            set(build_flags_common "-g -Wall -ffunction-sections -fdata-sections")
            set(build_flags_dep "-MMD")
            set(build_flags_optimize "-Os")
            set(build_flags_cpu "-mthumb -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16")
            set(build_flags_defs "-D${CPU_DEFINE} -DTEENSYDUINO=153 ")
            set(build_flags_cpp "-nostdlib -fno-exceptions -fpermissive -fno-rtti -fno-threadsafe-statics -felide-constructors -Wno-error=narrowing" PARENT_SCOPE)
            set(build_flags_c "-nostdlib")
            set(build_flags_S "-x assembler-with-cpp")
            set(build_flags_libs "-lm")
        elseif(TEENSY_VERSION EQUAL 41)
            message(STATUS "building for teensy 4.1")
            set(CPU_DEFINE __IMXRT1062__)
            set(LINKER_FILE ${COREPATH}imxrt1062_t41.ld)
            set(build_board TEENSY41)
            set(build_flags_ld " -Wl,--gc-sections,--relax ")
            set(build_core teensy4)
            set(build_mcu imxrt1062)
            set(build_warn_data_percentage 99)
            set(build_flags_common "-g -Wall -ffunction-sections -fdata-sections")
            set(build_flags_dep "-MMD")
            set(build_flags_optimize "-O2")
            set(build_flags_cpu "-mthumb -mcpu=cortex-m7 -mfloat-abi=hard -mfpu=fpv5-d16")
            set(build_flags_defs "-D${CPU_DEFINE} -DTEENSYDUINO=153")
            set(build_flags_cpp "-nostdlib -fno-exceptions -fpermissive -fno-rtti -fno-threadsafe-statics -felide-constructors -Wno-error=narrowing")
            set(build_flags_c "-nostdlib")
            set(build_flags_S "-x assembler-with-cpp")
            #set(build_flags_libs "-larm_cortexM7lfsp_math -lm -lstdc++")
            set(build_flags_libs "-lm")
        else()
            message(FATAL_ERROR "Teensy version not defined")    
        endif()

        # search for programs in the build host directories
        set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER CACHE INTERNAL "CMAKE_FIND_ROOT_PATH_MODE_PROGRAM")

        # for libraries and headers in the target directories
        set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY CACHE INTERNAL "CMAKE_FIND_ROOT_PATH_MODE_LIBRARY")
        set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY CACHE INTERNAL "CMAKE_FIND_ROOT_PATH_MODE_INCLUDE")
        set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY CACHE INTERNAL "CMAKE_FIND_ROOT_PATH_MODE_PACKAGE")

        set(CPP_COMPILE_FLAGS   "${build_flags_optimize} ${build_flags_common} ${build_flags_dep} ${build_flags_cpp} ${build_flags_cpu} ${build_flags_defs} -DARDUINO=${arduino_ide_version} -DARDUINO_${build_board} -DF_CPU=${build_fcpu} -D${build_usbtype} -DLAYOUT_${build_keylayout}")
        set(C_COMPILE_FLAGS     "${build_flags_optimize} ${build_flags_common} ${build_flags_dep} ${build_flags_c} ${build_flags_cpu} ${build_flags_defs} -DARDUINO=${arduino_ide_version} -DARDUINO_${build_board} -DF_CPU=${build_fcpu} -D${build_usbtype} -DLAYOUT_${build_keylayout}")
        set(S_COMPILE_FLAGS     "${build_flags_optimize} ${build_flags_common} ${build_flags_dep} ${build_flags_S} ${build_flags_cpu} ${build_flags_defs} -DARDUINO=${arduino_ide_version} -DARDUINO_${build_board} -DF_CPU=${build_fcpu} -D${build_usbtype} -DLAYOUT_${build_keylayout}")
        set(LINK_FLAGS          "${build_flags_optimize} ${build_flags_ld} ${build_flags_ldspecs} ${build_flags_cpu} -T${LINKER_FILE} ${build_flags_libs}")

        set(CPP_COMPILE_FLAGS   ${CPP_COMPILE_FLAGS} CACHE INTERNAL "CPP_COMPILE_FLAGS")
        set(C_COMPILE_FLAGS     ${C_COMPILE_FLAGS}   CACHE INTERNAL "C_COMPILE_FLAGS")
        set(S_COMPILE_FLAGS     ${S_COMPILE_FLAGS}   CACHE INTERNAL "S_COMPILE_FLAGS")
        set(LINK_FLAGS          ${LINK_FLAGS}        CACHE INTERNAL "LINK_FLAGS")

        message(STATUS "S_COMPILE_FLAGS: ${S_COMPILE_FLAGS}")
        message(STATUS "CPP_COMPILE_FLAGS: ${CPP_COMPILE_FLAGS}")
    endif()
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
    
    set(ELFTARGET ${TARGET}.o)
    foreach(arg IN LISTS ARGN)
        file(GLOB TEST_SOURCE RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${arg})
        list(FILTER TEST_SOURCE INCLUDE REGEX ".cpp$")
        set(TEENSY_EXE_CPP_SOURCES ${TEENSY_EXE_CPP_SOURCES} ${TEST_SOURCE}) 

        file(GLOB INO_SOURCE RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${arg})
        list(FILTER INO_SOURCE INCLUDE REGEX ".ino$")
        set(TEENSY_EXE_INO_SOURCES ${TEENSY_EXE_INO_SOURCES} ${INO_SOURCE}) 
    endforeach()

    foreach(SOURCE_CPP ${TEENSY_EXE_CPP_SOURCES})
        set_source_files_properties(${SOURCE_CPP} PROPERTIES COMPILE_FLAGS "${CPP_COMPILE_FLAGS} ${INCLUDE_DIRECTORIES}")
    endforeach(SOURCE_CPP ${TEENSY_EXE_CPP_SOURCES})

    #foreach(SOURCE_C ${TEENSY_LIB_C_SOURCES})
    #    set_source_files_properties(${SOURCE_C} PROPERTIES COMPILE_FLAGS "${C_COMPILE_FLAGS} ${INCLUDE_DIRECTORIES}")
    #endforeach(SOURCE_C ${TEENSY_LIB_C_SOURCES})

    #foreach(SOURCE_S ${TEENSY_LIB_S_SOURCES})
    #    set_property(SOURCE ${SOURCE_S} PROPERTY LANGUAGE C)
    #    set_source_files_properties(${SOURCE_S} PROPERTIES COMPILE_FLAGS "${S_COMPILE_FLAGS} ${INCLUDE_DIRECTORIES}")
    #endforeach(SOURCE_S ${TEENSY_LIB_S_SOURCES})

    foreach(SOURCE_INO ${TEENSY_EXE_INO_SOURCES})
        set_property(SOURCE ${SOURCE_INO} PROPERTY LANGUAGE CXX)
        set_source_files_properties(${SOURCE_INO} PROPERTIES COMPILE_FLAGS "${CPP_COMPILE_FLAGS} ${INCLUDE_DIRECTORIES} -x c++")
    endforeach(SOURCE_INO ${TEENSY_EXE_INO_SOURCES})

    add_executable(${ELFTARGET} ${ARGN})
#    add_executable(${ELFTARGET} ${ARGN} ${TEENSY_SOURCES} ${TEENSY_LIB_CPP_SOURCES} ${TEENSY_LIB_C_SOURCES} ${TEENSY_LIB_S_SOURCES})

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

    set(ELFTARGET ${TARGET}.o)

    set(TEENSY_LIB_CPP_SOURCES "") 
    set(TEENSY_LIB_C_SOURCES "") 
    set(TEENSY_LIB_S_SOURCES "") 

    foreach(arg ${ARGN})
        file(GLOB TEST_CPP_SOURCE RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${arg})
        list(FILTER TEST_CPP_SOURCE INCLUDE REGEX ".cpp$")
        set(TEENSY_LIB_CPP_SOURCES ${TEENSY_LIB_CPP_SOURCES} ${TEST_CPP_SOURCE}) 

        file(GLOB TEST_C_SOURCE RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${arg})
        list(FILTER TEST_C_SOURCE INCLUDE REGEX ".c$")
        set(TEENSY_LIB_C_SOURCES ${TEENSY_LIB_C_SOURCES} ${TEST_C_SOURCE}) 

        file(GLOB TEST_S_SOURCE RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} ${arg})
        list(FILTER TEST_S_SOURCE INCLUDE REGEX ".S$")
        set(TEENSY_LIB_S_SOURCES ${TEENSY_LIB_S_SOURCES} ${TEST_S_SOURCE}) 
    endforeach()
    #message(STATUS TEENSY_LIB_S_SOURCES: ${TEENSY_LIB_S_SOURCES})
    #message(STATUS TEENSY_LIB_C_SOURCES: ${TEENSY_LIB_C_SOURCES})
    #message(STATUS TEENSY_LIB_CPP_SOURCES: ${TEENSY_LIB_CPP_SOURCES})

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

    add_custom_command(OUTPUT ${TARGET}.hex 
        COMMAND ${COMPILERPATH}arm-none-eabi-size ${ELFTARGET}
        COMMAND ${COMPILERPATH}arm-none-eabi-objcopy -O ihex -R .eeprom ${ELFTARGET} ${TARGET}.hex
        DEPENDS ${ELFTARGET}
        COMMENT "Creating HEX file for ${ELFTARGET}")
endfunction()

macro(import_arduino_library LIB_NAME LIB_ROOT)
    message(STATUS "import_arduino_library(${LIB_NAME} ${LIB_ROOT} ${ARGN})")
    # Check if we can find the library.
    if(NOT EXISTS "${LIB_ROOT}")
        message(FATAL_ERROR "Could not find the directory for library '${LIB_ROOT}'")
    endif(NOT EXISTS "${LIB_ROOT}")
    set(INCLUDE_DIRECTORIES "${INCLUDE_DIRECTORIES} -I${LIB_ROOT} ")

    set(IMPORT_LIB_CPP_SOURCES "")
    set(IMPORT_LIB_C_SOURCES "")
    set(IMPORT_LIB_S_SOURCES "")

    # Mark source files to be built along with the sketch code.
    file(GLOB SOURCES_CPP ABSOLUTE "${LIB_ROOT}/*.cpp")
    foreach(SOURCE_CPP ${SOURCES_CPP})
        set(IMPORT_LIB_CPP_SOURCES ${IMPORT_LIB_CPP_SOURCES} ${SOURCE_CPP})
    endforeach(SOURCE_CPP ${SOURCES_CPP})

    file(GLOB SOURCES_C ABSOLUTE "${LIB_ROOT}/*.c")
    foreach(SOURCE_C ${SOURCES_C})
        set(IMPORT_LIB_C_SOURCES ${IMPORT_LIB_C_SOURCES} ${SOURCE_C})
    endforeach(SOURCE_C ${SOURCES_C})

    file(GLOB SOURCES_S ABSOLUTE "${LIB_ROOT}/*.S")
    foreach(SOURCE_S ${SOURCES_S})
        set(IMPORT_LIB_S_SOURCES ${IMPORT_LIB_S_SOURCES} ${SOURCE_S})
    endforeach(SOURCE_S ${SOURCES_S})

    foreach(arg ${ARGN})
        message(status " checking for ${LIB_ROOT}/${arg}")
        if(NOT EXISTS ${LIB_ROOT}/${arg})
            message(FATAL_ERROR "Could not find the Arduino library directory ${LIB_ROOT}/${arg}")
        endif(NOT EXISTS ${LIB_ROOT}/${arg})
        include_directories("${LIB_ROOT}/${arg}")
        set(INCLUDE_DIRECTORIES "${INCLUDE_DIRECTORIES} -I${LIB_ROOT}/${arg} ")

        # Mark source files to be built along with the sketch code.
        file(GLOB SOURCES_CPP ABSOLUTE "${LIB_ROOT}/${arg}/*.cpp")
        foreach(SOURCE_CPP ${SOURCES_CPP})
            set(IMPORT_LIB_CPP_SOURCES ${IMPORT_LIB_CPP_SOURCES} ${SOURCE_CPP})
        endforeach(SOURCE_CPP ${SOURCES_CPP})

        file(GLOB SOURCES_C ABSOLUTE "${LIB_ROOT}/${arg}/*.c")
        foreach(SOURCE_C ${SOURCES_C})
            set(IMPORT_LIB_C_SOURCES ${IMPORT_LIB_C_SOURCES} ${SOURCE_C})
        endforeach(SOURCE_C ${SOURCES_C})

        file(GLOB SOURCES_S ABSOLUTE "${LIB_ROOT}/${arg}/*.S")
        foreach(SOURCE_S ${SOURCES_S})
            set(IMPORT_LIB_S_SOURCES ${IMPORT_LIB_S_SOURCES} ${SOURCE_S})
        endforeach(SOURCE_S ${SOURCES_S})
    endforeach()
    
    teensy_add_library(${LIB_NAME} ${IMPORT_LIB_CPP_SOURCES} ${IMPORT_LIB_C_SOURCES} ${IMPORT_LIB_S_SOURCES})
endmacro(import_arduino_library)

macro(teensy_remove_sources LIB_DIR)
    file(GLOB_RECURSE FILES_TO_REMOVE ABSOLUTE "${LIB_DIR}/**.*")
    foreach(FILE_TO_REMOVE ${FILES_TO_REMOVE})
        list(REMOVE_ITEM TEENSY_LIB_SOURCES ${FILE_TO_REMOVE})
        message("REMOVED ${FILE_TO_REMOVE}")
    endforeach(FILE_TO_REMOVE ${FILES_TO_REMOVE})
endmacro(teensy_remove_sources)

macro(teensy_include_directories)
    set(list_var "${ARGN}")
    foreach(loop_var IN LISTS list_var)
        set(INCLUDE_DIRECTORIES "${INCLUDE_DIRECTORIES} -I${CMAKE_CURRENT_SOURCE_DIR}/${loop_var} ")
    endforeach()
endmacro(teensy_include_directories)

macro(teensy_target_link_libraries TARGET)
    set(list_var "${ARGN}")
    foreach(loop_var IN LISTS list_var)
        target_link_libraries(${TARGET}.o ${loop_var}.o)
    endforeach()
endmacro(teensy_target_link_libraries)
