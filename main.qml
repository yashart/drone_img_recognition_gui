import QtQuick 2.9
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.2
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQml 2.2
import Qt.labs.folderlistmodel 2.1
import FileIO 1.0
import Recognize 1.0


Window {
    visible: true
    width: 850
    height: 960
    title: qsTr("Sync Module");

    ColumnLayout {
        Label {
            id: folderNameLabel
            text: qsTr("Папка с фотографиями полёта:")
        }
        Button {
            text: qsTr("Выбрать")
            onClicked: {
                fileDialog.visible = true
            }
        }
        Label {
            text: qsTr("Задать начальное время: час:мин:сек.мс, например, 00:01:08.120")
        }
        TextField {
            id: timeTextField
            text : "00:00:00.000"
            inputMask: "99:99:99.999"
            inputMethodHints: Qt.ImhDigitsOnly
            validator: RegExpValidator { regExp: /^([0-5][0-9]):([0-5][0-9]):([0-5][0-9])\.([0-9][0-9][0-9])$ / }
        }
        Button {
            text: qsTr("Синхронизация")
            property date currentTime: new Date()
            property var currentTimeDouble
            onClicked: {

                //var timeString = currentTime.fromLocaleTimeString(Qt.locale(), timeTextField.text, Locale.ShortFormat)
                //currentTime.setTime(currentTime.getTime() + 20*60*1000);
                currentTime.setMinutes(timeTextField.text);
                currentTimeDouble = Date.parse('1970-01-01T' + timeTextField.text);

                console.log(folderModel.folder + " " + folderModel.count)
                var logText = "";
                for (var i = 0; i < folderModel.count; i++) {
                    console.log(folderModel.get(i, "fileName"));
                    logText += currentTimeDouble + " " + folderModel.get(i, "fileName") + "\n";
                    currentTimeDouble += 10;
                }
                syncFile.write(logText);
            }
        }
        Label {
            text: qsTr("Модуль рассчёта");
        }
        Label {
            text: qsTr("Время начала");
        }
        TextField {
            id: startTimeTextField
            text : "00:00:00.000"
            inputMask: "99:99:99.999"
            inputMethodHints: Qt.ImhDigitsOnly
            validator: RegExpValidator { regExp: /^([0-5][0-9]):([0-5][0-9]):([0-5][0-9])\.([0-9][0-9][0-9])$ / }
        }
        Label {
            text: qsTr("Широта, например, 55°04.61'N");
        }
        RowLayout {
            TextField {
                id: latDegreeTextField
            }
            Label {
                text: qsTr("°")
            }
            TextField {
                id: latMinuteTextField
            }
            Label {
                text: qsTr(".")
            }
            TextField {
                id: latSecondTextField
            }
            Label {
                text: qsTr("\'N")
            }
        }
        Label {
            text: qsTr("Долгота, например, 32°39.96'E");
        }
        RowLayout {
            TextField {
                id: lonDegreeTextField
            }
            Label {
                text: qsTr("°")
            }
            TextField {
                id: lonMinuteTextField
            }
            Label {
                text: qsTr(".")
            }
            TextField {
                id: lonSecondTextField
            }
            Label {
                text: qsTr("\'E")
            }
        }
        Label {
            text: qsTr("Высота")
        }
        RowLayout {
            Label {
                text: qsTr("Абсолютная коптера, м.");
            }
            TextField {
                id: heightTextField
            }
            Label {
                text: qsTr("Абсолютная земли, м.");

            }
            TextField {
                id: groundTextField
            }
        }
        Label {
            text: qsTr("Интервал для рассчёта, сек.");
        }
        TextField {
            id: intervalTextField
        }
        Label {
            text: qsTr("Частота, Гц");
        }
        TextField {
            id: frequencyTextField
        }
        Label {
            text: qsTr("Рысканье, градусы");
        }
        TextField {
            id: yawTextField
        }
        Button {
            id: calcButton
            text: qsTr("Посчитать")
            onClicked: {
                var syncText = syncFile.read()
                var currentTimeDouble = Date.parse('1970-01-01T' + startTimeTextField.text) / 10.0;
                var syncArray = syncText.split(".jpg")
                console.log(currentTimeDouble)
                var firstTime = syncArray[0].split(" ")[0]
                var startImgPos = 0;
                currentTimeDouble -= parseFloat(firstTime)/10.0;
                console.log(currentTimeDouble);
                for (var i = 0; i < syncArray.length; i++) {
                    if (syncArray[i].search(currentTimeDouble) != -1) {
                        startImgPos = i;
                        console.log("start time: " + i);
                        break;
                    }
                }
                var imgCount = parseFloat(intervalTextField.text) * 10;
                var latFloat = parseFloat(latDegreeTextField.text) +
                        parseFloat(latMinuteTextField.text)/60.0 +
                        parseFloat(latSecondTextField.text)/360000.0;
                var lonFloat = parseFloat(lonDegreeTextField.text) +
                        parseFloat(lonMinuteTextField.text)/60.0 +
                        parseFloat(lonSecondTextField.text)/360000.0;
                console.log(latFloat + " " + lonFloat)
                recognize.setLat(latFloat)
                recognize.setLon(lonFloat)
                recognize.setYaw(yawTextField.text)
                recognize.setHeight(parseFloat(heightTextField.text)-parseFloat(groundTextField.text))
                var recognizeText = ""
                currentTimeDouble = parseFloat(currentTimeDouble * 10) + parseFloat(firstTime)
                for (var i = startImgPos; i < startImgPos + imgCount; i=i+10.0/parseFloat(frequencyTextField.text)) {
                    var file1name = fileDialog.fileUrls[0] + "/" + folderModel.get(i, "fileName")
                    var file2name = fileDialog.fileUrls[0] + "/" + folderModel.get(i+1, "fileName")

                    file1name = file1name.replace("file://", "")
                    file2name = file2name.replace("file://", "")

                    recognize.calcOffset(file1name, file2name);

                    recognizeText += convert_decimal_time_to_text(currentTimeDouble) + " " +
                            convert_decimal_coord_to_text(recognize.lat) + "N " +
                            convert_decimal_coord_to_text(recognize.lon) + "E " +
                            Math.floor((recognize.height + parseFloat(groundTextField.text))*10.0)/10.0 + "\n";
                    console.log(recognize.lat + " " + recognize.lon + " " + recognize.yaw + " " + file1name)
                    currentTimeDouble += 10 * 100.0/parseFloat(frequencyTextField.text)
                }
                coordFile.write(recognizeText)
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Choose folder with imgs"
        selectFolder: true
        onAccepted: {
            folderNameLabel.text = "Папка с фотографиями полёта:\n" +
                    fileDialog.fileUrls
            console.log("You chose: " + fileDialog.fileUrls)
            folderModel.folder = fileDialog.fileUrls[0]
            var folderName = fileDialog.fileUrls[0] + "/sync.txt"
            folderName = folderName.replace("file://", "")
            var folderName2 = fileDialog.fileUrls[0] + "/coord.txt"
            folderName2 = folderName2.replace("file://", "")

            syncFile.source = folderName
            coordFile.source = folderName2
        }
        onRejected: {
            console.log("Canceled")
        }
        Component.onCompleted: visible = false
    }
    FolderListModel {
        id: folderModel
        nameFilters: ["*.jpg"]
    }
    FileIO {
        id: syncFile
        source: "sync.txt"
        onError: console.log(msg)
    }
    FileIO {
        id: coordFile
        source: "coord.txt"
        onError: console.log(msg)
    }
    Recognize {
        id: recognize
    }
    function convert_decimal_time_to_text(time) {
        var dectime = parseFloat(time);
        var textTime = "0:";
        textTime += Math.floor(dectime/60000.0) + ":"
        dectime -= Math.floor(dectime/60000.0)*60000
        textTime += Math.floor(dectime/1000.0) + "."
        dectime -= Math.floor(dectime/1000.0)*1000
        textTime += dectime
        return textTime
    }
    function convert_decimal_coord_to_text(coord) {
        var degrees = parseFloat(coord)
        var textDegrees = "" + Math.floor(degrees) + "°"
        degrees = parseFloat(degrees - Math.floor(degrees))
        degrees = parseFloat(degrees * 60.0)
        textDegrees += Math.floor(degrees) + "."
        degrees = parseFloat(degrees - Math.floor(degrees))
        degrees *= 36000000.0
        textDegrees += Math.floor(degrees) + "'"
        return textDegrees
    }
}
