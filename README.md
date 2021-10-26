# GHIF-QC
Outline of tools used to generate a set of key QC metrics for standardised reporting of sequencing data, initially focused on germline WGS QC for short-read squencers.

[Trello Card](https://trello.com/c/pRI1C3l2)

Driven by Practical guidelines for quality control of WGS results in population-scale initiatives

Initial scope:

  * Identify GiaB BAM
  * Re-create key bcbio QC metric steps in Nextflow
  * Apply to BAM
  * Generate QC metrics in JSON format (directly or through MultiQC processing)
  * Discuss, document key metrics; submit results and workflow to [wgs-sample-qc/proof-of-concept at main · c-BIG/wgs-sample-qc](https://github.com/c-BIG/wgs-sample-qc/tree/main/proof-of-concept)



## GHIF Practical guidelines for quality control of WGS results in population-scale initiatives

>In this document, the GHIF WGS QC workgroup intends to identify a set of key QC metrics and spell out their detailed definitions. Whilst doing so, we expect to encounter recurrent information fields that apply to many metrics. Those can then be used as the basis for standardised guidelines for reporting QC metrics.


>General notes
The document is just a first draft to capture conversations from our regular meetings. It provides some templated sections as a guide, but those may not be exhaustive. As such, feel free to make as many changes as needed; we can always recover previous versions of the document using the file history.
In terms of scope, the workgroup has agreed to focus on germline WGS QC first. While all of the workgroup participants are working with short-read data at the moment, we wish to make the definitions general enough to be applicable to other technologies as well. The workgroup also acknowledges that there are multiple stages in the analysis pipeline at which one may want to perform QC (e.g. post-FASTQ generation, post-alignment, post-variant calling). For the first iteration of the guidelines, the workgroup has agreed to focus on metrics that can be obtained from a BAM/CRAM file. Thus, metrics such as contamination or variant counts remain out of scope at the moment.

##Discussion points for GHIF meeting 26/10/21

  * Some of the required "field" metrics such as base quality are difficult to filter or change at the BAM stage (without creating a entirely new BAM file)
  These include:
    * removal of low quality bases ie BQ >= 30,
    * collapsing of UMIs
    * marking of duplicates
    * how unmapped reads have been handled, and whether they are still included with the bam file

    ##Discussion points for GHIF meeting 26/10/21

      * Some of the required "field" metrics such as base quality are difficult to filter or change at the BAM stage (without creating a entirely new BAM file)
      These include:
        * removal of low quality bases ie BQ >= 30,
        * collapsing of UMIs
        * marking of duplicates
        * how unmapped reads have been handled, and whether they are still included with the bam file

        These may affect some of the calculated QC metrics if the relevant information if not provided as metadata along with the Bam files. How to assess QC metrics if they are unknown?
        ie if unmapped reads are not included in BAM file, is "Contamination" QC metric assessable?



      * Common programs for dealing with BAM files seem to allow filtering bases on mapping quality but not base quality
        * ie BQ filter available for samtools coverage but not mosdepth nor samtools stats
        * Is it possible to just report % of bases <= Q20?

      * Some programs report a mean coverage per chromosome summary. To obtain mean coverage across all autosomes, should chromosome length be taken into account or is Sum of mean chromosome coverage / number of chromosomes sufficient?




  * Common programs for dealing with BAM files seem to allow filtering bases on mapping quality but not base quality
    * ie BQ filter available for samtools coverage but not mosdepth nor samtools stats
    * Is it possible to just report % of bases <= Q20?

  * Some programs report a mean coverage per chromosome summary. To obtain mean coverage across all autosomes, should chromosome length be taken into account or is Sum of mean chromosome coverage / number of chromosomes sufficient?



### Documents
[GHIF repo](https://github.com/c-BIG/wgs-sample-qc)

[GHIF WGS QC Meeting minutes](https://docs.google.com/document/d/1gjJ_C2OK8aTEbAOBpWn9ygk9VRUPTP0AICa86DBqOOo/edit#heading=h.3r5642cb8rj)

[GHIF WGS QC Metric definitions](https://docs.google.com/document/d/17bVufpacyoUM4UDKlwkr-0KOG-yZrcVSvM6yC9gbrk4/edit)

[GHIF example implementations - as of 25/10/21 branch ahead of main](https://github.com/c-BIG/wgs-sample-qc/tree/example_implementation_sg/example_implementations/sg-npm)

### Data File locations
NA12878 build for testing QC pipelines
```
# BAM - NA12878.bam/NA12878.bam.bai:
s3://1000genomes-dragen/data/dragen-3.5.7b/hg38_altaware_nohla-cnv-anchored/NA12878/

# reference - hg38_alt_aware_nohla.fa:
aws s3 ls s3://1000genomes-dragen-3.7.6/references/fasta/hg38.fa

# from https://registry.opendata.aws/ilmn-dragen-1kgp/
```
NIST Genome Stratifications -  

GRCh38_notinalllowmapandsegdupregions.bed.gz (The complement of the union of all difficult to map regions and all segmental duplications) used to limit estimates to higher confidence regions

(https://data.nist.gov/od/id/mds2-2190)

*Need to check if this really is limited to autosomes! - It does not appear to be so everything should be redone with an autosome only co-ordinates bed*



File locations on Gadi:

/g/data/gx8/projects/Mitchell_GHIFqc

*Note Gadi has different versions of mosdepth and samtools*



### Metric definitions
General template

**Id** (mandatory): metric_id

**Description** (mandatory): Metric description.

**Source** (mandatory): Tool and version used to calculate the metric.

**Implementation details** (optional, depending on metric): Standardised insights into the metric implementation, where possible.


#### Yield
*(Desired example implementation was for Base quality ≥ Q30, still not sure how to do this)*

**Id:** yield_mapped_bases

**Description:** The number of mapped bases - filtered by the CIGAR string corresponding to the read they belong to. Only alignment matches(M), inserts(I), sequence matches(=) and sequence mismatches(X) are counted.

**Source:** samtools v1.13

**Implementation details:**

`samtools stats --remove-overlaps --remove-dups --ref-seq hg38_alt_aware_nohla.fa NA12878.bam > samtools_stats_noDups_noOlps.txt`

*(The reference fasta file is only required for GC-depth and mismatches-per-cycle calculation - so not really required here)*

`samtools stats --remove-overlaps --remove-dups --target-regions  NA12878.bam > samtools_stats_noDups_noOlps.txt`


To obtain Summary Numbers only

`grep ^SN samtools_stats_noDups_NoOlps.txt | cut -f 2- >summaryNumbers.txt`

Yield

`grep -h "SN	bases mapped (cigar)" samtools_stats_noDups_NoOlps.txt | cut -f3 `

>102487807038

102,487,807,038 bp

Average base quality can be obtained from Summary Numbers "average quality"

Average quality:	29.5

Precise definitions from [samtools-stats](http://www.htslib.org/doc/samtools-stats.html)

reads mapped - number of reads, paired or single, that are mapped (flag 0x4 [read unmapped] or 0x8 [mate unmapped] not set).

bases mapped - number of processed bases that belong to reads mapped #ignores clipping

bases mapped (cigar) - number of mapped bases filtered by the CIGAR string corresponding to the read they belong to. Only alignment matches(M), inserts(I), sequence matches(=) and sequence mismatches(X) are counted. # more accurate


| Field   | Description | Format | Value in example implementation |
| --- | --- | --- | --- |
| MIN_BQ | Minimum base quality | Integer |  |
| DUP | Are duplicates included? | Boolean | FALSE |
| CLP | Are clipped bases (hard and soft clipped) included? | Boolean | FALSE |
| UMI | Are Unique Molecular Identifiers used to collapse reads? | Boolean | FALSE |
| OLP | Are paired-end read overlaps included in counts? | Boolean | FALSE |

*Samtools stats also allows a -t, --target-regions FILE to be specified. Do stats in these regions only. Tab-delimited file chr,from,to, 1-based, inclusive.*

*And percentage of target genome with coverage > VAL - percentage of target bases with a coverage larger than VAL. By default, VAL is 0, but a custom value can be supplied by the user with -g option.*


#### Average coverage (example implementation: Mean autosome coverage)

**Id:** mean_autosome_coverage

**Description:** The mean coverage in autosomes.

**Source:** samtools v1.13

**Implementation details:**

`samtools coverage --min-BQ 20 --min-MQ 1 --excl-flags DUP --output samtoolscov_all.txt NA12878.bam`

The tabulated output contains mean depth of coverage per chromosome ("meandepth" - column 7) which can be averaged for the 22 autosomes (ignoring chromosome length)

`cat samtoolscov_all.txt | awk 'NR==2,NR==23' | awk '{sum += $7} END {print sum / 22}' `
>29.998

*A messy calculation to take into account the length of the chromosomes:*

```
cat samtoolscov_all.txt | awk 'NR==2,NR==23' | awk '{sum7 += $7*$3; sum3 += $3} END {print sum7 / sum3}'

# where column 7 = mean depth and column 3 = end postion (or chromosome length)
```
>30.4515

| Field   | Description | Format | Value in example implementation |
| --- | --- | --- | --- |
| REF | Genomic reference | refget checksum |   |
| MIN_BQ | Minimum base quality | Integer | 20 |
| MIN_MQ | Minimum mapping quality | Integer | 1 |
| DUP | Are duplicates included? | Boolean | FALSE |
| CLP | Are clipped bases (hard and soft clipped) included? | Boolean | FALSE |
| UMI | Are Unique Molecular Identifiers used to collapse reads? | Boolean | FALSE |
| OLP | Are paired-end read overlaps included in counts? | Boolean | FALSE |

*Sill need to include checksum for GRCh38 reference*


*An Alternative may be to try and use mosdepth for estimates as it is faster than samtools, however mosdepth does not appear to be able to exclude bases because of low base-quality*

**Id:** mean_autosome_coverage_md

**Description:** The mean coverage in autosomes.

**Source:** mosdepth v0.3.2

**Implementation details:**

`mosdepth --no-per-base --by 1000 --mapq 1 NA12878_all NA12878.bam`

NA12878_all.mosdepth.summary.txt contains a summary of mean depths per chromosome and within specified regions per chromosome.

Mean for all autosomes can be calculated in a similar fashion to samtools mean_autosome_coverage

*Investigate using [datamash](https://www.gnu.org/software/datamash/) for extracting metrics from NA12878_all.mosdepth.summary.txt*
*Manual calculation for mean_autosome_coverage from mosdepth summary file = 30.0495*


Note: *.mosdepth.summary.txt as output was only added in v0.2.6

Mosdepth details

Default exclude flag is 1796
    read unmapped (0x4)
    not primary alignment (0x100)
    read fails platform/vendor quality checks (0x200)
    read is PCR or optical duplicate (0x400)

1000 bp window used to increase performance

It appears mate overlaps are corrected unless fast mode is used (--fast-mode)

Other options
-t --threads <threads>     number of BAM decompression threads. (use 4 or fewer) [default: 0]



##### Average coverage excluding low mapping regions

**Id:** mean_high_confidence_region_coverage

**Description:** The mean coverage in all autosomes excluding all difficult to map regions and all segmental duplications.

**Source:** mosdepth v0.3.2

**Implementation details:**

`mosdepth --no-per-base --by GRCh38_notinalllowmapandsegdupregions.bed --mapq 1 NA12878_nialmsdr NA12878.bam`

*Investigate using [datamash](https://www.gnu.org/software/datamash/) for extracting metrics from NA12878_nialmsdr.mosdepth.summary.txt*

*Manual calculation for mean_autosome_coverage from mosdepth summary file = 31.63*



#### Genome completeness (example implementation: Percent autosomes covered ≥ 15 X)

 **Id:** pct_high_confidence_regions_20x

**Description:** The percentage of bases that attained at least 20X sequence coverage in all autosomes excluding all difficult to map regions and all segmental duplications.

**Source:** mosdepth v0.3.2

**Implementation details:

```
#Run mosdepth - as used for mean_high_confidence_region_coverage

mosdepth --no-per-base --by GRCh38_notinalllowmapandsegdupregions.bed --mapq 1 NA12878_nialmsdr NA12878.bam

#Extract mean estimate from region distribution file

grep -h "\btotal	20\b" NA12878_nialmsdr.mosdepth.region.dist.txt | cut -f3
```
>0.98

98 %

From [Mosdepth readme](https://github.com/brentp/mosdepth)

>The $prefix.mosdepth.global.dist.txt file contains, a cumulative distribution indicating the proportion of total bases (or the proportion of the --by for $prefix.mosdepth.region.dist.txt) that were covered for at least a given coverage value. It does this for each chromosome, and for the whole genome.

So the global percent covered >= 20X is also available

`grep -h "\btotal	20\b" NA12878_nialmsdr.mosdepth.global.dist.txt | cut -f3`
>0.89


#### Genome coverage uniformity

**Id:** high_confidence_regions_coverage_uniformity

**Description:** The percentage of bases with more or less than 25% coverage difference from the mean autosome coverage

**Source:** in-house tool based on mosdepth v0.3.2 calculating (PCT < 0.75 * mean_autosome_coverage) + (PCT > 1.25 * mean_autosome_coverage)

**Implementation details:** same as mean_autosome_coverage.


```
#Run mosdepth - as used for high_confidence_region_coverage
mosdepth --no-per-base --by GRCh38_notinalllowmapandsegdupregions.bed --mapq 1 NA12878_nialmsdr NA12878.bam`
#mean_autosome_coverage = 30.0495 (PCT < 0.75*30.0495) + (PCT > 1.25*30.0495)
#Extract estimates from region distribution file

grep -h "\btotal	23\b" NA12878_nialmsdr.mosdepth.region.dist.txt | cut -f3
#0.95

grep -h "\btotal	40\b" NA12878_nialmsdr.mosdepth.region.dist.txt | cut -f3

#0.14
#So total = (1-0.95)+0.14 =0.19

```



#### Contamination estimate

**Id:** read_mapping_quality

**Description:** The percentage of reads mappable to the REF sequence with MAPQ>0

**Source:** samtools v1.13 (reads_mapped_percent)

**Implementation details

As used for average coverage

`samtools stats --remove-overlaps --remove-dups --ref-seq hg38_alt_aware_nohla.fa NA12878.bam > samtools_stats_noDups_noOlps.txt`

To obtain Summary Numbers only - optional

`grep ^SN samtools_stats_noDups_NoOlps.txt | cut -f 2- >summaryNumbers.txt`

Mapped Reads

`grep -h "SN	reads mapped:" samtools_stats_noDups_NoOlps.txt | cut -f3 `

>676950739

Reads MAPQ = 0

`grep -h "SN	reads MQ0:" samtools_stats_noDups_NoOlps.txt | cut -f3 `

>38854425

Total reads

`grep -h "SN	raw total sequences:" samtools_stats_noDups_NoOlps.txt | cut -f3 `

>758135204

read_mapping_quality [(Mapped Reads - Reads MQ0) / Total reads]
>0.841

84 %

Details from samtools stats

raw total sequences - total number of reads in a file, excluding supplementary and secondary reads. Same number reported by samtools view -c.

filtered sequences - number of discarded reads when using -f or -F option.

sequences - number of processed reads.


#### Library assessment

**Id:** discordant_read_pairs

**Description:** The percentage of properly paired reads after alignment

**Source:** samtools v1.13 (reads_properly_paired_percent)

**Implementation details:**

As used for average coverage

`samtools stats --remove-overlaps --remove-dups --ref-seq hg38_alt_aware_nohla.fa NA12878.bam > samtools_stats_noDups_noOlps.txt`

To obtain Summary Numbers only - optional

`grep ^SN samtools_stats_noDups_NoOlps.txt | cut -f 2- >summaryNumbers.txt`

reads_properly_paired_percent

`grep -h "SN	percentage of properly paired reads (%):" samtools_stats_noDups_NoOlps.txt | cut -f3 `

>98.0

98 %



#### Insert size assessment

**Id:** mean_insert_size

**Description:** A tuple of mean insert size for paired and mapped reads followed by the insert size standard deviation for the average template length distribution

**Source:** samtools v1.13 (Insert_size_average and insert_size_standard_deviation)

**Implementation details:**

As used for average coverage

`samtools stats --remove-overlaps --remove-dups --ref-seq hg38_alt_aware_nohla.fa NA12878.bam > samtools_stats_noDups_noOlps.txt`

To obtain Summary Numbers only - optional

`grep ^SN samtools_stats_noDups_NoOlps.txt | cut -f 2- >summaryNumbers.txt`

Insert_size_average

`grep -h "SN	insert size average:" samtools_stats_noDups_NoOlps.txt | cut -f3 `

>440.2

Insert_size_SD

`grep -h "SN	insert size standard deviation:" samtools_stats_noDups_NoOlps.txt | cut -f3 `

>98.9

samtools stats details

  *insert size average - the average absolute template length for paired and mapped reads.

  *insert size standard deviation - standard deviation for the average template length distribution.
