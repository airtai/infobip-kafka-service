# ARG BASE_IMAGE=ubuntu:22.04

ARG BASE_IMAGE=nvidia/cuda:11.8.0-runtime-ubuntu20.04

FROM $BASE_IMAGE

ARG ACCESS_REP_TOKEN

SHELL ["/bin/bash", "-c"]

# needed to suppress tons of debconf messages
ENV DEBIAN_FRONTEND noninteractive

RUN apt update --fix-missing && apt upgrade --yes \
    && apt install -y software-properties-common apt-utils build-essential \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt update \
    && apt install -y --no-install-recommends python3.9-dev python3.9-distutils python3-pip python3-apt \
    gettext-base default-libmysqlclient-dev virtualenv unattended-upgrades git wget curl vim \
    && apt purge --auto-remove \
    && apt clean \
    && rm -rf /var/lib/apt/lists/*


# RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1
# RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.10 2
# RUN update-alternatives --set python3 /usr/bin/python3.9
RUN python3 -m pip install --upgrade pip

# # Install airt-lib
# RUN if [ -n "$ACCESS_REP_TOKEN" ] ; \
#     then pip3 install git+https://oauth2:${ACCESS_REP_TOKEN}@gitlab.com/airt.ai/airt.git@${AIRT_LIB_BRANCH} ; \
#     else pip3 install git+https://gitlab-ci-token:${CI_JOB_TOKEN}@gitlab.com/airt.ai/airt.git@${AIRT_LIB_BRANCH} ; \
#     fi

COPY infobip_kafka_service infobip_kafka_service
COPY setup.py settings.ini scheduler_requirements.txt scripts/start_service.sh README.md ./

# RUN python3 setup.py sdist bdist_wheel

# Install requirements
RUN pip install -e ".[dev]"

RUN virtualenv venv -p python3
RUN venv/bin/pip install --no-cache-dir -e ".[dev]" && venv/bin/pip install --no-cache-dir -r scheduler_requirements.txt

ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/cuda/targets/x86_64-linux/lib/

ENTRYPOINT []
CMD [ "/usr/bin/bash", "-c", "./start_service.sh" ]
