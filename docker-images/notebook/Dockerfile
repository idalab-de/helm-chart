# jupyter/base-noteobok uploaded 2018-06-13
FROM jupyter/base-notebook:4417b81d04b7

USER root
RUN apt-get update && \
    apt-get install \
    -yq \
    --no-install-recommends \
    libfuse-dev \
    htop \
    nano \
    fuse \
    vim \
    git \
    graphviz \
    man \
    tree \
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
    bokeh=1.0.1 \
    bqplot \
    cython \
    cytoolz \
    dask=0.20.2 \
    dask-ml \
    datashader \
    distributed=1.24.2 \
    esmpy \
    fastparquet \
    gcsfs=0.1.2 \
    ipywidgets \
    ipyleaflet \
    jupyter \
    jupyterlab=0.35.4 \
    jupyterlab_launcher=0.13.1 \
    jupyter_client \
    holoviews \
    libsodium \
    lz4 \
    matplotlib \
    msgpack-python \
    nb_conda_kernels \
    netcdf4>1.4 \
    nomkl \
    numba \
    numcodecs \
    numpy=1.15.1 \
    pandas=0.23.2 \
    python-blosc \
    pyzmq \
    s3fs \
    scipy \
    scikit-image \
    scikit-learn \
    toolz=0.9.0 \
    tornado=5.0.2 \
    xarray=0.10.8 \
    zarr=2.2.0 \
    zict \
    intake-xarray \
    graphviz \
    python-graphviz \
    gsw \
    && conda clean -tipsy

RUN pip install --upgrade pip

RUN pip install fusepy \
                click \
                jedi \
                kubernetes==8.0.0 \
                dask-kubernetes==0.6.0 \
                xesmf \
                nbserverproxy==0.8.1 \
                git+https://github.com/xgcm/xgcm \
                pipenv \
                --upgrade --no-cache-dir \
                --upgrade-strategy only-if-needed


RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager \
                                 @jupyterlab/hub-extension \
                                 @pyviz/jupyterlab_pyviz \
                                 jupyter-leaflet \
                                 @jupyterlab/git \
                                 jupyterlab-drawio

RUN pip install jupyterlab-git


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


# Inject pyspark image

# Spark dependencies
ENV APACHE_SPARK_VERSION 2.4.0
ENV HADOOP_VERSION 2.7

RUN apt-get -y update && \
    apt-get install --no-install-recommends -y openjdk-8-jre-headless ca-certificates-java && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN cd /tmp && \
        wget -q http://mirrors.ukfast.co.uk/sites/ftp.apache.org/spark/spark-${APACHE_SPARK_VERSION}/spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
        echo "5F4184E0FE7E5C8AE67F5E6BC5DEEE881051CC712E9FF8AEDDF3529724C00E402C94BB75561DD9517A372F06C1FCB78DC7AE65DCBD4C156B3BA4D8E267EC2936 *spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz" | sha512sum -c - && \
        tar xzf spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /usr/local --owner root --group root --no-same-owner && \
        rm spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz
RUN cd /usr/local && ln -s spark-${APACHE_SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} spark

# Mesos dependencies
# Install from the Xenial Mesosphere repository since there does not (yet)
# exist a Bionic repository and the dependencies seem to be compatible for now.
COPY mesos.key /tmp/
RUN apt-get -y update && \
    apt-get install --no-install-recommends -y gnupg && \
    apt-key add /tmp/mesos.key && \
    echo "deb http://repos.mesosphere.io/ubuntu xenial main" > /etc/apt/sources.list.d/mesosphere.list && \
    apt-get -y update && \
    apt-get --no-install-recommends -y install mesos=1.2\* && \
    apt-get purge --auto-remove -y gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Spark and Mesos config
ENV SPARK_HOME /usr/local/spark
ENV PYTHONPATH $SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip
ENV MESOS_NATIVE_LIBRARY /usr/local/lib/libmesos.so
ENV SPARK_OPTS --driver-java-options=-Xms1024M --driver-java-options=-Xmx4096M --driver-java-options=-Dlog4j.logLevel=info

USER $NB_USER

# Install pyarrow
RUN conda install --quiet -y 'pyarrow' && \
    conda clean -tipsy && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER




ENTRYPOINT ["tini", "--", "/usr/bin/prepare.sh"]
CMD ["start.sh jupyter lab"]
