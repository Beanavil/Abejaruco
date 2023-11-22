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

if(DEPENDENCIES_FORCE_DOWNLOAD AND NOT EXISTS
                                   "${CMAKE_CURRENT_BINARY_DIR}/deps/iverilog")
  set(GIT_URL
      "https://github.com/steveicarus/iverilog/archive/refs/tags/v12_0.tar.gz")
  set(DOWNLOAD_PATH "${CMAKE_CURRENT_BINARY_DIR}/deps/v12_0.tar.gz")
  set(PARENT_FOLDER "${CMAKE_CURRENT_BINARY_DIR}/deps/iverilog")
  set(EXTRACTED_FOLDER
      "${CMAKE_CURRENT_BINARY_DIR}/deps/iverilog/iverilog-12_0")

  message(STATUS "Building iverilog dependency: ${PARENT_FOLDER}")

  if(NOT EXISTS "${DOWNLOAD_PATH}")
    file(DOWNLOAD "${GIT_URL}" "${DOWNLOAD_PATH}")
  endif()
  file(ARCHIVE_EXTRACT INPUT "${DOWNLOAD_PATH}" DESTINATION "${PARENT_FOLDER}")
  file(REMOVE "${DOWNLOAD_PATH}")

  # Build iverilog and check correctness
  execute_process(
    COMMAND "sh" "${EXTRACTED_FOLDER}/autoconf.sh"
    WORKING_DIRECTORY "${EXTRACTED_FOLDER}"
    OUTPUT_QUIET)
  message(STATUS "> Configuring iverilog")
  execute_process(
    COMMAND "sh" "configure" "--prefix=${EXTRACTED_FOLDER}"
    WORKING_DIRECTORY "${EXTRACTED_FOLDER}"
    OUTPUT_QUIET)
  message(STATUS "> Buildig iverilog")
  execute_process(
    COMMAND "make" "-j"
    WORKING_DIRECTORY "${EXTRACTED_FOLDER}"
    OUTPUT_QUIET)
  message(STATUS "> Installing iverilog")
  execute_process(
    COMMAND "make" "install"
    WORKING_DIRECTORY "${EXTRACTED_FOLDER}"
    OUTPUT_QUIET)
  message(STATUS "> Checking correctness of iverilog")
  execute_process(
    COMMAND "make" "check"
    WORKING_DIRECTORY "${EXTRACTED_FOLDER}"
    OUTPUT_QUIET)
endif()

if(DEPENDENCIES_FORCE_DOWNLOAD)
  set(IVERILOG_COMMAND "${EXTRACTED_FOLDER}/driver/iverilog")
  message(
    STATUS
      "Setting Icarus Verilog command from ${CMAKE_CURRENT_BINARY_DIR}/deps")
endif()
