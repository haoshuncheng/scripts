#!/bin/sh
source ../header.sh
port=6379
version=2.6.6

dependencies() {
  echo no dependencies...
}

download() {
  redis_tgz=redis-$version.tar.gz

	if [ ! -f $download/$redis_tgz ];
	then
		wget http://redis.googlecode.com/files/$redis_tgz
		tar zxvf $redis_tgz -C $prefix
	fi
}

install() {
	cd $prefix/redis-$version
	make;make install
}

usergroup() {
  echo no user group...	
}

config() {
	cp $root/redis_$port /etc/init.d/
  mkdir -p /usr/local/etc/redis 
  cp $root/6379.conf /usr/local/etc/redis/ 
  chmod +x /etc/init.d/redis_$port
  mkdir -p /logs/redis
  mkdir -p /opt/redis/var/$port
  chown -R www /logs
  /etc/init.d/redis_$port stop 
  /etc/init.d/redis_$port start
}

reload() {
	#warning: data would be disappear!
  /etc/init.d/redis_$port stop 
  /etc/init.d/redis_$port start
}

main $1
