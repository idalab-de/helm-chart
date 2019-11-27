FROM jupyter/base-notebook:lab-1.0.4

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
