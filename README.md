# Abejaruco
## What is this?

## Get started
### Dependencies
- iverilog
    - gperf
- verilator

#### iverilog
Download as described in https://github.com/steveicarus/iverilog.

### Configure
The project uses CMake as buildsystem. To configure the project using the system packages use
```
cmake -G Ninja -B build -S .
```
If you want CMake to download the necessary dependencies, use
```
cmake -G Ninja -B build -S . -DDEPENDENCIES_FORCE_DOWNLOAD=ON
```

### Build
Once the project is configured, just run
```
cmake --build build --clean-first
```

## Contribute
Please refer to the [Contributing Guidelines](/docs/Contributing.md).
