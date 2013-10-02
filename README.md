# S3 Archive

## What is it?

A simple library to archive data into S3 buckets.
Will support:
* Exactly one bucket
* Temporary access credentials (using EC2 instance profiles and IAM roles)
* Listing bucket contents
* Uploading to the bucket
* Downloading from the bucket
* Deleting from the bucket

### Why not use an existing library?

* Most libraries are huge and try to support all AWS' services. I only need S3.
* Many libraries depend on a third-party installer, e.g. pip or composer.
* I don't want to clutter up production servers (security), or SCM (annoying).

### Why BASH?

Why not?

## How can I try it?

### Temporary Access Credentials

Temporary Access Credentials allow EC2 instances to access S3 buckets without
needing the credentials for a particular IAM user.
`s3archive.template` is a
[CloudFormation](http://aws.amazon.com/documentation/cloudformation/) template
which sets up the bare minimum of resources needed to test the use of these:
 * EC2 instance
 * Security group allowing SSH access to that instance
 * S3 bucket
 * IAM role
 * IAM policy attached to the role allowing access to the bucket
 * IAM instance profile adding the instance to the role

Create the stack as follows:

    aws cloudformation create-stack               \
        --stack-name s3archive                    \
        --template-body file://s3archive.template \
        --capabilities CAPABILITY_IAM             \
        --parameters ParameterKey=KeyName,ParameterValue=<KEYNAME_GOES_HERE>

You need to specify the name of the keypair you'd like to use to connect to the
instance.
