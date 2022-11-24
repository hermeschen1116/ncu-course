import os
from typing import Optional

import numpy
import pytorch_lightning as torch_lightning
import torch
from torch.utils import data
from torch.utils.data import TensorDataset, DataLoader


class DataProcess:
	def __init__(self, source_path: str = '', source_type: str = 'train', sep: str = ' '):
		self.__source_path: str = source_path
		self.__source_type: str = source_type
		self.__source_sep: str = sep

		self.batch_count: int = 0
		self.batch_size: int = 0
		self.set_size: int = 0
		self.__data: list = []
		self.__label: list = []

		self.get_source(sep)

	def get_source(self, sep: str = '') -> None:
		if not os.path.exists(self.__source_path):
			print("Requested source does not exists.")
			exit()
		with open(self.__source_path, 'r', encoding="UTF-8") as source:
			data_buffer, label_buffer = [], []
			for line in source.readlines():
				if line == '\n':
					self.__data.append(data_buffer)
					self.__label.append(label_buffer)
					data_buffer, label_buffer = [], []
					self.batch_count += 1
				else:
					buffer = list(line.strip().split(sep))
					data_buffer.append(buffer[0].lower())
					self.set_size += 1
					if sep == ' ':
						label_buffer.append('')
					else:
						label_buffer.append(buffer[1])
		self.set_padding()

	def set_padding(self) -> None:
		self.batch_size = max([len(line) for line in self.__data])
		for sentence in self.__data:
			for i in range(self.batch_size - len(sentence)):
				sentence.append('<PAD>')
		for sentence in self.__label:
			for i in range(self.batch_size - len(sentence)):
				sentence.append('<PAD>')

	def __get_embedding(self, embedding_table: dict, label_table: dict) -> (numpy.array, numpy.array):
		data_ret: list = []
		for sentence in self.__data:
			buffer: list = []
			for word in sentence:
				try:
					buffer.append(embedding_table[word])
				except KeyError:
					buffer.append(embedding_table['<UNK>'])
			data_ret.append(buffer)
		label_ret: list = []
		for sentence in self.__label:
			buffer: list = []
			for word in sentence:
				if self.__source_type == 'test':
					if word == '<PAD>':
						buffer.append(label_table['<PAD>'])
					else:
						buffer.append(-1)
				else:
					try:
						buffer.append(label_table[word])
					except KeyError:
						print('Key not exists')
						exit()
			label_ret.append(buffer)

		return numpy.array(data_ret, dtype=float), numpy.array(label_ret, dtype=int)

	def get_data(self) -> list:
		return self.__data

	def get_label(self) -> list:
		return self.__label

	def get_data_set(self, embedding_table: dict, label_table: dict) -> TensorDataset:
		set_data, set_label = self.__get_embedding(embedding_table, label_table)
		return TensorDataset(torch.from_numpy(set_data), torch.from_numpy(set_label))


class NERDataLoader(torch_lightning.LightningDataModule):
	def __init__(self, train_set: TensorDataset, eval_set: TensorDataset, predict_set: TensorDataset,
				 val_split: float = 0.2, num_worker: int = 4):
		super().__init__()
		self.__val_split: float = val_split
		self.__num_worker: int = num_worker
		self.__train_set: TensorDataset = train_set
		self.__val_set = None
		self.__eval_set: TensorDataset = eval_set
		self.__predict_set: TensorDataset = predict_set

	def prepare_data(self) -> None:
		pass

	@staticmethod
	def split_data(data_set, val_split: float):
		train_set_split = int(len(data_set) * (1 - val_split))
		val_set_split = len(data_set) - train_set_split
		train_set, val_set = data.random_split(data_set, [train_set_split, val_set_split])

		return train_set, val_set

	def setup(self, stage: Optional[str] = None) -> None:
		self.__train_set, self.__val_set = self.split_data(self.__train_set, self.__val_split)

	def train_dataloader(self):
		return DataLoader(self.__train_set, shuffle=True, num_workers=self.__num_worker)

	def val_dataloader(self):
		return DataLoader(self.__val_set, num_workers=self.__num_worker)

	def test_dataloader(self):
		return DataLoader(self.__eval_set, num_workers=self.__num_worker)

	def predict_dataloader(self):
		return DataLoader(self.__predict_set, num_workers=self.__num_worker)
