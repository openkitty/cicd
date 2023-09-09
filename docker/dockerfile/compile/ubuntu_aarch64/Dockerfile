FROM swr.cn-south-1.myhuaweicloud.com/hellokitty/ubuntu:18.04
MAINTAINER xsmq <1027252281@qq.com>

##############
# User: root #
##############
# Set env
USER root
ENV USER root
ENV PATH /usr/local/bin:${PATH}
ENV JAVA_HOME /usr/lib/jvm/default-java
ENV PATH ${PATH}:${JAVA_HOME}/bin
ARG PYTHON38_PATH=/usr/local/python/python385
ARG CMAKE_PATH=/usr/local/cmake
ENV LD_LIBRARY_PATH ${PYTHON_PATH}/lib:${LD_LIBRARY_PATH}
ENV PATH ${CMAKE_PATH}/bin:${PYTHON_PATH}/bin:${PATH}
ARG VERSION=3.35
ARG user=jenkins
ARG group=jenkins
ARG uid=1000
ARG gid=1000
ARG AGENT_WORKDIR=/home/${user}/agent

# Set bash
RUN echo "dash dash/sh boolean false" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Set apt source
RUN cp -a /etc/apt/sources.list /etc/apt/sources.list.bak \
    && sed -i "s@http://ports.ubuntu.com@http://mirrors.huaweicloud.com@g" /etc/apt/sources.list \
    && apt update

# Install base tools
RUN apt update \
    && DEBIAN_FRONTEND=noninteractive apt install -y vim \
    wget \
    xz-utils \
    net-tools \
    openssh-client \
    git \
    curl \
    subversion \
    ntpdate \
    unzip \
    tzdata \
    tcl \
    sudo \
    bzip2 \
    tar \
    zip \
    default-jre

# Install compile tools
RUN DEBIAN_FRONTEND=noninteractive apt install -y gcc \
    g++ \
    gfortran \
    make \
    libgmp-dev \
    patch \
    autoconf \
    libtool \
    automake \
    flex \
    libnuma-dev

# Install dependency lib of python
RUN DEBIAN_FRONTEND=noninteractive apt install -y libffi-dev \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libncurses5-dev \
    libgdbm-dev \
    liblzma-dev \
    libreadline-dev \
    libsqlite3-dev

# Install dependency lib of postgresql
RUN DEBIAN_FRONTEND=noninteractive apt install -y libicu-dev \
    bison

# Install python-3.8.5
RUN umask 022 \
    && cd /tmp \
    && wget https://www.python.org/ftp/python/3.8.5/Python-3.8.5.tar.xz \
    && tar -xf Python-3.8.5.tar.xz \
    && cd /tmp/Python-3.8.5 \
    && ./configure --prefix=${PYTHON38_PATH} --enable-shared \
    && make -j8 \
    && make install -j8 \
    && cd ${PYTHON38_PATH}/bin \
    && rm -f python \
    && rm -f pip \
    && ln -s python3.8 python \
    && ln -s pip3.8 pip \
    && rm -rf /tmp/Python-3.8.5 \
    && rm -f /tmp/Python-3.8.5.tar.xz

# Set pip source
RUN mkdir /root/.pip \
    && echo "[global]" > /root/.pip/pip.conf \
    && echo "index-url=https://mirrors.aliyun.com/pypi/simple" >> /root/.pip/pip.conf \
    && echo "trusted-host=mirrors.aliyun.com" >> /root/.pip/pip.conf \
    && echo "timeout=120" >> /root/.pip/pip.conf

# Install pip package(build) for python-3.8.5
RUN umask 022 \
    && export LD_LIBRARY_PATH=${PYTHON38_PATH}/lib:${LD_LIBRARY_PATH} \
    && export PATH=${PYTHON38_PATH}/bin:${PATH} \
    && pip3 install 'wheel==0.34.2' \
    && pip3 install 'pybind11==2.5.0' \
    && pip3 list

# Install cmake
RUN cd /tmp \
    && wget https://github.com/Kitware/CMake/releases/download/v3.18.3/cmake-3.18.3.tar.gz \
    && tar -zxf cmake-3.18.3.tar.gz \
    && cd cmake-3.18.3 \
    && ./bootstrap --prefix=${CMAKE_PATH} --parallel=8 \
    && make -j8 \
    && make install -j8 \
    && chmod 755 -R ${CMAKE_PATH} \
    && rm -rf /tmp/cmake-3.18.3 \
    && rm -f /tmp/cmake-3.18.3.tar.gz

# Install ccache
RUN cd /tmp \
    && wget https://github.com/ccache/ccache/releases/download/v3.7.12/ccache-3.7.12.tar.gz \
    && tar -zxf ccache-3.7.12.tar.gz \
    && cd ccache-3.7.12 \
    && ./configure --prefix=/usr/local/ccache \
    && make -j8 \
    && make install -j8 \
    && chmod 755 -R /usr/local/ccache \
    && rm -f /usr/local/bin/gcc \
    && rm -f /usr/local/bin/g++ \
    && rm -f /usr/local/bin/cc \
    && rm -f /usr/local/bin/c++ \
    && ln -s /usr/local/ccache/bin/ccache /usr/local/bin/gcc \
    && ln -s /usr/local/ccache/bin/ccache /usr/local/bin/g++ \
    && ln -s /usr/local/ccache/bin/ccache /usr/local/bin/cc \
    && ln -s /usr/local/ccache/bin/ccache /usr/local/bin/c++ \
    && rm -rf /tmp/ccache-3.7.12 \
    && rm -f /tmp/ccache-3.7.12.tar.gz

# Set timezone
RUN rm -f /etc/localtime \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && echo "export TZ='Asia/Shanghai'" >> /etc/profile

# Install jenkins slave
RUN mkdir -p /usr/share/jenkins/ \
    && wget https://repo.jenkins-ci.org/public/org/jenkins-ci/main/remoting/${VERSION}/remoting-${VERSION}.jar -O /usr/share/jenkins/agent.jar \
    && chmod 755 /usr/share/jenkins \
    && chmod 644 /usr/share/jenkins/agent.jar \
    && ln -sf /usr/share/jenkins/agent.jar /usr/share/jenkins/slave.jar

# Install jnlp
RUN cd /tmp \
    && git clone https://github.com/jenkinsci/docker-inbound-agent.git -b 3.35-5 \
    && cp -a /tmp/docker-inbound-agent/jenkins-agent /usr/local/bin/jenkins-agent \
    && chmod 755 /usr/local/bin/jenkins-agent \
    && ln -s /usr/local/bin/jenkins-agent /usr/local/bin/jenkins-slave \
    && rm -rf /tmp/docker-inbound-agent

# Install tini
ADD https://github.com/krallin/tini/releases/download/v0.19.0/tini-arm64 /tini
RUN chmod +x /tini

# Create user of jenkins
RUN groupadd -g ${gid} ${group} \
    && useradd -c "Jenkins user" -d /home/${user} -u ${uid} -g ${gid} -m ${user} \
    && echo "jenkins ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


#################
# User: jenkins #
#################
# Set env
USER ${user}
ENV AGENT_WORKDIR=${AGENT_WORKDIR}
ENV CCACHE_DIR=${AGENT_WORKDIR}/.ccache
ENV PATH /home/${user}/.local/bin:/home/${user}/bin:$PATH
RUN echo "export TZ='Asia/Shanghai'" >> ~/.bashrc \
    && mkdir -p ${AGENT_WORKDIR}

# Set pip source
RUN mkdir -p /home/${user}/.pip \
    && echo "[global]" > /home/${user}/.pip/pip.conf \
    && echo "index-url=https://mirrors.aliyun.com/pypi/simple" >> /home/${user}/.pip/pip.conf \
    && echo "trusted-host=mirrors.aliyun.com" >> /home/${user}/.pip/pip.conf \
    && echo "timeout=120" >> /home/${user}/.pip/pip.conf

# Set ccache config
RUN export CCACHE_DIR=${CCACHE_DIR} \
    && /usr/local/ccache/bin/ccache -C \
    && /usr/local/ccache/bin/ccache --max-size=25 \
    && /usr/local/ccache/bin/ccache -p

# Clear cache
RUN rm -rf /home/${user}/.cache/pip

VOLUME ${AGENT_WORKDIR}
WORKDIR /home/${user}
#ENTRYPOINT ["/tini", "--", "jenkins-agent"]
