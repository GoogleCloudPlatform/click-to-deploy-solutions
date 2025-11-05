FROM maven:3-openjdk-11-slim
# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

ARG projectId=0
ARG comitid=Local
ARG apikey=0
ARG v3key=0
ARG v2key=0
ARG test2key=0
ARG test8key=0
ARG expresskey=0
ARG dev=false

# Install Tomcat
RUN groupadd tomcat
RUN useradd -s /bin/false -g tomcat -d /opt/tomcat tomcat
WORKDIR /tmp
RUN apt update 
RUN apt install curl wget jq git -y
# Apache Tomcat doesn't offer a "-latest" shortcut,
# figure out the latest Tomcat 9.0 and download it.
RUN curl -s "https://dlcdn.apache.org/tomcat/tomcat-9/?C=M;O=D" 2>&1 \
| grep "\[DIR\]" | head -1 | cut -d'"' -f6 | sed 's/v//g' | sed 's/\///g' \
| awk '{print "https://dlcdn.apache.org/tomcat/tomcat-9/v"$0"/bin/apache-tomcat-"$0".tar.gz"}' \
| xargs curl -O
RUN mkdir /opt/tomcat
RUN tar xzvf apache-tomcat-9*tar.gz -C /opt/tomcat --strip-components=1
WORKDIR /opt/tomcat
RUN chgrp -R tomcat /opt/tomcat
RUN chown -R tomcat webapps/ work/ temp/ logs/
RUN rm -rf /opt/tomcat/webapps/ROOT

WORKDIR /
RUN git clone https://github.com/GoogleCloudPlatform/click-to-deploy-solutions
WORKDIR /click-to-deploy-solutions/recaptcha-demo
RUN mvn package
RUN mv target/demo-container.war /opt/tomcat/webapps/ROOT.war

RUN echo "#!/usr/bin/env bash" > /newcatalina.sh
RUN echo ${projectId} | awk '{print "export PROJECTID="$0}'>> /newcatalina.sh
RUN echo ${comitid} | awk '{print "export COMMITID="$0}'>> /newcatalina.sh
RUN echo ${apikey} | awk '{print "export APIKEY="$0}'>> /newcatalina.sh
RUN echo ${v3key} | awk '{print "export V3KEY="$0}'>> /newcatalina.sh
RUN echo ${v2key} | awk '{print "export V2KEY="$0}'>> /newcatalina.sh
RUN echo ${test2key} | awk '{print "export TEST2KEY="$0}'>> /newcatalina.sh
RUN echo ${test8key} | awk '{print "export TEST8KEY="$0}'>> /newcatalina.sh
RUN echo ${expresskey} | awk '{print "export EXPRESSKEY="$0}'>> /newcatalina.sh
RUN export MYDATE=$(date +"%d-%b-%Y_%H:%M:%S") && echo export LASTBUILD="\"$MYDATE\"" >> /newcatalina.sh
RUN echo "" >> /newcatalina.sh

RUN sed 's/#!\/usr\/bin\/env bash//g' /opt/tomcat/bin/catalina.sh >> /newcatalina.sh && cp /newcatalina.sh /opt/tomcat/bin/catalina.sh && chmod +x /opt/tomcat/bin/catalina.sh

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]