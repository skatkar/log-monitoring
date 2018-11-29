clear
echo "**** Starting the script execution on the Hadoop cluster ****" >> hadoopLogs.log
JAR_FILE=./logprocessor-1.0.jar
FILE_TO_SCAN=$1
DATE_SUFFIX=`date +"%Y%m%d%H%M"`
ZERO=0
hadoopFunc(){
	aws s3 cp s3://hadoopsetup/input/${FILE_TO_SCAN} ./
	echo "Creating data folder" >> hadoopLogs.log
	hadoop fs -mkdir /data
	echo "Created data folder" >> hadoopLogs.log
	echo "Moving input file into data folder" >> hadoopLogs.log
	hadoop fs -put ./${FILE_TO_SCAN} /data
	echo "Moved input file into data folder" >> hadoopLogs.log
	echo "Executing hadoop code" >> hadoopLogs.log
	hadoop jar ./logprocessor-1.0.jar com.cs.mapreduce.logprocessor.LogAnalyzer /data/${FILE_TO_SCAN} /data/output >> hadoopLogs.log
	rc=$?
	echo "Executed hadoop code"	 >> hadoopLogs.log
	echo "The hadoop script returned with code: " $rc >> hadoopLogs.log
	if [ $rc -eq $ZERO ]
	then
		echo "Merging output file" >> hadoopLogs.log
		hdfs dfs -getmerge /data/output ./out_${DATE_SUFFIX}.csv
		echo "Merged output file" >> hadoopLogs.log
		aws s3 cp ./out_${DATE_SUFFIX}.csv s3://hadoopsetup/output/
		echo "Output file is uploaded to S3" >> hadoopLogs.log
		hadoop fs -rm -r /data
		return 0
	else
		echo "Hadoop code execution failed with return code: " $rc
		echo "Output file is not uploaded to S3" >> hadoopLogs.log
		return $rc
	fi
	
}
hadoop fs -rm -r /data
if [ -s $JAR_FILE ]
then
	hadoopFunc
	rs=$?
	echo "The Hadoop Function is executed with code: " $rs
else
	echo "Downloading Map reduce JAR FILE" >> hadoopLogs.log
	aws s3 cp s3://hadoopsetup/jar/logprocessor-1.0.jar ./
	echo "Downloaded log processing jar file" >> hadoopLogs.log
	hadoopFunc
	rs=$?
	echo "The Hadoop Function executed with code: " $rs >> hadoopLogs.log
fi
echo "******** Code exit *********" >> hadoopLogs.log
