import os
import os.path
import pickle
from pprint import pprint
from random import randint
from typing import Optional

import numpy as numpy
import pytorch_lightning as torch_lightning
import torch
from gensim import downloader
from pytorch_lightning import Trainer, seed_everything
from seqeval.metrics import classification_report
from seqeval.scheme import IOB2
from torch import nn, optim
from torch.utils import data
from torch.utils.data import DataLoader
from torch.utils.data import TensorDataset
from torchmetrics.classification import MulticlassF1Score, MulticlassAccuracy


class DataProcess:
    def __init__(self, source_path: str = "", source_type: str = "train", sep: str = " "):
        self.__source_path: str = source_path
        self.__source_type: str = source_type
        self.__source_sep: str = sep

        self.batch_count: int = 0
        self.batch_size: int = 0
        self.set_size: int = 0
        self.__data: list = []
        self.__label: list = []

        self.get_source(sep)

    def get_source(self, sep: str = "") -> None:
        if not os.path.exists(self.__source_path):
            print("Requested source does not exists.")
            exit()
        with open(self.__source_path, "r", encoding="UTF-8") as source:
            data_buffer, label_buffer = [], []
            for line in source.readlines():
                if line == "\n":
                    self.__data.append(data_buffer)
                    self.__label.append(label_buffer)
                    data_buffer, label_buffer = [], []
                    self.batch_count += 1
                else:
                    buffer = list(line.strip().split(sep))
                    data_buffer.append(buffer[0].lower())
                    self.set_size += 1
                    if sep == " ":
                        label_buffer.append("")
                    else:
                        label_buffer.append(buffer[1])
        self.set_padding()

    def set_padding(self) -> None:
        self.batch_size = max([len(line) for line in self.__data])
        for sentence in self.__data:
            for i in range(self.batch_size - len(sentence)):
                sentence.append("<PAD>")
        for sentence in self.__label:
            for i in range(self.batch_size - len(sentence)):
                sentence.append("<PAD>")

    def __get_embedding(self, embedding_table: dict, label_table: dict) -> (numpy.array, numpy.array):
        data_ret: list = []
        for sentence in self.__data:
            buffer: list = []
            for word in sentence:
                try:
                    buffer.append(embedding_table[word])
                except KeyError:
                    buffer.append(embedding_table["<UNK>"])
            data_ret.append(buffer)
        label_ret: list = []
        for sentence in self.__label:
            buffer: list = []
            for word in sentence:
                if self.__source_type == "test":
                    if word == "<PAD>":
                        buffer.append(label_table["<PAD>"])
                    else:
                        buffer.append(-1)
                else:
                    try:
                        buffer.append(label_table[word])
                    except KeyError:
                        print("Key not exists")
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
    def __init__(
        self,
        train_set: TensorDataset,
        eval_set: TensorDataset,
        predict_set: TensorDataset,
        val_split: float = 0.2,
        num_worker: int = 4,
    ):
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


class NERModel(torch_lightning.LightningModule):
    def __init__(
        self,
        embedding_size: int,
        num_lstm_out: int,
        num_lstm_hidden: int,
        lstm_dropout_rate: float,
        dropout_rate: float,
        labels_val: list,
        learning_rate: float,
    ):
        super(NERModel, self).__init__()
        self.save_hyperparameters()

        self.__embedding_size: int = embedding_size
        self.__num_lstm_out: int = num_lstm_out
        self.__num_lstm_hidden: int = num_lstm_hidden
        self.__lstm_dropout_rate: float = lstm_dropout_rate
        self.__dropout_rate: float = dropout_rate
        self.__num_label: int = len(labels_val)
        self.learning_rate: float = learning_rate
        self.__labels: list = labels_val

        self.__lstm = nn.LSTM(
            self.__embedding_size,
            self.__num_lstm_out,
            num_layers=self.__num_lstm_hidden,
            dropout=self.__lstm_dropout_rate,
            dtype=float,
            batch_first=True,
            bidirectional=True,
        )
        self.__dropout = nn.Dropout(self.__dropout_rate)
        self.__fc = nn.Linear(self.__num_lstm_out * 2, self.__num_label, dtype=float)
        self.__softmax = nn.LogSoftmax(dim=1)
        self.__loss_fn = nn.NLLLoss(ignore_index=0)

        self.__f1_score = MulticlassF1Score(num_classes=self.__num_label, ignore_index=0)
        self.__accuracy = MulticlassAccuracy(num_classes=self.__num_label, ignore_index=0)

    def configure_optimizers(self):
        return optim.Adam(self.parameters(), lr=self.learning_rate)

    def forward(self, input_batch):
        # noinspection PyTypeChecker
        hidden_state = torch.randn((self.__num_lstm_hidden * 2, input_batch.size(0), self.__num_lstm_out), dtype=float)
        # noinspection PyTypeChecker
        cell_state = torch.randn((self.__num_lstm_hidden * 2, input_batch.size(0), self.__num_lstm_out), dtype=float)
        lstm_output, _ = self.__lstm(input_batch, (hidden_state, cell_state))
        dropout_output = self.__dropout(lstm_output)
        dropout_output = dropout_output.view(dropout_output.shape[1], -1)
        fc_output = self.__fc(dropout_output)
        return self.__softmax(fc_output)

    @staticmethod
    def pad_filter(output_batch, label_batch, predict: bool = False):
        output_batch = torch.exp(output_batch)
        _, output_batch = output_batch.topk(1, dim=1)
        output_batch = output_batch.view(*label_batch.shape)

        if predict:
            mask = label_batch == -1
        else:
            mask = (output_batch > 0) & (label_batch > 0)
            label_batch = label_batch[mask]
        output_batch = output_batch[mask]

        return torch.Tensor(output_batch), torch.Tensor(label_batch)

    @staticmethod
    def show_step_result(batch_result, label_val):
        all_predictions = [[label_val[int(label)].upper() for label in batch["pred"]] for batch in batch_result]
        all_truths = [[label_val[int(label)].upper() for label in batch["truth"]] for batch in batch_result]

        print(classification_report(all_truths, all_predictions, mode="strict", scheme=IOB2, zero_division=0))

    def on_train_epoch_start(self) -> None:
        print("Epoch: {} starting to train...".format(self.current_epoch))

    def training_step(self, input_batch, input_batch_idx) -> dict:
        data_batch, label_batch = input_batch
        output_batch = self.forward(data_batch)
        train_loss = self.__loss_fn(output_batch, label_batch.view(-1))

        output_batch, label_batch = self.pad_filter(output_batch, label_batch)
        train_acc = self.__accuracy(output_batch, label_batch)
        train_f1 = self.__f1_score(output_batch, label_batch)

        self.log("train_loss", train_loss, on_step=True, on_epoch=True, prog_bar=True, add_dataloader_idx=True)
        self.log("train_acc", train_acc, on_step=True, on_epoch=True, add_dataloader_idx=True)
        self.log("train_f1", train_f1, on_step=True, on_epoch=True, add_dataloader_idx=True)

        return {"loss": train_loss, "acc": train_acc, "f1_score": train_f1, "pred": output_batch, "truth": label_batch}

    def training_epoch_end(self, batch_output) -> None:
        self.show_step_result(batch_output, self.__labels)

    def on_train_epoch_end(self) -> None:
        print("training ends")

    def on_validation_epoch_start(self) -> None:
        print("Epoch: {} starting to validate...".format(self.current_epoch))

    def validation_step(self, input_batch, input_batch_idx) -> dict:
        data_batch, label_batch = input_batch
        output_batch = self.forward(data_batch)
        val_loss = self.__loss_fn(output_batch, label_batch.view(-1))

        output_batch, label_batch = self.pad_filter(output_batch, label_batch)
        val_acc = self.__accuracy(output_batch, label_batch)
        val_f1 = self.__f1_score(output_batch, label_batch)

        self.log("val_loss", val_loss, on_step=True, on_epoch=True, prog_bar=True, add_dataloader_idx=True)
        self.log("val_acc", val_acc, on_step=True, on_epoch=True, add_dataloader_idx=True)
        self.log("val_f1", val_f1, on_step=True, on_epoch=True, add_dataloader_idx=True)

        return {
            "val_loss": val_loss,
            "val_acc": val_acc,
            "val_f1_score": val_f1,
            "pred": output_batch,
            "truth": label_batch,
        }

    def validation_epoch_end(self, batch_output) -> None:
        self.show_step_result(batch_output, self.__labels)

    def on_validation_epoch_end(self) -> None:
        print("validation ends")

    def on_test_epoch_start(self) -> None:
        print("start to test...")

    def test_step(self, input_batch, input_batch_idx) -> dict:
        data_batch, label_batch = input_batch
        output_batch = self.forward(data_batch)

        output_batch, label_batch = self.pad_filter(output_batch, label_batch)
        test_acc = self.__accuracy(output_batch, label_batch)
        test_f1 = self.__f1_score(output_batch, label_batch)

        self.log("test_acc", test_acc, on_step=True, on_epoch=True, prog_bar=True, add_dataloader_idx=True)
        self.log("test_f1", test_f1, on_step=True, on_epoch=True, add_dataloader_idx=True)

        return {"test_acc": test_acc, "test_f1": test_f1, "pred": output_batch, "truth": label_batch}

    def test_epoch_end(self, batch_output) -> None:
        self.show_step_result(batch_output, self.__labels)

    def on_test_epoch_end(self) -> None:
        print("testing ends")

    def on_predict_start(self) -> None:
        print("start to predict...")

    def predict_step(self, input_batch, input_batch_idx, dataloader_idx: int = 0) -> list:
        data_batch, label_batch = input_batch
        output_batch = self.forward(data_batch)

        output_batch, label_batch = self.pad_filter(output_batch, label_batch, True)
        output_batch = [self.__labels[int(label)] for label in output_batch]

        return output_batch

    def on_predict_end(self) -> None:
        print("prediction ends")


# files
train_set_path: str = "source/nlp-hw1-train.txt"
eval_set_path: str = "source/nlp-hw1-dev.txt"
test_set_path: str = "source/nlp-hw1-test-submit.txt"
embeddings_path: str = "source/embeddings.pickle"
# variables
label_val: list = [
    "<PAD>",
    "B-person",
    "I-person",
    "B-geo-loc",
    "I-geo-loc",
    "B-company",
    "I-company",
    "B-facility",
    "I-facility",
    "B-product",
    "I-product",
    "B-musicartist",
    "I-musicartist",
    "B-movie",
    "I-movie",
    "B-sportsteam",
    "I-sportsteam",
    "B-tvshow",
    "I-tvshow",
    "B-other",
    "I-other",
    "O",
]
label_index: list = [i for i in range(len(label_val))]
embedding_model_name: str = "glove-twitter-200"
embedding_size: int = int(embedding_model_name.split("-")[2])
embeddings: dict = dict()
labels: dict = dict(zip(label_val, label_index))
num_epoch: int = 100

# Load pretrained word embeddings
if os.path.exists(embeddings_path):
    with open(embeddings_path, "rb") as file:
        embeddings = pickle.load(file)
else:
    embedding_model = downloader.load(embedding_model_name)
    for word in embedding_model.index_to_key:
        embeddings[word] = numpy.array(embedding_model.get_vector(word))
    embeddings["<PAD>"] = numpy.ones(embedding_size)
    embeddings["<UNK>"] = numpy.zeros(embedding_size)
    with open(embeddings_path, "wb") as file:
        pickle.dump(embeddings, file)
# Load source
train_set: DataProcess = DataProcess(train_set_path, "train", "\t")
train_set: TensorDataset = train_set.get_data_set(embeddings, labels)

eval_set: DataProcess = DataProcess(eval_set_path, "eval", "\t")
eval_set: TensorDataset = eval_set.get_data_set(embeddings, labels)

test_set: DataProcess = DataProcess(test_set_path, "test")
test_set: TensorDataset = test_set.get_data_set(embeddings, labels)
# Instantiate Model
seed_everything(randint(0, 37710), workers=True)
model = NERModel(embedding_size, embedding_size // 2, 15, 0.3, 0.3, label_val, 1e-2)
data_loader = NERDataLoader(train_set, eval_set, test_set)
trainer = Trainer(
    max_epochs=num_epoch,
    auto_lr_find=True,
    accelerator="auto",
    reload_dataloaders_every_n_epochs=1,
    default_root_dir="model",
)

pprint(model)

model.unfreeze()
trainer.tune(model, datamodule=data_loader)
# Train model
model.unfreeze()
trainer.fit(model, datamodule=data_loader)
# Test model
model.freeze()
trainer.test(model, datamodule=data_loader, verbose=True)
# Predict
model.freeze()
predictions = trainer.predict(model, datamodule=data_loader, return_predictions=True)

source_path = "source/nlp-hw1-test-submit.txt"
target_path = "source/test-submit.txt"
contents = []
for batch in predictions:
    contents += batch

content_count = 0
with open(source_path, "r") as source, open(target_path, "w") as target:
    for line in source:
        if line == "\n":
            target.write("\n")
            continue
        target.write(line.strip() + "\t" + contents[content_count] + "\n")
        content_count += 1
