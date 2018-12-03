Terrafrom-Hello World
====

Ensure that the following are available on the machine you want to run this code from ( I tested it on my MacBook pro)
1. Terragrunt https://github.com/gruntwork-io/terragrunt
2. Terrafrom
3. Docker 

Other steps for local:
1. export AWS_SECRET_ACCESS_KEY and AWS_ACCESS_KEY_ID
2. unset KUBECONFIG variable

**Git repo checkout:**

We would be using 2 repositories:
1. https://github.com/aimanparvaiz/terraform-modules
2. https://github.com/aimanparvaiz/hello-world

Checkout hello-world repo. They are public repos so should be accessible.

**Executing the code:**

There are two ways to setup the whole stack - VPC, EKS, DB, helloworld app deployment in EKS.

Go to hello-world/app1/dev and run 

```terragrunt plan-all``` (This might fail as some dependent resources are not applied yet)

```terragrunt apply-all```

I personally like to provision in the following order:

go to vpc folder under app1 and run the following:

1a. ```terragrunt get --terragrunt-source-update```

1b. ```terragrunt plan```

1c. ```terragrunt apply```

Repeat steps 1 a, 1 b, 1c for EKS, app-deploy and DB in this order.

**helloworld app:**

Once EKS is successfully provisioned and you have executed the tf in app-deploy, go to EKS folder and execute the following:
 
```KUBECONFIG=kubeconfig_app1-dev-eks kubectl describe service helloworld```
 
and look for LoadBalancer Ingress (assumption is that the EKS cluster name is app1-dev-eks, if you named it differently your kubeconfig file would be named differently).
	
LoadBalancer Ingress is the AWS ELB you need to make a call to inorder to display the Hello World greeting. (Wait for the instances to get in service for the AWS ELB)

All the code for this app is in the source-code directory. For making changes to this app, we change the hello-world/app1/dev/source-code/app/src/app.py.

**Building the app:**

Post changes to the python file, in that dir run the following commands:

1. ```docker build -t aimanparvaiz/helloworld:hw-v$```, where $ can be any number greater than 6 (this is just a manual way of versioning the image)

2. ```docker push aimanparvaiz/helloworld:hw-v$```, $ in step 1 is same as $ here.

Update this image in hello-world/app1/dev/app-deploy/deploy.tf under spec,container. After this repeat steps 1 a, b, c from Executing the code section.


**Destroying the infrastructure:**

Just like provisioning, there are 2 ways to do this.
Go to hello-world/app1/dev and run 

```terragrunt destroy-all```

Note: DB might not destroy properly because of an open issue: https://github.com/hashicorp/terraform/issues/18084

Or you can go to app-deploy, DB, EKS, VPC folders and run terragrunt destroy. Sometime destroy timeout or fails depending on AWS behavior, in such cases run destroy again. Also, for DB please disable deletion protection.
