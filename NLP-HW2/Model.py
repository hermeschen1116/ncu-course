from typing import Any

import pytorch_lightning as torch_lightning
import torch
from torch import optim, nn, Tensor
from torch.nn import CrossEntropyLoss
from transformers import BertModel


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
