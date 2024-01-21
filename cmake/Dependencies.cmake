# GNU General Public License
#
# Copyright : (c) 2023 Javier Beiro Piñón
#           : (c) 2023 Beatriz Navidad Vilches
#           : (c) 2023 Stefano Petrilli
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

# Fetch dependencies
foreach(DEP IN ITEMS iverilog)
  list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/Dependencies/${DEP}")
  include(${DEP})
endforeach()

# Fetch tests dependencies TODO when using verilator
# if(BUILD_TESTS)
#   foreach(DEP IN ITEMS verilator)
#     list(APPEND CMAKE_MODULE_PATH
#          "${CMAKE_CURRENT_LIST_DIR}/Dependencies/${DEP}")
#     include(${DEP})
#   endforeach()
# endif(BUILD_TESTS)

