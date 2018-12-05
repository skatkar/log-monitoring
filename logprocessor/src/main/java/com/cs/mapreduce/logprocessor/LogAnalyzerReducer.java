package com.cs.mapreduce.logprocessor;

import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;
/**
 * 
 * @author Swapnil
 * This is a reducer class which combines the result of all the mappings
 */
public class LogAnalyzerReducer extends Reducer<Text, IntWritable, Text, IntWritable> {

	@Override
	public void reduce(Text key, Iterable<IntWritable> values, Context context)
			throws IOException, InterruptedException {
		System.out.println(" Reduce method....");

		System.out.println(" key:" + key);

		int sum = 0;
		for (IntWritable value : values) {
			System.out.println(" value :" + value + "for key" + key);
			sum += value.get();
		}
		context.write(key, new IntWritable(sum));
	}

}
