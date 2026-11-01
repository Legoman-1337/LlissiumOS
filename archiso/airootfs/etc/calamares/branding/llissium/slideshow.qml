import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

// Слайдшоу установщика LlissiumOS — Deep Eclipse
Rectangle {
    id: root
    color: "#08040C"

    property int step: 0
    readonly property var steps: [
        { title: "Добро пожаловать в LlissiumOS", text: "Дистрибутив Arch Linux для гейминга и вайбкодинга под глубоким затмением." },
        { title: "Гейминг из коробки", text: "Steam, Lutris, Wine, GameMode и MangoHud уже установлены. GE-Proton добавляется автоматически при первом входе." },
        { title: "Вайбкодинг", text: "kitty с неоновой темой, zsh, Git, Rust, Python и Node.js готовы к работе сразу после установки." },
        { title: "Deep Eclipse", text: "Тёмно-пурпурная тема с матовым стеклом и центрированной панелью. Погружайтесь в затмение." }
    ]

    Timer {
        interval: 6000
        running: true
        repeat: true
        onTriggered: root.step = (root.step + 1) % root.steps.length
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: parent.width * 0.7
        spacing: 32

        Item {
            Layout.alignment: Qt.AlignHCenter
            width: 220
            height: 220

            // корона
            Rectangle {
                anchors.centerIn: parent
                width: 220
                height: 220
                radius: 110
                color: "transparent"
                opacity: 0.9

                Rectangle {
                    anchors.fill: parent
                    radius: 110
                    color: "#C026D3"
                    opacity: 0.25
                }
            }

            // лимб
            Rectangle {
                anchors.centerIn: parent
                width: 156
                height: 156
                radius: 78
                color: "#F59E0B"
                opacity: 0.9
            }

            // диск луны
            Rectangle {
                anchors.centerIn: parent
                width: 148
                height: 148
                radius: 74
                color: "#050208"
            }
        }

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            text: root.steps[root.step].title
            font.pointSize: 26
            font.bold: true
            color: "#E36BF5"
        }

        Label {
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            text: root.steps[root.step].text
            font.pointSize: 14
            color: "#B9A8CC"
        }

        Row {
            Layout.alignment: Qt.AlignHCenter
            spacing: 10
            Repeater {
                model: root.steps.length
                Rectangle {
                    width: index === root.step ? 26 : 10
                    height: 10
                    radius: 5
                    color: index === root.step ? "#C026D3" : "#3A2A4A"
                    Behavior on width { NumberAnimation { duration: 200 } }
                }
            }
        }
    }
}
