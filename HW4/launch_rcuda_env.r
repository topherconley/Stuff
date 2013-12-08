
library(RCUDA)
cat("Setting cuGetContext(TRUE)...\n")
cuGetContext(TRUE)
cat("done. Profiling CUDA code...\n")
cat("Loading module...\n")
m = loadModule("rtruncnorm.ptx")
cat("done. Extracting kernel...\n")
kernel = m$rtruncnorm_kernel

#useful for determining the grid-block structure
source("utility.R")
#the wrapper function around the kernel execution
source("rtruncnorm_gpu.r")
