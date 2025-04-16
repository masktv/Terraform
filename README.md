Deployment AWS Infrastructure through Terraform
1. Configure User to Perform terraform Task and manage tfstate on remote backendd --> s3
2. Install Terraform

Web Server AMI -->   root volume size 50 gb
1. apache2 php nd requied dependencies install
2. apapche configmap with db env
3. sites enable files

Db Server AMI  -->  root volume size 70gb
1.  Install mysql server client
2.  start and enable mysql service
3.  cronjob
4.  mysql bind add
5.  install nfs common for efs

Remote backend  -->
1.  make bucket
2.  make folder in bucket
3.  set bucket pollicy with user that configured for perform terraform task
