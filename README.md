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

## Why not use an existing library?

* Most libraries are huge and try to support all AWS' services. I only need S3.
* Many libraries depend on a third-party installer, e.g. pip or composer.
* I don't want to clutter up production servers (security), or SCM (annoying).

## Why BASH?

Why not?
