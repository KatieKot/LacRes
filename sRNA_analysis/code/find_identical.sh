#/usr/bin/sh
# this code takes a BED file as an input and looks for identical/similar sequences in the genome. 

# Variables: 
# Input bed file 
BED=$1 #aca input.bed
REF=$2
REZ=$3

#BED="../output/print_sequences/sRNA.fasta"
#REF="NC_009004.fasta"
#REZ="../output/find_identical/pairwise_sim.csv"

mkdir -p tmp
cd tmp 

# Prepate database of sequences (sRNRs). Get forward and reverse sequences. 
cat ${BED}  >  input.fasta 
cat input.fasta | perl -ple 'y/ACGT/TGCA/ and $_ = reverse unless /^>/' - |\
awk '{if($1 ~ ">") {print $1"rev"} else {print $0}}' |\
cat - input.fasta > database.fasta

###############################################################################
# find identical sequences
# nothing fancy - we just read every second line (because it is FASTA) and grep against full database. While grepping, I select one line before - FASTA header. 
###############################################################################

while read first; 
 do 
  read second; 
  a=$(grep -B 1 "^"$second"$" database.fasta | grep ">")
  echo $a" "$first >> tmp.txt
 done < input.fasta 

###############################################################################
# First grep will find query sequences as well. So here I check if matches are 
# only with query or with more sequences.
###############################################################################

while read first; 
 do 
  reps=$(echo $first |tr " " "\n"  | uniq | wc -l)
  if [[ $reps -ne 1 ]]
  then
    echo $first  
  fi  
 done < tmp.txt > identiski.txt

cat identiski.txt |\
 awk  '{split($0, a, " " ); asort( a ); b="zz"; for( i = 1; i <= length(a); i++ ) {if (b != a[i]) {b=a[i]; printf( "%s ", a[i] )} else {b=a[i]}};  print( "\n" ); }' |\
 sort | uniq > rikiuoti.txt

echo -n "" > IDENTISKOS.txt
while read line;
  do
    echo $line | tr " " "\n" | sort | uniq | tr "\n" " "
    echo $i
done < rikiuoti.txt | uniq | grep -v "^ $" >> IDENTISKOS.txt

#while read line; 
#  do
#  echo $line; 

#  echo $line | tr " " "\n" | tr -d ">" | awk '{split($0, a, " " ); for( i = 1; i <= length(a); i++ ) {if (a[i] ~ "+") {split(a[i], b, ":"); split(b[2], c, "-"); print b[1], c[1], c[2], "p"} else {split(a[i], b, ":"); split(b[2], c, "-"); print b[1], c[1], c[2], "m"}}}' | tr -d "+()" | tr "pm" "+-" | sed 's/rev//g' | awk  'OFS="\t" {print $1,$2, $3, $1"_"$2"_"$3, "50", $4}' | bedtools getfasta -s -fi ${REF} -bed -  | mafft - > Identiskos_$RANDOM.fasta
#    sleep 1  
#  done < IDENTISKOS.txt  

# Find subsets 
###############################################################################
# find subsets/sequences
# nothing fancy - we just read every second line (because it is FASTA) and grep against full database. While grepping, I select one line before - FASTA header. 
# No "^" and "$" used in grep pattern. 
###############################################################################
while read first; 
 do 
  read second; 
  #echo "$first $second"; 
  a=$(grep -B 1 $second database.fasta | grep ">")
  echo $a" "$first
 done < input.fasta > tmp.txt

 while read first; 
 do 
#  read second; 
  #echo "$first $second" 
  echo $first | awk '{if ($1 != $2) {print $0}} '
 done < tmp.txt  > identiski.txt

cat identiski.txt |\
 awk  '{split($0, a, " " ); asort( a ); b="zz"; for( i = 1; i <= length(a); i++ ) {if (b != a[i]) {b=a[i]; printf( "%s ", a[i] )} else {b=a[i]}};  print( "\n" ); }' |\
 sort > rikiuoti.txt

echo -n "" > POAIBIAI.txt
 while read line;
  do
    echo $line | tr " " "\n" | sort | uniq | tr "\n" " "
    echo $i
  done < rikiuoti.txt | uniq | grep -v "^ $" >> POAIBIAI.txt


#while read line; 
#  do
#  echo $line | tr " " "\n" | tr -d ">" | awk '{split($0, a, " " ); for( i = 1; i <= length(a); i++ ) #{if (a[i] ~ "+") {split(a[i], b, ":"); split(b[2], c, "-"); print b[1], c[1], c[2]} else {split(a[i], b, ":"); split(b[2], c, "-"); print b[1], c[2], c[1]}}}' |  tr -d "+()" | sed 's/rev//g' | ../code/get_sequences.sh | mafft - > Poaibiai_$RANDOM.fasta
#  done < POAIBIAI.txt


## look for similar 


while read ID; 
 do 
  read seka;
  echo ${ID} > aseka
  echo ${seka} >> aseka
  while read ID2; 
    do 
      read seka2;
      echo ${ID2} > bseka
      echo ${seka2} >> bseka   
      ~/anaconda3/bin/needle -asequence aseka -bsequence bseka -brief TRUE -outfile needle_tmp -gapopen 10 -gapextend 0.5
      ide=$(cat needle_tmp | grep Identity | awk '{print $3}')
      echo ${ide} ${ID} ${ID2} >> pairwise.txt
    done < input.fasta  
 done < input.fasta 


Rscript ../code/make_csv_table.R ./pairwise.txt ${REZ}


######################################################### 
# Surasti genome visus pasikartojančius
# Tipo ar ko nors nepražioplinom ir pan..  Darom BLAST ir tada 
# atrenkam BLAST rezultatus. 
##########################################################

#~/Programs/ncbi-blast-2.9.0+/bin/makeblastdb -dbtype  nucl -in ${REF} -parse_seqids
blastn -dust no -soft_masking false -db ${REF} -query input.fasta -outfmt "6 qseqid pident length qlen mismatch qstart qend sstart send evalue sstrand" -evalue 1 > blast.results
cat blast.results | awk '{if ($11 == "minus") {$12="NC_009004.1:"$9-1"-"$8"(-)"} else {$12="NC_009004.1:"$8-1"-"$9"(+)"}; print $0}' |
  awk '{if($1 != $12) {print $0}}' | awk '{if(($2+0) > 60.0) {print $0}}' | awk '{if($8>$9) {a=$8; $8=$9; $9=a}; print $0 }'| awk '{uzklausa=($7-$6+1)/$4*100; surasta=(($9-$8)+1)/$3*100; if ((uzklausa > 80) && (surasta > 80) ) {print($1, $12)} }'  | awk '
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
}' > Atitikimai_genome.tsv

#rm aseka bseka tmp.txt database.fasta identiski.txt input.fasta rikiuoti.txt pairwise.txt needle_tmp blast.results
#cd ../

