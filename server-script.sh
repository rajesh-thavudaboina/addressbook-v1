#! /bin/bash
# sudo yum install java-1.8.0-openjdk-devel -y
#sudo yum install java -y
sudo yum install git -y
sudo yum install docker -y
sudo systemctl start docker
# sudo yum install maven -y


if [ -d "addressbook-v1" ]
then
  echo "repo is cloned and exists"
  cd /home/ec2-user/addressbook-v1
  git pull origin demo2
else
  git clone https://github.com/preethid/addressbook-v1.git
fi

cd /home/ec2-user/addressbook-v1
git checkout demo2

#mvn package
sudo docker build -t $1:$2 .