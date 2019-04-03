source config.bash

echo Updating the operating system
sudo yum install -y amazon-linux-extras install epel
sudo yum upgrade -y

echo Configuring AWS client
# TODO may not be necessary
#aws configure

echo Install additional packages
sudo yum install -y java-1.8.0-openjdk-devel openssl-devel libcurl-devel expat-devel ruby-devel gcc make rpm-build rubygems git nfs-utils
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.201.b09-0.amzn2.x86_64
export PATH=$PATH:$JAVA_HOME/bin
export JRE_HOME=$JAVA_HOME/jre

echo Mounting EFS
cd ~/
mkdir ~/efs
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport $EFS_MOUNT  ~/efs
sudo chmod 777 efs

echo Installing Git
cd ~/
wget https://mirrors.edge.kernel.org/pub/software/scm/git/git-2.20.0.tar.gz
tar -xzvf git-2.20.0.tar.gz
cd ~/git-2.20.0
make all prefix=/usr
sudo make install prefix=/usr

echo Installing Bitbucket
cd ~/
aws s3 cp $s3_bucket . --recursive
tar -xzvf atlassian-bitbucket-6.1.2.tar.gz
cd ~/atlassian-bitbucket-6.1.2/bin

echo Configuring Bitbucket
# TODO Postgre/RDS configuration
# TODO Elastic Configuration
cd ~/
export BITBUCKET_HOME=~/efs
echo Starting Bitbucket
cd ~/atlassian-bitbucket-6.1.2/bin
./start-bitbucket.sh
