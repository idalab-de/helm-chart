FROM jupyter/pyspark-notebook:5b2160dfd919
RUN pip install nbserverproxy
RUN jupyter serverextension enable --py nbserverproxy
USER root
RUN echo "$NB_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/notebook
USER $NB_USER
