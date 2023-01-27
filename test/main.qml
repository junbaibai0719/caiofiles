import QtQuick.Controls
import QtQuick
import Controllers

ApplicationWindow {
    id: window
    width: 360
    height: 520
    visible: true

    
    Row {
        anchors.fill: parent
        

        Button {
            id: syncBtn
            text: qsTr("Sync read")
            onClicked:{controller.sync_read()}
        }
        Button {
            id: asyncBtn
            text: qsTr("Aync read")

            onClicked:{controller.async_read()}
        }
    }
    

    Controller {
        id: controller
    }
}

