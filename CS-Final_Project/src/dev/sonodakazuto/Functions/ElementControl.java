package dev.sonodakazuto.Functions;

import javafx.scene.Node;
import javafx.scene.control.Label;
import javafx.scene.image.Image;
import javafx.scene.image.ImageView;
import javafx.scene.layout.HBox;
import javafx.scene.layout.VBox;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Objects;
import java.util.concurrent.atomic.AtomicInteger;

public class ElementControl {
    public static Node searchTask(String _taskId, HashMap<Node, ArrayList<Label>> _elementList) {
        Node _targetTask = null;
        for (Node element : _elementList.keySet()) {
            if (element.getId().equals(_taskId)) {
                _targetTask = element;
            }
        }
        return _targetTask;
    }

    public static void loadTask(HashMap<String, String> _taskDataList, HashMap<Node, ArrayList<Label>> _elementList, VBox _taskVbox) {
        int taskCnt = 0;
        for (String _taskData : _taskDataList.values()) {
            String[] tmp = _taskData.split(" ");
            VBox newTaskBanner = createNewTaskBanner(tmp[0], tmp[1], tmp[2], taskCnt, _elementList);
            _taskVbox.getChildren().add(newTaskBanner);
            taskCnt++;
        }
    }

    public static String addTask(String _inputData, int _currentTotalTask, HashMap<Node, ArrayList<Label>> _elementList, VBox _taskVbox) {
        String[] tmp = InputAnalysis.getNewTaskData(_inputData);
        String _taskData;
        if (!Objects.equals(tmp[1], "-1")) {
            String formattedTimeData = InputAnalysis.taskTimeFormatter(tmp[1]);
            VBox newTaskBanner = createNewTaskBanner(tmp[0], formattedTimeData, tmp[2], _currentTotalTask, _elementList);
            _taskVbox.getChildren().add(newTaskBanner);
            _taskData = "%s %s %s".formatted(tmp[0], formattedTimeData, tmp[2]);
        } else {
            _taskData = "-1";
        }
        return _taskData;
    }

    public static String modifyTask(String _inputData, String _selectedTask, HashMap<Node, ArrayList<Label>> _elementList) {
        Node targetTask = ElementControl.searchTask(_selectedTask, _elementList);
        ArrayList<Label> modifyGroup = _elementList.get(targetTask);
        String[] inputData = InputAnalysis.checkModifyTaskData(_inputData);
        String _taskData;
        if (!Objects.equals(inputData[1], "-1")) {
            for (int i = 0; i < 3; i++) {
                if (!Objects.equals(inputData[i], "")) {
                    modifyGroup.get(i).setText(inputData[i]);
                }
            }
            _taskData = "%s %s %s".formatted(modifyGroup.get(0).getText(), modifyGroup.get(1).getText(), modifyGroup.get(2).getText());
        } else {
            _taskData = "-1";
        }
        return _taskData;
    }

    public static void deleteTask(String _selectedTask, VBox _taskVBox, HashMap<Node, ArrayList<Label>> _elementList) {
        Node targetTask = ElementControl.searchTask(_selectedTask, _elementList);
        _elementList.remove(targetTask, _elementList.get(targetTask));
        _taskVBox.getChildren().remove(targetTask);
    }

    // create a new taskbanner
    public static VBox createNewTaskBanner(String _newTaskName, String _newTaskDate, String _newTaskSubject, int _totalTask, HashMap<Node, ArrayList<Label>> _elementList) {
        ArrayList<Label> labelGroup = new ArrayList<>();

        // create a new task container
        VBox _newTaskBanner = new VBox();
        _newTaskBanner.setStyle("-fx-alignment: center; -fx-background-color:  #2D2D36; -fx-background-radius: 10px; -fx-padding: 2; -fx-pref-width: 585; -fx-pref-height: 85; -fx-min-height: 85");
        _newTaskBanner.setId("vboxTaskBanner" + _totalTask);

        // create a new task name block
        HBox newTaskNameBlock = new HBox();
        newTaskNameBlock.setStyle("-fx-alignment: center_left; -fx-padding: 5; -fx-spacing: 5; -fx-pref-width: 585; -fx-pref-height: 35");
        newTaskNameBlock.setMouseTransparent(true);

        // write task name
        Label newTaskName = new Label(_newTaskName);
        newTaskName.setStyle("-fx-font-family: 'dev/sonodakazuto/res/font/NotoSansCJKtc-Bold.otf'; -fx-font-size: 20; -fx-text-fill: #ffffff; -fx-text-alignment: center; -fx-content-display: center; -fx-alignment: center_left; -fx-padding: 0 5 0 5; -fx-pref-width: 360; -fx-pref-height: 30");
        newTaskNameBlock.getChildren().add(newTaskName);
        _newTaskBanner.getChildren().add(newTaskNameBlock);
        newTaskName.setId("labelTaskName" + _totalTask);
        labelGroup.add(newTaskName);

        // create a new task data block
        HBox newTaskDataBlock = new HBox();
        newTaskDataBlock.setStyle("-fx-alignment: center_left; -fx-padding: 2 2 2 5; -fx-spacing: 3; -fx-pref-width: 585; -fx-pref-height: 40");

        // create a new tsk date data block
        HBox newTaskStatus = new HBox();
        newTaskStatus.setStyle("-fx-alignment: center_left; -fx-padding: 2 5 2 5; -fx-spacing: 5; -fx-min-width: 480; -fx-pref-height: 35");

        // add schedule icon
        ImageView scheduleIcon = new ImageView();
        scheduleIcon.setImage(new Image("dev/sonodakazuto/res/image/icon_schedule.png"));
        scheduleIcon.setFitHeight(25);
        scheduleIcon.setFitWidth(25);
        scheduleIcon.setMouseTransparent(true);
        newTaskStatus.getChildren().add(scheduleIcon);

        // write task time data
        Label newTaskDate = new Label(_newTaskDate);
        newTaskDate.setStyle("-fx-font-family: 'dev/sonodakazuto/res/font/NotoSansCJKtc-Bold.otf'; -fx-font-size: 20; -fx-text-alignment: center; -fx-content-display: center; -fx-alignment: center; -fx-min-width: 325; -fx-pref-height: 32");
        if (_newTaskDate.contains("Today")) {
            newTaskDate.setStyle("-fx-text-fill: #18f039");
        } else {
            newTaskDate.setStyle("-fx-text-fill: #ffffff");
        }
        newTaskDate.setId("labelTaskDate" + _totalTask);
        newTaskStatus.getChildren().add(newTaskDate);
        labelGroup.add(newTaskDate);

        newTaskStatus.setMouseTransparent(true);
        newTaskDataBlock.getChildren().add(newTaskStatus);

        //write task subject
        Label newTaskSubject = new Label(_newTaskSubject);
        newTaskSubject.setStyle("-fx-font-family: 'dev/sonodakazuto/res/font/NotoSansCJKtc-Bold.otf'; -fx-font-size: 20; -fx-text-fill: #ffffff;-fx-text-alignment: center; -fx-content-display: center; -fx-alignment: center; -fx-padding: 0 5 0 5; -fx-pref-width: 100; -fx-pref-height: 25");
        newTaskDataBlock.getChildren().add(newTaskSubject);
        newTaskSubject.setId("labelTaskSubject" + _totalTask);
        labelGroup.add(newTaskSubject);

        _newTaskBanner.getChildren().add(newTaskDataBlock);
        _elementList.put(_newTaskBanner, labelGroup);

        return _newTaskBanner;
    }

    // pomodoro operating function
    public static void pomoOperation(AtomicInteger _restPomoDuration, AtomicInteger _restPomoM, AtomicInteger _restPomoS, int _initPomo, Label _clock) {
        if (_restPomoDuration.get() - 1 >= 0) {
            if (_restPomoS.get() == 60) {
                _clock.setText("%02d：%d".formatted(_restPomoM.get() - 1, _restPomoS.get() - 1));
                _restPomoM.getAndDecrement();
                _restPomoS.getAndDecrement();
            } else if (_restPomoS.get() == 0) {
                _restPomoM.getAndDecrement();
                _restPomoS.set(60);
                _clock.setText("%02d：00".formatted(_restPomoM.get()));
            } else {
                _clock.setText("%02d：%02d".formatted(_restPomoM.get(), _restPomoS.get()));
                _restPomoS.getAndDecrement();
            }
            _restPomoDuration.getAndDecrement();
        } else if (_restPomoDuration.get() == 0) {
            _clock.setText("%02d：00".formatted(_initPomo));
        } else {
            _clock.setText("00：00");
        }
    }
}
