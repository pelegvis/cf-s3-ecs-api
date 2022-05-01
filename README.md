# cf-s3-ecs-api

This is a basic IoC task to create an API, using cloudfront, s3 bucket that holds static website and a basic dockerized python flask application, running on ECS


**To test the API**

URL: http://de2k1y8sgiv8x.cloudfront.net
* Main page will return Salt Security's static html home page.
* http://de2k1y8sgiv8x.cloudfront.net/v1/test will return "This is salt security", Status code 200
* http://de2k1y8sgiv8x.cloudfront.net/v1/health will return "", Status code 200 

**To create the API**

From the main directory

1. Create the docker image
```docker build -t flask-demo .```
2. Create the terraform infrastructure
```
cd tf
terraform init
terraform plan -out tf.out
terraform apply tf.out
```
3. Upload the index.html file to the s3 bucket (instructions: https://docs.aws.amazon.com/AmazonS3/latest/userguide/upload-objects.html).
4. Upload the flask-demo image to ECR (instructions: https://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html).
5. Use the domain URL to access your API (it should be returned in the ```terraform apply``` output, or you can get it from the aws console).
