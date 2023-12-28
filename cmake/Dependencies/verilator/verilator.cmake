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

include(DownloadProject)

# Verilator (https://github.com/verilator/verilator)
if(NOT DEPENDENCIES_FORCE_DOWNLOAD AND NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/deps/verilator")
  find_package(verilator)
endif()
if(NOT (verilator_FOUND OR TARGET verilator))
  if(NOT EXISTS "${CMAKE_CURRENT_BINARY_DIR}/deps/verilator")
    if(DEPENDENCIES_FORCE_DOWNLOAD)
      message(STATUS "DEPENDENCIES_FORCE_DOWNLOAD is ON. Downloading Verilator.")
    else()
      message(STATUS "Downloading Verilator.")
    endif()
    message(STATUS "Adding verilator subproject: ${CMAKE_CURRENT_BINARY_DIR}/deps/verilator")
  endif()
  set(ENV{VERILATOR_ROOT} ${CMAKE_CURRENT_BINARY_DIR}/deps/verilator)
  set(VERILATOR_ROOT ${CMAKE_CURRENT_BINARY_DIR}/deps/verilator)
  download_project(
    PROJ                verilator
    GIT_REPOSITORY      https://github.com/verilator/verilator.git
    GIT_TAG             master
    INSTALL_DIR         ${VERILATOR_ROOT}
    CMAKE_ARGS          -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=<INSTALL_DIR>
    LOG_DOWNLOAD        TRUE
    LOG_CONFIGURE       TRUE
    LOG_BUILD           TRUE
    LOG_INSTALL         TRUE
    BUILD_PROJECT       TRUE
    UPDATE_DISCONNECTED TRUE # Never update automatically from the remote repository
  )
  list(APPEND CMAKE_PREFIX_PATH ${VERILATOR_ROOT})
  find_package(verilator REQUIRED)
endif()
