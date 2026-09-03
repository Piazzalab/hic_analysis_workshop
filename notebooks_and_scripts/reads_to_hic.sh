#! /bin/bash
set -euo pipefail

# This script uses parasplit, hicstuff, and cooler to digest and align reads from hic libraries to generate contact matrices.  

## Input parameters ------------------------------------------------------------

thread=4              # number of threads
mode="normal"         # 'parasplit' or 'cutsite' or 'normal' (for no digestion)
enzymes="DpnII,HinfI" # enzymes to digest the reads
quality=20            # alignment quality

fastqdir='/path/to/data/dir'    # path to fastq file directory
genomedir='/path/to/genome/dir' # path to bowtie genome index directory
outputdir='/localtmp/'          # path to pipeline output directory
outdir_digest="${fastqdir}"     # path to store digested reads

SAMP=("AD281_0.02_subsamp_parasplit") #list of sample to run, with suffix in the form specified below:

r1ext=".end1"
r2ext=".end2"
fqext=".fastq.gz"


## Useful functions ------------------------------------------------------------

# Timestamp
ts(){
	echo "[$(date '+%Y-%m-%d %H:%M:%S')]"
}

# Dependency check
check_dependency(){
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: $1 not found. Check dependencies are installed." 2>&1
        exit 1
    fi
}


## Input checks ----------------------------------------------------------------

check_dependency hicstuff
check_dependency cooler
check_dependency parasplit

# Check sample/genome files exist
for sample in "${SAMP[@]}" ; do
	in_r1="${fastqdir}/${sample}${r1ext}${fqext}"
	in_r2="${fastqdir}/${sample}${r2ext}${fqext}"

	[ ! -e "${in_r1}" ] && { echo "Error: file not found '${in_r1}'."; exit 1; }
	[ ! -e "${in_r2}" ] && { echo "Error: file not found '${in_r2}'."; exit 1; }
done

[ ! -d "${genomedir}" ] && { echo "Error: directory not found '${genomedir}'."; exit 1; }
genome=$(basename ${genomedir})

# check mode.
! [ "${mode}" = "parasplit" -o "${mode}" = "cutsite" -o "${mode}" = "normal" ] && { echo "Error: invalid mode '${mode}'."; exit 1; }



## Processing ------------------------------------------------------------------

echo "$(ts) Started reads_to_hic.sh"

# logging parameters
echo "Params:"
for v in mode enzymes quality thread r1ext r2ext fastqdir genomedir outputdir outdir_digest; do
    declare -n vs=$v 
    echo -e "  [${v}]\t ${vs}"
done
echo "Tool versions:"
for t in parasplit hicstuff cooler;do
	echo -e "  [${t} --version]\t $($t --version)"
done

echo "Sample list:"
echo "  ${SAMP[@]}"


# hicstuff version to keep in filenames (sanitized)
hcsver="v$(hicstuff -v)"
hcsver="${hcsver//./}"


mkdir -p ${outputdir} ${outdir_digest}

for sample in "${SAMP[@]}" ; do
	
	echo "$(ts) Started ${sample}."
	
	sdir="${outputdir}/${sample}"
	mkdir -p "${sdir}"

	out_px="${sample}_${genome}_${mode}_q${quality}_${hcsver}"

	# input fq files
	in_r1="${fastqdir}/${sample}${r1ext}${fqext}"
	in_r2="${fastqdir}/${sample}${r2ext}${fqext}"

	if [ "$mode" = "parasplit" ]; then  # digest reads with parasplit

		echo "$(ts)   Digesting reads with parasplit."
		
		para_r1="${outdir_digest}/${sample}_parasplit${r1ext}${fqext}"
		para_r2="${outdir_digest}/${sample}_parasplit${r2ext}${fqext}"

		parasplit \
			--source_forward="${in_r1}" \
			--source_reverse="${in_r2}" \
			--output_forward="${para_r1}" \
			--output_reverse="${para_r2}" \
			--list_enzyme="${enzymes}" \
			--mode="all" --num_threads="${thread}"

		# replace inputs for next steps
		in_r1="${para_r1}"
		in_r2="${para_r2}"

		mode="normal" # set mode to 'normal' for hicstuff
	fi

	
	# align reads on ref genome and generate sparse matrices in fragments or binned in graal (3-columns) format
	echo "$(ts)   Running hicstuff pipeline."		
	hicstuff pipeline \
		--duplicates --distance-law --filter --force --no-cleanup --plot \
		--matfmt=graal  \
		--enzyme="${enzymes}" \
		--mapping="${mode}" \
		--quality-min="${quality}" \
		--threads="${thread}"  \
		--outdir "${sdir}" \
		--genome="${genomedir}/${genome}" \
		"${in_r1}" "${in_r2}"

	
	#rebin the matrix at 1kb in graal format
	echo "$(ts)   Rebinning matrix at 1kb."	
	hicstuff rebin \
		--binning=1kb \
		--force \
		--frags="${sdir}/fragments_list.txt" \
		--chroms="${sdir}/info_contigs.txt" \
		"${sdir}/abs_fragments_contacts_weighted.txt" \
		"${sdir}/${out_px}_1kb"


	# convert the binned graal matrix into cooler format, 
	echo "$(ts)   Converting binned matrix to cooler."
	scdir="${sdir}/Cool"
	mkdir -p "${scdir}"
	hicstuff convert \
		--force \
		--frags="${sdir}/${out_px}_1kb.frags.tsv" \
		--chroms="${sdir}/${out_px}_1kb.chr.tsv" \
		"${sdir}/${out_px}_1kb.mat.tsv" \
		"${scdir}/${out_px}_1kb"

	# ICE-balance it, 
	echo "$(ts)   ICE-balancing matrix."
	cooler balance \
	 	--nproc "${thread}" \
	 	"${scdir}/${out_px}_1kb.cool" &> "${scdir}/cooler_balance.log"


	# zoomify it at 1, 2, 5, 10, 15, and 20kb
	echo "$(ts)   Zoomifying at 1, 2, 5, 10, 15, and 20kb."
	cooler zoomify \
            --balance \
            --nproc "${thread}" \
            --resolutions 1000,2000,5000,10000,15000,20000 \
            --out "${scdir}/${out_px}.mcool" \
            "${scdir}/${out_px}_1kb.cool" &> "${scdir}/cooler_zoomify.log"
done

echo "$(ts) Done."

