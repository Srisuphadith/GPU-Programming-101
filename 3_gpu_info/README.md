# GTX 1050 Information

```
===== CUDA Device Characterization =====

Device name                    : NVIDIA GeForce GTX 1050
Compute capability             : 6.1
Number of SMs                  : 5
Max threads per SM             : 2048
Max threads per block          : 1024
Max warps per SM               : 64
Warp size                      : 32
Registers per SM               : 65536
Registers per block            : 65536
Shared memory per SM           : 98304 bytes
Shared memory per block        : 49152 bytes
L2 cache size                  : 1048576 bytes
Global memory total            : 2085748736 bytes
Memory clock rate              : 3504000 kHz
Memory bus width               : 128 bits
Peak memory bandwidth          : 112.13 GB/s

=========================================
```

### max_block_per_sm (exclude other constraints)
```
max_block_per_sm = 
Max_threads_per_SM / Max_threads_per_block = 
2048 / 1024 = 
2 block_per_sm
```

```
1 block = 256 threads

1 SM can handle:
2048 / 256 = 8 blocks

If 1 thread uses 32 registers:

1 block uses:
256 × 32 = 8,192 registers

8 blocks use:
8 × 8,192 = 65,536 registers

which equals Registers per SM.

```