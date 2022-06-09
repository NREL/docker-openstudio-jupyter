# AUTHOR:           Brian Ball
# DESCRIPTION:      OpenStudio / Jupyter notebook Docker Container
#
#  docker build . -t='os-jupyter'
#  docker run -p 8888:8888 os-jupyter

#may include suffix
ARG OPENSTUDIO_VERSION=3.4.0
FROM nrel/openstudio:dev-3.4.1-alpha as base
MAINTAINER Brian Ball brian.ball@nrel.gov

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  ca-certificates \
  emacs \
  git \
  locales \
  locales-all \
  python3-dev \
  python3-pip \
  jupyter \
  sudo

RUN ln -s /usr/bin/python3 /usr/bin/python
  
RUN pip3 install --upgrade pip
RUN pip3 install virtualenv
RUN pip3 install --ignore-installed pyzmq terminado 
RUN pip3 install jupyterlab

WORKDIR /workspace
VOLUME /workspace
EXPOSE 8888

CMD ["jupyter-lab", "--ip=0.0.0.0","--port=8888" ,"--no-browser", "--allow-root", "--LabApp.token=''"]