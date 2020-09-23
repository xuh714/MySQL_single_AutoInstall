#!/bin/bash
# 2019-07-10 MySQL AutoInstall Script version 1.0 (Author : xuh)
# 2019-07-15 version 1.2
#       add: Human interaction by xuh
# 2019-07-16 version 1.3
#       add: Step rollback by xuh
# 2019-07-18 version 1.4
#       add: Multi MySQL version Install/Deinstall by xuh
# 2019-07-22 version 1.5.5
#       add: specify options and helpinfo by xuh

export LANG=en_US.UTF-8
unset MAILCHECK
while getopts c:d:f:G:h:i:I:p:s:S: option
do
    case "$option" in
        c)
            CHARACTER=$OPTARG
            echo "option:c, value $OPTARG"
            echo "CHARACTER IS: $CHARACTER"
            #echo "next arg index:$OPTIND"
            ;;
        d)
            MEDIA_DIR=${OPTARG%*/}
            echo "option:d, value $OPTARG"
            echo "MEDIA_DIR IS: $MEDIA_DIR"
            ;;
        f)
            MEDIA_FULLNAME=$OPTARG
            echo "option:f, value $OPTARG"
            echo "MEDIA_FULLNAME IS: $MEDIA_FULLNAME"
            ;;
        G)
            my_debug_flg=$OPTARG
            echo "option:G, value $OPTARG"
            echo "my_debug_flg IS: $my_debug_flg"
            ;; 
        h)
            #echo "option:h, value $OPTARG"            
            echo "Usage: args [-c] [-d] [-f] [-G] [-h] [-i] [-I] [-p] [-s] [-S]"
            echo "-c means: character set, must be configured for mysql install"
            echo "-d means: media directory, must be configured for mysql both"
            echo "-f means: media fullname, must be configured for mysql both"
            echo "-G means: debug flag, Using keyword [McDeBuG] for MySQL install or deinstall Debug"
            echo "-h means: to get helpinfo"
            echo "-i means: ip address, must be configured for mysql install"
            echo "-I means: mysql instances, Default Value [1], must be configured for both if multi instances required"
            echo "-p means: mysql port, Default Value [3306], must be configured for both if multi instances required"
            echo "-s means: os sleep time for mysql service start/stop, Default Value [10 seconds]"
            echo "-S means: os sleep time for mysql DB initialize, Default Value [10 seconds]"
            echo ""
            echo "--For MySQL single instance Install"
            echo "Case 1:"
            echo "       Eg: sh 1.sh -c utf8 -d /u02/mysql57/ -f mysql-5.7.21-linux-glibc2.12-x86_64.tar.gz -i 192.168.239.62 -I 1 -p 3306 -s 10 -S 10"
            echo "Case 2:"
            echo "       Eg: sh 1.sh -c utf8 -d /u02/mysql57/ -f mysql-5.7.21-linux-glibc2.12-x86_64.tar.gz -i 192.168.239.62"            
            echo ""
            echo "--For MySQL single instance Deinstall"
            echo "Case :"
            echo "      Eg: sh 1.sh -d /u02/mysql57/ -f mysql-5.7.21-linux-glibc2.12-x86_64.tar.gz"
            echo ""
            echo ""
            echo "--For MySQL multi instances Install"
            echo "Case 1:"
            echo "       Eg: sh 1.sh -c utf8 -d /u02/mysql55/ -f mysql-5.5.61-linux-glibc2.12-x86_64.tar.gz -i 192.168.239.62 -I 4 -p 3305 -s 10 -S 10"
            echo "Case 2:"            
            echo "       Eg: sh 1.sh -c utf8 -d /u02/mysql56/ -f mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz -I 4 -p 3306"
            echo "       Eg: sh 1.sh -c utf8 -d /u02/mysql57/ -f mysql-5.7.21-linux-glibc2.12-x86_64.tar.gz -I 4 -p 3307"
            echo "       Eg: sh 1.sh -c utf8 -d /u02/mysql80/ -f mysql-8.0.15-linux-glibc2.12-x86_64.tar.xz -I 4 -p 3308"
            echo ""            
            echo "--For MySQL multi instances Deinstall"
            echo "Case :"
            echo "      Eg: sh 1.sh -d /u02/mysql80/ -f mysql-8.0.15-linux-glibc2.12-x86_64.tar.xz -I 4 -p 3308"
            echo "      Eg: sh 1.sh -d /u02/mysql57/ -f mysql-5.7.21-linux-glibc2.12-x86_64.tar.gz -I 4 -p 3307"
            echo "      Eg: sh 1.sh -d /u02/mysql56/ -f mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz -I 4 -p 3306"
            echo "      Eg: sh 1.sh -d /u02/mysql55/ -f mysql-5.5.61-linux-glibc2.12-x86_64.tar.gz -I 4 -p 3305"
            exit 1
            ;;
        i)
            IP=$OPTARG
            echo "option:i, value $OPTARG"
            echo "IP IS: $IP"
            ;;
        I)
            Instances=$OPTARG
            echo "option:I, value $OPTARG"
            echo "Instances IS: $Instances"
            ;;
        p)
            PORT=$OPTARG
            echo "option:p, value $OPTARG"
            echo "PORT IS: $PORT"
            ;;
        s)
            SleepNUM=$OPTARG
            echo "option:s, value $OPTARG"
            echo "SleepNUM IS: $SleepNUM"
            ;;
        S)
            InitDBsleepNUM=$OPTARG
            echo "option:S, value $OPTARG"
            echo "InitDBsleepNUM IS: $InitDBsleepNUM"
            ;;
        \?)
            echo "Warnning: Please must specify -h option and must specify Any option value"
            exit 1
            ;;
    esac
done
MEDIA_NAME=${MEDIA_FULLNAME%.tar*}
MEDIA_NAME_POSTFIX=${MEDIA_FULLNAME##*.}
MySQL_VERSION=${MEDIA_FULLNAME:6:3}
test -z "$PORT" && PORT=3306
test -z "$Instances" && Instances=1
test -z "$SleepNUM" && SleepNUM=10
test -z "$InitDBsleepNUM" && InitDBsleepNUM=10
SAFEDIR=/tmp/$(date +"%Y-%m-%d")
INSTALLPREDIR=${SAFEDIR}/McMysqlInstallPre
APPDIR=${MEDIA_DIR}/app
DBDIR=${APPDIR}/mysqldb
BASEDIR=${APPDIR}/mysql
DATADIR=${DBDIR}/data
LOGDIR=${DBDIR}/log
REDODIR=${DBDIR}/redo
UNDODIR=${DBDIR}/undo
BINLOGDIR=${DBDIR}/binlog
RELAYLOGDIR=${DBDIR}/relaylog
MySQL_GROUP=mysql
MySQL_USER=mysql
MySQL_PWD=mysql
MYSQL_SYSHOST=localhost
MySQL_SYSUSER=root
MySQL_SYSPWD=mysql

totalMem=`free -m | grep Mem: |sed 's/^Mem:\s*//'| awk '{print $1}'`
memLock=`echo "$totalMem*0.8*1024" |bc|awk '{printf "%.f", $0}'`

function alert() {
	echo -e "$1"
	exit -1
}

function os_config() {
    mkdir -p $SAFEDIR
    mkdir -p $INSTALLPREDIR
	if [ "$HOSTNAME"  != "localhost.localdomain" ]; then
        cp /etc/hosts $INSTALLPREDIR/
        echo "" >>/etc/hosts
    	echo "$IP $HOSTNAME" >>/etc/hosts
    fi
    #MySQL 5.5 / 5.6 / 5.7 AND 8.0 
    package="bc gcc gcc-c++ glibc glibc-devel ksh libaio libaio-devel libgcc libstdc++ libstdc++-devel make net-tools sysstat unzip tar xz"
	missing=$(rpm -q $package| grep "not installed")

    #estimate $missing is or not null.Here is not null,so done!
	if [ ! -z "$missing" ]; then
        #mount /dev/cdrom /mnt
		mount ${MEDIA_DIR}/*.iso -o loop /mnt		
		test $? != 0 && alert "***********************Error: mounting the os media***********************"    
        #test -d /etc/yum.repos.d/bak && mv -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak || mkdir /etc/yum.repos.d/bak
        test -d /etc/yum.repos.d/bak
        if [ $? -eq 0 ];then
            mv -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak
        else
            mkdir /etc/yum.repos.d/bak && mv -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak
        fi
        cat > /etc/yum.repos.d/yum.repo <<EOF
[base]
Name=base
Baseurl=file:///mnt
Enabled=1
Gpgcheck=0
EOF
		yum clean all
        yum makecache
		yum install -y $package 
		umount /mnt
        test $? != 0 && alert ":::::::::::::::[Error: umounting the os media]:::::::::::::::"
	fi

	groupadd $MySQL_GROUP
    #useradd -r -g $MySQL_GROUP -s /bin/false $MySQL_USER
    useradd -g $MySQL_GROUP $MySQL_USER
    echo $MySQL_PWD |passwd $MySQL_USER --stdin
    
    cp /etc/security/limits.conf $INSTALLPREDIR/
	cat >> /etc/security/limits.conf <<EOF
    
$MySQL_USER soft nproc 2047
$MySQL_USER hard nproc 16384
$MySQL_USER soft nofile 1024
$MySQL_USER hard nofile 65536
$MySQL_USER soft stack 10240
$MySQL_USER soft stack 32768
$MySQL_USER soft memlock $memLock
$MySQL_USER hard memlock $memLock
EOF
    systemver=`cat /etc/redhat-release|sed -r 's/.* ([0-9]+)\..*/\1/'`
    if [[ $systemver = "6" ]];then
        echo "Stop linux 6 firewall"
        service iptables stop
		chkconfig iptables off
        echo "Deinstall system native MySQL RPM Package"
        yum remove -y mysql
	else 
	    echo "Stop linux 7 firewall"
		systemctl stop firewalld
		systemctl disable firewalld
		systemctl disable avahi-daemon
        echo "Deinstall system native Mariadb RPM Package"
        yum remove -y mariadb
	fi
	#systemctl stop firewalld
	#systemctl disable firewalld
	#systemctl disable avahi-daemon
    cp /etc/selinux/config $INSTALLPREDIR/
	sed -i 's/^SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
	setenforce 0
    test -e /etc/my.cnf && cp /etc/my.cnf $INSTALLPREDIR/ && mv -f /etc/my.cnf /etc/my.cnf.bak
 	
 	MaxMemlock=`su - $MySQL_USER -c "ulimit -a"| grep 'max locked memory'| awk '{print $NF}'`
	if [ "$MaxMemlock" != "$memLock" ];then
    alert ":::::::::::::::[ERROR:User $MySQL_USER created or security limit configed with error]:::::::::::::::"
    fi
}

function os_config_rollback() {
    cd /tmp
    test -e $INSTALLPREDIR/hosts
    if [ $? -eq 0 ];then
        mv -f /etc/hosts /tmp
        cp $INSTALLPREDIR/hosts /etc/hosts
    fi
    test -e $INSTALLPREDIR/limits.conf
    if [ $? -eq 0 ];then
        mv -f /etc/security/limits.conf /tmp
        cp $INSTALLPREDIR/limits.conf /etc/security/limits.conf
    fi
    test -e $INSTALLPREDIR/config
    if [ $? -eq 0 ];then
        mv -f /etc/selinux/config /tmp
        cp $INSTALLPREDIR/config /etc/selinux/config
    fi
    test -e $INSTALLPREDIR/my.cnf && cp $INSTALLPREDIR/my.cnf /etc/my.cnf
    test -d $INSTALLPREDIR && rm -rf $INSTALLPREDIR
    test -d $SAFEDIR && rm -rf $SAFEDIR
    cat /etc/passwd|grep -w "$MySQL_USER"
    test $? = 0 && userdel -f $MySQL_USER
    cat /etc/group|grep -w "$MySQL_GROUP"
    test $? = 0 && groupdel $MySQL_USER
    test -d /home/$MySQL_USER && rm -rf /home/$MySQL_USER
    test -e /var/spool/mail/$MySQL_USER && rm -f /var/spool/mail/$MySQL_USER
}

function mysql_soft_install() {
    mkdir -p $APPDIR
    mkdir -p $DBDIR
    mkdir -p $BASEDIR    
    cd $MEDIA_DIR
    if [ "$MEDIA_NAME_POSTFIX" == 'xz' ];then
        tar xvJf $MEDIA_NAME.tar.xz
    elif [ "$MEDIA_NAME_POSTFIX" == 'gz' ];then
        tar zxvf $MEDIA_NAME.tar.gz
    elif [ "$MEDIA_NAME_POSTFIX" == 'tar' ];then
        tar -xvf $MEDIA_NAME.tar
    fi
    if [ $? -eq 0 ];then
        echo ":::::::::::::::[The Media DeCompress is OK.]:::::::::::::::"
    else
        alert ":::::::::::::::[ERROR:MySQL Media DeCompress is Failed]:::::::::::::::"
    fi
    
    chown $MySQL_USER:$MySQL_GROUP $APPDIR
    chown $MySQL_USER:$MySQL_GROUP $DBDIR
    chmod 775 $APPDIR
    chmod 775 $DBDIR
    
    mv $MEDIA_DIR/$MEDIA_NAME/* $BASEDIR
    chown $MySQL_USER:$MySQL_GROUP $BASEDIR
    chmod 775 $BASEDIR
    
    cd $BASEDIR
    bin/mysql --version
    if [ $? -ne 0 ];then
        alert ":::::::::::::::[ERROR:MySQL soft install failed]:::::::::::::::"
    fi
}

function mysql_soft_install_rollback() {
    cd $SAFEDIR
    test -d $BASEDIR
    if [ $? -eq 0 ];then
        rm -rf $BASEDIR
    fi
    test -d $MEDIA_DIR/$MEDIA_NAME
    if [ $? -eq 0 ];then
        rm -rf $MEDIA_DIR/$MEDIA_NAME
    fi
    test -d $DBDIR && rm -rf $DBDIR
    test -d $APPDIR && rm -rf $APPDIR
}

function dbinitialize_for_MySQL80() {
    mkdir -p $DATADIR
    mkdir -p $REDODIR
    mkdir -p $UNDODIR
    mkdir -p $BINLOGDIR
    mkdir -p $RELAYLOGDIR
    mkdir -p $LOGDIR
    chown $MySQL_USER:$MySQL_USER $DATADIR
    chown $MySQL_USER:$MySQL_USER $REDODIR
    chown $MySQL_USER:$MySQL_USER $UNDODIR
    chown $MySQL_USER:$MySQL_USER $BINLOGDIR
    chown $MySQL_USER:$MySQL_USER $RELAYLOGDIR
    chown $MySQL_USER:$MySQL_USER $LOGDIR
    chmod 775 $DATADIR
    chmod 775 $REDODIR
    chmod 775 $UNDODIR
    chmod 775 $BINLOGDIR
    chmod 775 $RELAYLOGDIR
    chmod 775 $LOGDIR
	#totalMem=`free -m | grep Mem: |sed 's/^Mem:\s*//'| awk '{print $1}'`
    if [ $totalMem -lt 2048 ];then
        alert ":::::::::::::::[Warning:The physical memory is ${totalMem}M,MySQL advises at least 2G]:::::::::::::::" 
    else
        echo ":::::::::::::::[The machine physical memory is ${totalMem} (in MB)]:::::::::::::::"
    fi
    declare -i mysqlMem=`echo "$totalMem*1024*1024*0.5/$Instances"|bc`
    test -d $BASEDIR/my.cnf
    if [ $? -eq 0 ];then
        rm -f $BASEDIR/my.cnf
        echo ":::::::::::::::[Warning:The old option file [$BASEDIR/my.cnf] is exist,it will be deleted.]:::::::::::::::"
    fi
	cat > $BASEDIR/my.cnf <<EOF
[client]
port = $PORT
socket = $DATADIR/mysql.sock

[mysqld_safe]
socket = $DATADIR/mysql.sock
nice = 0

[mysqld]
#skip-grant-tables
#skip-name-resolve = 1
user = $MySQL_USER
port = $PORT
socket = $DATADIR/mysql.sock
pid-file = $DATADIR/mysql.pid
basedir = $BASEDIR
datadir = $DATADIR
max_connections = 3000
character-set-server = $CHARACTER
wait_timeout = 3600
interactive_timeout = 3600

server-id = 1
auto_increment_offset = 1
auto_increment_increment = 1

log_output = FILE
#log_error = $DATADIR/mysql.err

slow_query_log = on
slow_query_log_file = $LOGDIR/mysql-slow.log
long_query_time = 3
log_queries_not_using_indexes = on
general_log = on
general_log_file = $LOGDIR/mysql-general.log

log-bin = $BINLOGDIR/mysql-binlog
binlog-format = ROW
#log_slave_updates=ON
#gtid_mode=ON
#enforce_gtid_consistency=ON
master_info_repository=TABLE
relay_log_info_repository=TABLE
#binlog_checksum=NONE
binlog_expire_logs_seconds=604800
sync_binlog = 0
max_binlog_size = 1024M
relay-log = $RELAYLOGDIR/mysql-relay-bin
#binlog_rows_query_log_events = 1

innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 16777216
#innodb_log_file_size = 524288000
innodb_log_files_in_group = 3
innodb_buffer_pool_size = $mysqlMem
innodb_log_group_home_dir = $REDODIR
#innodb_rollback_segments = 128
innodb_undo_directory = $UNDODIR
innodb_flush_method = O_DIRECT
innodb_write_io_threads = 8
innodb_read_io_threads = 8
innodb_page_cleaners = 16
innodb_io_capacity = 300
#innodb_doublewrite = off

max_heap_table_size = 64M
tmp_table_size = 64M
max_allowed_packet = 16M

secure_file_priv = 
log_bin_trust_function_creators = 1
[mysql]
#no-auto-rehash
#prompt="\\u@\\h:\\d \\r:\\m:\\s>"

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqldump]
quick
quote-names
max_allowed_packet = 16M
EOF

    cd $BASEDIR
    bin/mysqld --defaults-file=$BASEDIR/my.cnf --initialize --user=$MySQL_USER
    echo ":::::::::::::::[DB Initializing... Please be waitting for $InitDBsleepNUM seconds...]:::::::::::::::"
    sleep $InitDBsleepNUM
    #test $(ps -ef|egrep -w "mysqld|mysqld_safe"|grep -v grep|wc -l) != 0 && pkill -9 mysqld_safe && pkill -9 mysqld
    bin/mysqld_safe --defaults-file=$BASEDIR/my.cnf --user=$MySQL_USER --skip-grant-tables &
    #tmppwd=`cat /tmp/initialize.log|grep -w "A temporary password"|awk '{print $NF}'`
    echo ":::::::::::::::[Service starting... Please be waitting for $SleepNUM seconds...]:::::::::::::::"
    sleep $SleepNUM
    bin/mysql -hlocalhost -uroot -S $DATADIR/mysql.sock -e"show global status;" > /dev/null 2>&1
    if [ $? -eq 0 ];then
        echo ":::::::::::::::[MySQL DB initialize succesfully.]:::::::::::::::"
    else
       alert ":::::::::::::::[ERROR:MySQL DB initialize failed]:::::::::::::::"
    fi
}

function dbinitialize_for_MySQL57() {
    mkdir -p $DATADIR
    mkdir -p $REDODIR
    mkdir -p $UNDODIR
    mkdir -p $BINLOGDIR
    mkdir -p $RELAYLOGDIR
    mkdir -p $LOGDIR
    chown $MySQL_USER:$MySQL_USER $DATADIR
    chown $MySQL_USER:$MySQL_USER $REDODIR
    chown $MySQL_USER:$MySQL_USER $UNDODIR
    chown $MySQL_USER:$MySQL_USER $BINLOGDIR
    chown $MySQL_USER:$MySQL_USER $RELAYLOGDIR
    chown $MySQL_USER:$MySQL_USER $LOGDIR
    chmod 775 $DATADIR
    chmod 775 $REDODIR
    chmod 775 $UNDODIR
    chmod 775 $BINLOGDIR
    chmod 775 $RELAYLOGDIR
    chmod 775 $LOGDIR
	#totalMem=`free -m | grep Mem: |sed 's/^Mem:\s*//'| awk '{print $1}'`
    if [ $totalMem -lt 2048 ];then
        alert ":::::::::::::::[Warning:The physical memory is ${totalMem}M,MySQL advises at least 2G]:::::::::::::::" 
    else
        echo ":::::::::::::::[The machine physical memory is ${totalMem} (in MB)]:::::::::::::::"
    fi
    declare -i mysqlMem=$totalMem*1024*1024*50/100
    test -d $BASEDIR/my.cnf
    if [ $? -eq 0 ];then
        rm -f $BASEDIR/my.cnf
        echo ":::::::::::::::[Warning:The old option file [$BASEDIR/my.cnf] is exist,it will be deleted.]:::::::::::::::"
    fi
	cat > $BASEDIR/my.cnf <<EOF
[client]
port = $PORT
socket = $DATADIR/mysql.sock

[mysqld_safe]
socket = $DATADIR/mysql.sock
nice = 0

[mysqld]
#skip-grant-tables
#skip-name-resolve = 1
user = $MySQL_USER
port = $PORT
socket = $DATADIR/mysql.sock
pid-file = $DATADIR/mysql.pid
basedir = $BASEDIR
datadir = $DATADIR
max_connections = 3000
character-set-server = $CHARACTER
wait_timeout = 3600
interactive_timeout = 3600

server-id = 1
auto_increment_offset = 1
auto_increment_increment = 1

log_output = FILE
#log_error = $DATADIR/mysql.err

slow_query_log = on
slow_query_log_file = $LOGDIR/mysql-slow.log
long_query_time = 3
log_queries_not_using_indexes = on
general_log = on
general_log_file = $LOGDIR/mysql-general.log

log-bin = $BINLOGDIR/mysql-binlog
binlog-format = ROW
#log_slave_updates=ON
#gtid_mode=ON
#enforce_gtid_consistency=ON
master_info_repository=TABLE
relay_log_info_repository=TABLE
#binlog_checksum=NONE
expire_logs_days = 7
sync_binlog = 0
max_binlog_size = 1024M
relay-log = $RELAYLOGDIR/mysql-relay-bin
#binlog_rows_query_log_events = 1

innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 16777216
#innodb_log_file_size = 524288000
innodb_log_files_in_group = 3
innodb_buffer_pool_size = $mysqlMem
innodb_log_group_home_dir = $REDODIR
#innodb_rollback_segments = 128
innodb_undo_directory = $UNDODIR
innodb_undo_tablespaces = 2
innodb_flush_method = O_DIRECT
innodb_write_io_threads = 8
innodb_read_io_threads = 8
innodb_page_cleaners = 16
innodb_io_capacity = 300
#innodb_doublewrite = off

query_cache_type = off
query_cache_size = 0
max_heap_table_size = 64M
tmp_table_size = 64M
max_allowed_packet = 16M

secure_file_priv = 
log_bin_trust_function_creators = 1
[mysql]
#no-auto-rehash
#prompt="\\u@\\h:\\d \\r:\\m:\\s>"

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqldump]
quick
quote-names
max_allowed_packet = 16M
EOF

    cd $BASEDIR
    bin/mysqld --defaults-file=$BASEDIR/my.cnf --initialize --user=$MySQL_USER
    echo ":::::::::::::::[DB Initializing... Please be waitting for $InitDBsleepNUM seconds...]:::::::::::::::"
    sleep $InitDBsleepNUM
    #test $(ps -ef|egrep -w "mysqld|mysqld_safe"|grep -v grep|wc -l) != 0 && pkill -9 mysqld_safe && pkill -9 mysqld
    bin/mysqld_safe --defaults-file=$BASEDIR/my.cnf --user=$MySQL_USER --skip-grant-tables &
    #tmppwd=`cat /tmp/initialize.log|grep -w "A temporary password"|awk '{print $NF}'`
    echo ":::::::::::::::[Service starting... Please be waitting for $SleepNUM seconds...]:::::::::::::::"
    sleep $SleepNUM
    bin/mysql -hlocalhost -uroot -S $DATADIR/mysql.sock -e"show global status;" > /dev/null 2>&1
    if [ $? -eq 0 ];then
        echo ":::::::::::::::[MySQL DB initialize succesfully.]:::::::::::::::"
    else
       alert ":::::::::::::::[ERROR:MySQL DB initialize failed]:::::::::::::::"
    fi
}

function dbinitialize_for_MySQL56() {
    mkdir -p $DATADIR
    mkdir -p $REDODIR
    mkdir -p $UNDODIR
    mkdir -p $BINLOGDIR
    mkdir -p $RELAYLOGDIR
    mkdir -p $LOGDIR
    chown $MySQL_USER:$MySQL_USER $DATADIR
    chown $MySQL_USER:$MySQL_USER $REDODIR
    chown $MySQL_USER:$MySQL_USER $UNDODIR
    chown $MySQL_USER:$MySQL_USER $BINLOGDIR
    chown $MySQL_USER:$MySQL_USER $RELAYLOGDIR
    chown $MySQL_USER:$MySQL_USER $LOGDIR
    chmod 775 $DATADIR
    chmod 775 $REDODIR
    chmod 775 $UNDODIR
    chmod 775 $BINLOGDIR
    chmod 775 $RELAYLOGDIR
    chmod 775 $LOGDIR
	#totalMem=`free -m | grep Mem: |sed 's/^Mem:\s*//'| awk '{print $1}'`
    if [ $totalMem -lt 2048 ];then
        alert ":::::::::::::::[Warning:The physical memory is ${totalMem}M,MySQL advises at least 2G]:::::::::::::::" 
    else
        echo ":::::::::::::::[The machine physical memory is ${totalMem} (in MB)]:::::::::::::::"
    fi
    declare -i mysqlMem=$totalMem*1024*1024*50/100
    test -d $BASEDIR/my.cnf
    if [ $? -eq 0 ];then
        rm -f $BASEDIR/my.cnf
        echo ":::::::::::::::[Warning:The old option file [$BASEDIR/my.cnf] is exist,it will be deleted.]:::::::::::::::"
    fi
	cat > $BASEDIR/my.cnf <<EOF
[client]
port = $PORT
socket = $DATADIR/mysql.sock

[mysqld_safe]
socket = $DATADIR/mysql.sock
nice = 0

[mysqld]
#skip-grant-tables
#skip-name-resolve = 1
user = $MySQL_USER
port = $PORT
socket = $DATADIR/mysql.sock
pid-file = $DATADIR/mysql.pid
basedir = $BASEDIR
datadir = $DATADIR
max_connections = 3000
character-set-server = $CHARACTER
wait_timeout = 3600
interactive_timeout = 3600

server-id = 1
auto_increment_offset = 1
auto_increment_increment = 1

log_output = FILE
#log_error = $DATADIR/mysql.err

slow_query_log = on
slow_query_log_file = $LOGDIR/mysql-slow.log
long_query_time = 3
log_queries_not_using_indexes = on
general_log = on
general_log_file = $LOGDIR/mysql-general.log

log-bin = $BINLOGDIR/mysql-binlog
binlog-format = ROW
#log_slave_updates=ON
#gtid_mode=ON
#enforce_gtid_consistency=ON
master_info_repository=TABLE
relay_log_info_repository=TABLE
#binlog_checksum=NONE
expire_logs_days = 7
sync_binlog = 0
max_binlog_size = 1024M
relay-log = $RELAYLOGDIR/mysql-relay-bin
#binlog_rows_query_log_events = 1

innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 16777216
#innodb_log_file_size = 524288000
innodb_log_files_in_group = 3
innodb_buffer_pool_size = $mysqlMem
innodb_log_group_home_dir = $REDODIR
#innodb_rollback_segments = 128
innodb_undo_directory = $UNDODIR
innodb_undo_tablespaces = 2
innodb_flush_method = O_DIRECT
innodb_write_io_threads = 8
innodb_read_io_threads = 8
innodb_io_capacity = 300
#innodb_doublewrite = off

query_cache_type = off
query_cache_size = 0
max_heap_table_size = 64M
tmp_table_size = 64M
max_allowed_packet = 16M

#secure_file_priv = 
log_bin_trust_function_creators = 1
[mysql]
#no-auto-rehash
#prompt="\\u@\\h:\\d \\r:\\m:\\s>"

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqldump]
quick
quote-names
max_allowed_packet = 16M
EOF

    cd $BASEDIR
    scripts/mysql_install_db --defaults-file=$BASEDIR/my.cnf --user=$MySQL_USER
    echo ":::::::::::::::[DB Initializing... Please be waitting for $InitDBsleepNUM seconds...]:::::::::::::::"
    sleep $InitDBsleepNUM
    #test $(ps -ef|egrep -w "mysqld|mysqld_safe"|grep -v grep|wc -l) != 0 && pkill -9 mysqld_safe && pkill -9 mysqld
    bin/mysqld_safe --defaults-file=$BASEDIR/my.cnf --user=$MySQL_USER &
    echo ":::::::::::::::[Service starting... Please be waitting for $SleepNUM seconds...]:::::::::::::::"
    sleep $SleepNUM
    bin/mysql -hlocalhost -uroot -S $DATADIR/mysql.sock -e"show global status;" > /dev/null 2>&1
    if [ $? -eq 0 ];then
        echo ":::::::::::::::[MySQL DB initialize succesfully.]:::::::::::::::"
    else
       alert ":::::::::::::::[ERROR:MySQL DB initialize failed]:::::::::::::::"
    fi
}


function dbinitialize_for_MySQL55() {
    mkdir -p $DATADIR
    mkdir -p $REDODIR
    mkdir -p $BINLOGDIR
    mkdir -p $RELAYLOGDIR
    mkdir -p $LOGDIR
    chown $MySQL_USER:$MySQL_USER $DATADIR
    chown $MySQL_USER:$MySQL_USER $REDODIR
    chown $MySQL_USER:$MySQL_USER $BINLOGDIR
    chown $MySQL_USER:$MySQL_USER $RELAYLOGDIR
    chown $MySQL_USER:$MySQL_USER $LOGDIR
    chmod 775 $DATADIR
    chmod 775 $REDODIR
    chmod 775 $BINLOGDIR
    chmod 775 $RELAYLOGDIR
    chmod 775 $LOGDIR
	#totalMem=`free -m | grep Mem: |sed 's/^Mem:\s*//'| awk '{print $1}'`
    if [ $totalMem -lt 2048 ];then
        alert ":::::::::::::::[Warning:The physical memory is ${totalMem}M,MySQL advises at least 2G]:::::::::::::::" 
    else
        echo ":::::::::::::::[The machine physical memory is ${totalMem} (in MB)]:::::::::::::::"
    fi
    declare -i mysqlMem=$totalMem*1024*1024*50/100
    test -d $BASEDIR/my.cnf
    if [ $? -eq 0 ];then
        rm -f $BASEDIR/my.cnf
        echo ":::::::::::::::[Warning:The old option file [$BASEDIR/my.cnf] is exist,it will be deleted.]:::::::::::::::"
    fi
	cat > $BASEDIR/my.cnf <<EOF
[client]
port = $PORT
socket = $DATADIR/mysql.sock

[mysqld_safe]
socket = $DATADIR/mysql.sock
nice = 0

[mysqld]
#skip-grant-tables
#skip-name-resolve = 1
user = $MySQL_USER
port = $PORT
socket = $DATADIR/mysql.sock
pid-file = $DATADIR/mysql.pid
basedir = $BASEDIR
datadir = $DATADIR
max_connections = 3000
character-set-server = $CHARACTER
wait_timeout = 3600
interactive_timeout = 3600

server-id = 1
auto_increment_offset = 1
auto_increment_increment = 1

log_output = FILE
#log_error = $DATADIR/mysql.err

slow_query_log = on
slow_query_log_file = $LOGDIR/mysql-slow.log
long_query_time = 3
log_queries_not_using_indexes = on
general_log = on
general_log_file = $LOGDIR/mysql-general.log

log-bin = $BINLOGDIR/mysql-binlog
binlog-format = ROW
#log_slave_updates=ON
expire_logs_days = 7
sync_binlog = 0
max_binlog_size = 1024M
relay-log = $RELAYLOGDIR/mysql-relay-bin

innodb_flush_log_at_trx_commit = 2
innodb_log_buffer_size = 16777216
#innodb_log_file_size = 524288000
innodb_log_files_in_group = 3
innodb_buffer_pool_size = $mysqlMem
innodb_log_group_home_dir = $REDODIR
#innodb_rollback_segments = 128
innodb_flush_method = O_DIRECT
innodb_write_io_threads = 8
innodb_read_io_threads = 8
innodb_io_capacity = 300
#innodb_doublewrite = off

query_cache_type = off
query_cache_size = 0
max_heap_table_size = 64M
tmp_table_size = 64M
max_allowed_packet = 16M

#secure_file_priv = 
log_bin_trust_function_creators = 1
[mysql]
#no-auto-rehash
#prompt="\\u@\\h:\\d \\r:\\m:\\s>"

[myisamchk]
key_buffer_size = 20M
sort_buffer_size = 20M
read_buffer = 2M
write_buffer = 2M

[mysqldump]
quick
quote-names
max_allowed_packet = 16M
EOF

    cd $BASEDIR
    scripts/mysql_install_db --defaults-file=$BASEDIR/my.cnf --user=$MySQL_USER
    echo ":::::::::::::::[DB Initializing... Please be waitting for $InitDBsleepNUM seconds...]:::::::::::::::"
    sleep $InitDBsleepNUM
    #test $(ps -ef|egrep -w "mysqld|mysqld_safe"|grep -v grep|wc -l) != 0 && pkill -9 mysqld_safe && pkill -9 mysqld
    bin/mysqld_safe --defaults-file=$BASEDIR/my.cnf --user=$MySQL_USER &
    echo ":::::::::::::::[Service starting... Please be waitting for $SleepNUM seconds...]:::::::::::::::"
    sleep $SleepNUM
    bin/mysql -hlocalhost -uroot -S $DATADIR/mysql.sock -e"show global status;" > /dev/null 2>&1
    if [ $? -eq 0 ];then
        echo ":::::::::::::::[MySQL DB initialize succesfully.]:::::::::::::::"
    else
       alert ":::::::::::::::[ERROR:MySQL DB initialize failed]:::::::::::::::"
    fi
}

function dbinitialize_rollback() {
    cd $SAFEDIR
    test -d $DATADIR
    if [ $? -eq 0 ];then
        rm -rf $DATADIR
    fi
    test -d $REDODIR
    if [ $? -eq 0 ];then
        rm -rf $REDODIR
    fi
    test -d $UNDODIR
    if [ $? -eq 0 ];then
        rm -rf $UNDODIR
    fi
    test -d $BINLOGDIR
    if [ $? -eq 0 ];then
        rm -rf $BINLOGDIR
    fi
    test -d $RELAYLOGDIR
    if [ $? -eq 0 ];then
        rm -rf $RELAYLOGDIR
    fi
    test -d $LOGDIR
    if [ $? -eq 0 ];then
        rm -rf $LOGDIR
    fi
    test -e $BASEDIR/my.cnf
    if [ $? -eq 0 ];then
        rm -f $BASEDIR/my.cnf
    fi
}

function passwd_modify() {
    cd $BASEDIR
    refer_version=5.6
    mysql_version=`bin/mysql -hlocalhost -uroot -S $DATADIR/mysql.sock -e"select substring_index(substring_index(version(),'-',1),'.',2);"|awk '{print $NF}'|awk 'NR>1'`
    echo ":::::::::::::::[Current MySQL version IS $mysql_version]:::::::::::::::"
    if [ `echo "$mysql_version <= $refer_version"|bc` -eq 1 ];then
        bin/mysql -hlocalhost -uroot -S $DATADIR/mysql.sock <<EOF
set password for 'root'@'localhost' = password('$MySQL_SYSPWD');
flush privileges;
EOF
        bin/mysql -hlocalhost -uroot -p$MySQL_SYSPWD -S $DATADIR/mysql.sock -e"show global status;" > /dev/null 2>&1
        if [ $? -eq 0 ];then
            echo ":::::::::::::::[MySQL Account 'root'@'localhost' Password modified is succesfully.]:::::::::::::::"
        else
            alert ":::::::::::::::[ERROR:MySQL Account 'root'@'localhost' Password modified is failed]:::::::::::::::"
        fi
    else
        #tmppwd=`cat /tmp/initialize.log|grep -w "A temporary password"|awk '{print $NF}'`
        bin/mysql -hlocalhost -uroot -S $DATADIR/mysql.sock <<EOF
UPDATE mysql.user SET authentication_string='' WHERE user='root' and host='localhost';
commit;
EOF
        bin/mysqladmin -hlocalhost -uroot -S $DATADIR/mysql.sock shutdown
        echo ":::::::::::::::[Service stopping... Please be waitting for $SleepNUM seconds...]:::::::::::::::"
        sleep $SleepNUM
        #test $(ps -ef|egrep -w "mysqld|mysqld_safe"|grep -v grep|wc -l) != 0 && pkill -9 mysqld_safe && pkill -9 mysqld
        bin/mysqld_safe --defaults-file=$BASEDIR/my.cnf --user=$MySQL_USER &
        echo ":::::::::::::::[Service starting... Please be waitting for $SleepNUM seconds...]:::::::::::::::"
        sleep $SleepNUM
        bin/mysql -hlocalhost -uroot -S $DATADIR/mysql.sock --connect-expired-password <<EOF
alter user 'root'@'localhost' identified by '$MySQL_SYSPWD';
flush privileges;
EOF
        bin/mysql -hlocalhost -uroot -p$MySQL_SYSPWD -S $DATADIR/mysql.sock -e"show global status;" > /dev/null 2>&1
        if [ $? -eq 0 ];then
            echo ":::::::::::::::[MySQL Account 'root'@'localhost' Password modified is succesfully.]:::::::::::::::"
        else
            alert ":::::::::::::::[ERROR:MySQL Account 'root'@'localhost' Password modified is failed]:::::::::::::::"
        fi
    fi
}

function passwd_modify_rollback() {
    cd $BASEDIR
    refer_version=5.6
    mysql_version=`bin/mysql -hlocalhost -uroot -p$MySQL_SYSPWD -S $DATADIR/mysql.sock -e"select substring_index(substring_index(version(),'-',1),'.',2);"|awk '{print $NF}'|awk 'NR>1'`
    echo ":::::::::::::::[Current MySQL version IS $mysql_version]:::::::::::::::"
    if [ `echo "$mysql_version <= $refer_version"|bc` -eq 1 ];then
        bin/mysql -hlocalhost -uroot -p$MySQL_SYSPWD -S $DATADIR/mysql.sock <<EOF
set password for 'root'@'localhost' = password('');
flush privileges;
EOF
        bin/mysql -hlocalhost -uroot -S $DATADIR/mysql.sock -e"show global status;" > /dev/null 2>&1
        if [ $? -eq 0 ];then
            MySQL_SYSPWD=""
            echo ":::::::::::::::[MySQL Account 'root'@'localhost' Password rollback is succesfully.]:::::::::::::::"
        else
            echo ":::::::::::::::[ERROR:MySQL Account 'root'@'localhost' Password rollback is failed]:::::::::::::::"
        fi
    else
        bin/mysql -hlocalhost -uroot -p$MySQL_SYSPWD -S $DATADIR/mysql.sock <<EOF
alter user 'root'@'localhost' identified by '';
flush privileges;
EOF
        bin/mysql -hlocalhost -uroot -S $DATADIR/mysql.sock --connect-expired-password -e"show global status;" > /dev/null 2>&1
        if [ $? -eq 0 ];then
            MySQL_SYSPWD=""
            echo ":::::::::::::::[MySQL Account 'root'@'localhost' Password rollback is succesfully.]:::::::::::::::"
        else
            echo ":::::::::::::::[ERROR:MySQL Account 'root'@'localhost' Password rollback is failed]:::::::::::::::"
        fi
    fi
}  

function single_MySQL_config() {
    cd $SAFEDIR
    test -e /etc/my.cnf && mv -f /etc/my.cnf /etc/my.cnf.bak && cp $BASEDIR/my.cnf /etc/my.cnf || cp $BASEDIR/my.cnf /etc/my.cnf
    cp /etc/profile $INSTALLPREDIR/
	cat >> /etc/profile <<EOF
export PATH=$BASEDIR/bin:\$PATH
EOF
    source /etc/profile
    which mysql
    if [ $? -eq 0 ];then
        echo ":::::::::::::::[MySQL ENV Config is [Succesfully].]:::::::::::::::"
    else
        alert ":::::::::::::::[MySQL ENV Config is [Failed].]:::::::::::::::"
    fi
}

function Multi_MySQL_config() {
    cd $SAFEDIR
	cat > $SAFEDIR/mysql$PORT <<EOF
#!/bin/bash
export MYSQL_HISTFILE=$HOME/.mysql${PORT}_history
export MYSQL_HOST=$MYSQL_SYSHOST
export USER=$MySQL_SYSUSER
export MYSQL_PWD=$MySQL_SYSPWD
export MYSQL_UNIX_PORT=$DATADIR/mysql.sock
$BASEDIR/bin/mysql
EOF
    test -e $SAFEDIR/mysql$PORT && chmod +x $SAFEDIR/mysql$PORT && cp $SAFEDIR/mysql$PORT /usr/bin
}

function Multi_MySQL_config_rollback() {
    cd $SAFEDIR
    test -e /usr/bin/mysql$PORT && rm -f /usr/bin/mysql$PORT
    test -e $SAFEDIR/mysql$PORT && rm -f $SAFEDIR/mysql$PORT
}

function single_MySQL_config_rollback() {
    cd $SAFEDIR
    test -e /etc/my.cnf && mv -f /etc/my.cnf /tmp
    test -e $INSTALLPREDIR/profile
    if [ $? -eq 0 ];then
        mv -f /etc/profile /tmp
        cp $INSTALLPREDIR/profile /etc/profile
    fi
}

function mysql_check() {
    cd $BASEDIR
    if [ "$MySQL_SYSPWD" != "" ];then
        bin/mysql -hlocalhost -uroot -p$MySQL_SYSPWD -S $DATADIR/mysql.sock -e"show global status;" > /dev/null 2>&1
    else
        bin/mysql -hlocalhost -uroot -S $DATADIR/mysql.sock -e"show global status;" > /dev/null 2>&1
    fi
    if [ $? -eq 0 ];then
        echo ":::::::::::::::[MySQL SERVICE IS NORMAL.]:::::::::::::::"
    else
        echo ":::::::::::::::[MySQL SERVICE IS ABNORMAL.]:::::::::::::::"
    fi
}

function mysql_stop() {
    cd $BASEDIR
    #test $(ps -ef|egrep -w "mysqld|mysqld_safe"|grep -v grep|wc -l) != 0 && pkill -9 mysqld_safe && pkill -9 mysqld
    if [ "$MySQL_SYSPWD" != "" ];then
        bin/mysqladmin -hlocalhost -uroot -p$MySQL_SYSPWD -S $DATADIR/mysql.sock shutdown
    else
        bin/mysqladmin -hlocalhost -uroot -S $DATADIR/mysql.sock shutdown
    fi
    echo ":::::::::::::::[Service stopping... Please be waitting for $SleepNUM seconds...]:::::::::::::::"
    sleep $SleepNUM
}

function main() {
	DEBUG_FLG='McDeBuG'
	#my_debug_flg=`echo $*| awk '{print $NF}'`
    if [[ "$my_debug_flg" = "$DEBUG_FLG" ]]; then
        export PS4='+{$LINENO:${FUNCNAME[0]}} '
        set -x
        echo args=$@
    fi
    read -r -p "Welcome to the MySQL Install or Deinstall , please check? [I/d]" input
    case $input in
        [iI])
            read -r -p "It will be executing os_config [Attention:::running at the First Time - Just once], please check again? [Y/n]" input
            case $input in
                [yY])
                    echo ""
                    echo "***"
                    echo "---------------------------INFO:os_config Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
                    echo "***"
                    os_config
                    echo "***"
                    echo "---------------------------INFO:os_config End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
                    echo "***"
                    ;;
                [nN])
                    ;;
                *)
                    echo "Invalid input..."
                    exit 1
                    ;;
            esac
            echo ""
            echo "***"
            echo "---------------------------INFO:mysql_soft_install Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            mysql_soft_install
            echo "***"
            echo "---------------------------INFO:mysql_soft_install End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            #read -r -p "Enter the current installation MySQL media version , please check again? [5.5/5.6/5.7/8.0]" $MySQL_VERSION
            case $MySQL_VERSION in
                "5.5")
                    echo ""
                    echo "***"
                    echo "---------------------------INFO:dbinitialize_for_MySQL55 Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
                    echo "***"
                    dbinitialize_for_MySQL55
                    echo "***"
                    echo "---------------------------INFO:dbinitialize_for_MySQL55 End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
                    echo "***"
                    ;;
                "5.6")
                    echo ""
                    echo "***"
                    echo "---------------------------INFO:dbinitialize_for_MySQL56 Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
                    echo "***"
                    dbinitialize_for_MySQL56
                    echo "***"
                    echo "---------------------------INFO:dbinitialize_for_MySQL56 End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
                    echo "***"
                    ;;
                "5.7")
                    echo ""
                    echo "***"
                    echo "---------------------------INFO:dbinitialize_for_MySQL57 Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
                    echo "***"
                    dbinitialize_for_MySQL57
                    echo "***"
                    echo "---------------------------INFO:dbinitialize_for_MySQL57 End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
                    echo "***"
                    ;;
                "8.0")
                    echo ""
                    echo "***"
                    echo "---------------------------INFO:dbinitialize_for_MySQL80 Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
                    echo "***"
                    dbinitialize_for_MySQL80
                    echo "***"
                    echo "---------------------------INFO:dbinitialize_for_MySQL80 End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
                    echo "***"
                    ;;
                *)
                    echo "Invalid input..."
                    exit 1
                    ;;
            esac
            echo ""
            echo "***"
            echo "---------------------------INFO:passwd_modify Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            passwd_modify
            echo "***"
            echo "---------------------------INFO:passwd_modify End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            echo ""
            echo "***"
            echo "---------------------------INFO:mysql_config Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            test $Instances -eq 1 && single_MySQL_config || Multi_MySQL_config
            echo "***"
            echo "---------------------------INFO:mysql_config End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            echo ""
            echo "***"
            echo "---------------------------INFO:mysql_check Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            mysql_check
            echo "***"
            echo "---------------------------INFO:mysql_check End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            #echo ""
            #echo "---------------------------INFO:MYSQL INSTALL Completed successfully at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"           
            ;;
        [dD])
            echo ""
            echo "***"
            echo "---------------------------INFO:mysql_check Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            mysql_check
            echo "***"
            echo "---------------------------INFO:mysql_check End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            echo ""
            echo "***"
            echo "---------------------------INFO:passwd_modify_rollback Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            passwd_modify_rollback
            echo "***"
            echo "---------------------------INFO:passwd_modify_rollback End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            echo ""
            echo "***"
            echo "---------------------------INFO:mysql_stop Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            mysql_stop
            echo "***"
            echo "---------------------------INFO:mysql_stop End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            echo ""
            echo "***"
            echo "---------------------------INFO:mysql_config_rollback Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            test $Instances -eq 1 && single_MySQL_config_rollback || Multi_MySQL_config_rollback
            echo "***"
            echo "---------------------------INFO:mysql_config_rollback End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            echo ""
            echo "***"
            echo "---------------------------INFO:dbinitialize_rollback Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            dbinitialize_rollback
            echo "***"
            echo "---------------------------INFO:dbinitialize_rollback End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            echo ""
            echo "***"
            echo "---------------------------INFO:mysql_soft_install_rollback Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            mysql_soft_install_rollback
            echo "***"
            echo "---------------------------INFO:mysql_soft_install_rollback End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            echo "***"
            read -r -p "It will be executing os_config_rollback [Attention:::running at the Last Time - Just once], please check again? [Y/n]" input
            case $input in
                [yY])
                    echo ""
                    echo "***"
                    echo "---------------------------INFO:os_config_rollback Begin at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
                    echo "***"
                    os_config_rollback
                    echo "***"
                    echo "---------------------------INFO:os_config_rollback End   at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
                    echo "***"
                    ;;
                [nN])
                    exit 1
                    ;;
                *)
                    echo "Invalid input..."
                    exit 1
                    ;;
            esac
            #echo ""
            #echo "---------------------------INFO:MYSQL DEINSTALL Completed successfully at [$(date +"%Y-%m-%d %H:%M:%S")]---------------------------"
            ;;            
        [nN])
            exit 1
            ;;
        *)
            echo "Invalid input..."
            exit 1
            ;;
    esac
}
main $@ 2>&1