FROM idalab/hub_worker:0.0.4

RUN conda install -y -q \
    -c defaults \
    -c pyviz/label/dev \
    -c bokeh/channel/dev \
    -c intake \
    -c conda-forge \
    -c pytorch \

    pytorch \
    beautifulsoup4 \
    spacy \

    && conda clean -tipsy

USER root
RUN apt-get update && \
    apt-get install \
    -yq \
    --no-install-recommends \
    gcc\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
USER $NB_USER

RUN pip install --upgrade pip

RUN pip install flair \
                --upgrade --no-cache-dir \
                --upgrade-strategy only-if-needed

RUN python -m spacy download en_core_web_lg
