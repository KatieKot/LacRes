# LacRes
Small non-coding RNAs mediate Lactococcus lactis resistance to cell wall-targeting antimicrobials

Milda Mickutė, Kotryna Kvederavičiūtė, Janina Ličytė, Renatas Krasauskas, Sigita Grigaitytė, Oskaras Safinas, Algirdas Kaupinis, Mindaugas Valius, Marie-Piere Chapot-Chartier, Saulius Kulakauskas, Giedrius Vilkaitis


Sample codes to reproduce the analysis results.

## Requirements
R (at least v4.0.3)
Bioconductor (v3.12)

## Getting Started
These codes demonstrate how to reproduce most findings from Mickute et al. paper. Analysis consist of 3 sequencing experiments: sRNA-seq, RNA-seq and MAPS-seq. For each experiment, there is a folder with data preparation and data analysis.

Raw data pre-processing is performed using a snakemake. 
The analysis was performed using NC_009004.1 reference genome (NCBI). sRNAs annotation requires additional files: promoters, terminators predictions that are not included.  

