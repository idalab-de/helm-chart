FROM idalab/kube_worker:lab-1.2.5

USER root
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install \
    -yq \
    --no-install-recommends \
    htop \
    nano \
    git-extras \
    zsh \
    zip \
    unzip \
    less \
    vim \
    man \
    tree \
    tzdata \
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
    voila-gridstack \
    alembic \
    seaborn \
    voila \
    black \
    pymysql \
    jupyterlab_code_formatter \
    ptvsd \
    xeus-python notebook \
    && conda clean --all -f -y

RUN pip install --upgrade pip

# Install kfp SDK with known working version 
RUN pip install pipenv \
                nbserverproxy \
                jupyterlab-git \
                kfp==0.1.40 \
                kfp-server-api==0.1.18.3 \ 
                --upgrade --no-cache-dir \
                --upgrade-strategy only-if-needed

RUN pip install kubeflow-kale

RUN jupyter labextension install --debug \
                                 @jupyterlab/git \
                                 @jupyter-voila/jupyterlab-preview \
                                 @lckr/jupyterlab_variableinspector \
                                 @ryantam626/jupyterlab_code_formatter \
                                 plotlywidget@1.5.2 \
                                 jupyterlab-plotly@1.5.2 \
                                 jupyterlab-dash \
                                 @jupyterlab/debugger \
                                 @techrah/text-shortcuts \
                                 @telamonian/theme-darcula \
                                 @karosc/jupyterlab_dracula \
                                 jupyterlab-topbar-extension \
                                 jupyterlab-topbar-text \
                                 jupyterlab-theme-toggle

RUN jupyter labextension install --debug kubeflow-kale-launcher

RUN jupyter serverextension enable --py nbserverproxy \
                                        jupyterlab \
                                        jupyterlab_git \
                                        jupyterlab_sql \
                                        jupyterlab_code_formatter \
                                        --sys-prefix

RUN jupyter serverextension enable \
                            voila \
                            --sys-prefix

USER root

# Install Google Cloud SDK
RUN apt-get update \
    && yes | apt-get install gnupg \
    && echo "deb http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-get update \
    && yes | apt-get install google-cloud-sdk

# Install gcsFUSE
RUN apt-get update \
    && apt-get install  -yq lsb \
    && export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` \
    && echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list \
    && apt-get install gnupg \
    && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
    && apt-get update \
    && apt-get install gcsfuse 

COPY prepare.sh /usr/bin/prepare.sh
RUN chmod +x /usr/bin/prepare.sh
RUN mkdir /gcs && chown -R $NB_USER /gcs
RUN mkdir /opt/app

# Add NB_USER to sudo
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
RUN sed -ri "s#Defaults\s+secure_path=\"([^\"]+)\"#Defaults secure_path=\"\1:$CONDA_DIR/bin\"#" /etc/sudoers

# Configure container startup
USER $NB_USER
EXPOSE 8888
ENV DASK_CONFIG=/home/$NB_USER/config.yaml
ENV NB_PREFIX /

ENTRYPOINT ["tini", "--", "/usr/bin/prepare.sh"]
