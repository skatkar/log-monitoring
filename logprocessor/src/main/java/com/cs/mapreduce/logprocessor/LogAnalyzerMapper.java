package com.cs.mapreduce.logprocessor;

import java.io.IOException;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
/**
 * 
 * @author Swapnil
 * This is a mapper class 
 */
public class LogAnalyzerMapper extends Mapper<LongWritable, Text, Text, IntWritable> {

	private final static IntWritable one = new IntWritable(1);
	private Text word = new Text();

	@Override
	public void map(LongWritable key, Text value, Context context) throws IOException, InterruptedException {

		System.out.println(" Starting LogAnalyzerMapper...");
		String line = value.toString();
		String switchName = "default";

		if (line.contains("INFO")) {
			switchName = "INFO";

		} else if (line.contains("WARN")) {
			switchName = "WARN";

		} else if (line.contains("ERROR")) {
			switchName = "ERROR";

		} 

		processEvents(context, switchName);
	}

	private void processEvents(Context context, String switchName) throws IOException, InterruptedException {
		switch (switchName) {

		case "INFO":
			word.set(switchName);
			System.out.println(" pushing the key :INFO - value:" + one);
			context.write(word, one);
			break;

		case "WARN":
			word.set(switchName);
			System.out.println(" pushing the key :WARN - value:" + one);
			context.write(word, one);
			break;

		case "ERROR":
			word.set(switchName);
			System.out.println(" pushing the key :ERROR - value:" + one);
			context.write(word, one);
			break;

		default:
			System.out.println("default case !");
			break;
		}
	}

}
