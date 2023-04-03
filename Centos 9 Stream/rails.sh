dnf -y install epel-release

# dnf -y install mysql mysql-devel
dnf -y install  postgresql-contrib postgresql libpq postgresql-devel

curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
dnf -y install yarn
dnf -y install nodejs
dnf -y install libcurl-devel curl-devel 
dnf -y install perl
dnf -y install ImageMagick ImageMagick-devel 
dnf -y install libffi-devel readline-devel ruby sqlite-devel openssl-devel

useradd deploy

su - deploy << EoF
 
curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
curl -L get.rvm.io | bash -s stable 
 
source ~/.profile # source /etc/profile.d/rvm.sh

rvm install 3.2.1

echo 'export RAILS_ENV=production' >>  ~/.bashrc
source ~/.bashrc

EoF