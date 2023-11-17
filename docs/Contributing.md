# Contributing guideline
To keep the style of the project consistent, please follow the described guidelines when contributing.

## Make/CMake
This project uses `CMake` as buildsystem, so for any addition of modules the corresponding `CMake` files should be modified when necessary.

## Code Format
The formatting rules of the modules are enforced by [verilog-format](https://github.com/ericsonj/verilog-format) using the `.verilog-format.properties` file in the top-level directory. If using Visual Studio Code, the extension [Verilog Format](https://marketplace.visualstudio.com/items?itemName=ericsonj.verilogformat) can be used to apply this formatting to modified/added files.

## Variable Naming Conventions
- Use `snake_case` style to name variables and functions (e.g. and_gate, n_mux and 2_complement).
- Use `PascalCase` for `module`, `struct` and "template" argument definitions.

## File and Directory Naming Conventions
- Top-level directories use `snake_case`.
- Modules names use `PascalCase` and with `.v` extension.
- Test modules names use `snake_case` and with `.tb.v` extension.
- Documents names, either in PDF or Markdown format, should use `PascalCase`.
- Files for which a convention already exists (e.g. `README.md`, `LICENSE.md`, `CMakeLists.txt`, etc) should follow that convention.
- Module binaries should keep the module `PascalCase` name and switch the `.v` extension for the `.out` one.
