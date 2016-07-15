FROM centos:6.8

# Install EPEL
RUN yum install -y epel-release \

#ius repo
&& yum install -y https://centos6.iuscommunity.org/ius-release.rpm \

&& rpm -Uvh http://dev.mysql.com/get/mysql-community-release-el6-5.noarch.rpm \

# Update RPM Packages
&& yum -y update && yum clean all \
&& yum install -y wget tar gcc supervisor nginx git php56u-mbstring php56u-fpm php56u-pdo php56u-mcrypt php56u-imap php56u-gd php56u-cli php56u php56u-soap php56u-pear php56u-common php56u-xml php56u-opcache php56u-pecl-jsonc php56u-mysqlnd php56u-pecl-memcached php56u-pecl-igbinary mysql-community-server rsyslog cronie-noanacron openssh-server sudo 

# set timezone
RUN rm -f /etc/localtime 
RUN ln -s /usr/share/zoneinfo/UTC /etc/localtime 
RUN mv -f /etc/supervisord.conf /etc/supervisord.conf.org 

# no PAM
RUN cp -a /etc/pam.d/crond /etc/pam.d/crond.org 
RUN sed -i -e 's/^\(session\s\+required\s\+pam_loginuid\.so\)/#\1/' /etc/pam.d/crond 


# no PAM
# http://stackoverflow.com/questions/18173889/cannot-access-centos-sshd-on-docker
RUN sed -i -e 's/^\(UsePAM\s\+.\+\)/#\1/gi' /etc/ssh/sshd_config 
RUN echo -e '\nUsePAM no' >> /etc/ssh/sshd_config 

RUN echo 'root:root' | chpasswd 
# no direct ROOT login
RUN sed -i -e 's/^\(PermitRootLogin\s\+.\+\)/#\1/gi' /etc/ssh/sshd_config 
RUN echo -e '\nPermitRootLogin no' >> /etc/ssh/sshd_config 


RUN useradd -g wheel www 
RUN echo 'www:anhyeuem' | chpasswd 
RUN sed -i -e 's/^\(%wheel\s\+.\+\)/#\1/gi' /etc/sudoers 
RUN echo -e '\n%wheel ALL=(ALL) ALL' >> /etc/sudoers 

# allow sudo without tty for ROOT user and WHEEL group
# http://qiita.com/ryo0301/items/4daf5a6d22f16193410f
RUN echo -e '\nDefaults:root   !requiretty' >> /etc/sudoers 
RUN echo -e '\nDefaults:%wheel !requiretty' >> /etc/sudoers 

ADD ./mysql_init.sh /mysql_init.sh
RUN chmod +x /mysql_init.sh
RUN ./mysql_init.sh

#RUN service mysqld start 
#RUN /usr/bin/mysqladmin -u root password 'Anhyeuem123'
#RUN service mysqld stop

#RUN chown -R mysql:mysql /var/lib/mysql

ADD supervisord.conf /etc/
VOLUME /var/www
VOLUME /var/lib/mysql

EXPOSE 22 80 3306

CMD ["/usr/bin/supervisord"]