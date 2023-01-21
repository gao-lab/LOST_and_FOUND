#!/usr/bin/env bash

parameters=$(getopt -o h:u:a:t:m:s:i:l:r:o:e: \
-l Host:,User:,AnchorSpecies:,TargetSpecies:,MethodLinkType:,SpeciesSetName:,AnchorIDHeader:,CompleteLossCandidate:,OrthologousPath:,OutputPath:,ExtendLength: \
-n "$0" -- "$@")


if [ $? != 0 ]
then
	echo "Terminating....." >&2
	exit 1
fi

eval set -- "$parameters"

while true ; do
    case "$1" in
        -h|--Host)Ensembl_Host=$2 ;shift 2;;
        -u|--User)Ensembl_User=$2 ;shift 2;;
        -a|--AnchorSpecies)Anchor_Species=$2 ;shift 2;;
        -t|--TargetSpecies)targetSpeciesnames=$2 ;shift 2;;
        -m|--MethodLinkType)Method_Link_Type=$2 ;shift 2;;
        -s|--SpeciesSetName)Species_SetName=$2 ;shift 2;;
        -i|--AnchorIDHeader)AnchorID_Header=$2 ;shift 2;;
        -l|--CompleteLossCandidate)Loss_Candidate=$2 ;shift 2;;
        -r|--OrthologousPath)raw_orthologous_relation_path=$2 ;shift 2;;
        -o|--OutputPath)Output_Path=$2 ;shift 2;;
        -e|--ExtendLength)Length_extend=$2 ;shift 2;;
        --) break ;;
        *) echo "wrong";exit 1;;
    esac
done

#Length_extend=1000000
#targetSpeciesnames='homo_sapiens'

cat "$raw_orthologous_relation_path"* > "$raw_orthologous_relation_path"../all_orthologous_relation
grep '_one2one' "$raw_orthologous_relation_path"../all_orthologous_relation > "$raw_orthologous_relation_path"../all_one2one_relation
grep '2many' "$raw_orthologous_relation_path"../all_orthologous_relation | awk '$10+$11 > 110 {print $0}' > "$raw_orthologous_relation_path"../all_relation_2many
cat  "$raw_orthologous_relation_path"../all_one2one_relation "$raw_orthologous_relation_path"../all_relation_2many > "$raw_orthologous_relation_path"../solid_orthologous_relation


python ./scripts/07_Extract_candidate_genes_from_cluster.py \
$Loss_Candidate "$raw_orthologous_relation_path"../solid_orthologous_relation $AnchorID_Header \
> "$Output_Path"tmp_complete_loss_candidates

if [ -f "$Output_Path"Raw_alignment_for_Complete_Loss_Up ]; then
    rm -f "$Output_Path"Raw_alignment_for_Complete_Loss_Up
fi

if [ -f "$Output_Path"Raw_alignment_for_Complete_Loss_Down ]; then
    rm -f "$Output_Path"Raw_alignment_for_Complete_Loss_Down
fi


while read LINE
do
  echo $LINE | perl ./scripts/09_Get_Complete_Loss_upstream_blocks.pl \
  $Ensembl_Host $Ensembl_User $Anchor_Species $Method_Link_Type $Species_SetName $Length_extend >> "$Output_Path"Raw_alignment_for_Complete_Loss_Up
  echo $LINE | perl ./scripts/09_Get_Complete_Loss_downstream_blocks.pl \
  $Ensembl_Host $Ensembl_User $Anchor_Species $Method_Link_Type $Species_SetName $Length_extend >> "$Output_Path"Raw_alignment_for_Complete_Loss_Down
done < "$Output_Path"tmp_complete_loss_candidates

rm -f "$Output_Path"tmp_loss_candidates_gene_ID
rm -f "$raw_orthologous_relation_path"../solid_orthologous_relation $AnchorID_Header

python ./scripts/10_Selected_targeted_block.py "$Output_Path"Raw_alignment_for_Complete_Loss_Up $AnchorID_Header $targetSpeciesnames > "$Output_Path"Targeted_alignment_for_Complete_Loss_Up
python ./scripts/10_Selected_targeted_block.py "$Output_Path"Raw_alignment_for_Complete_Loss_Down $AnchorID_Header $targetSpeciesnames > "$Output_Path"Targeted_alignment_for_Complete_Loss_Down

rm -f "$Output_Path"Raw_alignment_for_Complete_Loss_Up
rm -f "$Output_Path"Raw_alignment_for_Complete_Loss_Down

python ./scripts/11_Select_upstream_blocks.py "$Output_Path"Targeted_alignment_for_Complete_Loss_Up $AnchorID_Header 2 > "$Output_Path"GenomeAlignment_for_Complete_Loss_synteny_UpStream
python ./scripts/11_Select_downstream_blocks.py "$Output_Path"Targeted_alignment_for_Complete_Loss_Down $AnchorID_Header 2 > "$Output_Path"GenomeAlignment_for_Complete_Loss_synteny_DownStream

cat "$Output_Path"GenomeAlignment_for_Complete_Loss_synteny_UpStream "$Output_Path"GenomeAlignment_for_Complete_Loss_synteny_DownStream | grep -e $AnchorID_Header -e $targetSpeciesnames > "$Output_Path"Blocks_for_Complete_Loss

python ./scripts/11_Select_upstream_blocks.py "$Output_Path"Targeted_alignment_for_Complete_Loss_Up $AnchorID_Header 1 > "$Output_Path"GenomeAlignment_for_Complete_Loss_corr_UpStream
python ./scripts/11_Select_downstream_blocks.py "$Output_Path"Targeted_alignment_for_Complete_Loss_Down $AnchorID_Header 1 > "$Output_Path"GenomeAlignment_for_Complete_Loss_corr_DownStream

cat "$Output_Path"GenomeAlignment_for_Complete_Loss_corr_UpStream "$Output_Path"GenomeAlignment_for_Complete_Loss_corr_DownStream | grep -e $AnchorID_Header -e $targetSpeciesnames > "$Output_Path"Blosks_for_tracing_Complete_Loss_region

rm -f "$Output_Path"Targeted_alignment_for_Complete_Loss_Up
rm -f "$Output_Path"Targeted_alignment_for_Complete_Loss_Down
rm -f "$Output_Path"GenomeAlignment_for_Complete_Loss_corr_UpStream
rm -f "$Output_Path"GenomeAlignment_for_Complete_Loss_corr_DownStream
rm -f "$Output_Path"GenomeAlignment_for_Complete_Loss_synteny_DownStream
rm -f "$Output_Path"GenomeAlignment_for_Complete_Loss_synteny_UpStream
rm -f "$raw_orthologous_relation_path"../solid_orthologous_relation