#!/usr/bin/env bash

# input parameter set
parameters=$(getopt -o a:s:g:n:o: \
-l AnchorHeader:,TargetSpecies:,GenomeAlignment:,NearestBlocksAlignment:,OutputPath: \
-n "$0" -- "$@")


if [ $? != 0 ]
then
	echo "Terminating....." >&2
	exit 1
fi

eval set -- "$parameters"

while true ; do
    case "$1" in
        -a|--AnchorHeader)anchor_header=$2 ;shift 2;;
        -s|--TargetSpecies)target_species=$2 ;shift 2;;
        -g|--GenomeAlignment)genome_alignment_blocks_data_with_up_and_down=$2 ;shift 2;;
        -n|--NearestBlocksAlignment)genome_alignment_blocks_with_nearest_block=$2 ;shift 2;;
        -o|--OutputPath)output_path=$2 ;shift 2;;
        --) break ;;
        *) echo "wrong";exit 1;;
    esac
done


# input parameter
#target_species='homo_sapiens'
#anchor_header='ENSMUSG'
#
#genome_alignment_blocks_data_with_up_and_down='../example/data/GenomeAlignment/Alignment_blocks_for_Complete_Loss_HUMAN'
#genome_alignment_blocks_with_nearest_block='../example/data/GenomeAlignment/Alignment_blosks_for_tracing_Complete_Loss_region_HUMAN'
#output_path='../example/result/'

python ./scripts/05_Confirm_Complete_Loss_Events.py $genome_alignment_blocks_data_with_up_and_down \
    $target_species $anchor_header > "$output_path"Complete_Loss_Events

echo "$(cat "$output_path"Complete_Loss_Events |wc -l)" ' Complete Loss Events have been found'

python ./scripts/06_Trace_back_Complete_Loss_region.py "$output_path"Complete_Loss_Events $genome_alignment_blocks_with_nearest_block \
    $target_species $anchor_header > "$output_path"Complete_Loss_synteny_region

