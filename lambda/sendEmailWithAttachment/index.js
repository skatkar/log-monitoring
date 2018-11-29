var aws = require("aws-sdk");
var nodemailer = require("nodemailer");

var ses = new aws.SES();
var s3 = new aws.S3();

function getS3File(bucket, key) {
    return new Promise(function (resolve, reject) {
        s3.getObject(
            {
                Bucket: bucket,
                Key: key
            },
            function (err, data) {
                if (err) return reject(err);
                else return resolve(data);
            }
        );
    })
}


exports.handler = function (event, context, callback) {

	const bucket = event.Records[0].s3.bucket.name;
	const fileUploaded = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, ' '));
	const fileName = fileUploaded.split("/")[1];
	const region = event.Records[0].awsRegion;
	
    getS3File(bucket, fileUploaded)
        .then(function (fileData) {
            var mailOptions = {
                from: '<verified_email_address>',
                subject: 'This is an email sent from a Lambda function!',
                html: `<p>Please find the attached file for the generated report.</p>`,
                to: '<verified_email_address>',
                // bcc: Any BCC address you want here in an array,
                attachments: [
                    {
                        filename: fileName,
                        content: fileData.Body
                    }
                ]
            };

            console.log('Creating SES transporter');
            // create Nodemailer SES transporter
            var transporter = nodemailer.createTransport({
                SES: ses
            });

            // send email
            transporter.sendMail(mailOptions, function (err, info) {
                if (err) {
                    console.log(err);
                    console.log('Error sending email');
                    callback(err);
                } else {
                    console.log('Email sent successfully');
                    callback();
                }
            });
        })
        .catch(function (error) {
            console.log(error);
            console.log('Error getting attachment from S3');
            callback(err);
        });
};
