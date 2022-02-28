```bash
#!/bin/bash
## for CentOS7-minimal版本的安装

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

yum install wget net-tools -y
systemctl enable rc-local.service
chmod +x /etc/rc.d/rc.local

## 修改yum资源库为阿里的镜像
cd /etc/yum.repos.d/
rm -f  *.repo 
wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo

## 升级系统，安装开发编译包及常用软件
echo -n "Upgrade the system package......"  
yum groupinstall "Development Tools" "System administration tools" -y
yum install zlib zlib-devel libpng libpng-devel freetype freetype-devel -y
yum install fontconfig fontconfig-devel libart_lgpl  libart_lgpl-devel  libtool-ltdl libtool-ltdl-devel -y
yum install ntp wget make cmake vim-enhanced man traceroute mailx  lsof bc tree telnet lrzsz -y
yum install net-snmp-utils net-snmp ntsysv bind-utils jwhois pciutils lm_sensors  -y
yum install apr apr-devel apr-util-devel  pcre-devel  libzip-devel libzip openssl openssl-devel  libjpeg-devel -y
yum install iotop dstat mtr iptraf sysstat  bind-utils bash -y
yum update -y 
rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

## 优化服务
echo "Turn off unnecessary system services."
systemctl disable firewalld.service

## 禁用ipv6
echo '127.0.0.1   localhost localhost.localdomain' > /etc/hosts
sed -i 's/quiet/quiet ipv6.disable=1/'  /etc/default/grub 
grub2-mkconfig -o /boot/grub2/grub.cfg

## 关闭SELINUX
echo -n "Disable SELinux....."
setenforce  0
sed -i 's/^SELINUX=.*$/SELINUX=disabled/g' /etc/selinux/config
echo "[OK]"

## 修改文件描述符数量
echo -n "Increase the system file descriptor."
echo "* soft nofile 204800" >> /etc/security/limits.conf
echo "* hard nofile 204800" >> /etc/security/limits.conf
echo "[OK]"

## 优化SSH配置
echo -n  "Configure ssh service......"
sed -i 's/^GSSAPIAuthentication yes$/GSSAPIAuthentication no/' /etc/ssh/sshd_config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
service sshd restart
echo "[OK]"

## network
echo -n  "Configure network setup ......"
echo >>/etc/sysctl.conf

cat << EOF >>/etc/sysctl.conf
## add system optimizer
fs.file-max = 655360
fs.inotify.max_user_watches = 8192000
net.core.netdev_max_backlog = 262144
net.core.rmem_max = 16777216
net.core.somaxconn = 65535
net.core.wmem_max = 16777216
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.arp_announce = 2
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.lo.arp_ignore = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.ip_forward = 1
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_intvl = 5
net.ipv4.tcp_keepalive_probes = 2
net.ipv4.tcp_keepalive_time = 60
net.ipv4.tcp_max_orphans = 3276800
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_max_tw_buckets = 30000
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_retries2 = 5
net.ipv4.tcp_rmem = 4096 87380 16777216 
net.ipv4.tcp_sack = 1
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syncookies = 1 
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_tw_recycle = 1 
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_window_scaling = 1
net.ipv4.tcp_wmem = 4096 87380 16777216
vm.overcommit_memory = 1
vm.swappiness = 0
EOF

sysctl -p
echo "[OK]"

## history
echo -n " Setup profile ......."
echo "ulimit -u 204800 -HSn 204800" >> /etc/profile
echo 'export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "' >>/etc/profile
echo 'export EDITOR="/usr/bin/vim"' >>/etc/profile
echo 'alias vi=vim' >>/etc/profile
sed -i "s/HISTSIZE=1000/HISTSIZE=10000/" /etc/profile
source /etc/profile
echo "[OK]"

## ntp  sync network time
##手动做一次时间同步
/usr/sbin/ntpdate ntp.ntsc.ac.cn
echo -n "Setup ntp ......"
echo '01 0 * * *  /usr/sbin/ntpdate ntp.ntsc.ac.cn  && /sbin/hwclock -w' >>  /var/spool/cron/root
echo '00 01 * * 7 /usr/bin/yum update -y' >>  /var/spool/cron/root
echo "[OK]"

## reboot
echo "Press any key to reboot server......"
read
reboot
```