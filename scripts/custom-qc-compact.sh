#!/usr/bin/env bash
# Set up for failure
set -xeuo pipefail

# Read input
input=$1
output=$2

get_json_str_from_stats_file(){
    local pattern="$1"
    local stats_file="$2"
    local key="$3"
    local description="$4"
    local value
    # Get value from file and then parse through jq
    value="$(grep "${pattern}" "${stats_file}" | cut -f2)"
    # Return json string
    jq -n \
        --arg des "$description" \
        --arg src "$pattern" \
        --arg val "$value" \
        --arg key_name "$key" \
        '{($key_name): {description: $des, source: $src, value: $val}}'
}
# Extract Summary Number section from stats file
samtools_stats_file="summary_numbers.txt" 
grep ^SN $1 | cut -f 2- > "${samtools_stats_file}"

# Sample metadata
JSON_STRING=$( jq -n \
                  --arg sm "NA12878" \
                  '{sampleID: $sm}' )
#echo $JSON_STRING >> $output

# embedded new line in a variable in bash
# Extract average base quality
JSON_STRING="${JSON_STRING}"$'\n'"$(get_json_str_from_stats_file "average quality" "${samtools_stats_file}" "average_base_quality" "average base quality")"

# Extract yield_mapped_bp
JSON_STRING="${JSON_STRING}"$'\n'"$(get_json_str_from_stats_file "bases mapped (cigar)" "${samtools_stats_file}" "yield_mapped_bp" "yield mapped bp")"

# Extract pct_autosomes_20x
JSON_STRING="${JSON_STRING}"$'\n'"$(get_json_str_from_stats_file "percentage of target genome with coverage > 20" "${samtools_stats_file}" "pct_autosomes_20x" "pct autosomes 20x")"

# Extract mean_insert_size
JSON_STRING="${JSON_STRING}"$'\n'"$(get_json_str_from_stats_file "insert size average:" "${samtools_stats_file}" "mean_insert_size" "mean insert size")"

# Extract insert_size_SD
JSON_STRING="${JSON_STRING}"$'\n'"$(get_json_str_from_stats_file "insert size standard deviation:" "${samtools_stats_file}" "insert_size_sd" "insert size sd")"

# Extract pct_discordant_read_pairs
pct_properly_paired_reads=$(grep -h "SN	percentage of properly paired reads (%):" $input | cut -f3)
pdr=$(awk -vn1="$pct_properly_paired_reads" 'BEGIN { print (100 - n1) }')
JSON_STRING="${JSON_STRING}"$'\n'"$( jq -n \
                  --arg des "pct properly paired reads" \
                  --arg src "SN	percentage of properly paired reads (%)" \
                  --arg val "$pct_properly_paired_reads" \
                  '{pct_discordant_reads: {description: $des, source: $src, value: $val}}' )"

# Extract pct_mapped_reads where pct_mapped_reads = [(Mapped Reads - Reads MQ0) / Total Reads]
# RM = Mapped Reads
# R0 = Reads MQ0
# RT = Total Reads
RM=$(grep -h "SN	reads mapped:" $input | cut -f3)
R0=$(grep -h "SN	reads MQ0:" $input | cut -f3)
RT=$(grep -h "SN	raw total sequences:" $input | cut -f3)
pct_mapped_reads=$(( 100 * ( $RM - $R0) / $RT ))
JSON_STRING="${JSON_STRING}"$'\n'"$( jq -n \
                  --arg des "pct mapped reads" \
                  --arg src "pct_mapped_reads = [(Mapped Reads - Reads MQ0) / Total Reads]" \
                  --arg val "$pct_mapped_reads" \
                  '{pct_mapped_reads: {description: $des, source: $src, value: $val}}' )"

# Write output to file
echo $JSON_STRING | jq '[inputs] | add' > $output
