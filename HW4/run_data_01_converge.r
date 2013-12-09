rm(list = ls())
source("probit_mcmc.r")
##############
# RUN THE MCMC

datfile <- "data_01.txt"
parfile <- "pars_01.txt"
niter <- 1e4
burnin <- 2e5

#CPU
system.time({
beta_mcmc_cpu <- run_mcmc(data = read.table(datfile, header = TRUE), 
                      niter, burnin, GPU = FALSE)
})
validate_mcmc(beta_mcmc_cpu, parfile, plot.trace = TRUE)


