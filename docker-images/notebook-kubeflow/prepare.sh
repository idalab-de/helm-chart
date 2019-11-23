#!/bin/bash

set -x

echo "Copy files from pre-load directory into home"
cp -r -v /pre-home /home/$NB_USER

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

# Run extra commands
# export PYSPARK_PYTHON=python3
# export PYSPARK_DRIVER_PYTHON=python3
# export SPARK_PUBLIC_DNS=hub.idalab.de${JUPYTERHUB_SERVICE_PREFIX}proxy/4040/jobs/
# export SPARK_OPTS="--deploy-mode=client \
# --master=k8s://https://kubernetes.default.svc \
# --conf spark.driver.host=`hostname -I` \
# --conf spark.driver.pod.name=${HOSTNAME} \
# --conf spark.kubernetes.container.image=idalab/spark-py:spark \
# --conf spark.ui.proxyBase=${JUPYTERHUB_SERVICE_PREFIX}proxy/4040 \
# --conf spark.executor.instances=2 \
# --driver-java-options=-Xms1024M \
# --driver-java-options=-Xmx4096M \
# --driver-java-options=-Dlog4j.logLevel=info"

$@
