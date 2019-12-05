#!/bin/bash

set -x
if [ -z "$DEVMODE" ]; then
    until curl --head localhost:15000 ; do echo "Waiting for Sidecar"; sleep 3 ; done ; sleep 5 ; echo "Sidecar available";
fi
sudo chmod 777 /home/$NB_USER
cd /home/$NB_USER

# Use zsh as standard shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
export SHELL=/usr/bin/zsh
sudo chsh -s $(which zsh) $NB_USER
conda init zsh

echo "Copy config files into user home"

if [ -z "$USER_CONFIG_URL" ]; then
    export USER_CONFIG_URL=https://github.com/idalab-de/user-config
fi

export USER_CONFIG=$(echo $NB_PREFIX | cut -d/ -f3)
rm -rf user-config
git clone $USER_CONFIG_URL user-config

if [ -d user-config/"$USER_CONFIG" ]
then
    cp -r user-config/$USER_CONFIG/. /home/$NB_USER
else
    cp -r user-config/defaults/. /home/$NB_USER
fi

echo "Move configs that do not live in home dir"
mkdir -p /home/$NB_USER/.jupyter && mv /home/$NB_USER/jupyter_notebook_config.py /home/$NB_USER/.jupyter
mkdir -p /opt/conda/share/jupyter/lab/settings && mv /home/$NB_USER/overrides.json /opt/conda/share/jupyter/lab/settings


echo "Copy data science handbook notebooks"
if [ -z "$EXAMPLES_GIT_URL" ]; then
    export EXAMPLES_GIT_URL=https://github.com/idalab-de/PythonDataScienceHandbook
fi
rmdir examples &> /dev/null # deletes directory if empty, in favour of fresh clone
if [ ! -d "examples" ]; then
  mkdir examples
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

# Generating private keys for GCP service account, this is an alternative approach of "gcloud init"
export PROJECT=idalab-kube
export SERVICE_ACCOUNT=kubeflow-user@${PROJECT}.iam.gserviceaccount.com
mkdir .service_account
gcloud iam service-accounts keys create --iam-account ${SERVICE_ACCOUNT} $HOME/.service_account/KEY.json 
gcloud auth activate-service-account ${SERVICE_ACCOUNT} --key-file=key.json 
gcloud config set project ${PROJECT}

# Generating or mounting ssh keys for user
export USER_KEY_BUCKET=user_key_bucket
mkdir .ssh
gsutil rsync -r gs://${USER_KEY_BUCKET}/${USER_CONFIG} .ssh
cd .ssh
if [ ! -f "id_rsa" ]; then
    echo "SSH keys for user ${USER_CONFIG} not found, generating SSH keys"
    ssh-keygen -t rsa -b 4096 -N '' -f $HOME/.ssh/id_rsa 
    eval "$(ssh-agent -s)" 
    ssh-add $HOME/.ssh/id_rsa 
    cd ..
    gsutil rsync -r .ssh gs://user_key_bucket/${USER_CONFIG}
fi
cd ..
chmod 400 $HOME/.ssh/id_rsa

jupyter lab --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=$NB_PREFIX

$@
