import QtQuick
import QtQuick.Controls
import "../../"
import "../../components"
import "../"

Item {
    id: root

    anchors.fill: parent


    PopupPage {
        anchors.fill: parent


        SettingCard {
            width: parent.width


            SectionTitle {
                text: "Appearance"
            }


            // =================================================================
            // Bar Transparency
            // =================================================================

            SettingRow {
                title: "Bar Transparency"
                subtitle: "Change top bar opacity"

                Row {
                    spacing: 10

                    Rectangle {
                        width: 35
                        height: 28
                        radius: 14

                        color: Theme.active

                        Text {
                            anchors.centerIn: parent
                            text: "-"
                            color: Theme.background
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                SettingsService.setBarOpacity(
                                    Math.max(
                                        0.0,
                                        SettingsService.barOpacity - 0.05
                                    )
                                )
                            }
                        }
                    }


                    Text {
                        width: 50

                        text:
                            Math.round(
                                SettingsService.barOpacity * 100
                            ) + "%"

                        color: Theme.text

                        horizontalAlignment:
                            Text.AlignHCenter
                    }


                    Rectangle {
                        width: 35
                        height: 28
                        radius: 14

                        color: Theme.active

                        Text {
                            anchors.centerIn: parent
                            text: "+"
                            color: Theme.background
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                SettingsService.setBarOpacity(
                                    Math.min(
                                        1.0,
                                        SettingsService.barOpacity + 0.05
                                    )
                                )
                            }
                        }
                    }
                }
            }


            Divider {}


            // =================================================================
            // Fonts
            // =================================================================

            SectionTitle {
                text: "Fonts"
            }


            SettingRow {
                title: "Interface Font"
                subtitle: "Default UI font for your user session"

                ComboBox {
                    id: interfaceFontBox

                    width: 260

                    model: SettingsService.availableFonts

                    currentIndex: {
                        var idx =
                            SettingsService.availableFonts.indexOf(
                                SettingsService.interfaceFont
                            )

                        return idx >= 0 ? idx : 0
                    }

                    onActivated: function(index) {
                        if (index >= 0 &&
                            index < SettingsService.availableFonts.length) {

                            SettingsService.setInterfaceFont(
                                SettingsService.availableFonts[index]
                            )
                        }
                    }
                }
            }


            Divider {}


            SettingRow {
                title: "Monospace Font"
                subtitle: "Terminal and monospace applications"

                ComboBox {
                    id: monospaceFontBox

                    width: 260

                    model: SettingsService.availableFonts

                    currentIndex: {
                        var idx =
                            SettingsService.availableFonts.indexOf(
                                SettingsService.monospaceFont
                            )

                        return idx >= 0 ? idx : 0
                    }

                    onActivated: function(index) {
                        if (index >= 0 &&
                            index < SettingsService.availableFonts.length) {

                            SettingsService.setMonospaceFont(
                                SettingsService.availableFonts[index]
                            )
                        }
                    }
                }
            }


            Divider {}


            SettingRow {
                title: "Font Size"
                subtitle: "Default UI and monospace size"

                Row {
                    spacing: 10

                    Rectangle {
                        width: 35
                        height: 28
                        radius: 14

                        color: Theme.active

                        Text {
                            anchors.centerIn: parent

                            text: "-"

                            color: Theme.background
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                SettingsService.setFontSize(
                                    SettingsService.fontSize - 1
                                )
                            }
                        }
                    }


                    Text {
                        width: 50

                        text:
                            SettingsService.fontSize + " pt"

                        color: Theme.text

                        horizontalAlignment:
                            Text.AlignHCenter
                    }


                    Rectangle {
                        width: 35
                        height: 28
                        radius: 14

                        color: Theme.active

                        Text {
                            anchors.centerIn: parent

                            text: "+"

                            color: Theme.background
                        }

                        MouseArea {
                            anchors.fill: parent

                            onClicked: {
                                SettingsService.setFontSize(
                                    SettingsService.fontSize + 1
                                )
                            }
                        }
                    }
                }
            }


            Divider {}


            SettingRow {
                title: "Apply Fonts"
                subtitle: "Apply the selected fonts user-wide"

                Rectangle {
                    width: 110
                    height: 34
                    radius: 17

                    color: Theme.active

                    Text {
                        anchors.centerIn: parent

                        text: "Apply"

                        color: Theme.background

                        font.bold: true
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            SettingsService.applyFonts()
                        }
                    }
                }
            }


            Divider {}


            // =================================================================
            // Existing placeholders
            // =================================================================

            SettingRow {
                title: "Corner Radius"
                subtitle: "Rounded UI"

                Text {
                    text: "Update Soon"
                    color: Theme.subtext
                }
            }


            Divider {}


            SettingRow {
                title: "Blur"
                subtitle: "Glass effect"

                Text {
                    text: "Update Soon"
                    color: Theme.subtext
                }
            }
        }
    }
}
