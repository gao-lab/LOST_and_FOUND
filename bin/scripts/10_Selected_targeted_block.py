#! /usr/bin/python
import sys

def confirm_target_blocks(input_list, target_species):
	indicator = 'False'
	for block_line in input_list:
		if target_species in block_line:
			indicator = 'True'
	return indicator

def output_function(input_list):
	for gene in input_list:
		print gene.strip('\n')

def selected_all_blocks(input_all_sets, AnchorHeader, TargetSpecies):
	tmp_line = []
	start_line = 'True'
	for line in input_all_sets:
		if AnchorHeader in line:
			if start_line == 'False':
				tmp_indicate = confirm_target_blocks(tmp_line, TargetSpecies)
				if tmp_indicate == 'True':
					output_function(tmp_line)
				tmp_line = []
				tmp_line.append(line)
			elif start_line == 'True':
				tmp_line.append(line)
				start_line = 'False'
		if AnchorHeader not in line:
			tmp_line.append(line)

def file_readlines(input_path):
	tmp_file = open(input_path, 'r')
	output_readlines = tmp_file.readlines()
	tmp_file.close()
	return output_readlines


if __name__ == "__main__":
	tmp_file = sys.argv[1]
	anchor_ID = sys.argv[2]
	target_species_names = sys.argv[3]
	selected_all_blocks(file_readlines(tmp_file), anchor_ID, target_species_names)