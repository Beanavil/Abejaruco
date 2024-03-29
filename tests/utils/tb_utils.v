// GNU General Public License
//
// Copyright : (c) 2023-2024 Javier Beiro Piñón
//           : (c) 2023-2024 Beatriz Navidad Vilches
//           : (c) 2023-2024 Stefano Petrilli
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

`include "tests/utils/display.v"

task automatic check_err;
  input err;
  input string test_name;
  begin
    if (err === 1'b0)
    begin
      begin_green_print();
      $display("TEST %s PASSED.", test_name);
      end_color_print();
    end
    else
    begin
      begin_red_print();
      $display("TEST %s FAILED.", test_name);
      end_color_print();
    end
  end
endtask

task automatic finish_test_run;
  input integer err_count;
  input integer num_tests;
  begin
    $display("");
    if (err_count == 0)
    begin
      begin_green_print();
      $display("%0d of %0d tests passed.", num_tests, num_tests);
      end_color_print();
      begin_blue_print();
      $display("No tests failed.");
      end_color_print();
    end
    else
    begin
      begin_blue_print();
      $display("%0d of %0d tests passed.", num_tests - err_count, num_tests);
      end_color_print();
      begin_red_print();
      $display("%0d of %0d tests failed.", err_count, num_tests);
      end_color_print();
    end
    $display("");
    $display("Done");
  end
endtask

task automatic print_info;
  input string str; /*max string length 32 characters (256 bytes)*/
  begin
    $display("-------------------------------");
    $display("%s", str);
    $display("-------------------------------");
  end
endtask
