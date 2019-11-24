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
    jupyterlab_server \
    alembic \
    && conda clean -tipsy

RUN pip install --upgrade pip

# Also install the Kubeflow Pipeline SDK
RUN pip install pipenv \
                jupyterlab==1.1.1 \
                jupyterlab_latex \
                nbserverproxy \
                jupyterlab-git \
                https://storage.googleapis.com/ml-pipeline/release/latest/kfp.tar.gz \
                --upgrade --no-cache-dir \
                --upgrade-strategy only-if-needed

RUN pip install git+https://github.com/kubeflow-kale/kale.git@kubecon-workshop               

RUN jupyter labextension install jupyter-leaflet \
                                 @jupyterlab/git \
                                 dask-labextension 
 
RUN git clone https://github.com/kubeflow-kale/jupyterlab-kubeflow-kale.git \
    && cd jupyterlab-kubeflow-kale \
    && jlpm install \
    && jlpm run build \
    && jupyter labextension install .                      

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
