#!/usr/bin/env bash

# input parameter set
parameters=$(getopt -o p:c:g:o: \
-l PartialLoss:,CompleteLoss:,AssemblyGap:,OutputPath: \
-n "$0" -- "$@")


if [ $? != 0 ]
then
	echo "Terminating....." >&2
	exit 1
fi

eval set -- "$parameters"

while true ; do
    case "$1" in
        -p|--PartialLoss)partial_loss=$2 ;shift 2;;
        -c|--CompleteLoss)complete_loss=$2 ;shift 2;;
        -g|--AssemblyGap)assembly_gap=$2 ;shift 2;;
        -o|--OutputPath)output_path=$2 ;shift 2;;
        --) break ;;
        *) echo "wrong";exit 1;;
    esac
done


if [ ! -d "$output_path" ]; then
  mkdir "$output_path"
fi

sort -k1,1 -k2,2n $assembly_gap > "$assembly_gap".sorted
sort -k1,1 -k2,2n $partial_loss > "$partial_loss".sorted
awk '{print $2 "\t" $3 "\t" $4 "\t" $1}' $complete_loss | sort -k1,1 -k2,2n > "$complete_loss".sorted

bedtools intersect -a "$partial_loss".sorted -b "$assembly_gap".sorted -wao -sorted > $output_path"Partial_Loss_intersect_Gap"
bedtools intersect -a "$complete_loss".sorted -b "$assembly_gap".sorted -wao -sorted > $output_path"Complete_Loss_intersect_Gap"

rm -f "$assembly_gap".sorted
rm -f "$partial_loss".sorted
rm -f "$complete_loss".sorted

awk '$5=="." {print $0}' $output_path"Partial_Loss_intersect_Gap" | cut -f 1-4 > $output_path"Partial_Loss_Events_without_gap"
awk '$5=="." {print $0}' $output_path"Complete_Loss_intersect_Gap" | cut -f 1-4 > $output_path"Complete_Loss_Events_without_gap"

rm -f $output_path"Partial_Loss_intersect_Gap"
rm -f $output_path"Complete_Loss_intersect_Gap"





