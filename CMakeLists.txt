# GNU General Public License
#
# Copyright : (c) 2023 Javier Beiro Piñón : (c) 2023 Beatriz Navidad Vilches :
# (c) 2023 Stefano Petrili
#
# This file is part of Abejaruco <https://github.com/Beanavil/Abejaruco>.
#
# Abejaruco is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# Abejaruco is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with
# Abejaruco placed on the LICENSE.md file of the root folder. If not, see
# <https://www.gnu.org/licenses/>.

cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(Abejaruco)
set(CMAKE_BUILD_TYPE Debug)

# Configuration options
option(BUILD_TESTS "Enable (ON) or disable (OFF) tests" ON)
option(BUILD_SIM "Build testbench simulations" ON)
option(DEPENDENCIES_FORCE_DOWNLOAD
       "Download dependencies instead of trying to find them locally" OFF)

# CMake project configuration
# cmake_policy(SET CMP0144 NEW)
list(APPEND CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake
     ${PROJECT_SOURCE_DIR}/cmake/Modules)
include(Dependencies)

set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_BINARY_DIR}/bin)

if(NOT IVERILOG_COMMAND)
  set(IVERILOG_COMMAND "iverilog")
  message(STATUS "Setting Icarus Verilog command from path")
endif()

# Add subdirectories
add_subdirectory(src)

if(BUILD_TESTS)
  add_subdirectory(tests)
endif()
