// GNU General Public License
//
// Copyright : (c) 2023 Javier Beiro Piñón
// : (c) 2023 Beatriz Navidad Vilches
// : (c) 2023 Stefano Petrili
//
// This file is part of Abejaruco <https:// github.com/Beanavil/Abejaruco>.
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
// If not, see <https:// www.gnu.org/licenses/>.

module priority_encoder(
    input wire [3:0] hit,
    output reg [1:0] line_number
);
    always @(*) begin
        case(hit)
            4'b1000: line_number = 2'b00;
            4'b0100: line_number = 2'b01;
            4'b0010: line_number = 2'b10;
            4'b0001: line_number = 2'b11;
            default: line_number = 2'bxx; // No hit or multiple hits
        endcase
    end
endmodule
