#! /usr/bin/python

import sys

class DataMap:

	def __init__(self):
		self.Data = dict()

	def add_data(self, input_key, input_value):
		if self.Data.has_key(input_key):
			self.Data[input_key].add(input_value)
		elif not self.Data.has_key(input_key):
			self.Data[input_key] = set()
			self.Data[input_key].add(input_value)

class OrthologousCluster:

	def __init__(self):
		self.elements = set()

	def first_element(self, input_ele):
		self.elements.add(input_ele)

	def expand(self, input_dict):
		for element in self.elements:
			tmp_set = input_dict[element]
			self.elements = self.elements | tmp_set

	def not_end_judge(self, input_dict):
		tmp_num = len(self.elements)
		self.expand(input_dict)
		tmp_expanded_num = len(self.elements)
		if tmp_expanded_num > tmp_num:
			return 1
		if tmp_num == tmp_expanded_num:
			return 0

	def output_cluster(self, input_i):
		output = 'Cluster'+str(input_i)
		for element in self.elements:
			output += '\t' + element
		print(output)


def main_func(input_path):
	tmp_file = open(input_path, 'r')
	tmp_data = tmp_file.readlines()
	tmp_file.close()

	data_store = DataMap()
	all_marker = set()

	for line in tmp_data:
		line = line.strip('\n').split('\t')
		data_store.add_data(line[0], line[4])
		data_store.add_data(line[4], line[0])
		all_marker.add(line[0])
		all_marker.add(line[4])

	max_num = len(all_marker)

	for i in range(0, max_num):
		tmp_cluster = OrthologousCluster()
		starting_node = all_marker.pop()
		tmp_cluster.first_element(starting_node)
		while tmp_cluster.not_end_judge(data_store.Data):
			tmp_cluster.expand(data_store.Data)
		while not tmp_cluster.not_end_judge(data_store.Data):
			tmp_cluster.output_cluster(i)
			break
		all_marker = all_marker - tmp_cluster.elements
		if len(all_marker) == 0:
			break


if __name__ == "__main__":

	data_path = sys.argv[1]
	main_func(data_path)

