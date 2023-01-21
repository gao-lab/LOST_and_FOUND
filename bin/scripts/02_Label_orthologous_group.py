#! /usr/bin/python

import sys

def count_exist(input_num):
	if len(input_num) > 0:
		return 1
	elif len(input_num) == 0:
		return 0

def vector_generate(input_list, input_dict, anchor_lists):
	anchor_exist_count = 0
	gene_num = []
	gene_exist = []
	gene_name = []
	for key in input_dict.keys():
		gene_name.append(key)
		gene_header = input_dict[key]
		tmp_gene_list = []
		for gene in input_list:
			cur_gene_header = gene.split('0')[0]
			if gene_header == cur_gene_header:
				tmp_gene_list.append(gene)
		gene_num.append(len(tmp_gene_list))
		gene_exist.append(count_exist(tmp_gene_list))
	for species in anchor_lists:
		tmp_index = gene_name.index(species)
		tmp_exist = gene_exist[tmp_index]
		if tmp_exist == 1:
			anchor_exist_count += 1
	Tmp_Num = 'Num'
	Tmp_Exi = 'Exist'
	for i in range(0, len(gene_name)):
		Tmp_Num += '_' + gene_name[i] + '_' + str(gene_num[i])
		Tmp_Exi += '_' + gene_name[i] + '_' + str(gene_exist[i])
	return Tmp_Num, Tmp_Exi, anchor_exist_count


def main_func(input_path, gene_header_dict, anchor_lists):
	data_f = open(input_path, 'r')
	data_use = data_f.readlines()
	data_f.close()

	for line in data_use:
		line_use = line.strip('\n').split('\t')
		cluster_num, cluster_exist, exist_count = vector_generate(line_use, gene_header_dict, anchor_lists)
		tmp_output = cluster_exist + '\t' + cluster_num
		for q in range(1, len(line_use)):
			tmp_output += '\t' + line_use[q]
		if exist_count == len(anchor_lists):
			print(tmp_output)


if __name__ == "__main__":

	input_path = sys.argv[1]
	gene_dict = sys.argv[2]
	gene_dict = eval(gene_dict)
	anchor_species = eval(sys.argv[3])
	main_func(input_path, gene_dict, anchor_species)
