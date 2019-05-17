FROM idalab/base-notebook-cuda:0.0.1

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
    # beautifulsoup4 \
    # spacy \
    # jupyterlab=0.35.4 \
    # jupyterlab_launcher=0.13.1 \
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
    numpy \
    pandas\
    python-blosc \
    pytorch \
    pyzmq \
    s3fs \
    scipy \
    scikit-image \
    scikit-learn \
    toolz\
    # torchvision \
    tornado=5.1.1 \
    xarray\
    zarr\
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
                kubernetes\
                dask-kubernetes \
                xesmf \
                git+https://github.com/xgcm/xgcm \
                --upgrade --no-cache-dir \
                --upgrade-strategy only-if-needed
