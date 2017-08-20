#!/bin/bash

make clean && \
make && \
qemu-system-x86_64 -kernel bin/kernel -m 4G -d int -s
