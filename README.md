# MySQL_single_AutoInstall
Implementation of MySQL single instance installation
脚本版本号：1.5.5

支持操作系统版本 : LINUX 6/7

支持数据库版本   : MySQL5.5 MySQL5.6 MySQL5.7 MySQL8.0

自动化安装步骤如下:

一、创建相关必要目录，假设为/u01/mysql57

注:若安装多个不同版本数据库请创建不同目录！！

mkdir -p /u01/mysql57

二、上传相关介质至操作系统文件系统/u01/mysql57

1.自动化安装脚本(LocalAutoInstall_Linux6-7_MySQL5.5-8.0_v1.5.5.sh)

2.MySQL数据库介质(二进制压缩文件)

3.对应操作系统介质(iso文件)

三、赋权

chmod u+x LocalAutoInstall_Linux6-7_MySQL5.5-8.0_v1.5.5.sh

四、开始自动化安装

1.相关参数介绍

-c : 数据字符集(UTF8,UTF8MB4,GBK等)

-d : 数据库安装目录(当前目录下需存在步骤二上传的三个文件)

-f : 数据库介质全称

-G : 输出调试信息

-h : 获取帮助信息(./LocalAutoInstall_Linux6-7_MySQL5.5-8.0_v1.5.5.sh -h 1)

-i : 当前主机IP

-I : 配置主机上数据库实例数量，默认为1

-p : 配置主机上数据库实例端口号，默认为3306

-s : 等待启动/关闭数据库服务等待时间，默认为10s

-S : 等待启动/关闭数据库初始化等待时间，默认为10s


2.MySQL安装

--单实例安装

Case 1:

       Eg: sh LocalAutoInstall_Linux6-7_MySQL5.5-8.0_v1.5.5.sh -c utf8 -d /u01/mysql57/ -f mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz -i 192.168.238.98 -I 1 -p 3306 -s 10 -S 10

Case 2:

       Eg: sh LocalAutoInstall_Linux6-7_MySQL5.5-8.0_v1.5.5.sh -c utf8 -d /u01/mysql57/ -f mysql-5.7.25-linux-glibc2.12-x86_64.tar.gz -i 192.168.238.98

--多实例安装

注:需将自动化安装脚本及操作系统介质移动到相应文件目录

Case 1:
      
      Eg: sh LocalAutoInstall_Linux6-7_MySQL5.5-8.0_v1.5.5.sh -c utf8 -d /u01/mysql55/ -f mysql-5.5.61-linux-glibc2.12-x86_64.tar.gz -i 192.168.238.98 -I 4 -p 3305 -s 10 -S 10

Case 2:
       
       Eg: sh LocalAutoInstall_Linux6-7_MySQL5.5-8.0_v1.5.5.sh -c utf8 -d /u01/mysql56/ -f mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz -I 4 -p 3306
       
       Eg: sh LocalAutoInstall_Linux6-7_MySQL5.5-8.0_v1.5.5.sh -c utf8 -d /u01/mysql57/ -f mysql-5.7.21-linux-glibc2.12-x86_64.tar.gz -I 4 -p 3307
       
       Eg: sh LocalAutoInstall_Linux6-7_MySQL5.5-8.0_v1.5.5.sh -c utf8 -d /u01/mysql80/ -f mysql-8.0.15-linux-glibc2.12-x86_64.tar.xz -I 4 -p 3308      

3.在任意阶段出现中断，请进行如下操作进行回滚

--单实例卸载

sh LocalAutoInstall_Linux6-7_MySQL5.5-8.0_v1.5.5.sh -d /u01/mysql57/ -f mysql-5.7.21-linux-glibc2.12-x86_64.tar.gz

--多实例卸载 

sh LocalAutoInstall_Linux6-7_MySQL5.5-8.0_v1.5.5.sh -d /u01/mysql80/ -f mysql-8.0.15-linux-glibc2.12-x86_64.tar.xz -I 4 -p 3308

sh LocalAutoInstall_Linux6-7_MySQL5.5-8.0_v1.5.5.sh -d /u01/mysql57/ -f mysql-5.7.21-linux-glibc2.12-x86_64.tar.gz -I 4 -p 3307

sh LocalAutoInstall_Linux6-7_MySQL5.5-8.0_v1.5.5.sh -d /u01/mysql56/ -f mysql-5.6.43-linux-glibc2.12-x86_64.tar.gz -I 4 -p 3306

sh LocalAutoInstall_Linux6-7_MySQL5.5-8.0_v1.5.5.sh -d /u01/mysql55/ -f mysql-5.5.61-linux-glibc2.12-x86_64.tar.gz -I 4 -p 3305   


五、测试使用

注：自动化安装完毕，当前root用户密码均为mysql

--单实例测试

shell> source /etc/profile

shell> mysql -uroot -pmysql 

--多实例测试(针对每个版本分装命令账号为root/mysql)

shell> mysql3305

shell> mysql3306

shell> mysql3307

shell> mysql3308

