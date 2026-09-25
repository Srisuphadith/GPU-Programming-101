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
Maximum blocks per SM =

Max threads per SM / Max threads per block =

2048 / 1024 =

2 blocks per SM
```

### With register constraints (exclude other constraints)
```
1 block = 256 threads

1 SM can handle:

2048 / 256 = 8 blocks

If each thread uses 32 registers:

1 block uses:

256 × 32 = 8,192 registers

8 blocks use:

8 × 8,192 = 65,536 registers

which equals the total number of registers available per SM.
```

### With shared memory constraints (exclude other constraints)
```
1 block = 256 threads

1 SM can handle:

2048 / 256 = 8 blocks

If 1 block uses 10 KB of shared memory:

Shared memory per block = 49 KB

10 KB < 49 KB → The shared memory usage per block is within the limit.

For 8 blocks:

8 × 10 KB = 80 KB of shared memory

Shared memory per SM = 98 KB

80 KB < 98 KB → The total shared memory usage is within the SM limit.

Therefore, the SM can handle all 8 blocks based on the shared memory constraint.
```