FROM jupyter/datascience-notebook

USER root
#link gtar to tar for devtools::install_github to work
RUN ln -s /bin/tar /bin/gtar

#setup directory structure
RUN mkdir /home/$NB_USER/data && chown $NB_USER:users /home/$NB_USER/data && chmod 775 /home/$NB_USER/data
RUN mkdir /home/$NB_USER/notebooks && chown $NB_USER:users /home/$NB_USER/notebooks && chmod 775 /home/$NB_USER/notebooks

#copy notebooks over and set permissions to joyvan
COPY ./notebooks/parallelCoords.ipynb /home/$NB_USER/notebooks/parallelCoords.ipynb
RUN chown $NB_USER:users /home/$NB_USER/notebooks/parallelCoords.ipynb

ARG GITHUB_PAT     
USER $NB_UID     
RUN conda install --quiet --yes \
    'r-rstan' \
    'r-fields' \
    'r-plotly' \
    'r-devtools' \
    && R -e "devtools::install_github('timelyportfolio/parcoords', auth_token = $GITHUB_PAT)"

#trust all notebooks
RUN find /home/$NB_USER/notebooks -name '*.ipynb' -exec jupyter trust {} \;

#start with no creditials, TODO: make secure for production
CMD ["jupyter", \
     "notebook", \
     "--port=8888", \
     "--no-browser", \
     "--ip=0.0.0.0", \
     "--allow-root", \
     "--NotebookApp.token=''", \
     "--NotebookApp.password=''", \
     "--NotebookApp.iopub_data_rate_limit=1.0e10"]