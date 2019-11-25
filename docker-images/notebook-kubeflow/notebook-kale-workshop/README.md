Registry Location: **idalab/hub_user:kubeflow-kale-workshop**

Image Enhancements:

* Installation of Kale under `kubecon-workshop` branch 
https://github.com/kubeflow-kale/kale/tree/kubecon-workshop
* Installation of Kale Jupyterlab extension under `kubecon-workshop` branch 
https://github.com/kubeflow-kale/jupyterlab-kubeflow-kale/tree/kubecon-workshop
* Set jupyter user as default user
* Installation of Kubeflow Pipeline SDK

To build the image run:
```
git clone git@github.com:Felihong/hub-images.git
cd docker-images/notebook-kubeflow/notebook-kale-workshop/
source build_image.sh
```




