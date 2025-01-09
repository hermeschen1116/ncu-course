from os import path
from typing import Any

import numpy
import pytorch_lightning as pl
import torch
from rank_bm25 import BM25Okapi as BM25
from torch.utils import data
from torch.utils.data import DataLoader
from tqdm.auto import tqdm, trange
from transformers import AutoTokenizer as Tokenizer


class QADataset(torch.utils.data.Dataset):
    def __init__(self, encoding_set):
        self.dataset = encoding_set

    def __getitem__(self, idx) -> (dict, dict):
        labels: list = ["q_start", "q_end", "start", "end"]
        data_batch: dict = {key: val[idx].clone().detach() for key, val in self.dataset.items() if key not in labels}
        label_batch: dict = {key: torch.from_numpy(val[idx]) for key, val in self.dataset.items() if key in labels}
        return data_batch, label_batch

    def __len__(self) -> int:
        return len(self.dataset.input_ids)


class DataPreprocess:
    def __init__(self, source_path: str, source_type: str = "train"):
        self.source_path: str = source_path
        self.source_type: str = source_type
        self.source_size: int = 0
        self.raw_data: dict = {"question": [], "answer": [], "reference": []}
        self.raw_label: dict = {"q_start": [], "q_end": [], "start": [], "end": []}
        self.__tokenizer_prams: dict = {
            "truncation": True,
            "padding": "max_length",
            "return_offsets_mapping": True,
            "return_overflowing_tokens": True,
            "return_tensors": "pt",
        }

        self.__get_raw_data()

    def __get_raw_data(self) -> None:
        if not path.exists(self.source_path):
            print("Request source does not exists.")
            exit()
        with open(self.source_path, "r", encoding="UTF-8") as source:
            for line in tqdm(source.readlines()):
                reference, question, answer = map(str, line.strip("\n").split(" ||| "))
                reference = [str(r).strip() for r in reference.strip().strip("<s>").strip("</s>").split("</s>  <s>")]
                bm25 = BM25([r.split(" ") for r in reference])
                mask = bm25.get_scores(question.split(" ")) > 0
                reference = [reference[i] for i in range(len(mask)) if mask[i]]
                for r in reference:
                    self.source_size += 1
                    self.raw_data["question"].append(question)
                    self.raw_data["answer"].append(answer)
                    self.raw_data["reference"].append(r)
                    self.raw_label["q_start"].append(0)
                    self.raw_label["q_end"].append(len(question))
                    answer_start = r.find(answer)
                    if answer_start == -1:
                        self.raw_label["start"].append(0)
                        self.raw_label["end"].append(0)
                    else:
                        self.raw_label["start"].append(answer_start)
                        self.raw_label["end"].append(answer_start + len(answer))

        print("Raw data got.")

    def get_dataset(self, tokenizer: Any) -> QADataset:
        encoding_set = tokenizer(
            self.raw_data["question"],
            self.raw_data["reference"],
            truncation=self.__tokenizer_prams["truncation"],
            padding=self.__tokenizer_prams["padding"],
            return_overflowing_tokens=self.__tokenizer_prams["return_overflowing_tokens"],
            return_offsets_mapping=self.__tokenizer_prams["return_offsets_mapping"],
            return_tensors=self.__tokenizer_prams["return_tensors"],
        )
        labels: dict = {"q_start": [], "q_end": [], "start": [], "end": []}
        for i in trange(self.source_size):
            q_start = encoding_set.char_to_token(i, self.raw_label["q_start"][i] + 1, 0)
            q_end = encoding_set.char_to_token(i, self.raw_label["q_end"][i] - 1, 0)
            labels["q_start"].append(numpy.array(q_start))
            labels["q_end"].append(numpy.array(q_end))
            if self.raw_label["start"][i] == 0 and self.raw_label["end"][i] == 0:
                labels["start"].append(numpy.array(0))
                labels["end"].append(numpy.array(0))
            else:
                labels["start"].append(numpy.array(encoding_set.char_to_token(i, self.raw_label["start"][i], 1)))
                labels["end"].append(numpy.array(encoding_set.char_to_token(i, self.raw_label["end"][i] - 1, 1)))
        encoding_set.update(labels)
        return QADataset(encoding_set)


class QADataModule(pl.LightningDataModule):
    def __init__(
        self,
        source_dir: str = "source/",
        tokenizer_name: str = "bert-base-uncased",
        num_worker: int = 4,
        batch_size: int = 8,
    ):
        super().__init__()
        self.source_dir: str = source_dir
        self.__tokenizer = Tokenizer.from_pretrained(tokenizer_name, do_lower_case=True)
        self.__num_worker: int = num_worker
        self.__batch_size: int = batch_size
        self.__train_set: QADataset = DataPreprocess(self.source_dir + "train.txt", "train").get_dataset(
            self.__tokenizer
        )
        self.__val_set: QADataset = DataPreprocess(self.source_dir + "val.txt", "val").get_dataset(self.__tokenizer)
        # self.__test_set: Any = None
        self.__predict_set: QADataset = DataPreprocess(self.source_dir + "test.txt", "predict").get_dataset(
            self.__tokenizer
        )

    # def setup(self, stage: str) -> None:
    # 	val_set_split = int(len(self.__val_set) * 0.8)
    # 	test_set_split = len(self.__val_set) - val_set_split
    # 	self.__val_set, self.__test_set = random_split(self.__val_set, [val_set_split, test_set_split])

    def train_dataloader(self) -> DataLoader:
        return DataLoader(self.__train_set, shuffle=True, batch_size=self.__batch_size, num_workers=self.__num_worker)

    def val_dataloader(self) -> DataLoader:
        return DataLoader(self.__val_set, batch_size=self.__batch_size, num_workers=self.__num_worker)

    # def test_dataloader(self) -> DataLoader:
    # 	return DataLoader(self.__test_set, batch_size=self.__batch_size, num_workers=self.__num_worker)

    def predict_dataloader(self) -> DataLoader:
        return DataLoader(self.__predict_set, batch_size=self.__batch_size, num_workers=self.__num_worker)
