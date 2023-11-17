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

`default_nettype none

`include "src/common/half_adder.v"

module Full_adder(input a, input b, input carry_in, output sum, output carry_out);
    wire operands_sum, operands_carry, carry_carry;
    
    Half_adder half_adder_operands (
        .a(a),
        .b(b),
        .sum(operands_sum),
        .carry_out(operands_carry)
    );

    Half_adder half_adder_carry (
        .a(operands_sum),
        .b(carry_in),
        .sum(sum),
        .carry_out(carry_carry) 
    );

    assign carry_out = operands_carry | carry_carry;
endmodule
