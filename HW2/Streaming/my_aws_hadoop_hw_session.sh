#!/bin/bash

# =============Step 1================================ #
#from a terminal login to the AWS cluster that was set up
#from the job workflow
ssh -i topher_aws_ec2.pem  hadoop@ec2-50-112-205-143.us-west-2.compute.amazonaws.com

#from a new terminal (inside the sta250/Stuff/HW2/Streaming directory)
#copy code to the AWS cluster that was just set up
scp -i topher_aws_ec2.pem *.py hadoop@ec2-50-112-205-143.us-west-2.compute.amazonaws.com:~/
scp -i topher_aws_ec2.pem *.sh hadoop@ec2-50-112-205-143.us-west-2.compute.amazonaws.com:~/
# =============Step 2================================ #
#create data directory on HDFS
hadoop fs -mkdir data
#copy from special S3 data structure to HDFS
hadoop distcp s3://sta250bucket/bsamples data/
#...
#wait while it copies
#...
#check success of copy
hadoop fs -ls data/bsamples

# =============Step 3================================ #
#make sure your code works in the AWS environment
hadoop fs -copyToLocal data/bsamples/out_mini.txt ./
cat out_mini.txt | ./mapper.py | sort -k1,1 | ./reducer.py

# =============Step 4================================ #
#officially run the MapReduce script, keep track of job number 
./hadoop_hw.sh
#in a new terminal, check status of job by: 
ssh -i topher_aws_ec2.pem  hadoop@ec2-50-112-205-143.us-west-2.compute.amazonaws.com
#once in AWS environment
lynx http://localhost:9100/

# =============Step 5================================ #
#If successful, copy the files from HDFS to AWS cluster
hadoop fs -copyToLocal binned-output ./
#Now copy from AWS cluster to local machine
scp -i topher_aws_ec2.pem -r hadoop@ec2-50-112-205-143.us-west-2.compute.amazonaws.com:~/binned-output ./

# =============Step 6================================ #
#Clean up HDFS on AWS
hadoop fs -rmr data
hadoop fs -rmr binned-output 
#Terminate all AWS sessions
