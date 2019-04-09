#!/bin/bash

#This script was written based on bam_to_ctss.sh in moirai packages
source ~/.bashrc
echo ">" $# options: $@
if [ $# -eq 0 ] || [ "$1" == "-h" ] || [ "$1" == "--help" ]
then
echo "Usage is : $0 -s (allow only 1 soft clip or perfect match at 5' end) -k (keep all temporary files) -q <mapping quality cutoff> -l <the minimum length to be filtered out> <map1.bam> <map2.bam> ... i"
exit 1;
fi

QCUT=
KEEP=
SOFT=
LCUT=
while getopts skq:l: opt
do
case ${opt} in
q) QCUT=${OPTARG};;
k) KEEP=true;;
s) SOFT=true;;
l) LCUT=${OPTARG};;
*) usage;;
esac
done


if [ "${QCUT}" = "" ]; then QCUT=0; fi
if [ "${KEEP}" = "" ]; then KEEP=false; fi
if [ "${SOFT}" = "" ]; then SOFT=false; fi
if [ "${LCUT}" = "" ]; then LCUT=300; fi

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
awk_soft_5p=" awk 'BEGIN{OFS=\"\\t\"}{if(\$6 ~ /^1S/ || \$6 ~ /^[0-9]*M/){ print }else if (NF == 3){print}}' "
awk_soft_3p=" awk 'BEGIN{OFS=\"\\t\"}{if(\$6 ~ /1S$/ || \$6 ~ /[0-9]*M$/){ print }else if (NF == 3){print}}' "
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
    samtools view -F 4 -h${option} $var | awk -v lcut="$LCUT" 'BEGIN{OFS="\t"}{if(NF == 3 || (length($10) >= 15 && length($10) < lcut)) { print }}' | samtools view -Shb - > ${TMPBAM}
    samtools sort ${TMPBAM} ${QTMPPRE}
else
    samtools view -q $QCUT -F 4 -h${option} $var | awk -v lcut="$LCUT" 'BEGIN{OFS="\t"}{if(NF == 3 || (length($10) >= 15 && length($10) < lcut)) { print }}' | samtools view -Shb - > ${TMPBAM}
    samtools sort ${TMPBAM} ${QTMPPRE}
fi
for seq in $QTMPPRE
do
samtools view -h -F 16 ${seq}.bam | eval ${awk_soft_5p} | samtools view -Shb - > ${seq}_plus.bam
samtools view -h -f 16 ${seq}.bam | eval ${awk_soft_3p} | samtools view -Shb - > ${seq}_minus.bam

#coverage
samtools view -hb  ${seq}_plus.bam | bedtools genomecov -bga -strand + -ibam stdin | awk -v x="$base" '{printf("%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $3, x, $4, "+")}' | sort -k1,1 -k2,2n > ${seq}_cov.bed
samtools view -hb ${seq}_minus.bam | bedtools genomecov -bga -strand - -ibam stdin | awk -v x="$base" '{printf("%s\t%s\t%s\t%s\t%s\t%s\n", $1, $2, $3, x, $4, "-")}' | sort -k1,1 -k2,2n >> ${seq}_cov.bed

#ctss

samtools view -hb ${seq}_plus.bam | bamToBed -i stdin \
| awk 'BEGIN{OFS="\t"}{if($6=="+"){print $1,$2,$2+1}}' | uniq -c \
| awk -v x="$base" 'BEGIN{OFS="\t"}{print $2,$3,$3+1,x,$1,"+"}' > ${file}/${seq}_ctss.bed

samtools view -h -u ${seq}_minus.bam | bamToBed -i stdin  \
| awk 'BEGIN{OFS="\t"}{if($6=="-" && $3 > 0){print $1,$3-1,$3}}'| uniq -c \
| awk -v x="$base" 'BEGIN{OFS="\t"}{print $2,$3,$4,x,$1,"-"}' >> ${file}/${seq}_ctss.bed


done

if [ "${KEEP}" = false ]
then
rm ${QTMPPRE}.bam
rm ${QTMPPRE}_plus.bam
rm ${QTMPPRE}_minus.bam
rm $TMPBAM
#rm ${QTMPPRE}_plus_bctss.txt
#rm ${QTMPPRE}_minus_bctss.txt
fi

fi
done
