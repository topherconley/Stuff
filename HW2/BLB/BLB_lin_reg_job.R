
mini <- TRUE 
local_machine <- TRUE
verbose <- TRUE
#============================== Setup for running on Gauss... ==============================#

args <- commandArgs(TRUE)

cat("Command-line arguments:\n")
print(args)

####
# sim_start ==> Lowest possible dataset number
###

###################
sim_start <- 1000
###################

if (length(args)==0){
  sim_num <- sim_start + 1
  set.seed(121231)
} else {
  # SLURM can use either 0- or 1-indexing...
  # Lets use 1-indexing here...
  sim_num <- sim_start + as.numeric(args[1])
  sim_seed <- (762*(sim_num-1) + 121231)
}

cat(paste("\nAnalyzing dataset number ",sim_num,"...\n\n",sep=""))

#============================== Run the simulation study ==============================#

# Load packages:
library(BH)
library(bigmemory.sri)
library(bigmemory)
library(biganalytics)

# I/O specifications:
#local machine or gauss?
if(!local_machine) {
    datapath <- "/home/pdbaines/data"
} else {
    datapath <- "/Users/dreambig/myrepos/sta250/Stuff/HW2/BLB"
}
outpath <- "output/"

# mini or full?
if (mini){
	rootfilename <- "blb_lin_reg_mini"
} else {
	rootfilename <- "blb_lin_reg_data"
}

# Filenames:
infilename <- paste0(rootfilename,".txt")
backingfilename <- paste0(rootfilename,".bin")
descriptorfilename <- paste0(rootfilename,".desc")

# Set up I/O stuff:
infile <- paste(datapath,infilename,sep="/")
backingfile <- paste(datapath,backingfilename,sep="/")
descriptorfile <- paste(datapath,descriptorfilename,sep="/")
 
# Attach big.matrix :
if (verbose){
    cat("Attaching big.matrix...\n")
}
dat <- attach.big.matrix(dget(descriptorfile),backingpath=datapath)

# dataset size (1m):
n <- nrow(dat)

# number of covariates (last column is response):
d <- ncol(dat)-1

# Remaining BLB specs:
S <- 5
R <- 50
gamma <- 0.7
b <- as.integer(n^gamma)

# Find r and s indices:
source("BLB_utils.R")
sr_pair <- sr_index(sim_num - sim_start, S, R)
s_index <- sr_pair[1]; r_index <- sr_pair[2];

# Extract the subset:

#each subset of S has the same observations
set.seed(s_index)
subset_s <- sample.int(n = n, size = b)
dat_s <- dat[subset_s,]

#data frame is convenient representation for lm() functionality
df_s <- data.frame(y_s = data_s[,d + 1], X_s = dat_s[,seq_len(d)])

# Reset simulation seed:
#each rth replication has a different resample of rows based on the multinomial
if (length(args)==0) {
    set.seed(121231)
} else {
    set.seed(sim_seed)
}

# Bootstrap dataset:
bootstrap_resamples <- rmultinom(n = 1, size = n, prob = rep(1/b, times = b))


# Fit lm:
fit_sr <- lm(y_s ~ ., data = df_s, weights = bootstrap_resamples) 

# Output file:
outfile = paste0("output/","coef_",sprintf("%02d",s_index),"_",sprintf("%02d",r_index),".txt")
# Save estimates to file:
beta_lm_estimates <- data.frame(beta_lm_coef = summary(fit_sr)$coefficients[,1])
write.table(x = beta_lm_estimates, file = outfile)

