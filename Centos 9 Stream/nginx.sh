#!/bin/bash

dnf update -y
dnf groupinstall "Development Tools" -y
dnf install ncurses-devel -y 
dnf install wget telnet -y
dnf install net-tools pciutils perl -y

systemctl start firewalld
systemctl enable firewalld.service 


sed -i 's/enforcing/disabled/g' /etc/selinux/config
setenforce 0


cd /usr/local/src/
PCRE_VERSION=8.44
wget http://jaist.dl.sourceforge.net/project/pcre/pcre/${PCRE_VERSION}/pcre-${PCRE_VERSION}.zip
unzip pcre-${PCRE_VERSION}.zip
cd pcre-${PCRE_VERSION}
./configure --prefix=/usr/local/pcre
make && make install


#zlib
cd /usr/local/src/
ZLIB_VERSION=1.2.13
cd /usr/local/src/
wget http://zlib.net/zlib-${ZLIB_VERSION}.tar.gz
tar xf zlib-${ZLIB_VERSION}.tar.gz
 

SSL_VERSION=1.1.1g
wget http://www.openssl.org/source/openssl-${SSL_VERSION}.tar.gz
tar xf  openssl-${SSL_VERSION}.tar.gz
 

dnf install gcc-c++ pcre-devel zlib-devel make unzip libuuid-devel -y
 

cd /usr/local/src/
NGINX_VERSION=1.23.1
wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar xf nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}

cd /usr/local/src/
PCRE_VERSION=8.44
ZLIB_VERSION=1.2.13
SSL_VERSION=1.1.1g
NGINX_VERSION=1.23.1
cd nginx-${NGINX_VERSION} 


./configure --prefix=/usr/local/nginx --with-http_gzip_static_module \
--with-http_stub_status_module --with-openssl=/usr/local/src/openssl-${SSL_VERSION} \
--with-http_realip_module \
--with-pcre=/usr/local/src/pcre-${PCRE_VERSION}  --with-http_ssl_module \
--with-zlib=/usr/local/src/zlib-${ZLIB_VERSION}
make && make install 
  

cat << EoF >  /etc/init.d/nginx
#!/bin/sh
#
# nginx - this script start and stop the nginx daemon
#
# chkconfig: 2345 55 25
# description: Startup script for nginx
# processname: nginx
# config: /usr/local/nginx/conf/nginx.conf
# pidfile: /var/run/nginx.pid
#
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

DAEMON=/usr/local/nginx/sbin/nginx
CONFIGFILE=/usr/local/nginx/conf/nginx.conf
PIDFILE=/var/run/nginx.pid
SCRIPTNAME=/etc/init.d/nginx
LOCKFILE=/var/lock/nginx.lock

set -e
[ -x "$DAEMON" ] || exit 0

start() {
       echo "Startting Nginx......"
       [ -x $DAEMON ] || exit 5
       [ -f $CONFIGFILE ] || exit 6
       $DAEMON -c $CONFIGFILE || echo -n "Nginx already running!"
       [ $? -eq 0 ] && touch $LOCKFILE
}

stop() {
       echo "Stopping Nginx......"
       MPID=`ps aux | grep nginx | awk '/master/{print $2}'`

       if [ "${MPID}X" != "X" ]; then
               kill -QUIT $MPID
               [ $? -eq 0 ] && rm -f $LOCKFILE
       else
               echo "Nginx server is not running!"
       fi
}

reload() {
       echo "Reloading Nginx......"
       MPID=`ps aux | grep nginx | awk '/master/{print $2}'`

       if [ "${MPID}X" != "X" ]; then
               kill -HUP $MPID
       else
               echo "Nginx can't reload!"
       fi
}  

case "$1" in
start)
       start
       ;;

stop)
       stop
       ;;

reload)
       reload
       ;;

restart)
       stop
       sleep 1
       start
       ;;

*)
       echo "Usage: $SCRIPTNAME {start|stop|reload|restart}"
       exit 3
       ;;

esac

exit 0
EoF

chmod +x /etc/init.d/nginx
chkconfig --add nginx
useradd nginx
service nginx start

firewall-cmd --permanent --zone=public --add-service=http 
firewall-cmd --permanent --zone=public --add-service=https
firewall-cmd --permanent --add-port=80/tcp 
firewall-cmd --permanent --add-port=443/tcp 
firewall-cmd --reload 
