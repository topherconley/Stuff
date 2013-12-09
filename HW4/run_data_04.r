rm(list = ls())
source("probit_mcmc.r")
##############
# RUN THE MCMC

datfile <- "data_04.txt"
parfile <- "pars_04.txt"
niter <- 2e3
burnin <- 5e2

#CPU
system.time({
beta_mcmc_cpu <- run_mcmc(data = read.table(datfile, header = TRUE), 
                      niter, burnin, GPU = FALSE)
})
validate_mcmc(beta_mcmc_cpu, parfile)

#GPU
system.time({
beta_mcmc_gpu <- run_mcmc(data = read.table(datfile, header = TRUE), 
                      niter, burnin, GPU = TRUE)
})
validate_mcmc(beta_mcmc_gpu, parfile, plot.trace = TRUE)

#save(list = ls(all = TRUE), file = "mini_out.rda")
#load("mini_out.rda")



