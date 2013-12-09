
#do not call this function without first calling: source("launch_rcuda_env.r")
rtruncnorm_gpu <- function(k, x, N, mu, sigma, lo, hi, bg) {  
  
  #make sure primitive type ints are passed in as such
  stopifnot(is.integer(N))
  max_tries = 2000L
  rng_a = 5L; rng_b = 11L; rng_c = 17L;
  
  mem = copyToDevice(x)
  .cuda(k, mem, N,
        mu, sigma, 
        lo, hi,
        N,N,N,N,
        max_tries, 
        rng_a, rng_b, rng_c,
        gridDim = bg$grid_dims, blockDim = bg$block_dims)
  #cat("Copying result back from device...\n")
  copyFromDevice(obj=mem,nels=mem@nels,type="float")
}

#this altered functions assumes that the memory has been copied to device already.
#do not call this function without first calling: source("launch_rcuda_env.r")
rtruncnorm_gpu_mcmc <- function(k, mem, N, mu, sigma, lo, hi, bg) {  
  
  #make sure primitive type ints are passed in as such
  stopifnot(is.integer(N))
  max_tries = 2000L
  rng_a = 5L; rng_b = 11L; rng_c = 17L;
  
  .cuda(k, mem, N,
        mu, sigma, 
        lo, hi,
        N,N,N,N,
        max_tries, 
        rng_a, rng_b, rng_c,
        gridDim = bg$grid_dims, blockDim = bg$block_dims)
  #cat("Copying result back from device...\n")
  copyFromDevice(obj=mem,nels=mem@nels,type="float")
}






