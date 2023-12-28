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

# # TODO This part should be uncommented when simulator tests are added

# # Set the C standard to C17 set(CMAKE_C_STANDARD 17)
# set(CMAKE_C_STANDARD_REQUIRED ON)

# # Set the CXX standard to C++17 set(CMAKE_CXX_STANDARD 17)
# set(CMAKE_CXX_STANDARD_REQUIRED ON) set(CMAKE_CXX_EXTENSIONS OFF)

# # Set Verilator arguments list( APPEND VERILATOR_FLAGS "-Wall" "-Wextra"
# "-Werror" "--trace" "--pedantic")

# enable_testing()

include(AddModule)

list(APPEND MAIN_MODULE abejaruco)

add_module(TARGET "${MAIN_MODULE}.tb" INCLUDES "${PROJECT_SOURCE_DIR}")

add_subdirectory(common)
add_subdirectory(execution)
