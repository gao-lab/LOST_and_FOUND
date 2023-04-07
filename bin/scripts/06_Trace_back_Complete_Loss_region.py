#! /usr/bin/python

import sys

def recall_human_line(input_line):
	human_cor_1 = float(input_line.strip('\n').split('/')[2].split('-')[0])
	human_cor_2 = float(input_line.strip('\n').split('/')[2].split('-')[1])
	return human_cor_1, human_cor_2


def extract_one_block(input_block, target_species):
	gene_names = input_block[0].strip('\n').split('>')[1].split(' ')[0]
	gene_state = input_block[0].strip('\n').split('>')[1].split(' ')[1].split('_')[0]
	for i in range(0, len(input_block)):
		if target_species in input_block[i]:
			human_chr = input_block[i].strip('\n').split('/')[1]
			human_cor_start, human_cor_end = recall_human_line(input_block[i])
			human_cor = [human_cor_start, human_cor_end]
			break
	return gene_names, human_chr, human_cor


def extract_all_genes(input_all_datas, target_species, anchor_header):
	line_nums = 0
	output_genes = dict()
	output_chr = dict()
	tmp_block = []
	for line in input_all_datas:
		if anchor_header in line:
			if line_nums == 0:
				tmp_block.append(line)
			elif line_nums > 0:
				tmp_gene, human_chr, human_cor = extract_one_block(tmp_block, target_species)
				output_genes[tmp_gene] = output_genes.get(tmp_gene, [])
				output_genes[tmp_gene] += human_cor
				output_chr[tmp_gene] = output_chr.get(tmp_gene, [])
				output_chr[tmp_gene].append(human_chr)
				tmp_block = []
				tmp_block.append(line)
		elif anchor_header not in line:
			tmp_block.append(line)
		line_nums += 1
	return output_genes, output_chr


def extract_true_total_loss(input_list):
	output = []
	for line in input_list:
		line = line.strip('\n')
		output.append(line)
	return output

def output_human_cor(input_list):
	input_list.sort()
	if len(input_list) != 4:
		print('ERROR Cor')
	output_line = str(int(input_list[1])) + '\t' + str(int(input_list[2]))
	return output_line

def output_cor(input_target_gene, input_chr_dict, input_cor):
	for gene in input_target_gene:
		tmp_output = gene + '\t'
		tmp_output += input_chr_dict[gene][0] + '\t'
		tmp_output += output_human_cor(input_cor[gene])
		print tmp_output

def file_readlines(input_path):
	tmp_file = open(input_path, 'r')
	output_readlines = tmp_file.readlines()
	tmp_file.close()
	return output_readlines


if __name__ == '__main__':
	true_loss_path = sys.argv[1]
	gene_data_path = sys.argv[2]
	target_species = sys.argv[3]
	anchor_header = sys.argv[4]
	genes, chrs = extract_all_genes(file_readlines(gene_data_path), target_species, anchor_header)
	final_loss = extract_true_total_loss(file_readlines(true_loss_path))
	output_cor(final_loss, chrs, genes)