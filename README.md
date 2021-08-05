# Directory Backup Moved to S3 (BashScript)
[![Build](https://travis-ci.org/joemccann/dillinger.svg?branch=master)](https://travis-ci.org/joemccann/dillinger)

---
## Description
Here it's a bash script that needs to use this script simply create a directory backup and moved that compressed backup file to a configured S3 bucket with the help of bash script and AWS IAM User with S3 full access. I have added a new feature the script will suitable for ubuntu/redhat repository and the script will installed the depandancies as itself. So, let's roll down.

----
## Feature
- Easy to configure for anyone 
- It generates the directory compressed format
- Which one we entered directory converted to a backup/compressed form to S3
- All the steps I have provided including AWS IAM User and S3 Bucket Creation
- Includes AWSCLI installation which you used debian or redhat repository the script will findout which you used and installed the same
- All the values append your answers while running the script

## Cons
- This script is not suitable for cronjob and it needs manual job but it just ask some kind of questions other the all things append your answer

----
## Pre-Requests
- Basic Knowledge of bash 
- Basic Knowledge of AWS IAM, S3 service
- Need to change your IAM user creds and then please enter the same while script running time

### IAM User Creation steps (_with screenshot_)
1. _log into your AWS account as a root user and go to IAM user_
2. _goto Access Managment >> Users_
![alt_txt](https://i.ibb.co/Y7kzZmN/IAM-1.png)
3. _Click Add User_ (_top right corner_)
![alt_txt](https://i.ibb.co/wW38xvR/IAM-2.png)
4. _Enter any username as you like and Choose "Programmatic access" >> Click Next Permissions_
![alt_txt](https://i.ibb.co/TrCbpBh/IAM-3.png)
5. _Set Permissions >> Select "Attach existing policies directly" >> Choose "AmazonS3FullAccess" >> Click Next Tags_
![alt_txt](https://i.ibb.co/8BHhwmc/IAM-4.png)
6. _Add Tags(Optional)_ >> _Enter a key and value as you like either you can leave as blank_
![alt_txt](https://i.ibb.co/QQb9svy/IAM-5.png)
7. _Review your user details and click "Create User"_
![alt_txt](https://i.ibb.co/RcxL770/IAM-6.png)
8. _Store your credentials to your local_
![alt_txt](https://i.ibb.co/nPVWcXZ/IAM-7.png)

_Reference URL_:: _IAM User creation [article](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_users_create.html)_

----
### S3 Bucket Creation (_with screenshot_)
1. _Go to S3 >  Click Create Bucket_
![alt_txt](https://i.ibb.co/bLky3Rb/S3-1.png)
2. _Any bucket name as you wish and then please enable versioning (that you upload same file multiple times or modified versions uploaded that the S3 stored as a version bases like Git)_
![alt_txt](https://i.ibb.co/kXCQJfQ/S3-3.png)
3. _Click create bucket_

![alt_txt](https://i.ibb.co/chwztWB/S3-4.png)

> Reference URL:: Creating S3 bucket please use this [doc](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html) and you can secure your bucket with IAM user using S3 [bucket policy](https://docs.aws.amazon.com/AmazonS3/latest/userguide/using-iam-policies.html)

----
### Pre-Requested (Dependency packages)
```sh
yum install -y git
```

### How to get
```sh
git clone https://github.com/yousafkhamza/backup-to-s3-bashscript.git
cd backup-to-s3-bashscript
chmod +x backup-to-S3.sh
```
> Change your creds and bucket name in at var.py file

Command to run the script::
```
[root@ip-172-31-10-180 backup-to-s3-bashscript]# ./backup-to-S3.sh
# --------------------------- or --------------------------------- #
[root@ip-172-31-10-180 backup-to-s3-bashscript]# bash backup-to-S3.sh
```

----
## Output be like
```sh
[root@ip-172-31-10-180 backup-to-s3-bashscript]# ./backup-to-S3.sh
AWS Package is installed.....

Start the script...

Please configure your IAM user creds on the server

AWS Access Key ID [None]:                                # <---------  Enter your access_key here.
AWS Secret Access Key [None]:                           # <--------- Enter your secret key here.
Default region name [None]: ap-south-1                 # <--------- Enter your region which you needs
Default output format [None]: json                    # <----------  Default output format is json

Let's roll to create your backup to S3

Please crosscheck the credentials are given below

aws_access_key_id = < Your accesss_key confirmation on the part of script >
aws_secret_access_key = < Your secret_key confirmation on the part of script >

Do you need to reconfigure the same [Y/N]: n

Let's roll to create your backup to S3

Enter your directory path(The directory will be compressed as a tar.gz file): /root/Python

Taking the directory path to your local as a temporary.........

tar: Removing leading `/' from member names
/root/Python/
/root/Python/test/
/root/Python/test/file.txt
/root/Python/test/two.txt

Local Backup Takes successfully,,,,

Enter your Bucket Name (S3 Destination): yousaf-test
Backup Moving to S3.......
upload: ../../tmp/Python-05082021.tar.gz to s3://yousaf-test/backup/Python-05082021.tar.gz

Removing local backup.....
Local backup removes successfully
```

## Output be like (ScreenShot)
![alt_txt](https://i.ibb.co/swxt5S6/out.png)

## View of S3 bucket
![alt_txt](https://i.ibb.co/KNd0jcQ/Screenshot-56.png)

----
## Behind the code
_vim backup-to-S3.sh_
```
#!/bin/bash

Ubuntu=$(which apt > 2&>1; echo $?)
Redhat=$(which yum > 2&>1; echo $?)
AWS=$(which aws > 2&>1; echo $?)
date=$(date "+%d%m%Y")

if [[ "$AWS" -eq 0 ]]; then
	echo "AWS Package is installed....."
	echo ""
	echo "Start the script..."
	
	if [[ $(ls ~/.aws/credentials > 2&>1; echo $?) -ne 0 ]]; then
		echo ""
		echo "Please configure your IAM user creds on the server"
		echo ""
		aws configure --profile backups3
		echo ""
		echo "Let's roll to create your backup to S3"
	fi
elif [[ "$Ubuntu" -eq 0 ]]; then
	echo "AWS Package is not installed on your debian distro. Installing AWS package...."
	sleep 1
	echo ""
	sudo apt install -y awscli
	echo "Please configure your IAM user creds on the server"
    echo ""
    aws configure --profile backups3
    echo ""
    echo "Let's roll to create your backup to S3"
elif [[ "$Redhat" -eq 0 ]]; then
	echo "AWS Package is not installed on your ReadHat distro. Installing AWS package...."
	sleep 1
	echo ""
	sudo yum install -y awscli
	echo "Please configure your IAM user creds on the server"
    echo ""
    aws configure --profile backups3
    echo ""
    echo "Let's roll to create your backup to S3"
else
	echo "Please install AWS Package..... and retry the same"
	exit 1
fi

isInFileA=$(cat ~/.aws/credentials | grep -c "backups3")
isInFileB=$(cat ~/.aws/config | grep -c "backups3")
CredInServer=~/.aws/credentials
# AWS Configuration on the server
if [ -f $CredInServer ] && [ "$isInFileA" -eq 1 ] && [ "$isInFileB" -eq 1 ]; then
    echo ""
	echo "Please crosscheck the credentials are given below"
    echo ""
    cat $CredInServer | grep -A 2 "backups3" | tail -n2
    echo ""
    read -p "Do you need to reconfigure the same [Y/N]: " con1
    if [[ "$con1" =~ ^([yY][eE][sS]|[yY])+$ ]]; then
        aws configure --profile backups3
    else
        echo ""
        echo "Let's roll to create your backup to S3"
    fi
else
	echo ""
    echo "Please configure your IAM user creds on the server"
    echo ""
    aws configure --profile backups3
    echo ""
    echo "Let's roll to create your backup to S3"
fi

isInFileA=$(cat ~/.aws/credentials | grep -c "backups3")
isInFileB=$(cat ~/.aws/config | grep -c "backups3")
CredInServer=~/.aws/credentials
# Taking a local Backup before S3 upload
if [ -f $CredInServer ] && [ "$isInFileA" -eq 1 ] && [ "$isInFileB" -eq 1 ]; then
	echo ""
	read -p "Enter your directory path(The directory will be compressed as a tar.gz file): " path
	BackupName=$(echo $path | awk -F "/" '{print $NF}')			
	if [ -z $path ]; then 
		echo "Please specify a a absalute directory path"
		exit 1
	else
		if [[ "$path" == */ ]]; then
			echo "Your entered directory path endswith /, so please remove the last / symbol"
		else
			if [ -d $path ]; then
				echo ""
				echo "Taking the directory path to your local as a temporary........."
				echo ""
				sleep 2
				rm -f /tmp/$BackupName-*.tar.gz 
				tar -cvf /tmp/$BackupName-$date.tar.gz $path/
				echo ""
				echo "Local Backup Takes successfully,,,,"
				# Backup Copy to S3
				echo ""
				read -p "Enter your Bucket Name (S3 Destination): " bucket
				if [ -z bucket ]; then
					echo "Please specify a Bucket name"
					exit 1
				else				
					if [ $(aws s3 --profile backups3 ls | grep -w "$bucket" > 2&>1; echo $?) -eq 0 ]; then
						echo "Backup Moving to S3......."
						aws s3 --profile backups3 cp "/tmp/$BackupName-$date.tar.gz" s3://$bucket/backup/
						echo ""
						echo "Removing local backup....."
						rm -f /tmp/$BackupName-*.tar.gz 
						echo "Local backup removes successfully"
					else
						echo ""
						echo "Please enter a valid bucket name"
						exit 1
					fi
				fi
			else
				echo ""
				echo "Enter a valid directory absalute path"
			fi
		fi
	fi
fi
```

----
## Conclusion
It's a simple bash script to take backup of directories (compressing) then the same to move your mentioned S3 bucket with the help of AWS IAM User. this script may be helpful who had face issues moving backups to S3 so it might be useful for cloud/linux/DevOps engineers.  

### ⚙️ Connect with Me 

<p align="center">
<a href="mailto:yousaf.k.hamza@gmail.com"><img src="https://img.shields.io/badge/Gmail-D14836?style=for-the-badge&logo=gmail&logoColor=white"/></a>
<a href="https://www.linkedin.com/in/yousafkhamza"><img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white"/></a> 
<a href="https://www.instagram.com/yousafkhamza"><img src="https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white"/></a>
<a href="https://wa.me/%2B917736720639?text=This%20message%20from%20GitHub."><img src="https://img.shields.io/badge/WhatsApp-25D366?style=for-the-badge&logo=whatsapp&logoColor=white"/></a><br />
