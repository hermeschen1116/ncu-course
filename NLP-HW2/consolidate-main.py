import os
from os import path
from typing import Any

import numpy
import pytorch_lightning as pl
import pytorch_lightning as torch_lightning
import torch
from pytorch_lightning import Trainer
from rank_bm25 import BM25Okapi as BM25
from torch import optim, nn, Tensor
from torch.nn import CrossEntropyLoss
from torch.utils import data
from torch.utils.data import DataLoader
from tqdm.auto import tqdm, trange
from transformers import AutoTokenizer
from transformers import AutoTokenizer as Tokenizer
from transformers import BertModel


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
        self.__tokenizer_prams: dict = {"truncation": True, "padding": "max_length", "return_tensors": "pt"}

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
        print("starting to get encodings")
        encoding_set = tokenizer(
            self.raw_data["question"],
            self.raw_data["reference"],
            truncation=self.__tokenizer_prams["truncation"],
            padding=self.__tokenizer_prams["padding"],
            return_tensors=self.__tokenizer_prams["return_tensors"],
        )
        print("starting to get index")
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
        print("dataset got")
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


class QAModel(torch_lightning.LightningModule):
    def __init__(self, tokenizer: Any, learning_rate: float = 1e-4):
        super(QAModel, self).__init__()

        self.__num_label: int = 4
        self.learning_rate: float = learning_rate
        self.save_hyperparameters()

        self.tokenizer: Any = tokenizer

        self.bert = BertModel.from_pretrained("bert-base-uncased")
        self.fc = nn.Linear(768, self.__num_label)

        self.loss_fn = CrossEntropyLoss()

    def configure_optimizers(self):
        return optim.Adam(self.parameters(), lr=self.learning_rate)

    def forward(self, input_batch):
        bert_output = self.bert(
            input_ids=input_batch["input_ids"],
            attention_mask=input_batch["attention_mask"],
            token_type_ids=input_batch["token_type_ids"],
            return_dict=True,
        )
        output = self.fc(bert_output["last_hidden_state"])

        return output

    @staticmethod
    def extract_predictions(output_batch: Tensor) -> (Tensor, Tensor, Tensor, Tensor):
        q_start_batch, q_end_batch, start_batch, end_batch = torch.split(output_batch, 1, 2)
        q_start_batch = q_start_batch.squeeze(-1).contiguous()
        q_end_batch = q_end_batch.squeeze(-1).contiguous()
        start_batch = start_batch.squeeze(-1).contiguous()
        end_batch = end_batch.squeeze(-1).contiguous()

        return q_start_batch, q_end_batch, start_batch, end_batch

    def calculate_loss(self, output_batch: Tensor, label_batch: Tensor) -> Any:
        q_start_batch, q_end_batch, start_batch, end_batch = self.extract_predictions(output_batch)

        q_start_loss = self.loss_fn(q_start_batch, label_batch["q_start"])
        q_end_loss = self.loss_fn(q_end_batch, label_batch["q_end"])
        start_loss = self.loss_fn(start_batch, label_batch["start"])
        end_loss = self.loss_fn(end_batch, label_batch["end"])

        return q_start_loss + q_end_loss + start_loss + end_loss

    def on_train_epoch_start(self) -> None:
        print("Epoch: {} starting to train...".format(self.current_epoch))

    def training_step(self, input_batch, input_batch_idx) -> dict:
        data_batch, label_batch = input_batch
        output_batch = self.forward(data_batch)

        loss = self.calculate_loss(output_batch, label_batch)

        self.log("loss", loss.item(), on_step=True, on_epoch=True, prog_bar=True)

        return {"loss": loss}

    def on_train_epoch_end(self) -> None:
        print("training ends")

    def on_validation_epoch_start(self) -> None:
        print("Epoch: {} starting to validate...".format(self.current_epoch))

    def validation_step(self, input_batch, input_batch_idx) -> dict:
        data_batch, label_batch = input_batch
        output_batch = self.forward(data_batch)

        loss = self.calculate_loss(output_batch, label_batch)

        self.log("loss", loss.item(), on_step=True, on_epoch=True, prog_bar=True)

        return {"val_loss": loss}

    def on_validation_epoch_end(self) -> None:
        print("validation ends")

    @staticmethod
    def get_predictions(predictions_batch: Tensor) -> list:
        _, predictions_batch = predictions_batch.topk(1, dim=1)

        return predictions_batch.squeeze(-1)

    # def on_test_epoch_start(self) -> None:
    # 	print('start to test...')
    #
    # def test_step(self, input_batch, input_batch_idx) -> dict:
    # 	data_batch, label_batch = input_batch
    # 	output_batch = self.forward(data_batch)
    #
    # 	q_start_batch, q_end_batch, start_batch, end_batch = self.extract_predictions(output_batch)
    # 	q_start_batch = self.get_predictions(q_start_batch)
    # 	q_end_batch = self.get_predictions(q_end_batch)
    # 	start_batch = self.get_predictions(start_batch)
    # 	end_batch = self.get_predictions(end_batch)
    #
    # 	predictions = [[q_start_batch[i], q_end_batch[i], start_batch[i], end_batch[i]] for i in range(len(q_start_batch))]
    # 	truths = [
    # 		[
    # 			int(label_batch['q_start'][i]),
    # 			int(label_batch['q_end'][i]),
    # 			int(label_batch['start'][i]),
    # 			int(label_batch['end'][i])
    # 		]
    # 		for i in range(len(label_batch['q_start']))
    # 	]
    #
    # 	return {'predict': predictions, 'truth': truths}
    #
    # def test_epoch_end(self, batch_output) -> None:
    # 	predict = torch.Tensor([prediction for batch in batch_output for prediction in batch['predict']])
    # 	truth = torch.Tensor([prediction for batch in batch_output for prediction in batch['truth']])
    #
    # 	print(predict)
    # 	print(truth)
    #
    # 	f1_score = MultilabelF1Score(num_labels=4, average='macro')
    # 	accuracy = MultilabelAccuracy(num_labels=4, average='macro')
    #
    # 	print(f1_score(predict, truth))
    # 	print('F1-Score: {:.2f}, Accuracy: {:.2f}'.format(f1_score(predict, truth), accuracy(predict, truth)))
    #
    # def on_test_epoch_end(self) -> None:
    # 	print('testing ends')

    def on_predict_start(self) -> None:
        print("start to predict...")

    def predict_step(self, input_batch, input_batch_idx, dataloader_idx: int = 0) -> dict:
        data_batch, question_batch = input_batch
        output_batch = self.forward(data_batch)

        q_start_batch, q_end_batch, start_batch, end_batch = self.extract_predictions(output_batch)
        q_start_batch = self.get_predictions(q_start_batch)
        q_end_batch = self.get_predictions(q_end_batch)
        start_batch = self.get_predictions(start_batch)
        end_batch = self.get_predictions(end_batch)

        questions = [
            self.tokenizer.decode(encoding[q_start_batch[i] : q_end_batch[i] + 1])
            for i, encoding in enumerate(data_batch["input_ids"])
        ]
        answers = [
            self.tokenizer.decode(encoding[start_batch[i] : end_batch[i] + 1])
            for i, encoding in enumerate(data_batch["input_ids"])
        ]

        return {"questions": questions, "answers": answers}

    def on_predict_end(self) -> None:
        print("prediction ends")


# Set Variables
num_epoch: int = 1
# Load source
data_loader = QADataModule()
# Instantiate model
tokenizer = AutoTokenizer.from_pretrained("bert-base-uncased")
model = QAModel(tokenizer)
trainer = Trainer(max_epochs=num_epoch, accelerator="auto", default_root_dir="model", check_val_every_n_epoch=1)
# Train
model.unfreeze()
trainer.fit(model, datamodule=data_loader)
# Test
# model.freeze()
# trainer.test(model, datamodule=data_loader)
# Predict
model.freeze()
predictions = trainer.predict(model, datamodule=data_loader, return_predictions=True)
questions = [question for batch in predictions for question in batch["questions"]]
answers = [answer for batch in predictions for answer in batch["answers"]]
target_path: str = "source/test-submit-out.txt"

with open(target_path, "w", encoding="UTF-8") as target:
    for question, answer in zip(questions, answers):
        target.write("{} ||| {}\n".format(question, answer))
