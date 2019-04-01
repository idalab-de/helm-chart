FROM idalab/hub_worker:0.0.4

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
    jupyterlab=0.35.4 \
    # jupyterlab_launcher=0.13.1 \
    jupyterlab_server \
    alembic \
    # pyspark=2.4.0 \

    && conda clean -tipsy

RUN pip install --upgrade pip

RUN pip install pipenv \
                nbserverproxy \
                jupyterlab-git \
                --upgrade --no-cache-dir \
                --upgrade-strategy only-if-needed


RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager \
                                 @jupyterlab/hub-extension \
                                 @pyviz/jupyterlab_pyviz \
                                 jupyter-leaflet \
                                 @jupyterlab/git \
                                 jupyterlab-drawio \
                                 dask-labextension

RUN jupyter serverextension enable --py nbserverproxy \
                                        jupyterlab \
                                        jupyterlab_git \
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

# Add NB_USER to sudo
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
# RUN echo "[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion" > /home/$NB_USER/.bashrc
RUN sed -ri "s#Defaults\s+secure_path=\"([^\"]+)\"#Defaults secure_path=\"\1:$CONDA_DIR/bin\"#" /etc/sudoers

ENTRYPOINT ["tini", "--", "/usr/bin/prepare.sh"]
# CMD ["start.sh jupyter lab"]
