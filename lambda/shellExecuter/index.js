var SSH = require('simple-ssh');
var fs = require('fs');

exports.handler = (event, context, callback) => {

	const bucket = event.Records[0].s3.bucket.name;
	const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
	const region = event.Records[0].awsRegion;
	const fileName = key.split("/")[1];
	
	var lastCreatedFile = event.Records[0].s3.object.key;
	//console.log(lastCreatedFile);
	//console.log(bucket);
	//console.log(key);
	//console.log(region);
	console.log("File to analyse: " + fileName);
	//var s3FileCommand = 'aws s3 cp s3://' + bucket + '/' + key + ' ./' + key + ' --region ' + region;
	var s3FileCommand = './execute-hadoop.sh ' + fileName;
	/* -- create SSH object wit the credentials that you need to connect to your EC2 instance -- */
	
	//If the server is of EMR cluster, provide the private IP address of master node
	/* How to get the private IP--
		Connect to the master node using the public IPv4 address
		On the terminal use the command hostanem -I
		Use this address below
	*/
	var ssh = new SSH({
		host: '172.31.55.13',
		//user: 'ec2-user(ubuntu/ec2-user)',
		user: 'hadoop',
		key: fs.readFileSync("EC2Key.pem")
	});
	
	/* -- execute SSH command -- */
	ssh.exec('cd /home/hadoop').exec('ls -al', {
	out: function(stdout) {
		console.log('ls -al got:');
		console.log(stdout);
		console.log('now launching command');
		console.log(s3FileCommand);
	}
	}).exec('' + s3FileCommand, {
	out: console.log.bind(console),
	exit: function(code, stdout, stderr) {
		console.log('operation exited with code: ' + code);
		console.log('STDOUT from EC2:\n' + stdout);
		console.log('STDERR from EC2:\n' + stderr);
		context.succeed('Success!');
	}
	}).start();
  
};