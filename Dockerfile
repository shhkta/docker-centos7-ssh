FROM centos:latest

RUN yum -y update && \
    yum -y install openssh-server openssh-clients initscripts sudo passwd sed tmux gcc make &&\
    yum -y clean all

COPY id_rsa.pub /root/id_rsa.pub
COPY sshd.sh /root/sshd.sh
RUN root_passwd=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 50 | head -n  1) &&\
    dev_passwd=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 50 | head -n  1) &&\
    echo $root_passwd > /root/root_passwd.txt &&\
	echo root:$root_passwd | chpasswd &&\
    useradd  dev &&\
	echo dev:$user_passwd | chpasswd &&\
	echo $dev_passwd > /home/dev/dev_passwd.txt &&\
	usermod -G wheel dev &&\
	mkdir /home/dev/.ssh &&\
	chmod 700 /home/dev/.ssh &&\
	cp /root/id_rsa.pub /home/dev/.ssh/authorized_keys &&\
	chmod 600 /home/dev/.ssh/authorized_keys &&\
	chown dev:dev /home/dev/.ssh /home/dev/.ssh/* /home/dev/dev_passwd.txt &&\
	sed -i -e 's/^#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config &&\
	sed -i -e 's/^#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config &&\
	sed -i -e 's/^#RSAAuthentication yes/RSAAuthentication yes/' /etc/ssh/sshd_config &&\
	sed -i -e 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config &&\
	#sed -i -e 's/^UsePAM yes/UsePAM no/' /etc/ssh/sshd_config &&\
	/usr/sbin/sshd-keygen

EXPOSE 22
ENTRYPOINT ["/bin/sh","/root/sshd.sh"]
#ENTRYPOINT ["/usr/sbin/sshd", "-D"]
