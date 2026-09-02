# HiC data analysis workshop

This repo contains material for our HiC data analysis workshop, split in 4 (unequal) parts.
Data required for the course is given during the course.



## Install / setup

All scripts (python/sh) run within a conda environment described in `analysis_mini.yml`.

Running the following should be sufficient to have everything running fine.
```sh
conda env create -n hic_analysis -f analysis_mini.yml
conda activate hic_analysis
```

**If installing the environment is not possible, the notebooks can be opened 
and run through Google Colab, [see below](#Google-Colab).**


## Full hicstuff pipeline (reads to HiC matrix)

### Goals / guidelines
**Goals:** 

  - Run a pipeline from raw data to analysis-ready contact matrices  
  - Understand important steps
    - read digestion
    - filtering steps 
      - unique alignment only (uniquely mapped for both ends)
      - remove uninformative events 
        - PCR duplicates (identical read mapping positions)
        - Loops (fragments religated to themselves)
        - "Uncut" (and religated) fragments (consecutive restriction fragment contacts)
    - binning
    - normalization (ICED balancing)
  - Understand output formats
    - graal matrix
    - cool/mcool formats

**In-class:**

 - Fetch the script, update paths, launch.
 - While the script runs, Quick reminder of the various steps
 - Check head of raw & parasplitted fq files
 - Check hicstuff plots
   - event distribution
   - P(s)
   - Genome fragmentation hist
 - Check hicstuff outputs (head of graal)



Notes: parasplit MUST use >=5 threads. This makes it unusable in the computer setup of the larger room (for 23 people – computers have max 4 threads with 2 cores).
Can give both raw & parasplitted reads to students and show the first few lines of either to show difference.

Full code in `reads_to_hic.sh` script, to hand as is, or with a few holes to students.


### Tests on subsampled data:
Sampled 2\% of AD281 library (WT DSB 4h), resulting in 1.4M read pairs (~ 110Mb fq.gz). 
After parasplit digestion: 3.6M digested read pairs (~140Mb).

The `reads_to_hic.sh` script (hicstuff pipeline + balancing + zoomify) runs in \~3min from already digested reads on my machine with 4 threads.
Pipeline outputs (without cleanup) are < 1Gb

Read digestion with parasplit takes \~2min.


## Cool file handling w/ cooler (part 2)

See notebook `HiC_analysis_part2.ipynb`.

- Load a cool file.
- Simple plotting of defined regions.
- Load mcool file.
- log10/normalization viz.

## Cool file handling w/ hicstuff (part 3)

See notebook `HiC_analysis_part3.ipynb`.

- Load a cool file w/ hicstuff 
- Normalization.
- Plotting.
- Recreating fig 1c from Piazza et al. (2021)

## Finer analysis w/ hicstuff (part 4)

See notebook `HiC_analysis_part4.ipynb`.

- Subsampling
- Ratio maps
- Serpentine
- WT vs. SCC1 ratio map
- P(s) computing / plotting (side note on using hicstuff outputs + from matrix)
- WT vs. SCC1 P(s) single chr, all chr, all chr averaged

## Data / computing requirements

### Full pipeline run:

Initial Data:

  - raw fastq files: 2x 110 Mb
  - digested fastq files: 2x 140 Mb
  - reference genome: 80 Mb

Requirements:

 - Output space: \~1 Gb
 - Computing power: < 2 Gb RAM, 5 threads (4 if skipping digestion)
 - Computing time: \~5 min with read digestion, \~3 min starting from digested reads.
 
Log of running `read_to_hic.sh`:

```
[2026-09-02 11:33:54] Started reads_to_hic.sh
Params:
  [mode]   parasplit
  [enzymes]  DpnII,HinfI
  [quality]  20
  [thread]   4
  [r1ext]  .end1
  [r2ext]  .end2
  [fastqdir]   ../data/fastq/
  [genomedir]  ../data/refgenome/S288c_DSB_chr3_rDNA/
  [outputdir]  ../data/hicstuff_output/
  [outdir_digest]  ../data/fastq/parasplitted/
Tool versions:
  [parasplit --version]  parasplit 1.1.5
  [hicstuff --version]   3.2.4
  [cooler --version]   cooler, version 0.10.3
Sample list:
  AD281_0.02_subsamp
[2026-09-02 11:33:57] Started AD281_0.02_subsamp.
[2026-09-02 11:33:57]   Digesting reads with parasplit.
Ligation sites: re.compile('GATCGATC')
Ligation sites: re.compile('GATCA.TC')
Ligation sites: re.compile('GA.TGATC')
Ligation sites: re.compile('GA.TGATC')
Ligation sites: re.compile('GATCA.TC')
Ligation sites: re.compile('GA.TA.TC')
Mode ALL selected
[2026-09-02 11:34:18]   Running hicstuff pipeline.
INFO :: ## hicstuff: v3.2.4 log file
INFO :: ## date: 2026-09-02 11:34:19
INFO :: ## enzyme: DpnII,HinfI
INFO :: ## input1: ../data/fastq/parasplitted//AD281_0.02_subsamp_parasplit.end1.fastq.gz 
INFO :: ## input2: ../data/fastq/parasplitted//AD281_0.02_subsamp_parasplit.end2.fastq.gz
INFO :: ## ref: ../data/refgenome/S288c_DSB_chr3_rDNA//S288c_DSB_chr3_rDNA
INFO :: ---
INFO :: Checking content of fastq files.
INFO :: 3677891 reads found in each fastq file.
3677891 reads; of these:
  3677891 (100.00%) were unpaired; of these:
    567105 (15.42%) aligned 0 times
    2781973 (75.64%) aligned exactly 1 time
    328813 (8.94%) aligned >1 times
84.58% overall alignment rate
[bam_sort_core] merging from 0 files and 8 in-memory blocks...
3677891 reads; of these:
  3677891 (100.00%) were unpaired; of these:
    588606 (16.00%) aligned 0 times
    2761269 (75.08%) aligned exactly 1 time
    328016 (8.92%) aligned >1 times
84.00% overall alignment rate
[bam_sort_core] merging from 0 files and 4 in-memory blocks...
INFO :: 78% reads (single ends) mapped with Q >= 20 (5728858/7355782)
INFO :: 2266648 pairs successfully mapped (61.63%)
INFO :: Filtering with thresholds: uncuts=9 loops=3
INFO :: Proportion of inter contacts: 15.5% (intra: 909373, inter: 166818)
INFO :: 1190457 pairs discarded: Loops: 98458, Uncuts: 1091681, Weirds: 318
INFO :: 1076191 pairs kept (47.48%)
INFO :: 1% PCR duplicates have been filtered out (10622 / 1076191 pairs) 
INFO :: 1065569 pairs remaining after removing PCR duplicates
INFO :: 1065569 pairs used to build a contact map of 74860 bins with 872871 nonzero entries.
INFO :: Fetching mapping and pairing stats
INFO :: {'Sample': 'hicstuff_20260902113419.log', 'Total read pairs': 3677891, 'Mapped reads': 5728858, 'Unmapped reads': 1626924, 'Recovered contacts': 2266648, 'Final contacts': 1065569, 'Removed contacts': 1201079, 'Filtered out': 1190457, 'Loops': 98458, 'Uncuts': 1091681, 'Weirds': 318, 'PCR duplicates': 10622}
INFO :: Contact map generated after 0h 2m 12s
[2026-09-02 11:36:32]   Rebinning matrix at 1kb.
[2026-09-02 11:36:43]   Converting binned matrix to cooler.
[2026-09-02 11:36:45]   ICE-balancing matrix.
[2026-09-02 11:36:48]   Zoomifying at 1, 2, 5, 10, 15, and 20kb.
[2026-09-02 11:36:54] Done.

```

### Cool file handling (part 2)

Initial Data:

  - outputs from part 1.

Requirements:

- Output space: \~1 Mb (plots)
- Computing power: <1 Gb RAM, 115\% CPU 
- Computing time: 5 sec

```sh
# Running the code with harshest resource limits described in the vademecum
OPENBLAS_NUM_THREADS=1 systemd-run \
  --scope \
  -p MemoryLimit=16G \
  -p CPUQuota=200% \
  -p TasksMax=4 \
  /usr/bin/time -v python nb_as_scripts/HiC_workshop_part2.py
```
```
  Command being timed: "python nb_as_scripts/HiC_workshop_part2.py"
  User time (seconds): 3.86
  System time (seconds): 0.78
  Percent of CPU this job got: 87%
  Elapsed (wall clock) time (h:mm:ss or m:ss): 0:05.33
  Average shared text size (kbytes): 0
  Average unshared data size (kbytes): 0
  Average stack size (kbytes): 0
  Average total size (kbytes): 0
  Maximum resident set size (kbytes): 996204
  Average resident set size (kbytes): 0
  Major (requiring I/O) page faults: 0
  Minor (reclaiming a frame) page faults: 324810
  Voluntary context switches: 1815
  Involuntary context switches: 106
  Swaps: 0
  File system inputs: 0
  File system outputs: 2168
  Socket messages sent: 0
  Socket messages received: 0
  Signals delivered: 0
  Page size (bytes): 4096
  Exit status: 0
```

## HiCstuff file handling (part 3)

Initial Data:

  - Outputs from part 1
  - 3 provided cool files (\~ 3x 20 Mb).

Requirements:

- Output space: \~5 Mb (plots)
- Computing power: \~2.5 Gb RAM, 100\% CPU 
- Computing time: 1 min

```sh
# Running the code with harshest resource limits described in the vademecum
OPENBLAS_NUM_THREADS=1 systemd-run \
  --scope \
  -p MemoryLimit=16G \
  -p CPUQuota=200% \
  -p TasksMax=4 \
  /usr/bin/time -v python nb_as_scripts/HiC_workshop_part3.py
```
```
  Command being timed: "python nb_as_scripts/HiC_workshop_part3.py"
  User time (seconds): 48.47
  System time (seconds): 6.65
  Percent of CPU this job got: 99%
  Elapsed (wall clock) time (h:mm:ss or m:ss): 0:55.60
  Average shared text size (kbytes): 0
  Average unshared data size (kbytes): 0
  Average stack size (kbytes): 0
  Average total size (kbytes): 0
  Maximum resident set size (kbytes): 2464920
  Average resident set size (kbytes): 0
  Major (requiring I/O) page faults: 0
  Minor (reclaiming a frame) page faults: 860028
  Voluntary context switches: 985
  Involuntary context switches: 732
  Swaps: 0
  File system inputs: 144
  File system outputs: 9448
  Socket messages sent: 0
  Socket messages received: 0
  Signals delivered: 0
  Page size (bytes): 4096
  Exit status: 0
```


## HiCstuff analysis (part 4)

Initial Data:

  - ( outputs from part 1 )
  - 2 provided cool files (\~ 1x 20 Mb, one was used in part 3)

Requirements:

- Output space: \~15 Mb (plots)
- Computing power: \~3.5 Gb RAM, 100\% CPU 
- Computing time: 10 min \*

\*: The time is super long because I had to set the nb of cores used by serpentine to 1 to have it run. 
This might be because its parallelization handling is incompatible with my resource-limiting command so it might run faster for the workshop.


```sh
# Running the code with harshest resource limits described in the vademecum
OPENBLAS_NUM_THREADS=1 systemd-run \
  --scope \
  -p MemoryLimit=16G \
  -p CPUQuota=200% \
  -p TasksMax=4 \
  /usr/bin/time -v python nb_as_scripts/HiC_workshop_part4.py
```
```
  Command being timed: "python nb_as_scripts/HiC_workshop_part4.py"
  User time (seconds): 553.38
  System time (seconds): 9.87
  Percent of CPU this job got: 99%
  Elapsed (wall clock) time (h:mm:ss or m:ss): 9:24.58
  Average shared text size (kbytes): 0
  Average unshared data size (kbytes): 0
  Average stack size (kbytes): 0
  Average total size (kbytes): 0
  Maximum resident set size (kbytes): 3104604
  Average resident set size (kbytes): 0
  Major (requiring I/O) page faults: 0
  Minor (reclaiming a frame) page faults: 5954984
  Voluntary context switches: 4002
  Involuntary context switches: 7770
  Swaps: 0
  File system inputs: 0
  File system outputs: 25184
  Socket messages sent: 0
  Socket messages received: 0
  Signals delivered: 0
  Page size (bytes): 4096
  Exit status: 0

```


## Google Colab

If installing the conda environment is not possible, the notebooks can be opened in Google colab, 
with provided data download links to fetch the course data.

The first part (`reads_to_hic.sh`) is not set up to work on the Google runtime environment, and will be done by the teacher.
