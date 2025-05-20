FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    make \
    gcc-arm-none-eabi \
    gdb-arm-none-eabi \
 && rm -rf /var/lib/apt/lists/*

# Local paths to dependencies. Update these paths as needed.
ENV TIVAWARE_HOME=/opt/TivaWare \
    FREERTOS_HOME=/opt/FreeRTOS

WORKDIR /app
COPY . /app

RUN mkdir build && cd build && cmake .. && make -j$(nproc)

CMD ["/bin/bash"]
