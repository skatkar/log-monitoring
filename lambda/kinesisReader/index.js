var SSH = require('simple-ssh');
var fs = require('fs');

exports.handler = function (event, context, callback) {
    const bucket = event.Records[0].s3.bucket.name;
	const key = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
	const fileName = key.substring(key.lastIndexOf('/') + 1);
	console.log("Bucket name: " + bucket);
	console.log("Uploaded file path: " + key);
	console.log("File name: " + fileName);
	
	//var s3FileCommand = './kinesisReader.sh ' + key;
	var s3FileCommand = './execute-kinesis-hadoop.sh ' + key + ' ' + fileName;
	console.log("The command is: " + s3FileCommand);
	var ssh = new SSH({
		host: '<Private IP address of EMR master node>',
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
