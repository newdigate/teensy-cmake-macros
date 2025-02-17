cmake_minimum_required(VERSION 3.10)
project(test_teensy_project_audio)

include(${teensy_cmake_macros_SOURCE_DIR}/CMakeLists.include.txt)

import_arduino_library(cores ${teensy_cores_SOURCE_DIR}/teensy4 avr util)
import_arduino_library_git(SPI https://github.com/PaulStoffregen/SPI master "")
import_arduino_library_git(SdFat https://github.com/PaulStoffregen/SdFat master src common DigitalIO ExFatLib FatLib FsLib iostream SdCard SpiDriver)
import_arduino_library_git(SD https://github.com/PaulStoffregen/SD Juse_Use_SdFat src)
import_arduino_library_git(SerialFlash https://github.com/PaulStoffregen/SerialFlash master "" util)
import_arduino_library_git(Wire https://github.com/PaulStoffregen/Wire master "" utility)
import_arduino_library_git(arm_math https://github.com/PaulStoffregen/arm_math master src)
import_arduino_library_git(Audio https://github.com/PaulStoffregen/Audio master "" utility)

teensy_add_executable(audio_app audio.cpp)
teensy_target_link_libraries(audio_app Audio cores Wire SPI SdFat SD SerialFlash  arm_math )