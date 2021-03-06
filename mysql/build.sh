#!/bin/bash
#author: Bowen Liu
#date: 30/01/2016

#description: MySQL build & install script
#$1: target output directory
#$2: target distributions name
#$3: target rootfs directory(absolutely)
#$4: kernel build directory(absolutely)
#return: 0: build success, other: failed

###################################################################################
###################### Initialise variables ####################
###################################################################################

echo "/packages/mysql/build.sh: outputdir=$1, distro=$2, rootfs=$3, kernel=$4"

if [ "$1" = '' ] || [ "$2" = '' ] ||  [ "$3" = '' ]  || [ "$4" = '' ]; then
    echo "Invalid parameter passed. Usage ./mysql/build.sh <outputdir> <distrib> <rootfs> <kernal>" 
    exit
fi

ROOTFS=$3
corenum=`cat /proc/cpuinfo | grep "processor"| wc -l`
current_dir=`pwd`/packages/mysql
echo "---- $current_dir ----"

###################################################################################
################################### Build MySQL ###################################
###################################################################################
LOCALARCH=`uname -m`
if [ x"$LOCALARCH" = x"x86_64" ]; then
    exit 1
fi

if [ x"$LOCALARCH" = x"aarch64" ]; then
    echo "Installing mysql ..."
    cd $current_dir/percona-server-5.6.22-72.0
    cd BUILD
    sh autorun.sh
    cd ..
    sudo apt-get install -y cmake g++
    echo "finish install cmake"
    cmake -DCMAKE_INSTALL_PREFIX=/u01/my3306 -DMYSQL_DATADIR=/u01/my3306/data -DMYSQL_USER=mysql -DSYSCONFDIR=/etc -DWITH_MYISAM_STORAGE_ENGINE=1 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DWITH_MEMORY_STORAGE_ENGINE=1 -DMYSQL_UNIX_ADDR=/u01/my3306/run/mysql.sock -DMYSQL_TCP_PORT=3306 -DENABLED_LOCAL_INFILE=1 -DWITH_PARTITION_STORAGE_ENGINE=1 -DEXTRA_CHARSETS=all -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
    make -j${corenum}
    sudo make DESTDIR=$ROOTFS install
    sudo cp $current_dir/my-sigle.cnf  $ROOTFS/etc/my.cnf
    sudo cp $current_dir/mysql $ROOTFS/etc/init.d
    
case $DISTRO in
    Fedora)
        ;;
    OpenSuse)
        ;;
    Ubuntu)
        ;;
    Debian)
    ;;
    esac

    echo "mysql make install finished"
    exit 0
fi

