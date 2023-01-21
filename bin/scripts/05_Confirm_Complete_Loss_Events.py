#! /usr/bin/python

import sys

def extract_block_up_links(input_block, target_species):
	gene_names = input_block[0].strip('\n').split('>')[1].split(' ')[0]
	mouse_cor = float(input_block[0].strip('\n').split('/')[2].split('-')[0])
	for i in range(0, len(input_block)):
		if target_species in input_block[i]:
			human_cor_1 = float(input_block[i].strip('\n').split('/')[2].split('-')[0])
			human_cor_2 = float(input_block[i].strip('\n').split('/')[2].split('-')[1])
			if human_cor_1 <= human_cor_2:
				human_direction = '+'
			elif human_cor_1 > human_cor_2:
				human_direction = '-'
			human_chr = input_block[i].strip('\n').split('/')[1]
			break
	return gene_names, mouse_cor, human_chr, human_direction, human_cor_1, human_cor_2

def extract_all_genes(input_all_datas, target_species, anchor_header):
	line_nums = 0
	output_genes = dict()
	output_chr = dict()
	output_symbol = dict()
	tmp_block = []
	for line in input_all_datas:
		if anchor_header in line:
			if line_nums == 0:
				tmp_block.append(line)
			elif line_nums > 0:
				tmp_gene, mouse_start, human_chr, human_direction, human_start, human_end = extract_block_up_links(tmp_block, target_species)
				output_genes[tmp_gene] = output_genes.get(tmp_gene, dict())
				output_genes[tmp_gene][mouse_start] = [human_start, human_end]
				output_chr[tmp_gene] = output_chr.get(tmp_gene, [])
				output_chr[tmp_gene].append(human_chr)
				output_symbol[tmp_gene] = output_symbol.get(tmp_gene, [])
				output_symbol[tmp_gene].append(human_direction)
				tmp_block = []
				tmp_block.append(line)
		elif anchor_header not in line:
			tmp_block.append(line)
		line_nums += 1
	return output_genes, output_chr, output_symbol

def compare_chr(input_genes):
	chr_indicate = 'True'
	tmp_anchor = input_genes[0]
	for tmp_chr in input_genes:
		if tmp_chr != tmp_anchor:
			chr_indicate = 'False'
	return chr_indicate

def compare_one_genes(input_block, input_symbol):
	output_indicator = ''
	symbol_count = 0
	tmp_symbol = input_symbol[0]
	for i in range(0, len(input_symbol)):
		current_symbol = input_symbol[i]
		if current_symbol == tmp_symbol:
			symbol_count += 1
	# print symbol_count
	if symbol_count == len(input_symbol):
		mouse_list = list(input_block.keys())
		mouse_list.sort()
		direction_count = 0
		for i in range(0, len(mouse_list)-1):
			current_mouse = mouse_list[i]
			next_mouse = mouse_list[i+1]
			if tmp_symbol == '+':
				current_human = input_block[current_mouse][0]
				next_human = input_block[next_mouse][0]
				if next_human > current_human:
					direction_count += 1
			elif tmp_symbol == '-':
				current_human = input_block[current_mouse][1]
				next_human = input_block[next_mouse][1]
				# print next_human
				if next_human <= current_human:
					direction_count += 1
		# print direction_count
		if direction_count == 3:
			output_indicator = 'True'
	return output_indicator


def count_all_blocks(all_data_dict, chr_dict, gene_symbol):
	for gene in all_data_dict:
		tmp_gene_dict = all_data_dict[gene]
		gene_syms = gene_symbol[gene]
		same_relation = compare_one_genes(tmp_gene_dict, gene_syms)
		tmp_chr_dict = chr_dict[gene]
		same_chr = compare_chr(tmp_chr_dict)
		# print same_relation
		if (same_relation == 'True') and (same_chr == 'True'):
			print(gene)

def file_readlines(input_path):
	tmp_file = open(input_path, 'r')
	output_readlines = tmp_file.readlines()
	tmp_file.close()
	return output_readlines


if __name__ == "__main__":
	data_path = sys.argv[1]
	target_species = sys.argv[2]
	anchor_header = sys.argv[3]
	all_gene, all_chr, all_sym = extract_all_genes(file_readlines(data_path), target_species, anchor_header)
	count_all_blocks(all_gene, all_chr, all_sym)