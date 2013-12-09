library(RCUDA)
cat("Setting cuGetContext(TRUE)...\n")
cuGetContext(TRUE)
cat("done. Profiling CUDA code...\n")
cat("Loading module...\n")
m = loadModule("rtruncnorm.ptx")
cat("done. Extracting kernel...\n")
k = m$rtruncnorm_kernel

#useful for determining the grid-block structure
source("utility.R")
N <- 100L;
bg <- compute_grid(N);
#make sure primitive type ints are passed in as such
stopifnot(is.integer(N))
max_tries = 2000L
rng_a = 5L; rng_b = 11L; rng_c = 17L;
x <- runif(N)
mu <- rep(2,N)
sigma <- rep(1,N)
lo <- rep(0,N);
hi <- rep(1.5, N);
#cat("Copying random N(0,1)'s to device...\n")
mem = copyToDevice(x)
.cuda(k, mem, N,
      mu, sigma,
      lo, hi,
      N,N,N,N,
      max_tries,
      rng_a, rng_b, rng_c,
      gridDim = bg$grid_dims, blockDim = bg$block_dims)
#cat("Copying result back from device...\n")
cu_ret <- copyFromDevice(obj=mem,nels=mem@nels,type="float")

