FROM ubuntu:16.04
MAINTAINER Charlie Lewis <clewis@iqt.org>

RUN apt-get update && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    iptables \
    lxc \
    python-dev \
    python-pip \
    sshpass

# install docker
RUN curl -sSL https://get.docker.com/ | sh

# hacks for vmware driver
RUN curl -L https://github.com/vmware/govmomi/releases/download/v0.7.1/govc_linux_amd64.gz >govc.gz && gzip -d govc.gz && mv govc /usr/local/bin/govc
RUN chmod +x /usr/local/bin/govc

# install docker-machine
RUN curl -L https://github.com/docker/machine/releases/download/v0.7.0/docker-machine-`uname -s`-`uname -m` >/usr/local/bin/docker-machine && \
    chmod +x /usr/local/bin/docker-machine

# TODO add vent iso
RUN curl --insecure -L https://github.com/CyberReboot/vent/releases/download/v0.4.2/vent.iso >boot2docker.iso && mkdir -p /root/.docker/machine/ && mv boot2docker.iso /root/.docker/machine/boot2docker.iso
RUN mkdir -p /root/.docker/machine/cache && ln -s /root/.docker/machine/boot2docker.iso /root/.docker/machine/cache/boot2docker.iso

ADD . /vcontrol
WORKDIR /vcontrol
RUN pip install -r vcontrol/requirements.txt
RUN py.test -v --cov=vcontrol --cov-report term-missing

VOLUME /var/lib/docker
VOLUME /root/.docker
ENV PATH "$PATH":/vcontrol/bin
ENV VENT_CONTROL_DAEMON http://localhost:8080
ENV VENT_CONTROL_API_VERSION /v1

EXPOSE 8080

ENTRYPOINT ["vcontrol"]
CMD ["daemon"]
