#! /usr/bin/python

import sys

def build_tree(input_left_node, input_right_node):
	output = ['', [input_left_node, input_right_node]]
	return output


def trans_input_target_tree_2_format(input_tree, output_tree_node):
	if type(input_tree) == list:
		left_tree = input_tree[0]
		right_tree = input_tree[1]

		if (type(left_tree) == str) and (type(right_tree) == str):
			output_tree_node = build_tree(left_tree, right_tree)

		if (type(left_tree) == list) and (type(right_tree) == str):
			output_tree_node = build_tree(trans_input_target_tree_2_format(left_tree, output_tree_node), right_tree)

		if (type(right_tree) == list) and (type(left_tree) == str):
			output_tree_node = build_tree(left_tree, trans_input_target_tree_2_format(right_tree, output_tree_node))

		if (type(left_tree) == list) and (type(right_tree) == list):
			output_tree_node = build_tree(trans_input_target_tree_2_format(left_tree, output_tree_node), trans_input_target_tree_2_format(right_tree, output_tree_node))

	return output_tree_node


def merge_per_value(input_value_1, input_value_2):
	if input_value_1 == input_value_2:
		output_value = input_value_1
	if input_value_1 != input_value_2:
		if (input_value_1 != 0.5) and (input_value_2 != 0.5):
			output_value = 0.5
		if (input_value_1 == 0.5) and (input_value_2 != 0.5):
			output_value = input_value_2
		if (input_value_1 != 0.5) and (input_value_2 == 0.5):
			output_value = input_value_1
	return output_value


def check_exsit(input_var):
	try:
		input_var
		var_exist = True
	except NameError:
		var_exist = False
	return var_exist


def get_speices_node(input_tree, node_name):

	if type(input_tree) == list:

		left = input_tree[1][0]
		right = input_tree[1][1]

		if (type(right) == str) and (type(left) == str):
			node_name.append(right)
			node_name.append(left)

		if (type(left) == str) and (type(right) == list):
			node_name.append(left)
			node_name = get_speices_node(right, node_name)

		if (type(left) == list) and (type(right) == str):
			node_name.append(right)
			node_name = get_speices_node(left, node_name)

		if (type(right) ==list) and (type(left) == list):
			node_name = get_speices_node(left, node_name)
			node_name = get_speices_node(right, node_name)

	return node_name


def file_readlines(input_path):
	tmp_file = open(input_path, 'r')
	output_readlines = tmp_file.readlines()
	tmp_file.close()
	return output_readlines


def get_species_signal(target_species, input_species):
	if target_species == input_species:
		out_sig = True
	if target_species != input_species:
		out_sig = False
	return out_sig

def trace_back_node(input_species_tree, input_vector, target_species, input_signal, target_path, target_event):

	input_vector_1 = input_vector.split('_')
	tmp_species_state = dict()
	for i in range(1, len(input_vector_1), 2):
		tmp_species_state[input_vector_1[i]] = int(input_vector_1[i + 1])

	left_tree = input_species_tree[1][0]
	right_tree = input_species_tree[1][1]

	if (type(left_tree) == list) and (type(right_tree) == list):

		left_tree_value, left_node, left_signal, target_path, target_event = trace_back_node(left_tree, input_vector, target_species, input_signal, target_path, target_event)
		left_tree[0] = left_tree_value
		if left_signal == True:
			target_path.append("-".join(get_speices_node(left_tree, [])))
			target_event.append(left_tree_value)

		right_tree_value, right_node, right_tree_signal, target_path, target_event = trace_back_node(right_tree, input_vector, target_species, input_signal, target_path, target_event)
		right_tree[0] = right_tree_value
		if right_tree_signal == True:
			target_path.append("-".join(get_speices_node(right_tree, [])))
			target_event.append(right_tree_value)

		out_signal = right_tree_signal or left_signal
		out_value = merge_per_value(right_tree_value, left_tree_value)
		input_species_tree[0] = out_value

	if (type(left_tree) != list) and (type(right_tree) != list):

		left_value = tmp_species_state[left_tree]
		left_signal = get_species_signal(left_tree, target_species)

		right_signal = get_species_signal(right_tree, target_species)
		right_value = tmp_species_state[right_tree]

		if left_signal == True:
			target_path.append(left_tree)
			target_event.append(left_value)

		if right_signal == True:
			target_path.append(right_tree)
			target_event.append(right_value)

		out_signal = right_signal or left_signal
		out_value = merge_per_value(left_value, right_value)
		input_species_tree[0] = out_value

	if (type(left_tree) != list) and (type(right_tree) == list):

		left_value = tmp_species_state[left_tree]
		left_signal = get_species_signal(left_tree, target_species)

		if left_signal == True:
			target_path.append(left_tree)
			target_event.append(left_value)

		right_tree_value, right_node,  right_tree_signal, target_path, target_event = trace_back_node(right_tree, input_vector, target_species, input_signal, target_path, target_event)
		right_tree[0] = right_tree_value

		if right_tree_signal == True:
			target_path.append('-'.join(get_speices_node(right_tree, [])))
			target_event.append(right_tree_value)

		out_value = merge_per_value(left_value, right_tree_value)
		out_signal = right_tree_signal or left_signal
		input_species_tree[0] = out_value

	if (type(left_tree) == list) and (type(right_tree) != list):

		left_tree_value, left_node, left_signal, target_path, target_event = trace_back_node(left_tree, input_vector, target_species, input_signal, target_path, target_event)
		left_tree[0] = left_tree_value
		if left_signal == True:
			target_path.append("-".join(get_speices_node(left_tree, [])))
			target_event.append(left_tree_value)

		right_value = tmp_species_state[right_tree]
		right_signal = get_species_signal(right_tree, target_species)
		if right_signal == True:
			target_path.append(right_tree)
			target_event.append(right_value)

		out_signal = right_signal or left_signal
		out_value = merge_per_value(left_tree_value, right_value)
		input_species_tree[0] = out_value

	out_tree_node = "-".join(get_speices_node(input_species_tree, []))

	return out_value, out_tree_node, out_signal, target_path, target_event


def trace_final_state(input_tree_trace_output):

	state_path = input_tree_trace_output[4]
	node_path = input_tree_trace_output[3]

	state_path.append(input_tree_trace_output[0])
	node_path.append(input_tree_trace_output[1])

	ancestor_node = merge_per_value(1, state_path[-1])
	state_path.append(ancestor_node)
	target_node = state_path[0]

	if (ancestor_node == 1) and (target_node == 0):

		out_state = 'Loss_node:'

		for i in range(0, len(state_path)):
			tmp_value = state_path[i]
			if tmp_value == 1:
				loss_node = node_path[i-1]
				break

		out_state += loss_node

	else:

		out_state = 'Non_lost_state'

	return out_state


class LossDetector:

	def __init__(self, input_tree, target_species, input_line):
		self.species = target_species
		self.species_tree = trans_input_target_tree_2_format(input_tree, '')
		self.line = input_line.strip('\n').split('\t')

	def label_orthologous_group(self):
		exist_vector = self.line[0]
		traced_output = trace_back_node(self.species_tree, exist_vector, self.species, False, [], [])
		label_state = trace_final_state(traced_output)
		output_line = '\t'.join(self.line)
		output_line = label_state + '\t' + output_line
		return output_line


def main_func(input_path, target_species, target_tree):
	orthologous_groups = file_readlines(input_path)
	for orthologous_group in orthologous_groups:
		og_detector = LossDetector(target_tree, target_species, orthologous_group)
		og_result = og_detector.label_orthologous_group()
		if 'Loss_node' in og_result:
			print(og_result)


if __name__ == '__main__':
	data_path = sys.argv[1]
	target_species = sys.argv[2]
	input_tree = eval(sys.argv[3])
	main_func(data_path, target_species, input_tree)
