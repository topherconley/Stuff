library(RCUDA)

cat("Setting cuGetContext(TRUE)...\n")
cuGetContext(TRUE)
cat("done. Profiling CUDA code...\n")

cat("Loading module...\n")
m = loadModule("rtruncnorm.ptx")
cat("done. Extracting kernel...\n")
k = m$rtruncnorm_kernel
cat("done. Setting up miscellaneous stuff...\n")
N = 1e6L
x = rnorm(N)
cat("done. Setting mu and sigma...\n")
mu = rep(2, times = N)
sigma = rep(1, times = N)

#useful for determining the grid-block structure
source("utility.R")
# if...
# N = 1,000,000
# => 1954 blocks of 512 threads will suffice
# => (62 x 32) grid, (512 x 1 x 1) blocks
bg <- computed_grid(N)
grid_dims <- bg$grid_dims
block_dims <- bg$block_dims

cat("Grid size:\n")
print(grid_dims)
cat("Block size:\n")
print(block_dims)

nthreads <- prod(grid_dims)*prod(block_dims) 
cat("Total number of threads to launch = ",nthreads,"\n")
if (nthreads < N){
    stop("Grid is not large enough...!")
}

cat("Running CUDA kernel...\n")

cu_time <- system.time({
    cat("Copying random N(0,1)'s to device...\n")
    mem = copyToDevice(x)
    .cuda(k, mem, N, mu, sigma, gridDim = grid_dims, blockDim = block_dims)
    cat("Copying result back from device...\n")
    cu_ret = copyFromDevice(obj=mem,nels=mem@nels,type="float")
})

r_time <- system.time({
    r_ret <- dnorm(x,mean=mu,sd=sigma)
})

cat("done. Finished profile run! :)\n")

# Not the best comparison but a rough real-world comparison:
cat("CUDA time:\n")
print(cu_time)

cat("R time:\n")
print(r_time)

# Differences due to floating point vs. double...
tdiff <- sum(abs(cu_ret - r_ret))
cat("Difference in RCUDA vs R results = ",tdiff,"\n")

cat("Differences in first few values...\n")
print(abs(diff(head(cu_ret)-head(r_ret))))

cat("Differences in last few values...\n")
print(abs(diff(tail(cu_ret)-tail(r_ret))))

# Note: the CUDA kernel can be launched without ever allocating
# memory on the device! To do this:
#cu_ret_v2 <- .cuda(k, "x"=x, N, mu, sigma, gridDim=grid_dims, blockDim=block_dims, outputs="x")
#cdiff <- sum(abs(cu_ret - cu_ret_v2))
#cat("Difference in RCUDA methods = ",cdiff,"\n")

# Free memory...
rm(list=ls())


