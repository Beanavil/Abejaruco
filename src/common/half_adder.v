// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
//           : (c) 2023 Beatriz Navidad Vilches
//           : (c) 2023 Stefano Petrili
//
// This file is part of Abejaruco <https://github.com/Beanavil/Abejaruco>.
//
// Abejaruco is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version.
//
// Abejaruco is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Abejaruco placed on the LICENSE.md file of the root folder.
// If not, see <https://www.gnu.org/licenses/>.

// 1-bit adder.
// Performs addition of 1-bit inputs.
// Input arguments:
// - a: first 1-bit input
// - b: second 1-bit input
// Output arguments:
// - sol: 1-bit binary number with the result of the operation
// - c_out: carry of the operation

module half_adder(input a,
                    input b,
                    output reg sol,
                    output reg c_out);
  always @(a or b)
  begin
    {sol, c_out} = {a ^ b, a & b};
  end
endmodule
