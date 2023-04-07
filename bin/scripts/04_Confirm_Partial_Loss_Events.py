#! /usr/bin/python
# -*- coding: UTF-8 -*-

from interval import interval
import sys


def extract_multi_blocks_region(filtered_blocks_sets, input_header, input_target_species):
	output_dict = dict()
	for i in range(0, len(filtered_blocks_sets)-1):
		block_info = filtered_blocks_sets[i]
		if input_header in block_info:
			tmp_anchor_gene = block_info.strip('\n').split('>')[1]
			q = 1
			while (i+q < len(filtered_blocks_sets)) and (input_header not in filtered_blocks_sets[i+q]):
				tmp_target_line = filtered_blocks_sets[i + q]
				if input_target_species in tmp_target_line:
					tmp_target_line = tmp_target_line.strip('\n').split('/')
					tmp_chr = tmp_target_line[1]
					tmp_region_str = tmp_target_line[2].split('-')
					tmp_target_region = interval([int(tmp_region_str[0]), int(tmp_region_str[1])])
					if not output_dict.has_key(tmp_anchor_gene):
						output_dict[tmp_anchor_gene] = dict()
						output_dict[tmp_anchor_gene][tmp_chr] = tmp_target_region
					elif output_dict.has_key(tmp_anchor_gene):
						if output_dict[tmp_anchor_gene].has_key(tmp_chr):
							output_dict[tmp_anchor_gene][tmp_chr] = output_dict[tmp_anchor_gene][tmp_chr] | tmp_target_region
						elif not output_dict[tmp_anchor_gene].has_key(tmp_chr):
							output_dict[tmp_anchor_gene][tmp_chr] = tmp_target_region
				q = q+1
			while (i+q >= len(filtered_blocks_sets)) or (input_target_species in filtered_blocks_sets[i+q]):
				break
	return output_dict


def file_readlines(input_path):
	tmp_file = open(input_path, 'r')
	output_readlines = tmp_file.readlines()
	tmp_file.close()
	return output_readlines


def extract_mouse_gene_from_orthologous_cluster(input_line, input_header):
	input_line = input_line.strip('\n').split('\t')
	output = []
	for i in range(0, len(input_line)):
		if input_header in input_line[i]:
			output.append(input_line[i])
	return output


def cal_blocks_length(input_blocks, input_limit_length):
	output = dict()
	for key in input_blocks:
		tmp_region_result = []
		block_anchor = 0
		for i in range(0, len(input_blocks[key]) - 1):
			blocks_gap = input_blocks[key][i+1][0] - input_blocks[key][i][1]
			if blocks_gap >= input_limit_length:
				tmp_interval_used = input_blocks[key][block_anchor:i+1]
				tmp_max = max(tmp_interval_used)[1]
				tmp_min = min(tmp_interval_used)[0]
				tmp_region = interval([tmp_min, tmp_max])
				block_anchor = i+1
				tmp_region_result.append(tmp_region)
		final_region = input_blocks[key][block_anchor : ]
		tmp_max = max(final_region)[1]
		tmp_min = min(final_region)[0]
		tmp_region = interval([tmp_min, tmp_max])
		tmp_region_result.append(tmp_region)
		output[key] = tmp_region_result
	return output


class AnchorGeneRegion:

	def __init__(self, inputline, input_header, input_block_gap_threshold):
		self.target_gene_sets = extract_mouse_gene_from_orthologous_cluster(inputline, input_header)
		self.raw_line = inputline.strip('\n')
		self.gene_target_blocks_sets = dict()
		self.threshold = input_block_gap_threshold

	def get_gene_regions(self, block_sets):
		for gene in self.target_gene_sets:
			if block_sets.has_key(gene):
				tmp_gene_blocks = block_sets[gene]
				self.gene_target_blocks_sets[gene] = cal_blocks_length(tmp_gene_blocks, self.threshold)

	def gene_condition(self):
		if len(self.gene_target_blocks_sets.keys()) > 0:
			return 1

	def output_gene_region(self):
		for gene in self.gene_target_blocks_sets:
			tmp_gene = gene
			for key in self.gene_target_blocks_sets[gene]:
				tmp_chr = key
				tmp_region = self.gene_target_blocks_sets[gene][key]

				if len(tmp_region) == 1:
					output_region = tmp_region[0]
					output_region_str = str(int(output_region[0][0])) + '\t' + str(int(output_region[0][1]))
					tmp_output = tmp_chr + '\t' + output_region_str + '\t' + tmp_gene
					print tmp_output

				elif len(tmp_region) > 1:
					for i in range(0, len(tmp_region)):
						tmp_interval = tmp_region[i]
						output_region_str = str(int(tmp_interval[0][0])) + '\t' + str(int(tmp_interval[0][1]))
						tmp_output = tmp_chr + '\t' + output_region_str + '\t' + tmp_gene + '_region_' +  str(i+1)
						print tmp_output

	def fillter_non_region_candidate(self, block_sets):
		non_sets_counts = 0
		for gene in self.target_gene_sets:
			if not block_sets.has_key(gene):
				non_sets_counts += 1
		if non_sets_counts == len(self.target_gene_sets):
			return self.raw_line + '\n'

	def output_single_anchored_gene(self):
		if len(self.target_gene_sets) == 1:
			self.output_gene_region()


if __name__ == '__main__':

	cluster_path = sys.argv[1]
	alignment_region_path = sys.argv[2]
	input_header = sys.argv[3]
	header_with_start = '>' + input_header
	target_species = '>' + sys.argv[4]
	output_total_loss_candidate_path = sys.argv[5]
	block_max_gap = int(sys.argv[6])

	orthologous_block_sets = extract_multi_blocks_region(file_readlines(alignment_region_path), header_with_start, target_species)
	cluster_sets = file_readlines(cluster_path)

	total_loss_group = []

	for line in cluster_sets:
		gene_cluster = AnchorGeneRegion(line, input_header, block_max_gap)
		gene_cluster.get_gene_regions(orthologous_block_sets)
		if gene_cluster.gene_condition():
			gene_cluster.output_gene_region()
		if gene_cluster.fillter_non_region_candidate(orthologous_block_sets):
			total_loss_group.append(gene_cluster.fillter_non_region_candidate(orthologous_block_sets))
	tmp_f = open(output_total_loss_candidate_path, 'w')
	tmp_f.writelines(total_loss_group)
	tmp_f.close()
