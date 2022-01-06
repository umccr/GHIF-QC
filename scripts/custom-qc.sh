#!/usr/bin/env bash

# Read input
input=$1
output=$2

# Sample metadata
JSON_STRING=$( jq -n \
                  --arg sm "NA12878" \
                  '{sampleID: $sm}' )
echo $JSON_STRING >> $output

# Extract average base quality
avg_base_qual=$(grep -h "SN	average quality" $input | cut -f 3)
JSON_STRING=$( jq -n \
                  --arg des "average base quality" \
                  --arg src "SN	average quality" \
                  --arg val "$avg_base_qual" \
                  '{average_base_quality: {description: $des, source: $src, value: $val}}' )
echo $JSON_STRING >> $output

# Extract yield_mapped_bp
yield_mapped_bp=$(grep -h "SN	bases mapped (cigar)" $input | cut -f 3)
JSON_STRING=$( jq -n \
                  --arg des "yield mapped bp" \
                  --arg src "SN	bases mapped (cigar)" \
                  --arg val "$yield_mapped_bp" \
                  '{yield_mapped_bp: {description: $des, source: $src, value: $val}}' )
echo $JSON_STRING >> $output

# Extract pct_autosomes_20x
pct_autosomes_20x=$(grep -h "SN	percentage of target genome with coverage > 20" $input | cut -f 3)
JSON_STRING=$( jq -n \
                  --arg des "pct autosomes 20x" \
                  --arg src "SN	percentage of target genome with coverage > 20" \
                  --arg val "$pct_autosomes_20x" \
                  '{pct_autosomes_20x: {description: $des, source: $src, value: $val}}' )
echo $JSON_STRING >> $output

# Extract pct_discordant_read_pairs
pct_properly_paired_reads=$(grep -h "SN	percentage of properly paired reads (%):" $input | cut -f3)
pdr=$(awk -vn1="$pct_properly_paired_reads" 'BEGIN { print (100 - n1) }')
JSON_STRING=$( jq -n \
                  --arg des "pct properly paired reads" \
                  --arg src "SN	percentage of properly paired reads (%)" \
                  --arg val "$pct_properly_paired_reads" \
                  '{pct_discordant_reads: {description: $des, source: $src, value: $val}}' )
echo $JSON_STRING >> $output

# Extract mean_insert_size
mean_insert_size=$(grep -h "SN	insert size average:" $input | cut -f3)
JSON_STRING=$( jq -n \
                  --arg des "mean insert size" \
                  --arg src "SN	insert size average" \
                  --arg val "$mean_insert_size" \
                  '{mean_insert_size: {description: $des, source: $src, value: $val}}' )
echo $JSON_STRING >> $output

# Extract Insert_size_SD
insert_size_sd=$(grep -h "SN	insert size standard deviation:" $input | cut -f3)
JSON_STRING=$( jq -n \
                  --arg des "insert size sd" \
                  --arg src "SN	insert size standard deviation" \
                  --arg val "$insert_size_sd" \
                  '{insert_size_sd: {description: $des, source: $src, value: $val}}' )
echo $JSON_STRING >> $output

# Extract pct_mapped_reads where pct_mapped_reads = [(Mapped Reads - Reads MQ0) / Total Reads]
# RM = Mapped Reads
# R0 = Reads MQ0
# RT = Total Reads
RM=$(grep -h "SN	reads mapped:" $input | cut -f3)
R0=$(grep -h "SN	reads MQ0:" $input | cut -f3)
RT=$(grep -h "SN	raw total sequences:" $input | cut -f3)
pct_mapped_reads=$(( 100 * ( $RM - $R0) / $RT ))
JSON_STRING=$( jq -n \
                  --arg des "pct mapped reads" \
                  --arg src "pct_mapped_reads = [(Mapped Reads - Reads MQ0) / Total Reads]" \
                  --arg val "$pct_mapped_reads" \
                  '{pct_mapped_reads: {description: $des, source: $src, value: $val}}' )
echo $JSON_STRING >> $output
