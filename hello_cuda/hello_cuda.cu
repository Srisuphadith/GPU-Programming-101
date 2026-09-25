#include <stdio.h>

// This program prints "hello from GPU thread" from each thread in a CUDA kernel.
__global__ void hello()
{
    printf("hello from GPU thread %d\n", threadIdx.x);
}
int main()
{
    // Launch the kernel with 2 blocks and 8 threads per block
    hello<<<2, 8>>>();
    // Synchronize the device to ensure all threads have completed before exiting
    cudaDeviceSynchronize();
    return 0;
}