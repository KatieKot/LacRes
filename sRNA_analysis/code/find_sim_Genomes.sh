#!/bin/sh
# Code takes bed file with coordinates and:
# 1. Extracts FASTA sequences from reference genome 
# 2. Creates reference database based on NCBI refseq IDs
# 3. Looks for the (1) homologues in (2) database
# 4. Reports some statistics.

# USAGE
#./Kodas ID.txt sequences.bed main_genome_ID
# ID.txt - a list (one ID per row) of NCBI IDs
# sequences.bed - bed6 with regions of interest
# main_genome - ID of the reference genome (NCBI ID). It should be also present in ID.txt. This genome 
# will be used to extract sequences using sequences.bed file.

#####################################################################
# Create databases from reference genomes
#####################################################################
ID=$1  # file with IDs
sekos=$2  # 
main_genome=$3

mkdir -p DB

while read line; 
  do
    file=./DB/${line}.fasta
    [[ ! -f "${file}" ]] && efetch -id ${line} -db nuccore -format fasta > ${file}  
    #~/Programs/ncbi-blast-2.9.0+/bin/makeblastdb -in ./DB/${line}.fasta -dbtype nucl -parse_seqids
  done < ${ID}

cat DB/*fasta > ./DB/Genomes.fastas
makeblastdb -in ./DB/Genomes.fastas -dbtype nucl -parse_seqids
 
cd DB 

#cd ../
#DATABASE="./DB/Genomes.fasta"

#####################################################################
# Get sRNAs - using ones that are generate previously. 
#####################################################################
cat ${sekos} > sekos.fa
cat sekos.fa | paste - - > sekos.single

#####################################################################
# Search. Report includes (this is non standard outfmt6 format):
# 1. 	 qseqid 	 query (e.g., unknown gene) sequence id
# 2. 	 sseqid 	 subject (e.g., reference genome) sequence id
# 3. 	 pident 	 percentage of identical matches
# 4. 	 length 	 alignment length (sequence overlap)
# 5.     qlen        query length
# 6. 	 mismatch 	 number of mismatches
# 7. 	 qstart 	 start of alignment in query
# 8. 	 qend 	 end of alignment in query
# 9. 	 sstart 	 start of alignment in subject
# 10. 	 send 	 end of alignment in subject
# 11. 	 evalue 	 expect value
# 12.    sstrand     subject strand    
#####################################################################

echo -n "" > REZU.txt
blastn -db Genomes.fastas -query sekos.fa -dust no -soft_masking false -outfmt "6 qseqid sseqid pident length qlen mismatch qstart qend sstart send evalue sstrand" > blast.results


while read line; 
  do
    # change region and get the sequence
    echo ${line} | awk '{if ($12 == "minus") {
       print $2, $10-20-($5-$8)"-"$9+20+$7+1, $12} 
        else {print $2, $9-20-$7+1"-"$10+20+($5-$8), $12
                                             }}' |\
          blastdbcmd -db ./Genomes.fastas -entry_batch - >  seka.seq
    id=$(echo $line | awk '{print $1}')
    cat sekos.single | grep $id | tr "\t" "\n"  > sRNA.seq
    needle -awidth3 2000 -gapopen 10 -gapextend 0.5 seka.seq sRNA.seq alignmnet.psa

    sbjct=$(cat alignmnet.psa | grep -v "^#" | grep -v "^$" | head -1 | awk '{print $3}')
    query=$(cat alignmnet.psa | grep -v "^#" | grep -v "^$" | tail -1 | awk '{print $3}')

    cstart=$(echo ${query} | grep -o "^-*[ATGC]*" | grep -o "-"  | wc -l)
    cgalas=$(echo ${query} | rev | grep -o "^-*[ATGC]*" | grep -o "-"  | wc -l)
    cend=$(echo ${query} | awk -v p=${cstart} -v e=${cgalas} '{print(length($0)-p-e)}')

    echo ${sbjct} | awk -v s=${cstart} -v e=${cend} '{print(substr($0, s+1, e))}' | tr -d "-" > tmp.fasta
    echo ">sbjct" | cat - tmp.fasta  > sbjct.fasta 
    echo ${query} | tr -d "-" > tmp.fasta
    echo ">query" | cat - tmp.fasta > query.fasta

    needle -gapopen 10 -gapextend 0.5 query.fasta sbjct.fasta alignmnet.psa
    ident=$(      cat alignmnet.psa | grep Identity | awk '{print $4}' | tr -d "(" | tr -d ")")
    id_q=$(cat sRNA.seq | grep ">")
    id_s=$(cat seka.seq | grep ">" | awk '{print $1}'| grep -o "[A-Za-z0-9_\.]*:" | tr -d ":")
    echo ${id_q} ${id_s} ${ident} >> REZU.txt

  done < blast.results

rm query.fasta sbjct.fasta sRNA.seq tmp.fasta alignmnet.psa sekos.single seka.seq sekos.fa blast.results