FROM acmeofmanas/rhel7.4:latest

# Presto-RHEL74
ARG Starburst-Presto=208.x.0.2

# Configure environment
ENV HTTPS_PORT 7778
ENV HOSTNAME='coordinator'

# Create superset user & install dependencies
RUN mkdir -p /opt/presto/client
ADD presto-server-0.208-x.0.2.tar.gz /opt/presto/
RUN ln -s /opt/presto/presto-server-0.208-x.0.2 /opt/presto/presto-server
RUN ls -l /opt/presto/
COPY presto-cli-0.208-x.0.8-executable.jar /opt/presto/client/
COPY config/jvm.config  /opt/presto/presto-server/etc/
COPY config/config.properties /opt/presto/presto-server/etc/
COPY config/node.properties /opt/presto/presto-server/etc/
COPY config/log.properties /opt/presto/presto-server/etc/
COPY config/presto.jks /opt/presto/presto-server/etc/

#Copy all dependent file
COPY alluxio-client.jar /opt/presto/presto-server/plugin/hive-hadoop2/

#COPY config/presto.keytab /opt/presto/presto-server/etc/

COPY catalog/jmx.properties /opt/presto/presto-server-0.208-x.0.2/etc/catalog/
COPY start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh
#Hadoop Specific file Copy
COPY hadoop_conf/ /etc/
#COPY krb5-example.conf /etc/krb5.conf 
COPY krb5.conf /etc/

COPY jdk-8u191-linux-x64.rpm  /tmp/jdk-8u191-linux-x64.rpm
RUN rpm -ivh /tmp/jdk-8u191-linux-x64.rpm
RUN mv /etc/yum.repos.d/*.repo /tmp/
COPY base.repo /etc/yum.repos.d/
RUN ls -l /etc/yum.repos.d/
#COPY cityfan.repo /etc/yum.repos.d/
#COPY epel.repo /etc/yum.repos.d/
#Install Dependency 
#RUN yum update -y curl
#RUN yum install net-tools -y \
#    krb5-workstation	
RUN yum install net-tools krb5-workstation openssh openssh-server openssh-clients openssl-libs rsync augeas -y
#RUN chown presto:presto -R /opt/presto/
#COPY presto1.keytab /opt/presto/presto-server/etc/presto.keytab
COPY entry.sh /entry.sh
# Configure Filesystem
#VOLUME /opt/presto 

#WORKDIR /home/superset

# Deploy application
EXPOSE 7778 22
RUN ln -s /opt/presto/client/presto-cli-0.208-x.0.8-executable.jar /opt/presto/client/presto-cli
#CMD /opt/presto/presto-server-0.208-x.0.2/bin/launcher run
ENTRYPOINT ["/entry.sh"]
CMD ["/usr/sbin/sshd", "-D"]
