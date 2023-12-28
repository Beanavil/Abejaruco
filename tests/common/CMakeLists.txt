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

include(AddModule)

list(
  APPEND
  VERILOG_MODULES
  adder
  base_multiplier
  complement2
  demux1to2
  flip_flop
  full_adder
  half_adder
  mux2to1)

foreach(MODULE IN ITEMS ${VERILOG_MODULES})
  add_module(TARGET "${MODULE}.tb" INCLUDES "${PROJECT_SOURCE_DIR}")
endforeach()
