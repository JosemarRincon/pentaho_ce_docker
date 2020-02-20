FROM openjdk:8u242-slim
LABEL maintainer="josemar.rincon@goias.gov.br"

# Never prompt the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Init ENV
ENV BISERVER_VERSION 8.0
ENV BISERVER_TAG 8.0.0.0-28

# Apply JAVA_HOME
ENV PENTAHO_HOME /opt/pentaho
ENV SOLUTION_HOME ${PENTAHO_HOME}/pentaho-server/pentaho-solutions
RUN . /etc/environment
ENV PENTAHO_JAVA_HOME $JAVA_HOME
ENV PATH $PENTAHO_HOME/pentaho-server:$PATH

ENV TIMEZONE "America/Sao_Paulo"
ENV LOCALE "en_US.UTF-8 UTF-8"
# Define en_US.
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

# Install Dependences
RUN set -ex \
        && apt-get update -yqq \
        && apt-get upgrade -yqq \
        && apt-get install -yqq --no-install-recommends \
        apt-utils \
        python3 \
        openssh-client \
        curl \
        vim  \
        rsync \
        git \
        netcat \
        postgresql-client \
        locales \
        wget \
        zip \
        unzip \
        && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
        && locale-gen \
        && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 


RUN echo $TIMEZONE > /etc/timezone && \
        echo $LOCALE >> /etc/locale.gen && \
        locale-gen && \
        dpkg-reconfigure locales && \
        dpkg-reconfigure -f noninteractive tzdata

RUN mkdir ${PENTAHO_HOME}; useradd -s /bin/bash -d ${PENTAHO_HOME} pentaho;

COPY ./entrypoint.sh /
COPY config ${PENTAHO_HOME}/config
COPY scripts ${PENTAHO_HOME}/scripts
COPY pentaho-server-ce-${BISERVER_TAG}.zip /tmp
#COPY custom.zip /tmp

# Download Pentaho BI Server
RUN  unzip -q  /tmp/pentaho-server-ce-${BISERVER_TAG}.zip -d  ${PENTAHO_HOME} \
        && chmod +x ${PENTAHO_HOME}/pentaho-server/tomcat/bin/*.sh \
        && echo ${PENTAHO_HOME} \
        && chown -R pentaho:pentaho ${PENTAHO_HOME} \
        && rm -rf /tmp/pentaho-server-ce-${BISERVER_TAG}.zip \ 
        && chmod +x ${PENTAHO_HOME}/pentaho-server/*.sh 

RUN  wget -q --show-progress --progress="bar:force:noscroll" https://github.com/JosemarRincon/pentaho-fastsync-plugin/releases/download/v0.3.0/fastsync-0.3.0.zip \
        -O /tmp/fastsync-0.3.0.zip && unzip -q /tmp/fastsync-0.3.0.zip -d ${SOLUTION_HOME}/system \
        && rm -rf ${PENTAHO_HOME}/pentaho-server/tomcat/lib/mysql-connector-java-5.1.17.jar 

RUN  apt-get purge --auto-remove -yqq \
        && apt-get autoremove -yqq --purge \
        && apt-get clean \
        && rm -f $PENTAHO_HOME/pentaho-server/promptuser.sh \
        && rm -rf \
                /var/lib/apt/lists/* \
                /tmp/* \
                /var/tmp/* \
                /usr/share/man \
                /usr/share/doc \
                /usr/share/doc-base 



USER pentaho


EXPOSE 8080 8009
WORKDIR ${PENTAHO_HOME} 

ENTRYPOINT ["/entrypoint.sh"]
CMD ["run"]
