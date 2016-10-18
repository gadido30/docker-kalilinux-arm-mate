# Pull base image.
FROM antoineb/kalilinux-arm

ENV DEBIAN_FRONTEND noninteractive
ADD sources.list /etc/apt/
RUN 	apt-get update
RUN     apt-get -o Dpkg::Options::="--force-confdef" dist-upgrade -y
RUN     apt-get install -y kali-defaults kali-root-login x11vnc autocutsel xvfb supervisor kali-linux-web

RUN     apt-get install -y --reinstall dbus
RUN     apt-get install -y desktop-base mate-core

#RUN    apt-get install --no-install-recommends blueman -y desktop-base mate-core mate-desktop-environment-extra mate-desktop-environment-extras

# Install Java.
ENV JAVA_VERSION 8u101
ENV BUILD_VERSION b13
RUN  wget --no-cookies --no-check-certificate --header "Cookie: oraclelicense=accept-securebackup-cookie" "http://download.oracle.com/otn-pub/java/jdk/$JAVA_VERSION-$BUILD_VERSION/jdk-$JAVA_VERSION-linux-arm32-vfp-hflt.tar.gz" -O /tmp/jdk-8-linux-arm.tar.gz
RUN  tar zxvf /tmp/jdk-8-linux-arm.tar.gz -C /opt
RUN  update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_101/bin/java 1
RUN  update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_101/bin/javac 1
RUN  update-alternatives --set java /opt/jdk1.8.0_101/bin/java
RUN  update-alternatives --set javac /opt/jdk1.8.0_101/bin/javac

RUN mkdir -p /root/.x11vnc /root/.vnc/certs/ /data &&\
	ln -s /data /root/Documents &&\
	x11vnc -storepasswd passw0rd /root/.x11vnc/passwd

ADD agent.conf /etc/supervisor/conf.d
ADD supervisord.conf /etc/supervisor
ADD server.pem /root/.vnc/certs/

ENV DISPLAY ":0.0"

EXPOSE 5901

# Define working directory.
WORKDIR /data

CMD /usr/bin/supervisord --nodaemon --configuration /etc/supervisord.conf
