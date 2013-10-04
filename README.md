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

## Installation

### Requirements

The library uses several external programs.
These are all available via `apt` on Ubuntu (and probably Debian too),
or as source from the linked locations.

#### bash

The core requirement is a working bash installation (for obvious reasons).
Used as the command interpreter.
Luckily this is almost always available on *nix systems.
http://www.gnu.org/software/bash/

#### base64

Used to encode signed requests for transmission across the web.
Again this is almost always available: it's part of GNU coreutils.
The `coreutils` package is considered essential for Ubuntu.
http://www.gnu.org/software/coreutils/

#### curl

Used to make requests to the AWS API.
If this isn't installed then Ubuntu provides it in the `curl` package.
http://curl.haxx.se/

### openssl

Used to signs requests using AWS credentials.
This is probably already installed - it's required by most server software.
Ubuntu provides this in the `openssl` package.
http://www.openssl.org/

### which

Used to check required programs exist.
If you don't have a binary for this, and don't fancy compiling it,
you'll probably be able to find a shell script on the web to do the job.
Ubuntu provides this via the `debianutils` package, which is marked essential.
http://carlo17.home.xs4all.nl/which/

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
