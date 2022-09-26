FROM ubuntu:18.04

RUN apt-get update && apt-get install -y \
    wget \
    unzip

RUN cd /usr/local/bin && \
    wget https://s3.amazonaws.com/plink2-assets/alpha3/plink2_linux_x86_64_20220814.zip && \
    unzip plink2_linux_x86_64_20220814.zip
