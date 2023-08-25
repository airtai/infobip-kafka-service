# ARG BASE_IMAGE=ubuntu:22.04

ARG BASE_IMAGE=registry.gitlab.com/airt.ai/airt-docker-dask-tf2:dev

FROM $BASE_IMAGE

ARG ACCESS_REP_TOKEN

SHELL ["/bin/bash", "-c"]

# needed to suppress tons of debconf messages
ENV DEBIAN_FRONTEND noninteractive

# make sure we don't upgrade cuda installed by TF because everything likely will break
RUN apt-mark hold cuda-compat-11-2

RUN apt update --fix-missing && apt upgrade --yes \
    && apt install --assume-yes --fix-missing --no-install-recommends \
    wget alien libaio-dev libsnappy-dev graphviz vim figlet fish htop tmux cmake libncurses5-dev \
    libncursesw5-dev git zip nano make less sudo \
    alien libaio-dev build-essential zlib1g-dev ssh-client openssh-client libmysqlclient-dev \
    unattended-upgrades \
    && apt purge --auto-remove --yes && apt clean && rm -rf /var/lib/apt/lists/*


RUN pip install virtualenv

COPY infobip_kafka_service infobip_kafka_service
COPY setup.py settings.ini scheduler_requirements.txt scripts/start_service.sh README.md ./


# Install requirements
RUN pip install -e ".[dev]"

# RUN python3 -m venv venv
RUN virtualenv venv -p python3
RUN venv/bin/pip install --no-cache-dir -e ".[dev]" && venv/bin/pip install --no-cache-dir -r scheduler_requirements.txt

ENTRYPOINT []
CMD [ "/usr/bin/bash", "-c", "./start_service.sh" ]
