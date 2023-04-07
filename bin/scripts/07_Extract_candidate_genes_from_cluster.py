#! /usr/bin/python
# -*- coding: UTF-8 -*-

import sys

def file_readlines(input_path):
	tmp_file = open(input_path, 'r')
	output_readlines = tmp_file.readlines()
	tmp_file.close()
	return output_readlines

def get_all_anchor(input_orthologous_relation, candidates_path, header):
	all_datas = file_readlines(input_orthologous_relation)
	candidates_datas = file_readlines(candidates_path)
	dict_for_coors = dict()
	for line in all_datas:
		line = line.strip('\n').split('\t')
		genes = line[0]
		locations = "\t".join(line[0:4])
		dict_for_coors[genes] = locations
	for candidate in candidates_datas:
		candidate = candidate.strip('\n').split('\t')
		for gene in candidate:
			if header == gene.split('0')[0]:
				tmp_outs = dict_for_coors[gene]
				print tmp_outs


if __name__ == "__main__":
	# candidates_path = '../result/03_loss_candidates_group'
	candidates_path = sys.argv[1]
	genes_corr_path = sys.argv[2]
	# genes_corr_path = '../data/solid_orthologous_relation'
	input_header = sys.argv[3]
	get_all_anchor(genes_corr_path, candidates_path, input_header)
