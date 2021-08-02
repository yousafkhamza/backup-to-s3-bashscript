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