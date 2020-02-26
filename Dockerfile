FROM nvidia/cuda:10.2-devel-ubuntu18.04

# install depends
RUN apt-get update && \
    apt-get install -y wget p7zip make build-essential git libcurl4-openssl-dev libssl-dev zlib1g-dev python3 python3-psutil pciutils

CMD mkdir /root/hashcat


WORKDIR /root/hashcat


RUN export HASHCAT_VER="$(wget -O- -q https://hashcat.net/beta/ | grep hashcat | cut -f 2 -d '"')" && \
    wget -q -O hashcat.7z "https://hashcat.net/beta/${HASHCAT_VER}" && \
    7zr x hashcat.7z

RUN export PRINCE_URL="$(wget -O- -q https://github.com/hashcat/princeprocessor/releases/latest | grep -i \.7z | grep href | cut -f 2 -d '"')" && \
    wget -O prince.7z -q "https://github.com/${PRINCE_URL}" && \
    7zr x prince.7z

 RUN ln -s /root/hashcat/hashcat-5.1.0/hashcat64.bin /usr/bin/hashcat


