FROM bitnami/spark:3.4

USER root

RUN echo 'spark:x:1001:0:Spark User:/home/spark:/bin/bash' >> /etc/passwd && \
    echo 'spark:x:1001:' >> /etc/group

RUN mkdir -p /home/spark && chown -R spark:spark /home/spark

USER spark