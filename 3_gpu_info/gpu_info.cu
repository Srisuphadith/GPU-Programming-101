#include <cuda_runtime.h>
#include <iostream>
#include <iomanip>

int main()
{
    int device = 0;

    // Get number of CUDA devices
    int deviceCount = 0;
    cudaGetDeviceCount(&deviceCount);

    if (deviceCount == 0) {
        std::cerr << "No CUDA device found.\n";
        return 1;
    }

    // Get current device
    cudaGetDevice(&device);

    cudaDeviceProp prop;
    cudaGetDeviceProperties(&prop, device);

    std::cout << "===== CUDA Device Characterization =====\n\n";

    // Basic information
    std::cout << "Device name                    : "
              << prop.name << '\n';

    std::cout << "Compute capability             : "
              << prop.major << "." << prop.minor << '\n';

    std::cout << "Number of SMs                  : "
              << prop.multiProcessorCount << '\n';

    // Thread / warp limits
    std::cout << "Max threads per SM             : "
              << prop.maxThreadsPerMultiProcessor << '\n';

    std::cout << "Max threads per block          : "
              << prop.maxThreadsPerBlock << '\n';

    std::cout << "Max warps per SM               : "
              << prop.maxThreadsPerMultiProcessor / prop.warpSize
              << '\n';

//#if CUDART_VERSION >= 11000
//    std::cout << "Max blocks per SM              : "
//              << prop.maxBlocksPerMultiprocessor << '\n';
//#else
//    std::cout << "Max blocks per SM              : unavailable\n";
//#endif

    std::cout << "Warp size                      : "
              << prop.warpSize << '\n';

    // Register resources
    std::cout << "Registers per SM               : "
              << prop.regsPerMultiprocessor << '\n';

    std::cout << "Registers per block            : "
              << prop.regsPerBlock << '\n';

    // Shared memory
    std::cout << "Shared memory per SM           : "
              << prop.sharedMemPerMultiprocessor
              << " bytes\n";

    std::cout << "Shared memory per block        : "
              << prop.sharedMemPerBlock
              << " bytes\n";

    // Cache / global memory
    std::cout << "L2 cache size                  : "
              << prop.l2CacheSize
              << " bytes\n";

    std::cout << "Global memory total            : "
              << prop.totalGlobalMem
              << " bytes\n";

    // Memory information
    std::cout << "Memory clock rate              : "
              << prop.memoryClockRate
              << " kHz\n";

    std::cout << "Memory bus width               : "
              << prop.memoryBusWidth
              << " bits\n";

    double bandwidth =
        2.0 *
        prop.memoryClockRate * 1000.0 *
        prop.memoryBusWidth / 8.0;

    double bandwidthGBs =
        bandwidth / 1e9;

    std::cout << std::fixed << std::setprecision(2);

    std::cout << "Peak memory bandwidth          : "
              << bandwidthGBs
              << " GB/s\n";

    std::cout << "\n=========================================\n";

    return 0;
}