FROM ubuntu:18.04

LABEL com.nvidia.volumes.needed="nvidia_driver"

RUN apt-get update && apt-get install -y --no-install-recommends \
        ocl-icd-libopencl1 \
        clinfo && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/OpenCL/vendors && \
    echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd

RUN echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf

ENV PATH /usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/local/nvidia/lib:/usr/local/nvidia/lib64:${LD_LIBRARY_PATH}

# nvidia-container-runtime
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
# install depends
RUN apt-get update && \
    apt-get install -y wget p7zip make build-essential git libcurl4-openssl-dev libssl-dev zlib1g-dev python3 python3-psutil pciutils


ENV HASHCAT_UTILS_VERSION  1.9
ENV HCXTOOLS_VERSION       5.3.0
ENV HCXDUMPTOOL_VERSION    6.0.1

CMD mkdir /root/


WORKDIR /root/


RUN export HASHCAT_VER="$(wget -O- -q https://hashcat.net/beta/ | grep hashcat | cut -f 2 -d '"')" && \
    wget -q -O hashcat.7z "https://hashcat.net/beta/${HASHCAT_VER}" && \
    7zr x hashcat.7z && \
    rm hashcat.7z

WORKDIR /root/

RUN export PRINCE_URL="$(wget -O- -q https://github.com/hashcat/princeprocessor/releases/latest | grep -i \.7z | grep href | cut -f 2 -d '"')" && \
    wget -O prince.7z -q "https://github.com/${PRINCE_URL}" && \
    7zr x prince.7z && \
    rm prince.7z

WORKDIR /root/

RUN wget --no-check-certificate https://github.com/hashcat/hashcat-utils/releases/download/v${HASHCAT_UTILS_VERSION}/hashcat-utils-${HASHCAT_UTILS_VERSION}.7z && \
    7zr x hashcat-utils-${HASHCAT_UTILS_VERSION}.7z && \
    rm hashcat-utils-${HASHCAT_UTILS_VERSION}.7z

WORKDIR /root/
RUN wget --no-check-certificate https://github.com/ZerBea/hcxtools/archive/${HCXTOOLS_VERSION}.tar.gz && \
    tar xfz ${HCXTOOLS_VERSION}.tar.gz && \
    rm ${HCXTOOLS_VERSION}.tar.gz
WORKDIR hcxtools-${HCXTOOLS_VERSION}
RUN make install

WORKDIR /root/
RUN wget --no-check-certificate https://github.com/ZerBea/hcxdumptool/archive/${HCXDUMPTOOL_VERSION}.tar.gz && \
    tar xfz ${HCXDUMPTOOL_VERSION}.tar.gz && \
    rm ${HCXDUMPTOOL_VERSION}.tar.gz
WORKDIR hcxdumptool-${HCXDUMPTOOL_VERSION}
RUN make install

WORKDIR /root/
# commit 49059f3 on Jun 19, 2018
RUN git clone https://github.com/hashcat/kwprocessor.git
WORKDIR kwprocessor
RUN make
WORKDIR /root/

 RUN ln -s /root/hashcat-5.1.0/hashcat.bin /usr/bin/hashcat

 WORKDIR /root/


