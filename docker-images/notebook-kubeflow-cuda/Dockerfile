FROM tensorflow/tensorflow:1.13.2-py3-jupyter

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

USER root

COPY prepare.sh /usr/bin/prepare.sh
RUN chmod +x /usr/bin/prepare.sh

# Add NB_USER to sudo
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
RUN sed -ri "s#Defaults\s+secure_path=\"([^\"]+)\"#Defaults secure_path=\"\1:$CONDA_DIR/bin\"#" /etc/sudoers

# Configure container startup
USER $NB_USER
EXPOSE 8888
ENV NB_PREFIX /

ENTRYPOINT ["tini", "--", "/usr/bin/prepare.sh"]


