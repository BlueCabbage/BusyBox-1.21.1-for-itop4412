#!/bin/sh
#*************************************************************************
#    > File Name: make_instll_busybox.sh
#    > Author: ZHAOCHAO
#    > Mail: 479680168@qq.com 
#    > Created Time: Sun 02 Oct 2016 07:15:08 AM PDT
# ************************************************************************/

#### first edit ./makefile
#
#		modified:
#			CROSS_COMPILE ?= xxx
#			arch ?= arm

#### edit menuconfig

	#make menuconfig
#	
#		Busybox Settings --> Installation Options (dir to make install the filesystem)
#			or instead use make CONFIG_PREFIX=./dir;

#### make the project

	#make -j4

	#make -j4 install

#### then copy the lia file and create other dir and config file
	
	cd ./NMR4412_FileSystem

	mkdir dev etc lib mnt proc sys tmp var


# copy the lib 
	
	cd ./lib
	
	cp -r /opt/arm-2009q3/arm-none-linux-gnueabi/libc/lib/* ./

	cd ..


# etc/eth0-setting
	
	cd etc

	echo 'IP=192.168.1.230'		>  eth0-setting
	echo 'Mask=255.255.255.0'	>> eth0-setting
	echo 'Gateway=192.168.1.1'	>> eth0-setting
	echo 'DNS=192.168.1.1'		>> eth0-setting
	echo 'MAC=08:90:90:90:90'	>> eth0-setting
	
	chmod 755 ./eth0-setting


# etc/init.d/ifconfig-eth0

	mkdir init.d

	cd init.d
	
	cat > ./ifconfig-eth0 << EOF
#!/bin/sh

echo -n Try to bring eth0 interface up....>/dev/ttySAC2

if [ -f /etc/eth0-setting ]; then
	source /etc/eth0-setting

	if gerp -q "^/dev/root / nfs " /etc/mtab ; then
		echo -n NFS root ... > /dec/ttySAC2
	else
		ifconfig eth0 down
		ifconfig eht0 hw ether $MAC
		ifconfig eth0 $IP netmask $Mask up
		route add default gw $Gateway
	fi

	echo nameserver $DNS > /etc/resolv.conf

else

	if gerp -q "^/dev/root / nfs " /etc/mtab ; then
		echo -n NFS root ... > /dev/ttySAC2
	else
		/sbin/ifconfig etho 192.168.253.12 netmask 255.255.255.0 up
	fi
fi

echo Done > /dev/ttySAC2
EOF

	chmod 755 ifconfig-eth0


# etc/init.d/rcS
	
	cat > ./rcS << EOF
#!/bin/sh
PATH=/shin:/bin:/usr/sbin:/usr/bin:/usr/local/bin:
runlevel=S
prevlevel=N
umask 022
export PATH runlevel prevlevel

#
# Trap CTRL-C &c only in this shell so we can interrupt subprocesses.
#
trap ":" INT QUIT TSTP
/bin/hostname NMR-4412

#/bin/mount -n -t proc none /proc
#/bin/mount -n -t sysfs none /sys
#/bin/mount -n -t usbfs none /proc/bus/usb
#/bin/mount -t ramfs none /dev
[ -e /proc/1 ]		|| /bin/mount -n -t proc  none /proc
[ -e /sys/class ]	|| /bin/mount -n -t sysfs none /sys
[ -e /dev/tty ]		|| /bin/mount	 -t ramfs none /dev

echo /sbin/mdev > /proc/sys/kernel/hotplug
/sbin/mdev -s
#/bin/hotplug
# mounting file system specified in /etc/fstab

mkdir -p /dev/pts
mkdir -p /dev/shm

/bin/mount -n -t devpts none /dev/pts -o mode=0622
/bin/mount -n -t tmpfs tmpfs /dev/shm
#/bin/mount -n -t ramfs none /tmp
#/bin/mount -n -t ramfs none /var

mkdir -p /var/empty
mkdir -p /var/log
mkdir -p /var/log/boa
mkdir -p /var/lock
mkdir -p /var/run
mkdir -p /var/tmp

ln -sf /dev/ttyS2 /dev/tty2
ln -sf /dev/ttyS2 /dev/tty3
ln -sf /dev/ttyS2 /dev/tty4

syslogd
/etc/rc.d/init.d/netd start
echo "			             " > /dev/tty1
echo " starting networking..." > /dev/tty1
#sleep 1
#/etc/rc.d/init,d/httpd start
#echo "							" > /dev/tty1
#echo " starting web server...  " > /dev/tty1
#sleep 1
#/etc/rc.d/init.d/leds start
#echo "							" > /dev/tty1
#echo " starting leds services  " > /dev/tty1
#sleep 1

echo " -------- NMR - ZHAOCHAO ----- " > /dev/ttySAC2
echo " -------- NMR - ZHAOCHAO ----- " 

mkdir /mnt/disk

sleep 1
/sbin/ifconfig lo 127.0.0.1
/etc/init,d/ifconfig-eth0

EOF

	chmod 755 ./rcS
	

# /etc/passwd

	cd ../
	
	cat > ./passwd << EOF
root::0:0:root:/:/bin/sh
bin:*:1:1:bin:/bin:
daemon:*:2:2:daemon:/sbin:
nobody:*:99:99:Nobody:/:
EOF

	chmod 755 ./passwd


# /etc/profile

	cat > ./profile << EOF
# Ash profile
# vim: syntax=sh

# No core files by default
ulimit -S -c 0 > /dev/null 2>&1

USER="`id -un`"
LOGNAME=$USER
PS1='[$USER@$HOSTNMAE]#'
PATH=$PATH

HOSTNAME=`/bin/hostname`

export USER LOGNAME PS1 PATH
EOF

	chmod 755 ./profile


# /etc/rc.d/init.d/netd

	mkdir rc.d

	cd rc.d

	mkdir init.d

	cd init.d

	cat > ./netd << EOF
#!/bin/sh

base=inetd

# See how we were called.
case "$1" in
	start)
			/usr/shib/$base
			;;
	stop)
			pid=`/bin/pidof $base`
			if [ -n "$pid" ]; then
				kill -9 $pid
			fi
			;;
	esac


	exit 0
EOF

	chmod 755 ./netd


