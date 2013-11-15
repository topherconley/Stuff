
# =============Login into AWS================================ #
ssh -i topher_aws_ec2.pem  hadoop@[dns name ]

#================= Copy data to Hadoop ======================#
#for testing
hadoop fs -mkdir data
hadoop distcp s3://sta250bucket/mini_groups.txt data/
hadoop fs -ls data/

#for final data
hadoop fs -mkdir final_data
hadoop distcp s3://sta250bucket/groups.txt final_data/
hadoop fs -ls final_data/

#inspect file
hadoop fs -copyToLocal final_data/ ./
less final_data/groups.txt

#directory for writing to file
mkdir -p output/means
mkdir output/unbiased_sample_vars
mkdir output/pop_var

# =============Launch Hive environment================================ #
hive

#avoid great pain, kind of cryptic
set hive.base.inputformat=org.apache.hadoop.hive.ql.io.HiveInputFormat;
set mapred.min.split.size=134217728;

# =================Load data into Hive============================ #


CREATE EXTERNAL TABLE final_groups (
id int,
value double)
ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t'
LINES TERMINATED BY '\n'
LOCATION '/user/hadoop/final_data/';

#make sure "final_groups" table was created
SHOW TABLES;
#To list columns and column types of table.
DESCRIBE EXTENDED final_groups;

# =================Compute within-group means, variances============================ #

#RESOURCE FOR User Defined Functions (UDF) 
#https://cwiki.apache.org/confluence/display/Hive/LanguageManual+UDF

#mean
INSERT OVERWRITE LOCAL DIRECTORY 'output/means/'
SELECT final_groups.id, avg(final_groups.value)
FROM final_groups 
GROUP BY final_groups.id;

#unbiased sample variance
INSERT OVERWRITE LOCAL DIRECTORY 'output/unbiased_sample_vars'
SELECT final_groups.id, var_samp(final_groups.value)
FROM final_groups
GROUP BY final_groups.id;


#population variance (is it any different)
INSERT OVERWRITE LOCAL DIRECTORY 'output/pop_var/'
SELECT final_groups.id, var_pop(final_groups.value)
FROM final_groups
GROUP BY final_groups.id;

