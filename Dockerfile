#!/bin/sh

[ -r /etc/sysconfig/i18n ] && . /etc/sysconfig/i18n
export LANG
export SYSFONT
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus
vncconfig -iconic &
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
OS=`uname -s`
if [ $OS = 'Linux' ]; then
  case "$WINDOWMANAGER" in
    *gnome*)
      if [ -e /etc/SuSE-release ]; then
        PATH=$PATH:/opt/gnome/bin
        export PATH 
      fi
      ;;
  esac
fi
if [ -x /etc/X11/xinit/xinitrc ]; then
  exec /etc/X11/xinit/xinitrc &
fi
if [ -f /etc/X11/xinit/xinitrc ]; then
  exec sh /etc/X11/xinit/xinitrci & 
fi
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
xterm -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
twm & ibus-daemon -drx &
[vagrant@localhost centos6-xrdp-vnc-freemind110]$ cat Dockerfile 
FROM kevensen/centos-vnc
MAINTAINER hidetarou2013 <hidetoshi_maekawa@e-it.co.jp>

#----------------------------
# japanese
#----------------------------
USER root
RUN yum reinstall -y glibc-common
ENV LANG ja_JP.utf8

#----------------------------
# java8
#----------------------------
#USER root
ADD install_java8.sh /tmp/install_java8.sh
RUN /bin/bash /tmp/install_java8.sh
ENV JAVA_HOME /usr/java/latest
ENV JRE_HOME /usr/java/latest

#----------------------------
# freemind
#----------------------------
#USER root
RUN yum install -y unzip wget curl sudo
#RUN wget https://osdn.jp/projects/sfnet_freemind/downloads/freemind-unstable/1.1.0_Beta2/freemind-bin-max-1.1.0_Beta_2.zip
ADD freemind-bin-max-1.1.0_Beta_2.zip /tmp/freemind/
WORKDIR /tmp/freemind
RUN unzip freemind-bin-max-1.1.0_Beta_2.zip
#RUN ls -l /tmp/freemind
RUN mv /tmp/freemind /usr/local/
RUN ls -l /usr/local/freemind
RUN rm -f /usr/local/freemind/freemind-bin-max-1.1.0_Beta_2.zip
RUN chmod 755 /usr/local/freemind/freemind.sh

#----------------------------
# tag:1920x1024
#----------------------------
WORKDIR /usr/bin
RUN sed -i -e 's/1024x768/1920x1024/g' vncserver

#----------------------------
# ipa font
#----------------------------
RUN yum update -y && yum install -y ipa-mincho-fonts \
    ipa-gothic-fonts \
    ipa-pmincho-fonts \
    ipa-pgothic-font \
    gnome-session && yum clean all; rm -rf /var/cache/yum

RUN yum -y groupinstall "X Window System"
RUN yum -y groupinstall "GNOME Desktop Environment"
RUN yum groupinstall -y 'Desktop'
RUN yum groupinstall -y fonts
RUN yum groupinstall -y "Japanese Support"
RUN sed -i -e 's/LANG=\"en_US.UTF-8\"/#LANG=\"en_US.UTF-8\"/g' /etc/sysconfig/i18n
RUN echo "LANG=\"ja_JP.UTF-8\"" >> /etc/sysconfig/i18n
RUN echo "SYSFONT=\"latarcyrheb-sun16\"" >> /etc/sysconfig/i18n

#----------------------------
# keyboard
#----------------------------
RUN sed -i -e 's/KEYTABLE=\"us\"/KEYTABLE=\"jp106\"/g' /etc/sysconfig/keyboard 
RUN sed -i -e 's/MODEL=\"pc105+inet\"/MODEL=\"jp106\"/g' /etc/sysconfig/keyboard 
RUN sed -i -e 's/LAYOUT=\"us\"/LAYOUT=\"jp\"/g' /etc/sysconfig/keyboard
RUN echo kioskuser | passwd --stdin kioskuser
#----------------------------
# test
#----------------------------
#WORKDIR /etc/sysconfig/
#RUN sed -i -e 's/\# VNCSERVERS=\"2:myusername\"/VNCSERVERARGS\[2\]=\"-nolisten tcp -localhost\"/g' > vncservers

USER kioskuser
ENV LANG ja_JP.utf8
RUN export LANG=ja_JP.UTF-8

WORKDIR /home/kioskuser/.vnc/
ADD xstartup /home/kioskuser/.vnc/
USER root
WORKDIR /home/kioskuser/.vnc/
RUN chmod 775 xstartup
RUN chown kioskuser:kioskuser xstartup
RUN /bin/echo "exec sh /usr/local/freemind/freemind.sh" >> /home/kioskuser/.vnc/xstartup
USER kioskuser

#EXPOSE 5901
#ENTRYPOINT ["/usr/bin/vncserver","-fg"]
