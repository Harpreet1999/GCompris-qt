/* GCompris - playpiano.qml
 *
 * Copyright (C) 2016 Johnny Jazeix <jazeix@gmail.com>
 *
 * Authors:
 *   Beth Hadley <bethmhadley@gmail.com> (GTK+ version)
 *   Johnny Jazeix <jazeix@gmail.com> (Qt Quick port)
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU General Public License as published by
 *   the Free Software Foundation; either version 3 of the License, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details.
 *
 *   You should have received a copy of the GNU General Public License
 *   along with this program; if not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.1
import QtQuick.Controls 1.0

import "../../core"
import "playpiano.js" as Activity
import "melodies.js" as Dataset

ActivityBase {
    id: activity

    onStart: focus = true
    onStop: {}

    property bool horizontalLayout: background.width > background.height ? true : false

    pageComponent: Rectangle {
        id: background
        anchors.fill: parent
        color: "#ABCDEF"
        signal start
        signal stop

        Component.onCompleted: {
            activity.start.connect(start)
            activity.stop.connect(stop)
        }

        // Add here the QML items you need to access in javascript
        QtObject {
            id: items
            property Item main: activity.main
            property alias background: background
            property GCAudio audioEffects: activity.audioEffects
            property alias bar: bar
            property alias bonus: bonus
            property alias staff2: staff2
            property string staffLength: "short"
        }

        onStart: { Activity.start(items) }
        onStop: { Activity.stop() }

        property int currentType: 1

        MultipleStaff {
            id: staff2
            width: horizontalLayout ? parent.width * 0.50 : parent.height * 0.5
            height: parent.height * 0.5
            nbStaves: 3
            clef: "bass"
            nbMaxNotesPerStaff: 8
            noteIsColored: true
            isMetronomeDisplayed: true
            anchors.right: parent.right
            anchors.top: instructionBox.bottom
            anchors.topMargin: parent.height * 0.13
            anchors.rightMargin: 20
        }

        Rectangle {
            id: instructionBox
            radius: 10
            width: background.width / 1.9
            height: horizontalLayout ? background.height / 5 : background.height / 4
            anchors.horizontalCenter: parent.horizontalCenter
            opacity: 0.8
            border.width: 6
            color: "white"
            border.color: "#87A6DD"

            GCText {
                id: instructionText
                color: "black"
                z: 3
                anchors.fill: parent
                anchors.rightMargin: parent.width * 0.1
                anchors.leftMargin: parent.width * 0.1
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.Fit
                wrapMode: Text.WordWrap
                text: Activity.instructions[bar.level - 1]
            }
        }

            Piano {
                id: piano
                width: horizontalLayout ? parent.width * 0.4 : parent.width * 0.45
                height: horizontalLayout ? parent.height * 0.45 : parent.width * 0.4
                anchors.left: parent.left
                anchors.leftMargin: horizontalLayout ? parent.width * 0.06 : parent.height * 0.01
                anchors.top: instructionBox.bottom
                anchors.topMargin: 70
                blackLabelsVisible: [4, 5, 6, 7, 8].indexOf(items.bar.level) == -1 ? false : true
                useSharpNotation: bar.level == 5 ? false : true
                onNoteClicked: {
                    onlyNote.value = note;
                    staff2.addNote(note, currentType, piano.useSharpNotation ? "sharp" : "flat", false)
                    var noteToPlay = 'qrc:/gcompris/src/activities/playpiano/resource/' + 'bass' + '_pitches/' + currentType + '/' + note + '.wav';
                    items.audioEffects.play(noteToPlay);
                }
                Note {
                    id: onlyNote
                    value: "1"
                    type: currentType
                    visible: false
                }
            }

            Row {
                id: optionsRow
                anchors.bottom: parent.bottom
                anchors.right: parent.right
                anchors.rightMargin: 50
                spacing: 30

                Image {
                    id: wholeNote
                    source: "qrc:/gcompris/src/activities/playpiano/resource/whole-note.svg"
                    sourceSize.width: 50
                    visible: bar.level == 1 || bar.level == 2 ? false : true
                    MouseArea{
                        anchors.fill: parent
                        onClicked: currentType = onlyNote.wholeNote
                    }
                }
                Image {
                    id: halfNote
                    source: "qrc:/gcompris/src/activities/playpiano/resource/half-note.svg"
                    sourceSize.width: 50
                    visible: wholeNote.visible
                    MouseArea{
                        anchors.fill: parent
                        onClicked: currentType = onlyNote.halfNote
                    }
                }
                Image {
                    id: quarterNote
                    source: "qrc:/gcompris/src/activities/playpiano/resource/quarter-note.svg"
                    sourceSize.width: 50
                    visible: wholeNote.visible
                    MouseArea{
                        anchors.fill: parent
                        onClicked: currentType = onlyNote.quarterNote
                    }
                }
                Image {
                    id: eighthNote
                    source: "qrc:/gcompris/src/activities/playpiano/resource/eighth-note.svg"
                    sourceSize.width: 50
                    visible: wholeNote.visible
                    MouseArea{
                        anchors.fill: parent
                        onClicked: currentType = onlyNote.eighthNote
                    }
                }
                Image {
                    id: playButton
                    source: "qrc:/gcompris/src/activities/playpiano/resource/play.svg"
                    sourceSize.width: 75
                    MouseArea{
                        anchors.fill: parent
                        onClicked: staff2.play()
                    }
                }
                Image {
                    id: clearButton
                    source: "qrc:/gcompris/src/activities/playpiano/resource/edit-clear.svg"
                    sourceSize.width: 75
                    MouseArea{
                        anchors.fill: parent
                        onClicked: staff2.eraseAllNotes()
                    }
                }

                Image {
                    id: openButton
                    source: "qrc:/gcompris/src/activities/playpiano/resource/open.svg"
                    sourceSize.width: 50
                    MouseArea{
                        anchors.fill: parent
                        onClicked: loadMelody()
                    }
                }
            }

//             GCDialogCheckBox {
//                 id: button
//                 anchors.top: parent.top
//                 onClicked: piano.useSharpNotation = !piano.useSharpNotation
//             }
//             GCText {
//                 text: qsTr("Change accidental style")
//             }
// 
//             Image {
//                 source: piano.useSharpNotation ? "qrc:/gcompris/src/activities/playpiano/resource/blacksharp.svg" : "qrc:/gcompris/src/activities/playpiano/resource/blackflat.svg"
//             }

        function loadMelody() {
            var data = Dataset.get();
            var selectedMusic = data.filter(function(item) { return item.title === 'Frère jacques'; });
            staff2.loadFromData(selectedMusic[0]["melody"]);
        }

        DialogHelp {
            id: dialogHelp
            onClose: home()
        }

        Bar {
            id: bar
            content: BarEnumContent { value: help | home | level }
            onHelpClicked: {
                displayDialog(dialogHelp)
            }
            onPreviousLevelClicked: Activity.previousLevel()
            onNextLevelClicked: Activity.nextLevel()
            onHomeClicked: activity.home()
        }

        Bonus {
            id: bonus
            Component.onCompleted: win.connect(Activity.nextLevel)
        }
    }

}