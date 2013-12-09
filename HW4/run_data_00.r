rm(list = ls())
source("probit_mcmc.r")
##############
# RUN THE MCMC

datfile <- "mini_data.txt"
parfile <- "mini_pars.txt"
niter <- 5e4
burnin <-5e5 

#CPU
system.time({
beta_mcmc_cpu <- run_mcmc(data = read.table(datfile, header = TRUE), 
                      niter, burnin, GPU = FALSE)
})
validate_mcmc(beta_mcmc_cpu, parfile, plot.trace = TRUE)

#GPU
#system.time({
#beta_mcmc_gpu <- run_mcmc(data = read.table(datfile, header = TRUE), 
#                      niter = 2.5e3, burnin =5e2, GPU = TRUE)
#})
#validate_mcmc(beta_mcmc_gpu, parfile)

#save(list = ls(all = TRUE), file = "mini_out.rda")
#load("mini_out.rda")



