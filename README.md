# GPU-Programming-101

### Description

Lean how to programming GPU with CUDA \
explain concept of GPU structure, memory, etc.

---
### Environment

- GPU: NVIDIA GeForce GTX 1050 VRAM DDR5 2 GB
- CPU: Intel(R) Core(TM) i7-14700K
- OS: Ubuntu 22.04.5 LTS
- Driver Version: 580.178.04
- CUDA Version: 13.0
- nvcc Version: V11.5.119
- g++ Version: g++-10

---
### Compile command

```
nvcc -ccbin g++-10 -O3 [file.cu] -o [executable_file]
```
---
### Run program command
```
./[executable_file]
```