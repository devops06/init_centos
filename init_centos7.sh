

#chaneg eth name
LOCAL_ENNAME=ens33
LOCAL_IP=`ip a show ens33 |awk '/inet.*brd.*'$LOCAL_ENNAME'/{print $2}' |awk -F "/" '{print $1}'`
#changed timezone to shanghai
ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

#yum 
yum install -y bash-completion  net-tools  git vim ntpdate 
yum -y groupinstall Development tools
#set hostname
hostname |grep devops ||hostnamectl set-hostname devops
grep devops /etc/hosts || echo "$LOCAL_IP devops" >>/etc/hosts


# disbale firewalld 
systemctl disable firewalld && systemctl stop firewalld

# disable selinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
grep SELINUX=disabled /etc/selinux/config

# change open file and process

grep  65535 /etc/security/limits.conf  || echo "* soft noproc 65535
* hard noproc 65535
* soft nofile 65535
* hard nofile 65535" >>/etc/security/limits.conf

# install docker-engine and config 
rpm -aq|grep docker || yum install -y http://mirrors.aliyun.com/docker-engine/yum/repo/main/centos/7/Packages/docker-engine-1.12.6-1.el7.centos.x86_64.rpm 
grep overlay /usr/lib/systemd/system/docker.service ||sed -i "s#ExecStart=/usr/bin/dockerd#ExecStart=/usr/bin/dockerd -s overlay -g /data/docker --insecure-registry 0.0.0.0/0#" /usr/lib/systemd/system/docker.service
systemctl daemon-reload && systemctl restart docker && systemctl enable  docker

#install dao  for get docker images fast 
rpm -qa|grep dao||curl -sSL https://get.daocloud.io/daomonit/install.sh | sh -s 7a6d83cbe808b45fbcc77d451d82f

# install docker-compose 
which docker-compose ||curl -o /usr/bin/docker-compose  https://mirrors.aliyun.com/docker-toolbox/linux/compose/1.8.0/docker-compose-Linux-x86_64
chmod +x  /usr/bin/docker-compose

# install golang
rpm -aq |grep golang || yum install -y golang  

docker-compose up -d 
