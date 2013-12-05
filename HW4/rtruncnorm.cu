#include <stdio.h>
#include <stdlib.h>

#include <cuda.h>
#include <curand_kernel.h>
#include <math_constants.h>
//for boolean functionality
#include <stdbool.h>

extern "C"
{

__global__ void 
rtruncnorm_kernel(float *vals, int n, 
                  float *mu, float *sigma, 
                  float *lo, float *hi,
                  int mu_len, int sigma_len,
                  int lo_len, int hi_len,
                  int max_tries, 
                  int rng_a, int rng_b, int rng_c)
{
    // Usual block/thread indexing...
    int myblock = blockIdx.x + blockIdx.y * gridDim.x;
    int blocksize = blockDim.x * blockDim.y * blockDim.z;
    int subthread = threadIdx.z*(blockDim.x * blockDim.y) + threadIdx.y*blockDim.x + threadIdx.x;
    int idx = myblock * blocksize + subthread;

    //mkae sure index is not overrunning the number of threads
    if (idx < N) {
        printf("WARNING! Exceeded number of threads. Did not sample.");
        return;
    }

    // Setup the RNG:
    curandState rng_state;
    curand_init(rng_a + idx*rng_b, rng_c, 0, &rng_state);

    //Rejection Sampling:
    int rejected = 0;
    int iter_count = 0;
    while (rejected == 0 && iter_count < max_tries) {
        iter_count = iter_count + 1;
        vals[idx] = mu[idx] + sigma[idx] * curand_normal(&rng_state); 
        if (vals[idx] > lo[idx] && vals[idx] <= hi[idx]) {
            rejected = 1;
        }
    }
    return;
}

} // END extern "C"

