## Notes

Terraform script which will initialize our EKS cluster. It will also create an ECR repository which will be used later on to push & pull images for our python app. You will need the Terraform cli before that. You can get it from [HERE](https://www.terraform.io/downloads.html). 

To check what resources will be created run:

> terraform plan

To apply them: 

> terraform apply 

You must be authenticated to AWS before doing the above commands. You can achieve that with the AWS CLI. More info [HERE](https://docs.aws.amazon.com/polly/latest/dg/setup-aws-cli.html). 
