#!/usr/bin/env bash

parameters=$(getopt -o h:u:a:m:s:i:l:r:o: \
-l Host:,User:,AnchorSpecies:,MethodLinkType:,SpeciesSetName:,AnchorIDHeader:,LossCandidate:,OrthologousPath:,OutputPath: \
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
        -m|--MethodLinkType)Method_Link_Type=$2 ;shift 2;;
        -s|--SpeciesSetName)Species_SetName=$2 ;shift 2;;
        -i|--AnchorIDHeader)AnchorID_Header=$2 ;shift 2;;
        -l|--LossCandidate)Loss_Candidate=$2 ;shift 2;;
        -r|--OrthologousPath)raw_orthologous_relation_path=$2 ;shift 2;;
        -o|--OutputPath)Output_Path=$2 ;shift 2;;
        --) break ;;
        *) echo "wrong";exit 1;;
    esac
done

cat "$raw_orthologous_relation_path"* > "$raw_orthologous_relation_path"../all_orthologous_relation
grep '_one2one' "$raw_orthologous_relation_path"../all_orthologous_relation > "$raw_orthologous_relation_path"../all_one2one_relation
grep '2many' "$raw_orthologous_relation_path"../all_orthologous_relation | awk '$10+$11 > 110 {print $0}' > "$raw_orthologous_relation_path"../all_relation_2many
cat  "$raw_orthologous_relation_path"../all_one2one_relation "$raw_orthologous_relation_path"../all_relation_2many > "$raw_orthologous_relation_path"../solid_orthologous_relation

python ./scripts/07_Extract_candidate_genes_from_cluster.py \
$Loss_Candidate "$raw_orthologous_relation_path"../solid_orthologous_relation $AnchorID_Header \
> "$Output_Path"tmp_loss_candidates_gene_ID

rm -f "$raw_orthologous_relation_path"../all_orthologous_relation
rm -f "$raw_orthologous_relation_path"../all_one2one_relation
rm -f "$raw_orthologous_relation_path"../all_relation_2many

if [ ! -d "$Output_Path" ]; then
  mkdir "$Output_Path"
fi

if [ -f "$Output_Path"Genome_Alignment_for_orthologous_loss_candidates ]; then
    rm -f "$Output_Path"Genome_Alignment_for_orthologous_loss_candidates
fi

while read LINE
do
  echo $LINE | perl ./scripts/08_Get_alignment_blocks_for_loss_candidates.pl $Ensembl_Host $Ensembl_User \
  $Anchor_Species $Method_Link_Type $Species_SetName \
  >> "$Output_Path"Genome_Alignment_for_orthologous_loss_candidates
done < "$Output_Path"tmp_loss_candidates_gene_ID

rm -f "$Output_Path"tmp_loss_candidates_gene_ID
rm -f "$raw_orthologous_relation_path"../solid_orthologous_relation