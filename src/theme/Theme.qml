pragma Singleton

import QtQuick
import "."
import "../services"

QtObject {
    // Colors

    property color background: ThemeManager.background
    property color active: ThemeManager.active
    property color activeBackground: "#262626"
    property color activeText: "#FFFFFF"
    property color text: ThemeManager.text
    property color subtext: ThemeManager.subtext
    property color icon: ThemeManager.icon
    property color border: ThemeManager.border
    property color iconFont: ThemeManager.iconFont
    property color surface: ThemeManager.surface
    property color surfaceAlt: ThemeManager.surfaceAlt
    property color muted: ThemeManager.muted
    property color hover: ThemeManager.hover
    property color selected: ThemeManager.selected

    property color success: ThemeManager.success
    property color warning: ThemeManager.warning
    property color danger: ThemeManager.danger

    property color workspaceActive: ThemeManager.workspaceActive
    property color workspaceOccupied: ThemeManager.workspaceOccupied
    property color workspaceEmpty: ThemeManager.workspaceEmpty
    property color workspaceUrgent: ThemeManager.workspaceUrgent

        // Workspace

    property color wsBackground: Qt.rgba(
        background.r,
        background.g,
        background.b,
        0.12
    )

    property color wsActive: ThemeManager.workspaceActive

    property color wsOccupied: ThemeManager.workspaceOccupied

    property color wsEmpty: ThemeManager.workspaceEmpty

    property color wsOverlay: Qt.rgba(
        background.r,
        background.g,
        background.b,
        0.80
    )

    property color wsUrgent: ThemeManager.workspaceUrgent
    // Metrics

    property bool barEnabled: Metrics.barEnabled

    property real barOpacity: ThemeManager.barOpacity

    property int borderWidth: ThemeManager.borderWidth
    property int cornerRadius: ThemeManager.cornerRadius

    property int blurRadius: ThemeManager.blurRadius
    property real transparency: ThemeManager.transparency

    property int notchRadius: ThemeManager.notchRadius
    property int notchHeight: Metrics.notchHeight
    property int exclusionGap: Metrics.exclusionGap
    property int spacing: Metrics.spacing

    property int notchPadding: Metrics.notchPadding
    property int notchHorizontalPadding: Metrics.notchHorizontalPadding
    property int notchVerticalPadding: Metrics.notchVerticalPadding
    property int notchSideMargin: Metrics.notchSideMargin

    property int lNotchMinWidth: Metrics.lNotchMinWidth
    property int lNotchMaxWidth: Metrics.lNotchMaxWidth

    property int cNotchMinWidth: Metrics.cNotchMinWidth
    property int cNotchMaxWidth: Metrics.cNotchMaxWidth

    property int rNotchMinWidth: Metrics.rNotchMinWidth
    property int rNotchMaxWidth: Metrics.rNotchMaxWidth

    property int dashboardWidth: Metrics.dashboardWidth
    property int dashboardHeight: Metrics.dashboardHeight

    property int notificationsWidth: Metrics.notificationsWidth
    property int notificationToastWidth: Metrics.notificationToastWidth
    property int networkPopupWidth: Metrics.networkPopupWidth

    property int popupMinWidth: Metrics.popupMinWidth
    property int popupMaxWidth: Metrics.popupMaxWidth
    property int popupMinHeight: Metrics.popupMinHeight
    property int popupMaxHeight: Metrics.popupMaxHeight
    property int popupPadding: Metrics.popupPadding

    property int wsDotSize: Metrics.wsDotSize
    property int wsActiveWidth: Metrics.wsActiveWidth
    property int wsSpacing: Metrics.wsSpacing
    property int wsPadding: Metrics.wsPadding
    property int wsRadius: ThemeManager.wsRadius

    property int animDuration: Metrics.animDuration 

    // Fonts
    property string fontFamily: SettingsService.interfaceFont
    property string monoFontFamily: SettingsService.monospaceFont
    property int fontSize: SettingsService.fontSize
}
