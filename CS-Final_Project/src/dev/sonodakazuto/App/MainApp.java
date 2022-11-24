package dev.sonodakazuto.App;

import dev.sonodakazuto.Functions.DataControl;
import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.image.Image;
import javafx.stage.Stage;

import java.io.IOException;
import java.util.Objects;

import static dev.sonodakazuto.App.MainController.taskDataList;

public class MainApp extends Application {

    public static void main(String[] args) {
        launch(args);
    }

    @Override
    public void start(Stage primaryStage) throws Exception {
        Parent root = FXMLLoader.load(Objects.requireNonNull(getClass().getResource("MainView.fxml")));
        primaryStage.setTitle("Todopomo");
        primaryStage.getIcons().add(new Image("dev/sonodakazuto/res/image/appIcon_minase_inori.png"));
        primaryStage.setResizable(false);
        primaryStage.setScene(new Scene(root, 1110, 645));
        // save All Task
        primaryStage.setOnCloseRequest(e -> {
            try {
                DataControl.saveTaskData(taskDataList);
            } catch (IOException ioException) {
                ioException.printStackTrace();
            }
        });
        primaryStage.show();
    }
}
