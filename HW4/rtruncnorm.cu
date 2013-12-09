#include <stdio.h>
#include <stdlib.h>

#include <cuda.h>
#include <curand_kernel.h>
#include <math_constants.h>
#include <math.h>
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
    /* Usual block/thread indexing. Note this code, according to Prof. Baines,
       is only robust when the grid and block dims have the structure like;
            (x, 1,1)
       */
    int myblock = blockIdx.x + blockIdx.y * gridDim.x;
    int blocksize = blockDim.x * blockDim.y * blockDim.z;
    int subthread = threadIdx.z*(blockDim.x * blockDim.y) + threadIdx.y*blockDim.x + threadIdx.x;
    int idx = myblock * blocksize + subthread;

    //make sure index is not overrunning the number of threads
    if (idx < n) {

	    // Setup the RNG:
	    curandState rng_state;
	    curand_init(rng_a + idx*rng_b, rng_c, 0, &rng_state);

	    /*
	       Rejection Sampling:
	       (i) First try two-sided truncation naive approach. It works for cases 
where: |high - low| >> 0. which will be true for this homework 
assignment. This code is not robust to really tricky two-sided 
truncation. because the probability of sampling from that region 
is high. 
(ii) When that fails for the one-sided tail regions, that have a small 
probability of being sampled, then apply the Robert approach. 
	     */

	    int accepted = 0;
	    int iter_count = 0;
	    while (accepted == 0 && iter_count < max_tries) {
		    iter_count = iter_count + 1;
		    vals[idx] = mu[idx] + sigma[idx] * curand_normal(&rng_state); 
		    //accepted or not?
		    if (vals[idx] > lo[idx] && vals[idx] <= hi[idx]) {
			    accepted = 1;
			    return;
		    }
	    }

	    /*If it never accepted, then for this assignment we can assume that
	      we have a case of heavy right or left truncation where we are 
	      trying to sample from only one of the tails. 
	     */
	    if (accepted == 0) {

		    /*right truncation requires adaptation because the Robert-rejection 
		      sampling for one-sided truncation defaults to left truncation*/

		    //indicate whether it is right truncated to flip the sign of the 
		    //sampled value if right_trunc = 1.
		    int right_trunc;

		    float mu_tmp = mu[idx];
		    float lo_tmp = lo[idx];

		    if (hi[idx] <  mu_tmp) {
			    right_trunc = 1;
			    mu_tmp = -1 * mu_tmp;
			    lo_tmp = -1 * hi[idx];
		    } else {
			    //left truncation
			    right_trunc = 0;
		    }

		    //see Appendix A below
		    int mu_minus = ( lo_tmp  - mu_tmp ) / sigma[idx];

		    /****************************************/
		    /* left truncation, right tail sampling*/

		    /*step 0: set the optimal rate parameter for the exponential 
		      distribution*/
		    float alpha =  ( mu_minus + sqrtf(mu_minus*mu_minus + 4) ) / 2;

		    while (accepted == 0) {
			    /*step 1:generate: z ~ Expo(\alpha, \mu_minus)
			      by the inv-cdf transform (since z is continous)
			     */
			    float z = mu_minus - log (curand_uniform(&rng_state)) / alpha; 

			    /*step 2: compute ratio h(z) / ( M * g(z) ) */
			    float psi;
			    float offset1 = alpha - z;
			    float offset2;
			    if (mu_minus < alpha) { 
				    psi  = exp( -0.5 * offset1*offset1 );
			    } else {
				    offset2 = mu_minus - alpha;
				    psi = exp( -0.5 * ( offset1*offset1 + offset2*offset2 ) );
			    }

			    //accepted the sample
			    if (curand_uniform(&rng_state) <= psi) {
				    if (right_trunc == 1) {
					    vals[idx] = -1 * (mu_tmp + sigma[idx]*z);
				    } else {
					    vals[idx] = mu_tmp + sigma[idx]*z;
				    }
				    accepted = 1;
				    return;
			    }
		    } // END while loop
	    } // END Robert rejection-sampling.
    }
    return;
} // END rtruncnorm_kernel

} // END extern "C"

/*Appendix A*/
/*Need to adjust the truncation boundary of X, which is
          lo[idx] to the truncation boundary of a standard normal (Z):
          
          Std Normal (left truncation):
          Z ~ N(\mu = 0, \sigma = 1, low_z = \mu_minus, hi_z = \Inf)
          
          Standardized location-scale relation:
          Z = (X - \mu_x) / \sigma_x 
          X = \mu_x + \sigma_x * Z
          X ~ N(\mu = \mu_x, 
                \sigma = \sigma_x, 
                lo[idx] = \sigma_x*\mu_minus + \mu_x,
                \Inf)

          Then:
          \mu_minus = ( lo[idx] - \mu_x ) / sigma_x;

*/


