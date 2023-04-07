#!/usr/bin/env bash

# input parameter set

parameters=$(getopt -o r:i:s:t:n:o: \
-l OrthologousPath:,IDheader:,AnchorSpeciesSet:,TargetTree:,TargetSpecies:,OutputPath: \
-n "$0" -- "$@")


if [ $? != 0 ]
then
	echo "Terminating....." >&2
	exit 1
fi

eval set -- "$parameters"

while true ; do
    case "$1" in
        -r|--OrthologousPath)raw_orthologous_relation_path=$2 ;shift 2;;
        -i|--IDheader)gene_header_dict=$2 ;shift 2;;
        -s|--AnchorSpeciesSet)anchor_species=$2 ;shift 2;;
        -t|--TargetTree)target_trees=$2 ;shift 2;;
        -n|--TargetSpecies)target_species=$2 ;shift 2;;
        -o|--OutputPath)output_path=$2 ;shift 2;;
        --) break ;;
        *) echo "wrong";exit 1;;
    esac
done

# path of orthologous relation
# raw_orthologous_relation_path='../example/data/OrtholougousRelation/'

# species name and their gene id header in str format with python dict type written way
# gene_header_dict='{"Mou":"ENSMUSG","Rat":"ENSRNOG","Ryukyu":"MGP_CARO","Shrew":"MGP_Paha","Hum":"ENSG0","Chimp":"ENSPTRG","Mac":"ENSMMUG","Gor":"ENSGGOG"}'

# anchor species for gene loss detection in str format with python list type written
#anchor_species='["Mou","Rat","Ryukyu","Shrew"]'

# target species sets gene tree in str format with python list type written
#target_trees='[[["Chimp","Hum"],"Gor"],"Mac"]'
# target species for loss detection
#target_species="Hum"

# path for output
#output_path='../example/result/'

# filter_orthologous_relation

echo 'Filtering orthologous relation...'

cat "$raw_orthologous_relation_path"* > "$raw_orthologous_relation_path"../all_orthologous_relation
grep '_one2one' "$raw_orthologous_relation_path"../all_orthologous_relation > "$raw_orthologous_relation_path"../all_one2one_relation
grep '2many' "$raw_orthologous_relation_path"../all_orthologous_relation | awk '$10+$11 > 110 {print $0}' > "$raw_orthologous_relation_path"../all_relation_2many
cat  "$raw_orthologous_relation_path"../all_one2one_relation "$raw_orthologous_relation_path"../all_relation_2many > "$raw_orthologous_relation_path"../solid_orthologous_relation

echo 'Filter process finished:'
echo "$(cat "$raw_orthologous_relation_path"../solid_orthologous_relation | wc -l)" ' reliable orthologous relation remained'

rm -f "$raw_orthologous_relation_path"../all_orthologous_relation
rm -f "$raw_orthologous_relation_path"../all_one2one_relation
rm -f "$raw_orthologous_relation_path"../all_relation_2many

if [ ! -d "$output_path" ]; then
  mkdir "$output_path"
fi

# cluster orthologous relation

echo 'Clustering orthologous into orthologous groups...'
python ./scripts/01_Cluster_orthologous_genes.py  "$raw_orthologous_relation_path"../solid_orthologous_relation > "$output_path"01_raw_orthologous_groups

echo 'Generate ' "$(cat "$output_path"01_raw_orthologous_groups | wc -l)" ' orthologous groups'

# label orthologous groups

python ./scripts/02_Label_orthologous_group.py "$output_path"01_raw_orthologous_groups $gene_header_dict $anchor_species > "$output_path"02_selected_orthologous_groups_with_vectors

echo 'Tracing back orthologous groups state...'

# detecting orthologous groups loss candidate
python ./scripts/03_Identify_loss_candidates_based_on_maximum_parsimony.py "$output_path"02_selected_orthologous_groups_with_vectors $target_species $target_trees > "$output_path"Loss_candidates_of_orthologous_group

echo "$(cat "$output_path"Loss_candidates_of_orthologous_group | wc -l)" ' orthologous groups are classified as loss candidates'

rm -f "$output_path"01_raw_orthologous_groups
rm -f "$output_path"02_selected_orthologous_groups_with_vectors
rm -f "$raw_orthologous_relation_path"../solid_orthologous_relation

