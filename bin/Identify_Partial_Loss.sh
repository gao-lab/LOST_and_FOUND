#!/usr/bin/env bash

# input parameter set
parameters=$(getopt -o l:a:s:g:o:t: \
-l LossCandidate:,AnchorHeader:,TargetSpecies:,GenomeAlignment:,OutputPath:,RegionThreshold: \
-n "$0" -- "$@")


if [ $? != 0 ]
then
	echo "Terminating....." >&2
	exit 1
fi

eval set -- "$parameters"

while true ; do
    case "$1" in
        -l|--LossCandidate)loss_candidates=$2 ;shift 2;;
        -a|--AnchorHeader)anchor_species_gene_header_2_trace=$2 ;shift 2;;
        -s|--TargetSpecies)target_species_name_in_geneome_alignment=$2 ;shift 2;;
        -g|--GenomeAlignment)alignment_data_path=$2 ;shift 2;;
        -o|--OutputPath)output_path=$2 ;shift 2;;
        -t|--RegionThreshold)region_merge_threshold=$2 ;shift 2;;
        --) break ;;
        *) echo "wrong";exit 1;;
    esac
done


#anchor_species_gene_header_2_trace="ENSMUSG"
#target_species_name_in_geneome_alignment="homo_sapiens"
#alignment_data_path='../example/data/GenomeAlignment/Blocks_for_Loss_candidates_HUMAN'
#region_merge_threshold=500000
#output_path='../example/result/'

# trace partial loss region and select total loss candidate
python ./scripts/04_Confirm_Partial_Loss_Events.py \
        $loss_candidates \
        $alignment_data_path \
        $anchor_species_gene_header_2_trace \
        $target_species_name_in_geneome_alignment \
        "$output_path"Orthologous_group_candidate_for_Complete_Loss \
        $region_merge_threshold \
        > "$output_path"Partial_Loss_Events

echo "$(cat "$output_path"Partial_Loss_Events |wc -l)" ' Partial Loss Events have been found'



