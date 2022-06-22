# AUTHOR:           Brian Ball
# DESCRIPTION:      OpenStudio / Jupyter notebook Docker Container
#
#  docker build . -t='os-jupyter'
#  docker run -it -p 8888:8888 os-jupyter
#
#  JupyterLab application directory is  /usr/local/share/jupyter/lab

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

# PAT dependencies
# libc-ares2 libgconf-2-4 libgtk2.0-0 libnode64 libnss3 libqdbm14 libuv1 libx11-xcb1 libxss1 nodejs nodejs-doc
  
RUN ln -s /usr/bin/python3 /usr/bin/python
  
RUN pip3 install --upgrade pip
RUN pip3 install virtualenv
RUN pip3 install --ignore-installed pyzmq terminado 
RUN pip3 install jupyterlab

RUN gem install bundler cztop iruby rest-client open-uri && \
    iruby register --force

#install PAT
#RUN curl -SLO https://github.com/NREL/OpenStudio-PAT/releases/download/v3.4.0/ParametricAnalysisTool-3.4.0-Linux.deb
#RUN dpkg -i ParametricAnalysisTool-3.4.0-Linux.deb
#/usr/local/ParametricAnalysisTool-3.4.0/pat_3.4.0/opt/Resources/OpenStudio-server/bin/openstudio_meta

#install OpenStudio-server
RUN cd /opt && \
    mkdir OpenStudio-server && \
    cd OpenStudio-server && \
    git clone https://github.com/NREL/OpenStudio-server.git . && \
    cd bin && \
    /opt/OpenStudio-server/bin/openstudio_meta install_gems

WORKDIR /examples
RUN mkdir /examples/notebooks

#copy notebooks over and set permissions
COPY ./notebooks/submit_single_run.ipynb /examples/notebooks/submit_single_run.ipynb
COPY ./notebooks/submit_URBANopt.ipynb /examples/notebooks/submit_URBANopt.ipynb

#trust all notebooks
RUN find /examples/notebooks -name '*.ipynb' -exec jupyter trust {} \;

EXPOSE 8888
CMD ["jupyter-lab", "--ip=0.0.0.0","--port=8888" ,"--no-browser", "--allow-root", "--LabApp.token=''"]