FROM idalab/hub_worker:lab-1.0.4

USER root
RUN apt-get update && \
    apt-get install \
    -yq \
    --no-install-recommends \
    htop \
    nano \
    vim \
    man \
    tree \
    openssh-server \
    build-essential \
    bash-completion \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER $NB_USER

RUN conda install --yes \
    -c defaults \
    -c pyviz/label/dev \
    -c bokeh/channel/dev \
    -c intake \
    -c conda-forge \
    -c anaconda \
    jupyterlab=1.0.4 \
    # jupyterlab_launcher=0.13.1 \
    jupyterlab_server \
    alembic \
    # pyspark=2.4.0 \
    && conda clean -tipsy

RUN pip install --upgrade pip

# Also install the Kubeflow Pipeline SDK
RUN pip install pipenv \
                jupyterlab_latex \
                nbserverproxy \
                jupyterlab-git \
                https://storage.googleapis.com/ml-pipeline/release/latest/kfp.tar.gz \
                --upgrade --no-cache-dir \
                --upgrade-strategy only-if-needed

RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager \
                                 @jupyterlab/hub-extension \
                                 @pyviz/jupyterlab_pyviz \
                                 jupyter-leaflet \
                                 @jupyterlab/git \
                                 jupyterlab-drawio \
                                 dask-labextension \
                                 @jupyter-widgets/jupyterlab-manager@1.0 \
                                 plotlywidget@1.1.1 \
                                 jupyterlab-plotly@1.1.2 \
                                 jupyterlab-chart-editor@1.2

RUN jupyter serverextension enable --py nbserverproxy \
                                        jupyterlab \
                                        jupyterlab_git \
                                        jupyterlab_sql \
                                        --sys-prefix

USER root
COPY prepare.sh /usr/bin/prepare.sh
RUN chmod +x /usr/bin/prepare.sh
RUN mkdir /pre-home && chown -R $NB_USER /pre-home

ENV DASK_CONFIG=/home/$NB_USER/config.yaml
COPY config.yaml /pre-home
COPY worker-template.yaml /pre-home
COPY .condarc /pre-home
COPY .bashrc /pre-home

RUN mkdir /gcs && chown -R $NB_USER /gcs
RUN mkdir /opt/app

RUN /usr/bin/prepare.sh

# Add NB_USER to sudo
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
RUN sed -ri "s#Defaults\s+secure_path=\"([^\"]+)\"#Defaults secure_path=\"\1:$CONDA_DIR/bin\"#" /etc/sudoers

# Configure container startup
USER $NB_USER
EXPOSE 8888
ENV NB_PREFIX /
CMD ["sh", "-c", "jupyter lab --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=${NB_PREFIX}"]
