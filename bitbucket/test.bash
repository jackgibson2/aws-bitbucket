#!/usr/bin/env bash


echo "#!/usr/bin/env bash" > install.bash
echo "export EFS_MOUNT=$mnt" >> install.bash
cat install-template.bash >> install.bash

#source config.bash
#
#echo "Deploying solution in $region and vpc $vpc_id"
#
#
#echo "export MYREGION=$region" >> /Users/jackgibson/IdeaProjects/aws-scripts/install.bash
#
#instance_id=$(aws ec2 run-instances \
#--image-id $ami_id \
#--count 1 \
#--instance-type t2.micro \
#--associate-public-ip-address \
#--security-group-ids sg-0b89f86f6144a0a46 \
#--subnet-id subnet-053b4e55c9c5e01bd \
#--key-name $keypair \
#--region $region \
#--user-data file:///Users/jackgibson/IdeaProjects/aws-scripts/install.bash \
#--output text \
#--query 'Instances[*].InstanceId' \
#--profile default)
#
##--user-data '#!/bin/bash>export MNT_ID=$prefix' \
#
#
#echo "Starting instance($instance_id)"
#
#while state=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].State.Name'); test "$state" = "pending"; do
#  sleep 1; echo -n '.'
#done; echo " $state"

#aws ec2 create-tags \
#--resources $instance_id  \
#--tags Key=Name,Value=Fungus-01  \
#--region $region \
#--profile default

#
### Create Security Groups
#ec2_sg=$(aws ec2 create-security-group \
#--region $region \
#--group-name $prefix-bitbucket-efs-ec2-sg \
#--description "BitBucket EFS SG for EC2" \
#--vpc-id $vpc_id \
#--output text \
#--query 'GroupId' \
#--profile $profile)
#
#echo $ec2_sg