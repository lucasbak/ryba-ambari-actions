FROM centos:7
MAINTAINER Lucas BAKALIAN

# Install essential packages
RUN yum install -y wget epel-release unzip

# Install ambari-server & ambari-agent
RUN wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.6.2.2/ambari.repo -O /etc/yum.repos.d/ambari.repo
RUN yum install -y ambari-server ambari-agent
RUN systemctl enable ambari-server

# Install JAVA 1.8
WORKDIR /tmp
ENV JAVA_HOME /usr/java/default
#RUN curl -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" -k "http://download.oracle.com/otn-pub/java/jdk/8u181-b13/96a7b8442fe848ef90c96a2fad6ed6d1/jdk-8u181-linux-x64.rpm"
ADD jdk/jdk-8u191-linux-x64.rpm /tmp/jdk-8u191-linux-x64.rpm
RUN rpm -ivh jdk-8u191-linux-x64.rpm
ADD jdk/jce_policy-8.zip /tmp/jce_policy-8.zip
# RUN curl -L -O -H "Cookie: oraclelicense=accept-securebackup-cookie" -k "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"
RUN unzip jce_policy-8.zip
RUN cp UnlimitedJCEPolicyJDK8/US_export_policy.jar /usr/java/default/jre/lib/security/US_export_policy.jar
RUN cp UnlimitedJCEPolicyJDK8/local_policy.jar /usr/java/default/jre/lib/security/local_policy.jar


# Install supervisor
RUN \
  yum install -y iproute python-setuptools hostname inotify-tools yum-utils which && \
  easy_install supervisor

# Install SSH
RUN yum install -y openssh-server openssh-clients \
  && ssh-keygen -t rsa -f ~/.ssh/id_rsa -N '' \
  && cat ~/.ssh/id_rsa.pub > ~/.ssh/authorized_keys \
  && ssh-keygen -f /etc/ssh/ssh_host_rsa_key

# Ambari Server Setup

RUN yum install -y mysql-connector-java
#RUN yum install -y mariadb-server 
RUN yum clean all

RUN systemctl enable ambari-server

RUN echo DefaultEnvironment=\"JAVA_HOME=$JAVA_HOME\" >> /etc/systemd/system.conf
ENV TERM xterm
EXPOSE 8080 22

RUN yum install -y mariadb
RUN wget -nv http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.39.tar.gz -O /var/lib/ambari-server/resources/mysql-jdbc-driver.jar
RUN wget -nv https://jdbc.postgresql.org/download/postgresql-9.4.1208.jre7.jar -O /var/lib/ambari-server/resources/postgres-jdbc-driver.jar
ADD ./supervisord.conf /etc/supervisord.conf
ADD ./run.sh /run.sh
RUN chmod +x /run.sh
ADD ./hostname.sh /etc/ambari-agent/conf/hostname.sh
RUN chmod +x /etc/ambari-agent/conf/hostname.sh
ADD ./ambari-agent.ini /etc/ambari-agent/conf/ambari-agent.ini
RUN chmod +x /etc/ambari-agent/conf/ambari-agent.ini
ENTRYPOINT ["/run.sh"]
CMD []