#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <math.h>

// kernel function for vector addition
__global__ void vecAdd(float *A_d, float *B_d, float *C_d, float *D_d, int N)
{

    // calculate global thread index
    int i = blockIdx.x * blockDim.x + threadIdx.x;
    // check if the thread index is within the bounds of the array
    if (i < N)
    {
        // perform vector addition
        D_d[i] = A_d[i] + B_d[i] + C_d[i];
    }
}

int main()
{

    int vect_size = 1000000;
    int size = vect_size * sizeof(float);

    // host var
    float *A_h = (float *)malloc(size);
    float *B_h = (float *)malloc(size);
    float *C_h = (float *)malloc(size);
    float *D_h = (float *)malloc(size);

    // initialize host arrays
    for (int i = 0; i < vect_size; i++)
    {
        A_h[i] = i + 1 + 0.5;
        B_h[i] = i * 2 + 0.7;
        C_h[i] = i * 3 + 0.7;
    }

    // device var
    float *A_d, *B_d, *C_d, *D_d;
    cudaMalloc((void **)&A_d, size);
    cudaMalloc((void **)&B_d, size);
    cudaMalloc((void **)&C_d, size);
    cudaMalloc((void **)&D_d, size);

    // copy data from host to device
    cudaMemcpy(A_d, A_h, size, cudaMemcpyHostToDevice);
    cudaMemcpy(B_d, B_h, size, cudaMemcpyHostToDevice);
    cudaMemcpy(C_d, C_h, size, cudaMemcpyHostToDevice);

    // --------------------set up execution configuration--------------------
    // number of threads per block
    int thread_num = 256;
    // calculate number of blocks needed to cover all elements
    int block_num = (vect_size + thread_num - 1) / thread_num;
    // print execution configuration
    printf("vect_size: %d\n", vect_size);
    printf("block: %d\n", block_num);
    printf("thread: %d\n", thread_num);
    printf("total thread: %d\n", block_num * thread_num);
    // --------------------set up execution configuration--------------------

    // launch kernel
    vecAdd<<<block_num, thread_num>>>(A_d, B_d, C_d, D_d, vect_size);

    // check for kernel launch errors
    cudaError_t error = cudaGetLastError();
    if (error != cudaSuccess)
    {
        printf("Kernel launch error: %s\n", cudaGetErrorString(error));
        return 1;
    }

    // synchronize device
    cudaDeviceSynchronize();

    // copy result from device to host
    cudaMemcpy(D_h, D_d, size, cudaMemcpyDeviceToHost);

    // free device memory
    cudaFree(A_d);
    cudaFree(B_d);
    cudaFree(C_d);
    cudaFree(D_d);

    float *expected_result = (float *)malloc(size);
    int fault_cnt = 0;
    // check results
    for (int i = 0; i < vect_size; i++)
    {
        expected_result[i] = A_h[i] + B_h[i] + C_h[i];
        if (expected_result[i] - D_h[i] != (float)0)
        {
            fault_cnt++;
        }
    }

    // free host memory
    free(A_h);
    free(B_h);
    free(C_h);
    free(D_h);
    free(expected_result);

    // print result
    if (fault_cnt == 0)
    {
        printf("PASS: all %d elements correct\n", vect_size);
    }
    else
    {
        printf("FAIL: %d of %d elements wrong\n", fault_cnt, vect_size);
    }
}