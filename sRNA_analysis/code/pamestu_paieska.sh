#/usr/bin/sh
# this code takes a BED file as an input and looks for identical/similar sequences in the genome. 


# Variables: 
# Input bed file 
BED=$1 #aca input.bed
REF=$2
REZ=$3

cd tmp 
cat ${BED}  >  input.fasta 

blastn -dust no -soft_masking false -db ${REF} -query input.fasta -outfmt "6 qseqid pident length qlen mismatch qstart qend sstart send gaps sstrand" -evalue 1 |\
  awk '{if ($11 == "minus") {$12="NC_009004.1:"$9"-"$8"(-)"} else {$12="NC_009004.1:"$8-1"-"$9"(+)"}; print $0}' |\
  awk '{if($2 == 100.000) {print $0}}' |\
  awk '{if($6 == 1) {print $0}}' |\
  awk '{if($7 == $4) {print $0}}' |\
  awk '{if($7 == $3) {print $0}}' |\
  awk '{if($5 == 0) {print $0}}' |\
  awk '{if($10 == 0) {print($1, $12)}}' |\
  awk '
  {
    k=$2
    for (i=3;i<=NF;i++)
      k=k " " $i
    if (! a[$1])
      a[$1]=k
    else
      a[$1]=a[$1] " " k
  }
  END{
    for (i in a)
      print i "\t" a[i]
  }' |\
  awk 'NF > 2 {print $0}' > Identiski_genome.tsv

rm input.fasta
cd ../