# Select proper version to be used from our internal repository
ARG DOCKER_IMAGE

FROM ${DOCKER_IMAGE}

ENV SHELL /bin/bash

USER root

COPY custom-addons /mnt/custom-addons/
COPY external-addons /mnt/external-addons/
COPY external-modified /mnt/external-modified/

RUN apt-get update && apt-get install -y \
    pg-activity \
    pgtop

RUN cd /mnt/ && \
    pip3 install --upgrade pip && \
    find . -type f -iname requirements.txt -exec pip3 install -r  {} \; && \
    pip3 install debugpy

RUN pip3 install --upgrade pip && pip3 install -r /mnt/custom-addons/requirements.txt

USER odoo

CMD ["odoo"]
