# Acoustic Gas Analyzer — Firmware

Firmware for the acoustic gas analyzer developed as a thesis project. The system
samples an audio signal via ADC, runs linear regression for calibration, and
exposes command-line control over UART.

## Hardware

- **MCU:** TI Tiva C `TM4C129ENCPDT` (ARM Cortex-M4F, hard-float FPU)
- **Peripherals:**
  - `ADC0` sequence 3 — captures the microphone/transducer signal
  - `UART0` — host communication (115200 8N1)
  - `GPIO PORTN`:
    - `PN0` — heartbeat LED (blinks while sampling)
    - `PN1` — command-ACK LED
  - Digital potentiometer (front-end gain control):
    - `PN2` — CS
    - `PN3` — INC
    - `PN4` — U/D

## Software stack

- **RTOS:** FreeRTOS (`GCC/ARM_CM4F` port, `heap_4`)
- **HAL:** TivaWare driverlib
- **DSP:** FFTW3 (static `libfftw3.a`, in `lib/`)
- **Build:** CMake + `arm-none-eabi-gcc`

## Architecture

Four FreeRTOS tasks coordinated by queues, an event group, and a UART mutex:

| Task             | Priority | Role                                                            |
|------------------|----------|-----------------------------------------------------------------|
| `DecoderTask`    | 4        | Consumes the UART ISR buffer and decodes commands               |
| `SamplerTask`    | 4        | Triggers the ADC and streams samples over UART at 10 kHz        |
| `WorkingTask`    | 4        | Blinks the status LED (`PN0`)                                   |
| `RegressionTask` | 4        | Accumulates (x, y) pairs and runs linear regression on demand   |

Synchronization primitives:
- `mEventGroup` — `RUNNING_SAMPLING` and `RUNNING_REGRESSION` bits
- `mQueue` — raw commands pushed from the UART ISR (`UARTIntHandler`)
- `mQueueRegression` — points enqueued for regression
- `mMutex` — serializes UART writes
- `mTimer` — stops sampling after `SamplingTime` seconds

## UART protocol

Commands are read until 6 `#` characters have been received in the buffer.

| Command     | ID | Action                                                       |
|-------------|----|--------------------------------------------------------------|
| `CMD_START` | 1  | Start sampling for `param1` seconds                          |
| `CMD_STOP`  | 2  | Stop sampling                                                |
| `CMD_PLUS`  | 3  | Increment the digital potentiometer                          |
| `CMD_MINUS` | 4  | Decrement the digital potentiometer                          |
| `CMD_STRRG` | 5  | Append point (`param1`, `param2`) to the regression table    |
| `CMD_STRG`  | 6  | Run linear regression over the accumulated table             |
| `CMD_CLRRG` | 7  | Clear the regression table                                   |

Regression response: `#<angular_coef>,<linear_coef>#`
Each ADC sample is sent as ASCII digits followed by `\n`.

## Build

### Prerequisites

- `arm-none-eabi-gcc` (GNU Arm Embedded toolchain)
- `cmake >= 3.0`
- TivaWare installed (`TIVAWARE_HOME` points to its root)
- FreeRTOS installed (`FREERTOS_HOME` points to the root containing `FreeRTOS/Source`)

### Environment variables

```bash
export TIVAWARE_HOME=/path/to/tivaware
export FREERTOS_HOME=/path/to/FreeRTOSv10.x
```

### Compiling

```bash
mkdir build && cd build
cmake ..
make
```

Outputs: `NOME_DO_PROJETO.elf` and `NOME_DO_PROJETO.bin`.

### Flashing

Use `lm4flash` or OpenOCD to program the Tiva LaunchPad:

```bash
lm4flash NOME_DO_PROJETO.bin
```

## Project layout

```
.
├── CMakeLists.txt        # Build config (Cortex-M4F + TivaWare + FreeRTOS + FFTW)
├── linkerscripts/
│   └── linker.ld         # TM4C129 memory map
├── include/              # Public headers
├── source/               # Implementations (main, setup, decoder, regression, ...)
└── lib/                  # Pre-built static libraries (FFTW, driverlib)
```

## Author

Gabriel Alexandre Linhares Calper Seabra — `gcalperseabra@gmail.com`
