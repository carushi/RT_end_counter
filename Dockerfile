FROM genomicpariscentre/bedtools
RUN apt-get update && apt-get -y install samtools=0.1.19-1  && apt-get clean

MAINTAINER carushi trumpet-lambda@hotmail.co.jp
