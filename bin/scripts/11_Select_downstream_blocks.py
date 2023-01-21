#! /usr/bin/python
import sys

def extract_header(input_line):
	gene_name = input_line.strip('\n').split('>')[1].split(' ')[0]
	gene_anchor = float(input_line.strip('\n').split('/')[2].split('-')[0])
	return gene_name, gene_anchor

def get_all_block_data(input_all_file, anchor_header):
	line_nums = 0
	all_data = dict()
	tmp_block = []
	for line in input_all_file:
		if anchor_header in line:
			if line_nums == 0:
				tmp_block.append(line)
			elif line_nums > 0:
				tmp_gene, tmp_anchor = extract_header(tmp_block[0])
				all_data[tmp_gene] = all_data.get(tmp_gene, dict())
				all_data[tmp_gene][tmp_anchor] = tmp_block
				tmp_block = []
				tmp_block.append(line)
		elif anchor_header not in line:
			tmp_block.append(line)
		line_nums += 1
	return all_data

def output_function(input_list):
	for gene in input_list:
		print gene.strip('\n')

def output_closest_2_blocks(all_blocks_data, counted_blocks):
	for gene in all_blocks_data:
		tmp_genes_blocks = all_blocks_data[gene]
		tmp_genes_list = list(tmp_genes_blocks.keys())
		tmp_genes_list.sort()
		all_indexs = range(0, counted_blocks)
		for index_used in all_indexs:
			try:
				output_function(tmp_genes_blocks[tmp_genes_list[index_used]])
			except IndexError:
				pass

def file_readlines(input_path):
	tmp_file = open(input_path, 'r')
	output_readlines = tmp_file.readlines()
	tmp_file.close()
	return output_readlines


if __name__ == "__main__":
	file_path = sys.argv[1]
	ID_header = sys.argv[2]
	all_data_dict = get_all_block_data(file_readlines(file_path), ID_header)
	counted_of_blocks = int(sys.argv[3])
	output_closest_2_blocks(all_data_dict, counted_of_blocks)