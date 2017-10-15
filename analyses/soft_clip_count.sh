#!/bin/bash

#This script was written based on bam_to_ctss.sh in moirai packages
if [ $# -eq 0 ]
then
echo "Usage is : $0 -s (allow only 1 soft clip or perfect match at 5' end) -k (keep all temporary files) -q <mapping quality cutoff> <map1.bam> <map2.bam> ... i"
iexit 1;
fi

QCUT=
LCUT=
KEEP=
SOFT=
while getopts skq: opt
do
case ${opt} in
q) QCUT=${OPTARG};;
k) KEEP=true;;
l) LCUT=${OPTARG};;
*) usage;;
esac
done


if [ "${QCUT}" = "" ]; then QCUT=0; fi
if [ "${KEEP}" = "" ]; then KEEP=false; fi
if [ "${LCUT}" = "" ]; then LCUT=300; fi
SOFT=true;

for var in "$@"
do
if [[ $var =~ sam$ || $var =~ bam$ ]]; then
file=${var##*/}
base=${file%%.*}
option="S"
if [[ $var =~ bam$ ]]
then
option=""
fi

if [ "${SOFT}" = true ]
then
TMPPRE="${base}_l15filt_s1"
QTMPPRE="${base}_l15q${QCUT}filt_s1"
awk_soft_5p=" gawk 'BEGIN{OFS=\"\\t\"}{if (NF == 3) {;} else if (\$6 ~ /^[0-9]*M/){ print 0 } else if (\$6 ~ /^[0-9]*S/){print gensub(/^([0-9]*)S.*\$/, \"\\\\1\", \"1\", \$6)} else {print \"Error\", \$6}}'"
awk_soft_3p=" gawk 'BEGIN{OFS=\"\\t\"}{if (NF == 3) {;} else if (\$6 ~ /[0-9]*M\$/){ print 0 } else if (\$6 ~ /[0-9]*S\$/){match(\$6, /[0-9]+S\$/); print substr(\$6, RSTART, RLENGTH-1)} else {print \"Error\", \$6}}' "
# echo $awk_soft_5p
# echo $awk_soft_3p
TMPBAM="${base}_tmp_l15_s1"
else
TMPPRE="${base}_l15filt"
QTMPPRE="${base}_l15q${QCUT}filt"
awk_soft_5p=" cat - "
awk_soft_3p=" cat - "
TMPBAM="${base}_tmp_l15"
fi

if [ "${QCUT}" = "0" ]
then
    samtools view -F 4 -h${option} $var |  awk 'BEGIN{OFS="\t"}{if(NF == 3 || (length($10) >= 15 && length($10) < $LCUT)) { print }}' | samtools view -Shb - > ${QTMPPRE}.bam
else
    samtools view -q $QCUT -F 4 -h${option} $var | awk 'BEGIN{OFS="\t"}{if(NF == 3 || (length($10) >= 15 && length($10) < $LCUT)) { print }}' | samtools view -Shb - > ${QTMPPRE}.bam
fi

for seq in $QTMPPRE
do
samtools view -h -F 16 ${seq}.bam | eval ${awk_soft_5p} > ${seq}.tmp
samtools view -h -f 16 ${seq}.bam | eval ${awk_soft_3p} >> ${seq}.tmp
sort -n ${seq}.tmp | uniq -c | sed 's/^ *//g' > ${seq}_soft_count.txt


done

if [ "${KEEP}" = false ]
then
rm ${QTMPPRE}.bam
rm ${QTMPPRE}.tmp
fi

fi
done
