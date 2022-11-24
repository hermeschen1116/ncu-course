package dev.sonodakazuto.Functions;

import javafx.scene.control.TextField;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Objects;

public class InputAnalysis {
    // preprocess the original data by splitting it and test if it contains enough data
    static String[] getPostNewTaskData(String _originalInput) {
        String[] tmp = _originalInput.split(" ");
        int tmpLen = tmp.length;
        String[] _postData;
        // check if it contains enough data
        if (tmpLen == 2 || tmpLen == 3) {
            _postData = tmp;
        } else {
            _postData = new String[]{""};
        }
        return _postData;
    }

    // get current time in different pattern
    public static String getCurrentTime(Integer mode) {
        String pattern = switch (mode) {
            case 7 -> "yyyy-MM-dd";
            case 6 -> "MM-dd";
            case 5 -> "HH:mm";
            case 4 -> "mm";
            case 3 -> "HH";
            case 2 -> "dd";
            case 1 -> "MM";
            case 0 -> "yyyy";
            default -> "yyyy-MM-dd@HH:mm";
        };
        DateTimeFormatter dtf = DateTimeFormatter.ofPattern(pattern);
        LocalDateTime now = LocalDateTime.now();
        return dtf.format(now);
    }

    // check if it is a leap year
    static boolean getLeapYearStatus(Integer _year) {
        return _year % 4 == 0 || _year % 400 == 0 && _year % 100 != 0;
    }

    // check if the format of month is valid and check the month type(by day)
    static String[] checkMonth(String _month) {
        String[] bigMonth = new String[]{"1", "3", "5", "7", "8", "10", "12"};
        String[] smallMonth = new String[]{"4", "6", "9", "11"};
        int month = Integer.parseInt(_month);
        int currentMonth = Integer.parseInt(getCurrentTime(1));
        if (month >= currentMonth && month >= 1 && Integer.parseInt(_month) <= 12) {
            for (int i = 0; i < 7; i++) {
                if (Objects.equals(_month, bigMonth[i])) {
                    // big month
                    return new String[]{_month, "1"};
                }
            }
            for (int i = 0; i < 4; i++) {
                if (Objects.equals(_month, smallMonth[i])) {
                    // small month
                    return new String[]{_month, "0"};
                }
            }
            if (Objects.equals(_month, "2")) {
                // February
                return new String[]{_month, "-1"};
            }
        }
        return new String[]{"-1"};
    }

    // check if the format of day is valid
    static String checkDay(String _day, String _month) {
        String[] month = checkMonth(_month);
        int currentYear = Integer.parseInt(getCurrentTime(0));
        int currentDay = Integer.parseInt(getCurrentTime(2));
        int day = Integer.parseInt(_day);
        if (!Objects.equals(month[0], "-1")) {
            if (Objects.equals(month[1], "1")) {
                if (day <= currentDay && day >= 31) {
                    day = -1;
                }
            } else if (Objects.equals(month[1], "0")) {
                if (day <= currentDay && day >= 30) {
                    day = -1;
                }
            } else {
                if (getLeapYearStatus(currentYear)) {
                    if (day <= currentDay && day >= 29) {
                        day = -1;
                    }
                } else {
                    if (day <= currentDay && day >= 28) {
                        day = -1;
                    }
                }
            }
        }
        return String.valueOf(day);
    }

    // check if the format of time is valid
    static String checkTime(String _hour, String _minute) {
        int hour = Integer.parseInt(_hour);
        int minute = Integer.parseInt(_minute);
        String time;
        if (hour >= 0 && hour <= 23) {
            if (minute >= 0 && minute <= 59) {
                time = "%s：%s".formatted(_hour, _minute);
            } else {
                time = "-1";
            }
        } else {
            time = "-1";
        }
        return time;
    }

    // check if the date is today
    public static boolean checkToday(String _month, String _day) {
        String tmp = "%02d-%02d".formatted(Integer.parseInt(_month), Integer.parseInt(_day));
        return tmp.equals(getCurrentTime(6));
    }

    // preprocess the date data and split it
    static String[] getPostTimeData(String _originalTimeData) {
        String[] postTimeData;
        if (_originalTimeData.contains("@")) {
            String[] _postTimeData = _originalTimeData.toLowerCase().split("@");
            if (_postTimeData[0].contains("-")) {
                String[] _date = _postTimeData[0].split("-");
                if (_postTimeData[1].contains(":")) {
                    String[] _time = _postTimeData[1].split(":");
                    // date with month, day, time
                    postTimeData = new String[]{"1", _date[0], _date[1], _time[0], _time[1]};
                } else {
                    postTimeData = new String[]{"#"};
                }
            } else {
                postTimeData = new String[]{"#"};
            }
        } else {
            if (_originalTimeData.contains("-")) {
                String[] _date = _originalTimeData.split("-");
                if (_date.length == 2) {
                    // only date
                    postTimeData = new String[]{"0", _date[0], _date[1]};
                } else {
                    postTimeData = new String[]{"#"};
                }
            } else if (_originalTimeData.contains(":")) {
                String[] _time = _originalTimeData.split(":");
                if (_time.length == 2) {
                    // only time, so it means this happens today
                    postTimeData = new String[]{"-1", _time[0], _time[1]};
                } else {
                    postTimeData = new String[]{"#"};
                }
            } else {
                postTimeData = new String[]{"#"};
            }
        }
        return postTimeData;
    }

    // check all date and time data
    public static String checkTimeData(String _originalTimeData) {
        String[] postTimeData = getPostTimeData(_originalTimeData);
        String processedTimeData;
        if (!Objects.equals(postTimeData[0], "#")) {
            if (Objects.equals(postTimeData[0], "1")) {
                String[] month = checkMonth(postTimeData[1]);
                String day = checkDay(postTimeData[2], postTimeData[1]);
                String time = checkTime(postTimeData[3], postTimeData[4]);
                if (!Objects.equals(month[0], "-1") && !Objects.equals(day, "-1") && !Objects.equals(time, "-1")) {
                    // date with month, day, time
                    if (checkToday(month[0], day)) {
                        processedTimeData = "Today %s".formatted(time);
                    } else {
                        processedTimeData = "%s %s %s".formatted(month[0], day, time);
                    }
                } else {
                    processedTimeData = "-1";
                }
            } else if (Objects.equals(postTimeData[0], "0")) {
                String[] month = checkMonth(postTimeData[1]);
                String day = checkDay(postTimeData[2], postTimeData[1]);
                if (!Objects.equals(month[0], "-1") && !Objects.equals(day, "-1")) {
                    // only date
                    if (checkToday(month[0], day)) {
                        processedTimeData = "Today";
                    } else {
                        processedTimeData = "%s %s".formatted(month[0], day);
                    }
                } else {
                    processedTimeData = "-1";
                }
            } else {
                String time = checkTime(postTimeData[3], postTimeData[4]);
                if (!Objects.equals(time, "-1")) {
                    // only time, so it means this happens todayˋ
                    processedTimeData = "Today %s".formatted(time);
                } else {
                    processedTimeData = "-1";
                }
            }
        } else {
            processedTimeData = "-1";
        }
        return processedTimeData;
    }

    //make preprocessed data into final output
    public static String[] getNewTaskData(String _originalInput) {
        String[] postData = getPostNewTaskData(_originalInput);
        String[] processedInput;
        int postDataLen = postData.length;
        if (!Objects.equals(postData[0], "")) {
            if (postDataLen == 2) {
                processedInput = new String[]{postData[0], "Today", postData[1]};
            } else {
                String timeData = checkTimeData(postData[1]);
                if (!Objects.equals(timeData, "-1")) {
                    processedInput = new String[]{postData[0], timeData, postData[2]};
                } else {
                    processedInput = new String[]{"", "-1"};
                }
            }
        } else {
            processedInput = new String[]{"", "-1"};
        }
        return processedInput;
    }

    // format task time data
    public static String taskTimeFormatter(String _timeData) {
        String formattedTimeData;
        String[] timeData = _timeData.split(" ");
        if (Objects.equals(timeData[0], "Today")) {
            if (timeData.length == 2) {
                formattedTimeData = "Today@%s".formatted(timeData[1]);
            } else {
                formattedTimeData = "Today";
            }
        } else {
            if (timeData.length == 3) {
                formattedTimeData = "%s-%s@%s".formatted(timeData[0], timeData[1], timeData[2]);
            } else {
                formattedTimeData = "%s-%s".formatted(timeData[0], timeData[1]);
            }
        }
        return formattedTimeData;
    }

    // show error message in textfield
    public static void showErrorMessage(TextField _inputBox) {
        _inputBox.setText("Invalid Input");
        _inputBox.setStyle("-fx-text-fill: #e21818");
    }

    // check modify task data
    public static String[] checkModifyTaskData(String _originalInputDat) {
        String[] tmp = _originalInputDat.split(";");
        String[] _modifyTaskData = new String[]{"", "", ""};
        for (String _element : tmp) {
            String[] pairData = getPostNewTaskData(_element);
            if (pairData.length != 0) {
                String label = pairData[0].toLowerCase();
                switch (label) {
                    case "name":
                        _modifyTaskData[0] = pairData[1];
                        break;
                    case "date":
                    case "time":
                        String timeData = checkTimeData(pairData[1]);
                        if (!Objects.equals(timeData, "-1")) {
                            _modifyTaskData[1] = taskTimeFormatter(timeData);
                        } else {
                            _modifyTaskData[1] = "-1";
                        }
                        break;
                    case "subject":
                        _modifyTaskData[2] = pairData[1];
                        break;
                    default:
                        return new String[]{"", "-1"};
                }
            } else {
                _modifyTaskData[1] = "-1";
            }
        }
        return _modifyTaskData;
    }
}
