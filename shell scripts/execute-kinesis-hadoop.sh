clear
echo "**********************************************************************" >> kinesisHadoopLogs.log
echo "`date`: **** Starting the script execution on the Hadoop cluster ****" >> kinesisHadoopLogs.log
echo "**********************************************************************" >> kinesisHadoopLogs.log
JAR_FILE=./logprocessor-1.0.jar
FILE_PATH=$1
FILE_TO_SCAN=$2
DATE_SUFFIX=`date +"%Y%m%d%H%M"`
ZERO=0
hadoopFunc(){
	aws s3 cp s3://log-analytics-sk/${FILE_PATH} ./
	echo "`date`: Creating data folder" >> kinesisHadoopLogs.log
	hadoop fs -mkdir /data
	echo "`date`: Created data folder" >> kinesisHadoopLogs.log
	echo "`date`: Moving input file into data folder" >> kinesisHadoopLogs.log
	hadoop fs -put ./${FILE_TO_SCAN} /data
	echo "`date`: Moved input file into data folder" >> kinesisHadoopLogs.log
	echo "`date`: Executing hadoop code" >> kinesisHadoopLogs.log
	hadoop jar ./logprocessor-1.0.jar com.cs.mapreduce.logprocessor.LogAnalyzer /data/${FILE_TO_SCAN} /data/output >> kinesisHadoopLogs.log
	rc=$?
	echo "`date`: Executed hadoop code"	 >> kinesisHadoopLogs.log
	echo "`date`: The hadoop script returned with code: " $rc >> kinesisHadoopLogs.log
	if [ $rc -eq $ZERO ]
	then
		echo "`date`: 'Merging output file" >> kinesisHadoopLogs.log
		hdfs dfs -getmerge /data/output ./out_${DATE_SUFFIX}.csv
		echo "`date`: Merged output file" >> kinesisHadoopLogs.log
		aws s3 cp ./out_${DATE_SUFFIX}.csv s3://hadoopsetup/output/
		echo "`date`: Output file is uploaded to S3" >> kinesisHadoopLogs.log
		hadoop fs -rm -r /data
		return 0
	else
		echo "`date`: Hadoop code execution failed with return code: " $rc
		echo "`date`: Output file is not uploaded to S3" >> kinesisHadoopLogs.log
		return $rc
	fi
	
}
hadoop fs -rm -r /data
if [ -s $JAR_FILE ]
then
	hadoopFunc
	rs=$?
	echo "`date`: The Hadoop Function is executed with code: " $rs
else
	echo "`date`: Downloading Map reduce JAR FILE" >> kinesisHadoopLogs.log
	aws s3 cp s3://hadoopsetup/jar/logprocessor-1.0.jar ./
	echo "`date`: Downloaded log processing jar file" >> kinesisHadoopLogs.log
	hadoopFunc
	rs=$?
	echo "`date`: The Hadoop Function executed with code: " $rs >> kinesisHadoopLogs.log
fi
echo "`date`: ******** Code exit *********" >> kinesisHadoopLogs.log
