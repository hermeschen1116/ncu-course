package dev.sonodakazuto.App;

import dev.sonodakazuto.Functions.DataControl;
import dev.sonodakazuto.Functions.ElementControl;
import dev.sonodakazuto.Functions.InputAnalysis;
import javafx.animation.KeyFrame;
import javafx.animation.Timeline;
import javafx.fxml.FXML;
import javafx.scene.Node;
import javafx.scene.control.Button;
import javafx.scene.control.Label;
import javafx.scene.control.TextField;
import javafx.scene.layout.VBox;
import javafx.util.Duration;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Objects;
import java.util.concurrent.atomic.AtomicInteger;

public class MainController {
    private final Timeline pomoSecondHand = new Timeline();
    private final AtomicInteger restPomoDuration = new AtomicInteger();
    private final AtomicInteger restPomoM = new AtomicInteger();
    private final AtomicInteger restPomoS = new AtomicInteger();
    private final HashMap<Node, ArrayList<Label>> taskList = new HashMap<>();
    public int curTaskQuantity = 0;
    public String selectedTask;
    public static HashMap<String, String> taskDataList = new HashMap<>();
    @FXML
    public TextField textFieldAddTask, textFieldInputData;
    public Button btAddTask, btModifyTask, btSetPomo, btSkipPomo;
    public Label labelPomoClock;
    public Button btStartPomo, btFinishTask;
    public VBox vboxDataInput;
    public VBox vboxEditorBar;
    public VBox vboxTaskList;
    public Button btDeleteTask;
    private int pomoSetM, pomoSetDuration;
    private String inputData, curOnWorkTask;
    private boolean onTypeStatus = false;

    // load saved task
    public void initialize() throws IOException {
        curTaskQuantity = DataControl.loadTaskData(taskDataList);
        if (curTaskQuantity > 0) {
            ElementControl.loadTask(taskDataList, taskList, vboxTaskList);
            for (Node _taskBanner : taskList.keySet()) {
                _taskBanner.setOnMouseClicked((taskPicker) -> {
                    selectedTask = _taskBanner.getId();
                    vboxDataInput.setVisible(true);
                });
            }
        } else {
            System.out.println("No Data To Load");
        }
    }

    public void onPressedbtPomoStart() {
        curOnWorkTask = selectedTask;
        btStartPomo.setMouseTransparent(true);
        restPomoDuration.set(pomoSetDuration);
        restPomoM.set(pomoSetM);
        restPomoS.set(60);
        pomoSecondHand.getKeyFrames().add(new KeyFrame(Duration.seconds(1), (timer) -> ElementControl.pomoOperation(restPomoDuration, restPomoM, restPomoS, pomoSetM, labelPomoClock)));
        pomoSecondHand.setCycleCount(Timeline.INDEFINITE);
        pomoSecondHand.play();
    }

    public void onPressedbtPomoFinish() {
        pomoSecondHand.stop();
        btStartPomo.setMouseTransparent(false);
        ElementControl.deleteTask(curOnWorkTask, vboxTaskList, taskList);
        taskDataList.remove(selectedTask);
        curTaskQuantity--;
        labelPomoClock.setText("%02d：00".formatted(pomoSetM));
    }

    public void onPressedbtPomoSkip() {
        pomoSecondHand.stop();
        btStartPomo.setMouseTransparent(false);
        labelPomoClock.setText("00：00");
    }

    public void onEnterbtSetPomo() {
        if (!onTypeStatus) {
            textFieldInputData.setText("Input Format：minutes(Up to 180 mins)");
            textFieldInputData.setVisible(true);
            textFieldAddTask.setVisible(false);
            btStartPomo.setMouseTransparent(true);
            btFinishTask.setMouseTransparent(true);
            btSkipPomo.setMouseTransparent(true);
        }
    }

    public void onClickTextFieldInputData() {
        textFieldInputData.clear();
        textFieldInputData.setStyle("-fx-text-fill: #000000");
        onTypeStatus = true;
    }

    public void onPressedbtSetPomo() {
        inputData = textFieldInputData.getText();
        onTypeStatus = false;
        if (inputData.matches("^\\d{1,3}$")) {
            int tmp = Integer.parseInt(inputData);
            if (tmp <= 180 && tmp > 0) {
                pomoSetM = tmp;
                pomoSetDuration = pomoSetM * 60;
                labelPomoClock.setText("%02d：00".formatted(pomoSetM));
                textFieldInputData.setVisible(false);
                vboxDataInput.setVisible(false);
                btStartPomo.setMouseTransparent(false);
                btFinishTask.setMouseTransparent(false);
                btSkipPomo.setMouseTransparent(false);
            } else {
                InputAnalysis.showErrorMessage(textFieldInputData);
            }
        } else {
            InputAnalysis.showErrorMessage(textFieldInputData);
        }
    }

    public void onEnterbtAddTask() {
        if (!onTypeStatus) {
            textFieldAddTask.setText("Input Format：{Task Name} {Date(MM-DD)@Time(HH-MM, Optional)} {Subject}");
            textFieldInputData.setStyle("-fx-text-fill: #000000");
            textFieldAddTask.setVisible(true);
            textFieldInputData.setVisible(false);
            vboxDataInput.setVisible(false);
            btStartPomo.setMouseTransparent(true);
            btFinishTask.setMouseTransparent(true);
            btSkipPomo.setMouseTransparent(true);
        }
    }

    public void onClickTextFieldAddTask() {
        textFieldAddTask.clear();
        textFieldAddTask.setStyle("-fx-text-fill: #000000");
        onTypeStatus = true;
    }

    public void onPressedbtAddTask() {
        inputData = textFieldAddTask.getText();
        String taskData = ElementControl.addTask(inputData, curTaskQuantity, taskList, vboxTaskList);
        if (!Objects.equals(taskData, "-1")) {
            Node newTask = vboxTaskList.getChildren().get(curTaskQuantity);
            newTask.setOnMouseClicked((taskPicker) -> {
                selectedTask = newTask.getId();
                vboxDataInput.setVisible(true);
                textFieldAddTask.setVisible(false);
            });
            taskDataList.put(newTask.getId(), taskData);
            curTaskQuantity++;
            textFieldAddTask.clear();
            textFieldAddTask.setVisible(false);
            btStartPomo.setMouseTransparent(false);
            btFinishTask.setMouseTransparent(false);
            btSkipPomo.setMouseTransparent(false);
        } else {
            InputAnalysis.showErrorMessage(textFieldAddTask);
        }
        onTypeStatus = false;
    }

    public void onEnterbtModifyTask() {
        if (!onTypeStatus) {
            textFieldInputData.setText("Input Format：{Label} {Content}(seperate by ;)");
            textFieldInputData.setVisible(true);
            textFieldAddTask.setVisible(false);
            btStartPomo.setMouseTransparent(true);
            btFinishTask.setMouseTransparent(true);
            btSkipPomo.setMouseTransparent(true);
        }
    }

    public void onPressedbtModifyTask() {
        inputData = textFieldInputData.getText();
        String taskData = ElementControl.modifyTask(inputData, selectedTask, taskList);
        if (!Objects.equals(taskData, "-1")) {
            taskDataList.replace(selectedTask, taskDataList.get(selectedTask), taskData);
            textFieldInputData.setVisible(false);
            btStartPomo.setMouseTransparent(false);
            btFinishTask.setMouseTransparent(false);
            btSkipPomo.setMouseTransparent(false);
        } else {
            InputAnalysis.showErrorMessage(textFieldInputData);
        }
        onTypeStatus = false;
    }

    public void onEnterbtDeleteTask() {
        textFieldInputData.setVisible(false);
        textFieldAddTask.setVisible(false);
        btStartPomo.setMouseTransparent(true);
        btFinishTask.setMouseTransparent(true);
        btSkipPomo.setMouseTransparent(true);
    }

    public void onPressedbtDeleteTask() {
        ElementControl.deleteTask(selectedTask, vboxTaskList, taskList);
        taskDataList.remove(selectedTask);
        curTaskQuantity--;
        vboxDataInput.setVisible(false);
        btStartPomo.setMouseTransparent(false);
        btFinishTask.setMouseTransparent(false);
        btSkipPomo.setMouseTransparent(false);
    }

    public void onEntervboxTaskList() {
        textFieldAddTask.setVisible(false);
    }
}
