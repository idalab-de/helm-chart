FROM jupyter/base-notebook:latest
RUN pip install voila \
            matplotlib \
            numpy \
EXPOSE 8866
CMD voila dashboard.ipynb
