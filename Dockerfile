# Docker file for presentation and network/malware forensics
# create a temp folder on your drive anywhere
# copy this file inside it run
# docker build . && YOU DAM profit!!!
# docker run --rm -ti $name

#A small script that can help you with parsing malicious pcaps
#!/bin/bash
# clear
# rm /var/log/suricata/fast.log
# suricata -c /etc/suricata/suricata.yaml -r *.pcap
# clear
# cat /var/log/suricata/fast.log
# bro -C -r *.pcap /usr/share/bro/site/file-extraction/scripts/plugins/extract-all-files.bro
# cd extract_files/
# for i in *.*; do md5sum $i >> hashes.txt; done
# cat hashes.txt

FROM ubuntu:latest
MAINTAINER Ziran "@grotezinfosec"

RUN apt-get update
RUN apt-get install -y software-properties-common
RUN add-apt-repository ppa:wireshark-dev/stable
RUN add-apt-repository ppa:oisf/suricata-stable
RUN apt-get update
RUN apt-get install -y python python-pip
RUN apt-get install -y bro
RUN pip install bro-pkg
RUN apt-get install -y wget git
RUN apt-get install -y libpcre3-dbg libpcre3-dev autoconf automake libtool libpcap-dev libnet1-dev libyaml-dev libjansson4 libcap-ng-dev libmagic-dev libjansson-dev zlib1g-dev
RUN apt-get install -y libnetfilter-queue-dev libnetfilter-queue1 libnfnetlink-dev
RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tshark
RUN wget https://www.openinfosecfoundation.org/download/suricata-3.2.tar.gz
RUN tar -xvzf suricata-3.2.tar.gz
RUN cd suricata-3.2 && ./configure --enable-nfqueue --prefix=/usr --sysconfdir=/etc --localstatedir=/var && make && make install && make install-conf && make install-rules
RUN apt-get install -y oinkmaster
RUN echo "url = http://rules.emergingthreats.net/open/suricata/emerging.rules.tar.gz" >> /etc/oinkmaster.conf
RUN oinkmaster -C /etc/oinkmaster.conf -o /etc/suricata/rules
RUN rm /etc/suricata/suricata.yaml
RUN wget -O /etc/suricata/suricata.yaml https://pastebin.com/raw/g0t5fuKh
RUN cd usr/share/bro/site && git clone git://github.com/hosom/file-extraction file-extraction
RUN echo "@load file-extraction" >> local.bro
RUN git clone https://github.com/omriher/CapTipper.git

ENTRYPOINT oinkmaster -C /etc/oinkmaster.conf -o /etc/suricata/rules && clear && echo "welcome" && /bin/bash
