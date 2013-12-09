    

gpu <- c(173.230, 178.995, 232.663, 746.910)
cpu <- c(2.070, 8.488, 57.727, 499.047)
#data size
n <- c(1e3, 1e4, 1e5, 1e6)
pdf("data_chunk_performance.pdf")
plot(log(n), gpu, type = 'b', pch = 19, main = "data chunk performance", 
    ylim = c(0, 800), ylab = "elapsed time (seconds)", 
    xlab = "log (sample size of y)", col = "blue")
lines(log(n), cpu, type = 'b', pch = 19)
dev.off()
