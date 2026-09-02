# HiC data analysis workshop

This repo contains material for our HiC data analysis workshop, split in 4 (unequal) parts.
Data required for the course is given during the course.


## Install / Setup

All scripts (python/sh) run within a conda environment described in `analysis_mini.yml`.

Running the following should be sufficient to have everything running fine.
```sh
conda env create -n hic_analysis -f analysis_mini.yml
conda activate hic_analysis
```

**If installing the environment is not possible, the notebooks can be opened 
and run through Google Colab, [see below](#Google-Colab).**

The course is designed to require minimal disk space (< 2Gb including inputs) 
& computing power (< 4Gb RAM), it runs fine on a laptop. 
See [doc/Computing_requirements.md](doc/Computing_requirements.md) for details.


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



Notes: 
parasplit MUST use >=5 threads, which might make it unusable in some computer setups.
We can give both raw & parasplitted reads to students and show the first few lines of either to show difference.

Full code in `reads_to_hic.sh` script, to hand as is, or with a few holes to students.


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



## Google Colab

If installing the conda environment is not possible, the notebooks can be opened in Google colab, 
and the data required for the course will be provided through download links.

The first part (`reads_to_hic.sh`) is not set up to work on the Google runtime environment, and will be done by the teacher.

To start, go to (https://colab.research.google.com/github/Piazzalab/hic_analysis_workshop/).
