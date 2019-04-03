#!/usr/bin/env bash

## Source in the variables for usage
source config.bash
efs_token=`uuidgen`

echo "Deploying solution in $region and vpc $vpc_id"

## TODO Add IAM role and attach to EC2 Instance
#aws iam create-role --role-name Test-Role --assume-role-policy-document file://policy-roles.json

# TODO Setup PostgreSql/RDS
# TODO Setup ElasticSearch Service

## Create Security Groups
## TODO Fix SG access
## TODO Add inbound SG for EC2 and ALB

echo "Creating Security Groups"
ec2_sg=$(aws ec2 create-security-group \
--region $region \
--group-name $prefix-bitbucket-efs-ec2-sg \
--description "BitBucket EFS SG for EC2" \
--vpc-id $vpc_id \
--output text \
--query 'GroupId' \
--profile $profile)

mt_sg=$(aws ec2 create-security-group \
--region $region \
--group-name $prefix-bitbucket-efs-mt-sg \
--description "BitBucket EFS SG for mount target" \
--vpc-id $vpc_id \
--output text \
--query 'GroupId' \
--profile $profile)

## Add Inbound Rules to Security Groups
aws ec2 authorize-security-group-ingress \
--group-id $ec2_sg \
--protocol tcp \
--port 22 \
--cidr 0.0.0.0/0 \
--profile $profile \
--region $region

## Add Outbound Rules to Security Groups
aws ec2 authorize-security-group-ingress \
--group-id $mt_sg \
--protocol tcp \
--port 2049 \
--source-group $ec2_sg \
--profile $profile \
--region $region


## Create the EFS File System
echo "Creating Elastic File System"
efs_id=$(aws efs create-file-system \
--creation-token $efs_token \
--region $region \
--output text \
--query 'FileSystemId' \
--profile $profile)

echo "Wating on file system($efs_id) to be available"

while state=$(aws efs describe-file-systems --file-system-id $efs_id --output text --query 'FileSystems[*].LifeCycleState'); test "$state" != "available"; do
  sleep 1; echo -n '.'
done; echo " $state"

## Create the Mount Target
mnt_id=$(aws efs create-mount-target \
--file-system-id $efs_id \
--subnet-id  $subnet_id \
--security-group $mt_sg \
--region $region \
--query 'MountTargetId' \
--profile $profile)

echo "Mount target $mnt_id created"

echo "Creating User-Data file"
echo "#!/usr/bin/env bash" > install.bash
echo "export EFS_MOUNT=$mnt" >> install.bash
cat install-template.bash >> install.bash

# TODO Attache IAM Role for SSM, S3, RDS, EFS from above
# TODO Use relative link for user-data
## Create an EC2 Instance
instance_id=$(aws ec2 run-instances \
--image-id $ami_id \
--count 1 \
--instance-type $instance_type \
--associate-public-ip-address \
--key-name $keypair \
--security-group-ids $ec2_sg \
--subnet-id $subnet_id \
--user-data file:///Users/jackgibson/IdeaProjects/aws-scripts/install.bash \
--region $region \
--output text \
--query 'Instances[*].InstanceId' \
--profile $profile)


echo "Starting instance($instance_id)"

while state=$(aws ec2 describe-instances --instance-ids $instance_id --output text --query 'Reservations[*].Instances[*].State.Name'); test "$state" = "pending"; do
  sleep 1; echo -n '.'
done; echo " $state"

aws ec2 create-tags \
--resources $instance_id  \
--tags Key=Name,Value=$prefix-`uuidgen`  \
--region $region \
--profile $profile

# TODO Setup ALB on 443 to proxy 7900
# TODO launch config with ASG for EC2
# TODO Setup back plan
