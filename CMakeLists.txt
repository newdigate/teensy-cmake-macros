cmake_minimum_required(VERSION 3.0)
project(teensy_cmake_macros)
set(teensy_cmake_macros_VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 11)

set(LIB_INSTALL_DIR ${CMAKE_INSTALL_PREFIX}/lib/teensy_cmake_macros )

include(CMakePackageConfigHelpers)
configure_package_config_file(cmake/teensy.cmake
		${CMAKE_CURRENT_BINARY_DIR}/teensy_cmake_macrosConfig.cmake
		INSTALL_DESTINATION ${LIB_INSTALL_DIR}/teensy_cmake_macros/cmake
		PATH_VARS)

write_basic_package_version_file(
		${CMAKE_CURRENT_BINARY_DIR}/teensy_cmake_macrosConfigVersion.cmake
		VERSION ${teensy_cmake_macros_VERSION}
		COMPATIBILITY SameMajorVersion )

install(FILES
		${CMAKE_CURRENT_SOURCE_DIR}/cmake/teensy.cmake
		${CMAKE_CURRENT_BINARY_DIR}/teensy_cmake_macrosConfig.cmake
		${CMAKE_CURRENT_BINARY_DIR}/teensy_cmake_macrosConfigVersion.cmake
		${CMAKE_CURRENT_SOURCE_DIR}/cmake/uninstall.cmake
		DESTINATION "lib/cmake/teensy_cmake_macros" )

##
# copied from: https://gist.github.com/royvandam/3033428
# Add uninstall target
# Requirements: Copy the uninstall.cmake file to the appropriate CMAKE_MODULE_PATH.
#

add_custom_target(uninstall
		"${CMAKE_COMMAND}" -P "${CMAKE_CURRENT_SOURCE_DIR}/cmake/uninstall.cmake"
		)