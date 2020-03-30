#!/bin/bash

set -x
if [ -z "$DEVMODE" ]; then
    until curl --head localhost:15000 ; do echo "Waiting for Sidecar"; sleep 5 ; done ; sleep 5 ; echo "Sidecar available";
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

# Copy r shortcuts setting to enable jupyterlab extension 
if [ ! -d .jupyter/lab/user-settings ]; then
    mkdir -p .jupyter/lab/user-settings/@jupyterlab/shortcuts-extension
    cp user-config/R-user/shortcuts.jupyterlab-settings .jupyter/lab/user-settings/@jupyterlab/shortcuts-extension/.
fi

# Re-configure Olson timezone database  
echo "Europe/Berlin" | sudo tee /etc/timezone
sudo rm -f /etc/localtime
sudo dpkg-reconfigure -f noninteractive tzdata

# Set git committer name & email globally
export USER_NAME=$(echo ${USER_CONFIG} | tr "-" " ")
export USER_EMAIL=$(echo ${USER_NAME}@idalab.de | tr " " ".")
git config --global user.email ${USER_EMAIL}
git config --global user.name ${USER_NAME}

# Increase npm timeout setting 
npm install -g yarn@1.15.2 
yarn install --cwd /opt/conda/share/jupyter/lab/staging --network-timeout 1000000

echo "Move configs that do not live in home dir"
mkdir -p /home/$NB_USER/.jupyter && mv /home/$NB_USER/jupyter_notebook_config.py /home/$NB_USER/.jupyter
mkdir -p /opt/conda/share/jupyter/lab/settings && mv /home/$NB_USER/overrides.json /opt/conda/share/jupyter/lab/settings

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
if [ -z "$DEVMODE" ]; then
    export PROJECT=idalab-kube
    export SERVICE_ACCOUNT=kubeflow-user@${PROJECT}.iam.gserviceaccount.com
    mkdir .service_account
    gcloud iam service-accounts keys create --iam-account ${SERVICE_ACCOUNT} $HOME/.service_account/KEY.json
    gcloud auth activate-service-account ${SERVICE_ACCOUNT} --key-file=key.json
    gcloud config set project ${PROJECT}

    # Mounting practical skills and project template repositories
    export PRACTICALSKILLS_GIT_URL=bitbucket_idalab_idalab-practicalskills
    export NOTEBOOK_GIT_URL=https://github.com/idalab-de/PythonDataScienceHandbook.git
    export TEMPLATE_GIT_URL=bitbucket_idalab_idalab-project-template
    if [ ! -d "practical-skills" ]; then
        gcloud source repos clone ${PRACTICALSKILLS_GIT_URL} practical-skills --project=${PROJECT}
        cd practical-skills/notebooks
        rm -rf PythonDataScienceHandbook
        git clone ${NOTEBOOK_GIT_URL}
        cd ~
    fi

    if [ ! -d "project-template" ]; then
        gcloud source repos clone ${TEMPLATE_GIT_URL} project-template --project=${PROJECT}
    fi

    # Generate key folder automatically for new user
    export USER_KEY_BUCKET=user_key_bucket
    gsutil -q stat gs://${USER_KEY_BUCKET}/${USER_CONFIG} &> /dev/null
    if [ $? -eq 1 ]; then
        echo "User key folder not found, create one with user name"
        mkdir ${USER_CONFIG}
        touch ${USER_CONFIG}/init # It won't work if the local directory is empty
        gsutil cp -r ${USER_CONFIG} gs://${USER_KEY_BUCKET}
        rm -r ${USER_CONFIG}
        gsutil rm gs://${USER_KEY_BUCKET}/${USER_CONFIG}/init
    fi

    # Mount or create SSH key pairs
    mkdir .ssh
    gsutil rsync -r gs://${USER_KEY_BUCKET}/${USER_CONFIG} .ssh
    if [ ! -f ".ssh/id_rsa" ]; then
        echo "SSH keys for user ${USER_CONFIG} not found, generating SSH keys"
        ssh-keygen -t rsa -b 4096 -N '' -f .ssh/id_rsa
        eval "$(ssh-agent -s)"
        ssh-add .ssh/id_rsa
        gsutil rsync -r .ssh gs://${USER_KEY_BUCKET}/${USER_CONFIG}
    fi
    sudo chmod 400 .ssh/id_rsa

fi
jupyter lab --notebook-dir=/home/jovyan --ip=0.0.0.0 --no-browser --allow-root --port=8888 --NotebookApp.token='' --NotebookApp.password='' --NotebookApp.allow_origin='*' --NotebookApp.base_url=$NB_PREFIX --VoilaConfiguration.template=gridstack --VoilaConfiguration.resources='{"gridstack": {"show_handles": True}}'

$@
