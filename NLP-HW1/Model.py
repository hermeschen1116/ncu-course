import pytorch_lightning as torch_lightning
import torch
from seqeval.metrics import classification_report
from seqeval.scheme import IOB2
from torch import nn, optim
from torchmetrics.classification import MulticlassF1Score, MulticlassAccuracy


class NERModel(torch_lightning.LightningModule):
	def __init__(self, embedding_size: int, num_lstm_out: int, num_lstm_hidden: int, lstm_dropout_rate: float,
				 dropout_rate: float, labels_val: list, learning_rate: float):
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

		self.__lstm = nn.LSTM(self.__embedding_size, self.__num_lstm_out, num_layers=self.__num_lstm_hidden,
							  dropout=self.__lstm_dropout_rate, dtype=float, batch_first=True, bidirectional=True)
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
		hidden_state = torch.randn((self.__num_lstm_hidden * 2, input_batch.size(0), self.__num_lstm_out),
								   dtype=float)
		# noinspection PyTypeChecker
		cell_state = torch.randn((self.__num_lstm_hidden * 2, input_batch.size(0), self.__num_lstm_out),
								 dtype=float)
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
		all_predictions = [[label_val[int(label)].upper() for label in batch['pred']] for batch in batch_result]
		all_truths = [[label_val[int(label)].upper() for label in batch['truth']] for batch in batch_result]

		print(classification_report(all_truths, all_predictions, mode='strict', scheme=IOB2, zero_division=0))

	def on_train_epoch_start(self) -> None:
		print('Epoch: {} starting to train...'.format(self.current_epoch))

	def training_step(self, input_batch, input_batch_idx) -> dict:
		data_batch, label_batch = input_batch
		output_batch = self.forward(data_batch)
		train_loss = self.__loss_fn(output_batch, label_batch.view(-1))

		output_batch, label_batch = self.pad_filter(output_batch, label_batch)
		train_acc = self.__accuracy(output_batch, label_batch)
		train_f1 = self.__f1_score(output_batch, label_batch)

		self.log('train_loss', train_loss, on_step=True, on_epoch=True, prog_bar=True, add_dataloader_idx=True)
		self.log('train_acc', train_acc, on_step=True, on_epoch=True, add_dataloader_idx=True)
		self.log('train_f1', train_f1, on_step=True, on_epoch=True, add_dataloader_idx=True)

		return {'loss': train_loss, 'acc': train_acc, 'f1_score': train_f1, 'pred': output_batch,
				'truth': label_batch}

	def training_epoch_end(self, batch_output) -> None:
		self.show_step_result(batch_output, self.__labels)

	def on_train_epoch_end(self) -> None:
		print('training ends')

	def on_validation_epoch_start(self) -> None:
		print('Epoch: {} starting to validate...'.format(self.current_epoch))

	def validation_step(self, input_batch, input_batch_idx) -> dict:
		data_batch, label_batch = input_batch
		output_batch = self.forward(data_batch)
		val_loss = self.__loss_fn(output_batch, label_batch.view(-1))

		output_batch, label_batch = self.pad_filter(output_batch, label_batch)
		val_acc = self.__accuracy(output_batch, label_batch)
		val_f1 = self.__f1_score(output_batch, label_batch)

		self.log('val_loss', val_loss, on_step=True, on_epoch=True, prog_bar=True, add_dataloader_idx=True)
		self.log('val_acc', val_acc, on_step=True, on_epoch=True, add_dataloader_idx=True)
		self.log('val_f1', val_f1, on_step=True, on_epoch=True, add_dataloader_idx=True)

		return {'val_loss': val_loss, 'val_acc': val_acc, 'val_f1_score': val_f1, 'pred': output_batch,
				'truth': label_batch}

	def validation_epoch_end(self, batch_output) -> None:
		self.show_step_result(batch_output, self.__labels)

	def on_validation_epoch_end(self) -> None:
		print('validation ends')

	def on_test_epoch_start(self) -> None:
		print('start to test...')

	def test_step(self, input_batch, input_batch_idx) -> dict:
		data_batch, label_batch = input_batch
		output_batch = self.forward(data_batch)

		output_batch, label_batch = self.pad_filter(output_batch, label_batch)
		test_acc = self.__accuracy(output_batch, label_batch)
		test_f1 = self.__f1_score(output_batch, label_batch)

		self.log('test_acc', test_acc, on_step=True, on_epoch=True, prog_bar=True, add_dataloader_idx=True)
		self.log('test_f1', test_f1, on_step=True, on_epoch=True, add_dataloader_idx=True)

		return {'test_acc': test_acc, 'test_f1': test_f1, 'pred': output_batch, 'truth': label_batch}

	def test_epoch_end(self, batch_output) -> None:
		self.show_step_result(batch_output, self.__labels)

	def on_test_epoch_end(self) -> None:
		print('testing ends')

	def on_predict_start(self) -> None:
		print('start to predict...')

	def predict_step(self, input_batch, input_batch_idx, dataloader_idx: int = 0) -> list:
		data_batch, label_batch = input_batch
		output_batch = self.forward(data_batch)

		output_batch, label_batch = self.pad_filter(output_batch, label_batch, True)
		output_batch = [self.__labels[int(label)] for label in output_batch]

		return output_batch

	def on_predict_end(self) -> None:
		print('prediction ends')
