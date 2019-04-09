FROM genomicpariscentre/bedtools
RUN apt-get update && apt-get -y install samtools  && apt-get clean && apt-get autoclean && apt-get autoremove
RUN apt-get install -y curl && curl https://raw.githubusercontent.com/carushi/RT_end_counter/master/analyses/count_and_cov.sh > count_and_cov.sh
ENTRYPOINT [ "bash" ]
CMD ["count_and_cov.sh"]
MAINTAINER carushi trumpet-lambda@hotmail.co.jp
