# Shell scripts

This README outlines the details of various shell scripts which are part of this application.

### execute-hadoop / execute-kinesis-hadoop 
The main functionality of these shell scripts is to execute Map-Reduce Java code.The only difference is that these shell scripts are invoked by different lambda functions. execute-hadoop is invoked by shellExecuter whereas execute-kinesis-hadoop is invoked by kinesisReader. Upon successful completion of the Java code, both of these shell scripts merge the output files created on HDFS. The final merged output file is uploaded to the S3 bucket.

### log-generator
This shell scripts generates the fake live streaming of the logs. The high level functionality is to read the inputSample.txt file and append its content to the log file which looks like continuous streaming of the log statements.

Parameters expected-

i - number of iterations. By default, this is 10
d - delay between each iteration. By default, this is 5 seconds
