rm(list = ls())
source("probit_mcmc.r")
##############
# RUN THE MCMC

#CPU
beta_mcmc_cpu <- run_mcmc(data = read.table("mini_data.txt", header = TRUE), 
                      niter = 1e6, burnin = 1e5, GPU = FALSE)
validate_mcmc(beta_mcmc_cpu, "mini_pars.txt")

#GPU
beta_mcmc_gpu <- run_mcmc(data = read.table("mini_data.txt", header = TRUE), 
                      niter = 1e6, burnin = 1e5, GPU = TRUE)
validate_mcmc(beta_mcmc_gpu, "mini_pars.txt")

#save(list = ls(all = TRUE), file = "mini_out.rda")
#load("mini_out.rda")



