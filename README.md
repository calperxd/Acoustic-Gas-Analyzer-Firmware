# Acoustic Gas Analyzer Firmware

This project contains the firmware for an acoustic gas analyzer targeting the TM4C129ENCPDT microcontroller. It is built using **CMake** and the **arm-none-eabi** toolchain.

## Building locally

1. Install the ARM GCC toolchain (`gcc-arm-none-eabi`) and `cmake` on your system.
2. Configure the project:
   ```
   cmake -S . -B build
   ```
3. Build the firmware:
   ```
   cmake --build build
   ```

## Building with Docker

If you do not wish to install the toolchain locally, you can build the firmware using Docker. A `Dockerfile` and a minimal `docker-compose.yml` are provided.

1. Ensure Docker and Docker Compose are installed on your machine.
2. Run the following command in the repository root:
   ```
   docker compose build
   ```
   The image will compile the firmware during the build process.

## Repository structure

- `source/` - application source files
- `include/` - header files
- `linkerscripts/` - linker scripts for the target MCU
- `lib/` - third-party libraries

## License

This project is provided under the MIT license. See the `LICENSE` file for details.
