#!/bin/bash

chunks=`ls run_data*.r | xargs`

for chunk in $chunks
do
	echo "Processing $chunk"
	R CMD BATCH $chunk > ${chunk}.Rout
done
 
