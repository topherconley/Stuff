rm(list = ls())

GPU <- TRUE
max_tries_r <- 25L
ntimes <- 8L
log_n <- sapply(seq_len(ntimes), function(k) log(10^k))

if (!GPU) {
  source("rtruncnorm_cpu.r")
  library(Rcpp)
  sourceCpp("rtruncnorm_cpu.cpp")
  cpu_times <- sapply(seq_len(ntimes), function(k) {
    system.time({
      N <- as.integer(10^k)
      mu <- rep(2,N)
      sd <- rep(1,N)
      lo <- rep(0,N)
      hi <- rep(1.5, N)
      rtruncnorm_cpu_rcpp(n = N, mu, sd, 
                          lo, hi,
                          max_tries_r)
    })
  })
  pdf("q1e_cpu_run_time.pdf")
  plot(log_n, cpu_times["elapsed",], type = 'b', pch = 19, 
       main = "CPU based on Rcpp code", xlab = "log(number sampled)", ylab = "elapsed time (seconds)" )
  dev.off()
    
} else {
  
  source("launch_rcuda_env.r")
  gpu_times <- sapply(seq_len(ntimes), function(k) {
    system.time({
      N <- as.integer(10^k)
      mu <- rep(2,N)
      sd <- rep(1,N)
      lo <- rep(0,N)
      hi <- rep(1.5, N)
      rtruncnorm_gpu(kernel, x = runif(N), N, mu, sd, lo, hi, 
                     computed_grid(N))  
    })
  })
  
  pdf("q1e_gpu_run_time.pdf")
  plot(log_n, gpu_times["elapsed",], type = 'b', pch = 19, 
       main = "GPU based on Rcpp code", xlab = "log(number sampled)", ylab = "elapsed time (seconds)" )
  dev.off()  
}
