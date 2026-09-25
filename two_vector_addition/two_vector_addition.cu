/*
two_vector_addition.cu
This program adds two vectors using CUDA
with error checking for memory allocation, data transfer, kernel launch, and device synchronization.
*/
#include <stdio.h>
#include <cuda_runtime.h>

// Kernel function to add two vectors
__global__ void add(int *a, int *b, int *c)
{
    int i = threadIdx.x;

    c[i] = a[i] + b[i];
}
// device mean GPU, Host mean CPU
int main()
{
    // Host arrays
    int a[10] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10};
    int b[10] = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100};
    int c[10];

    // Device arrays
    int *d_a, *d_b, *d_c;

    // Allocate device memory with error checking
    cudaError_t err_malloc = cudaMalloc(&d_a, 10 * sizeof(int));
    if (err_malloc != cudaSuccess)
    {
        printf("Error allocating device memory for a: %s\n", cudaGetErrorString(err_malloc));
        return -1;
    }

    err_malloc = cudaMalloc(&d_b, 10 * sizeof(int));
    if (err_malloc != cudaSuccess)
    {
        printf("Error allocating device memory for b: %s\n", cudaGetErrorString(err_malloc));
        return -1;
    }

    err_malloc = cudaMalloc(&d_c, 10 * sizeof(int));
    if (err_malloc != cudaSuccess)
    {
        printf("Error allocating device memory for c: %s\n", cudaGetErrorString(err_malloc));
        return -1;
    }

    // Copy data from host to device with error checking
    cudaError_t err_memcpy = cudaMemcpy(d_a, a, 10 * sizeof(int), cudaMemcpyHostToDevice);
    if (err_memcpy != cudaSuccess)
    {
        printf("Error copying data from host to device for a: %s\n", cudaGetErrorString(err_memcpy));
        return -1;
    }

    err_memcpy = cudaMemcpy(d_b, b, 10 * sizeof(int), cudaMemcpyHostToDevice);
    if (err_memcpy != cudaSuccess)
    {
        printf("Error copying data from host to device for b: %s\n", cudaGetErrorString(err_memcpy));
        return -1;
    }

    // Launch kernel to add vectors
    add<<<1, 10>>>(d_a, d_b, d_c);

    // Check for kernel launch errors
    cudaError_t err = cudaGetLastError();
    if (err != cudaSuccess)
    {
        printf("Launch error: %s\n",
               cudaGetErrorString(err));
    }

    // Synchronize device and check for errors
    cudaError_t err_sync = cudaDeviceSynchronize();
    if (err_sync != cudaSuccess)
    {
        printf("Sync error: %s\n",
               cudaGetErrorString(err_sync));
    }

    // Copy result from device to host with error checking
    err_memcpy = cudaMemcpy(c, d_c, 10 * sizeof(int), cudaMemcpyDeviceToHost);
    if (err_memcpy != cudaSuccess)
    {
        printf("Error copying data from device to host for c: %s\n", cudaGetErrorString(err_memcpy));
        return -1;
    }

    // Print the result
    for (int i = 0; i < 10; i++)
    {
        printf("%d + %d = %d\n", a[i], b[i], c[i]);
    }

    // Free device memory
    cudaError_t err_free = cudaFree(d_a);
    if (err_free != cudaSuccess)
    {
        printf("Error freeing device memory for a: %s\n", cudaGetErrorString(err_free));
    }

    err_free = cudaFree(d_b);
    if (err_free != cudaSuccess)
    {
        printf("Error freeing device memory for b: %s\n", cudaGetErrorString(err_free));
    }

    err_free = cudaFree(d_c);
    if (err_free != cudaSuccess)
    {
        printf("Error freeing device memory for c: %s\n", cudaGetErrorString(err_free));
    }

    return 0;
}