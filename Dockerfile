FROM genomicpariscentre/bedtools
RUN apt-get update && apt-get -y install samtools=0.1.19-1  && apt-get clean
RUN curl https://raw.githubusercontent.com/carushi/RT_end_counter/master/analyses/count_and_cov.sh
MAINTAINER carushi trumpet-lambda@hotmail.co.jp
