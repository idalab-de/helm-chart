#!/bin/sh

set -x

echo "Copy config files into home"
if [ -z "$USER_CONFIG_URL" ]; then
    export USER_CONFIG_URL=https://github.com/idalab-de/user-config
fi

git clone $USER_CONFIG_URL user-config
cd user-config
cp .condarc /home/$NB_USER
cp .zshrc /home/$NB_USER
cp jupyter_notebook_config.py /home/$NB_USER/.jupyter
cp overrides.json /opt/conda/share/jupyter/lab/settings
cp config.yaml /home/$NB_USER
cp worker-template.yaml /home/$NB_USER
cd ..
export SHELL=/usr/bin/zsh
conda init zsh
conda config --set auto_activate_base false

echo "Copy example notebooks"
if [ -z "$EXAMPLES_GIT_URL" ]; then
    export EXAMPLES_GIT_URL=https://github.com/idalab-de/pangeo-example-notebooks
fi
rmdir examples &> /dev/null # deletes directory if empty, in favour of fresh clone
if [ ! -d "examples" ]; then
  git clone $EXAMPLES_GIT_URL examples
fi

cd examples
git remote set-url origin $EXAMPLES_GIT_URL
git fetch origin
git reset --hard origin/master
git merge --strategy-option=theirs origin/master
if [ ! -f DONT_SAVE_ANYTHING_HERE.md ]; then
  echo "Files in this directory should be treated as read-only"  > DONT_SAVE_ANYTHING_HERE.md
fi

cd ..
mkdir -p work

if [ -e "/opt/app/environment.yml" ]; then
    echo "environment.yml found. Installing packages"
    /opt/conda/bin/conda env update -f /opt/app/environment.yml
else
    echo "no environment.yml"
fi

if [ "$EXTRA_CONDA_PACKAGES" ]; then
    echo "EXTRA_CONDA_PACKAGES environment variable found.  Installing."
    /opt/conda/bin/conda install $EXTRA_CONDA_PACKAGES
fi

if [ "$EXTRA_PIP_PACKAGES" ]; then
    echo "EXTRA_PIP_PACKAGES environment variable found.  Installing".
    /opt/conda/bin/pip install $EXTRA_PIP_PACKAGES
fi

if [ "$GCSFUSE_BUCKET" ]; then
    echo "Mounting $GCSFUSE_BUCKET to /gcs"
    /opt/conda/bin/gcsfuse $GCSFUSE_BUCKET /gcs --background
fi

start.sh jupyter lab --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=$NB_PREFIX

$@
