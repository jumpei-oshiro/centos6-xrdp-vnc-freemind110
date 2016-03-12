#!/bin/bash

# java download
curl --insecure --junk-session-cookies --location --remote-name --silent --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u66-b17/jdk-8u66-linux-x64.rpm

# java8 install
yum localinstall -y jdk-8u66-linux-x64.rpm

# setting alternatives
alternatives --install /usr/bin/java java /usr/java/default/bin/java 18066
alternatives --install /usr/bin/javac javac /usr/java/default/bin/javac 18066

exit 0
