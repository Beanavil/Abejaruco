# GNU General Public License
#
# Copyright : (c) 2023 Javier Beiro Piñón
#           : (c) 2023 Beatriz Navidad Vilches
#           : (c) 2023 Stefano Petrili
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

include(CMakeParseArguments)

# Usage:
# add_module(
#     TEST                               # optional, adds a test for the sample TODO
#     TARGET <name>                      # specifies the name of the module
#     INCLUDES <include0> <include1> ... # include directories
# )
function(add_module)

  set(options TEST)
  set(one_value_args TARGET)
  set(multi_value_args INCLUDES)

  cmake_parse_arguments(MODULE "${options}" "${one_value_args}"
                        "${multi_value_args}" ${ARGN})

  add_custom_command(
    OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/${MODULE_TARGET}.vvp"
    COMMAND
      "${IVERILOG_COMMAND}" "-I" "${MODULE_INCLUDES}" "-o"
      "${CMAKE_CURRENT_BINARY_DIR}/${MODULE_TARGET}.vvp"
      "${CMAKE_CURRENT_SOURCE_DIR}/${MODULE_TARGET}.v"
      "-g2012"
    DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${MODULE_TARGET}.v"
    COMMENT
      "Synthesizing Verilog file ${CMAKE_CURRENT_SOURCE_DIR}/${MODULE_TARGET}"
    VERBATIM)

  add_custom_target(${MODULE_TARGET} ALL
                    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/${MODULE_TARGET}.vvp")
endfunction()
