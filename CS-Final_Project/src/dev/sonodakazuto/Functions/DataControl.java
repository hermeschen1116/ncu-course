package dev.sonodakazuto.Functions;

import java.io.*;
import java.util.HashMap;

public class DataControl {
    public static int loadTaskData(HashMap<String, String> _taskDataList) throws IOException {
        try {
            String filePath = "src/dev/sonodakazuto/SavaFiles/savedTaskList.txt";
            FileReader _inputFile = new FileReader(filePath);
            BufferedReader inputFile = new BufferedReader(_inputFile);
            int taskCnt = 0;
            while (inputFile.ready()) {
                _taskDataList.put("vboxTaskBanner" + taskCnt, inputFile.readLine());
                taskCnt++;
            }
            inputFile.close();
            File _targetFile = new File(filePath);
            _targetFile.delete();
            return _taskDataList.size();
        } catch (FileNotFoundException e) {
            System.out.println("File Does Not Exist");
            return 0;
        }
    }

    public static void saveTaskData(HashMap<String, String> _taskDataList) throws IOException {
        String filePath = "src/dev/sonodakazuto/SavaFiles/savedTaskList.txt";
        FileWriter _outputFile = new FileWriter(filePath);
        BufferedWriter outputFile = new BufferedWriter(_outputFile);
        for (String _taskData : _taskDataList.values()) {
            outputFile.write(_taskData);
            outputFile.newLine();
        }
        outputFile.close();
    }
}
