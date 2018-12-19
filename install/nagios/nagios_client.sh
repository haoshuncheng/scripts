#!/bin/sh
source ../header.sh
#plugin_version=1.4.15
plugin_version=2.2.1
nrpe_version=3.1.0


dependencies() {
	yum install perl-devel perl-CPAN -y
	
}

download() {
  plugin_tgz=nagios-plugins-$plugin_version.tar.gz
	if [ ! -f $download/$plugin_tgz ];
	then
		wget https://www.nagios-plugins.org/download/$plugin_tgz
		#wget http://sourceforge.net/projects/nagiosplug/files/nagiosplug/$plugin_version/$plugin_tgz
		tar zxvf $plugin_tgz 
	fi

  nrpe_tgz=nrpe-$nrpe_version.tar.gz
	if [ ! -f $download/$nrpe_tgz ];
	then
		#wget http://nchc.dl.sourceforge.net/project/nagios/nrpe-2.x/nrpe-$nrpe_version/$nrpe_tgz
		wget https://sourceforge.net/projects/nagios/files/nrpe-3.x/$nrpe_tgz
		tar zxvf $nrpe_tgz
	fi
}

install() {
	#plugin
	cd $download/nagios-plugins-$plugin_version
  ./configure --with-nagios-user=nagios --with-nagios-group=nagios --enable-perl-modules
	make;make install
  chown nagios.nagios /usr/local/nagios
	chown -R nagios.nagios /usr/local/nagios/libexec

	#nrpe
	cd $download/nrpe-$nrpe_version
	./configure
	make all
	make install-plugin
  	make install-daemon
	make install-daemon-config
	
}

usergroup() {
	useradd nagios -M -s /sbin/nologin
	#passwd nagios
}

config() {
	mkdir /usr/local/nagios/etc/
	cp $download/nrpe-$nrpe_version/sample-config/nrpe.cfg /usr/local/nagios/etc/nrpe.cfg
	/usr/local/nagios/bin/nrpe -d -c /usr/local/nagios/etc/nrpe.cfg 
	echo "/usr/local/nagios/bin/nrpe -d -c /usr/local/nagios/etc/nrpe.cfg" >> /etc/rc.local
	/usr/local/nagios/libexec/check_nrpe -H localhost
	cp $root/nrpe.cfg /usr/local/nagios/etc/nrpe.cfg
	cp $root/check_mem.pl /usr/local/nagios/libexec/check_mem.pl
	chmod 755 /usr/local/nagios/libexec/check_mem.pl
	kill -HUP `ps -ef|grep nrpe|awk 'NR==1{print $2}'`
	/usr/local/nagios/libexec/check_nrpe -H localhost -c check_mem
	/usr/local/nagios/libexec/check_nrpe -H localhost -c check_disk
	#cp $root/htpasswd.users /usr/local/nagios/etc/htpasswd.users
	# echo -e "nrpe\t5666/tcp\t#nrpe" >> /etc/services
	# /etc/init.d/xinetd restart
	# chkconfig --level 35 xinetd on

	# sed -i s/"only_from.*"/"only_from = $moniter_server 127.0.0.1"/g /etc/xinetd.d/nrpe
	# echo "+++++++++++++++++++++++++++++++++++++++++++++++++"
	# echo "/usr/local/nagios/etc/nrpe.cfg your's command"
}

reload() {
	/etc/init.d/xinetd restart
}


main $1