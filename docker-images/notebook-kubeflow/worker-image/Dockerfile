FROM jupyter/base-notebook:lab-2.0.1

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
    netcdf4 \
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
    tornado \
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
        'r-caret' \
        'r-crayon' \
        'r-devtools' \
        'r-forecast' \
        'r-hexbin' \
        'r-htmltools' \
        'r-htmlwidgets' \
        'r-irkernel' \
        'r-nycflights13' \
        'r-plyr' \
        'r-randomforest' \
        'r-rcurl' \
        'r-xgboost' \
        'r-glmnet' \
        'r-modelr' \
        'r-reshape2' \
        'r-rmarkdown' \
        'r-rodbc' \
        'r-rsqlite' \
        'r-shiny' \
        'r-sparklyr' \
        'r-tidyverse' \
        'unixodbc' \
        'r-repr' \
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
