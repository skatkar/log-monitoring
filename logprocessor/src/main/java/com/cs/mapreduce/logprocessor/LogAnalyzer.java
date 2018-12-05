package com.cs.mapreduce.logprocessor;

import java.io.IOException;

import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
/**
 * 
 * @author Swapnil
 * This is an entry class for running MapReduce jog
 * You need to pass two arguments, 1) Input file path, 2) Output folder path
 */
public class LogAnalyzer {

	public static void main(String[] args) throws IOException, ClassNotFoundException, InterruptedException, Exception {
		System.out.println(" Starting the MapReduce program...");

		if (args.length != 2) {
			System.err.println("Usage: LogAnalyzer <input path> <output path>");
			System.exit(-1);
		}

		Job job = new Job();
		job.setJarByClass(LogAnalyzer.class);
		job.setJobName("Log Analyzer");
		System.out.println(" Processing the input file :" + args[0]);
		FileInputFormat.addInputPath(job, new Path(args[0]));
		FileOutputFormat.setOutputPath(job, new Path(args[1]));// pull this outside Hadoop for reporting
		System.out.println(" setting the mapper class");
		job.setMapperClass(LogAnalyzerMapper.class);
		job.setReducerClass(LogAnalyzerReducer.class);

		job.setOutputKeyClass(Text.class);
		job.setOutputValueClass(IntWritable.class);

		System.exit(job.waitForCompletion(true) ? 0 : 1);
	}

}
