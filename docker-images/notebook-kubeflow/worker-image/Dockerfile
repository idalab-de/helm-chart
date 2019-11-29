FROM jupyter/base-notebook:lab-1.1.3

USER root
RUN apt-get update && \
    apt-get install \
    -yq \
    --no-install-recommends \
    libfuse-dev \
    fuse \
    git \
    graphviz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

USER $NB_USER

# Install python packages
RUN conda install --yes \
    -c defaults \
    -c pyviz/label/dev \
    -c bokeh/channel/dev \
    -c intake \
    -c conda-forge \
    xgboost \
    bokeh \
    bqplot \
    cython \
    cytoolz \
    dask \
    dask-ml \
    datashader \
    distributed\
    esmpy \
    fastparquet \
    gcsfs \
    ipywidgets \
    ipyleaflet \
    jupyter \
    jupyter_client \
    holoviews \
    libsodium \
    lz4 \
    matplotlib \
    plotly \
    msgpack-python \
    nb_conda_kernels \
    netcdf4>1.4 \
    nomkl \
    notebook \
    numba \
    numcodecs \
    numpy \
    pandas\
    python-blosc \
    pyzmq \
    s3fs \
    scipy \
    scikit-image \
    scikit-learn \
    toolz\
    tornado=5.1.1 \
    xarray\
    zarr\
    zict \
    intake-xarray \
    graphviz \
    python-graphviz \
    gsw \
    psycopg2 \
    && conda clean --all -f -y

# R packages
RUN conda install --quiet --yes \
        'r-base=3.6.1' \
        'r-caret=6.0*' \
        'r-crayon=1.3*' \
        'r-devtools=2.0*' \
        'r-forecast=8.7*' \
        'r-hexbin=1.27*' \
        'r-htmltools=0.3*' \
        'r-htmlwidgets=1.3*' \
        'r-irkernel=1.0*' \
        'r-nycflights13=1.0*' \
        'r-plyr=1.8*' \
        'r-randomforest=4.6*' \
        'r-rcurl=1.95*' \
        'r-reshape2=1.4*' \
        'r-rmarkdown=1.14*' \
        'r-rodbc=1.3*' \
        'r-rsqlite=2.1*' \
        'r-shiny=1.3*' \
        'r-sparklyr=1.0*' \
        'r-tidyverse=1.2*' \
        'unixodbc=2.3.*' \
        'repr=1.*' \
        && \
        conda clean --all -f -y && \
        fix-permissions $CONDA_DIR



RUN pip install --upgrade pip

RUN pip install fusepy \
                click \
                jedi \
                kubernetes\
                dask-kubernetes \
                xesmf \
                dask_labextension \
                jupyterlab_sql \
                git+https://github.com/xgcm/xgcm \
                --upgrade --no-cache-dir \
                --upgrade-strategy only-if-needed
