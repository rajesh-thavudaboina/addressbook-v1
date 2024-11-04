sudo yum install java-1.8.0-openjdk-devel -y
sudo yum install git -y
sudo yum install maven -y

if [ -d "addressbook-v1" ]
then
  echo "repo is cloned and exists"
    git pull origin jfrog-b1
    cd addressbook-v1
else
  git clone https://github.com/preethid/addressbook-v1.git
fi

cd addressbook-v1

mvn package
mvn -U deploy -s settings.xml