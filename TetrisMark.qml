import QtQuick
import QtQuick.Effects
import qs.Commons

Item {
  id: root
  property color foreground: Color.foreground
  readonly property bool darkSurface: {
    var c = Color.bar.background
    return (c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722) < 0.5
  }

  Image {
    id: mark
    anchors.fill: parent
    source: Qt.resolvedUrl(root.darkSurface ? "icon-white.svg" : "icon.svg")
    fillMode: Image.PreserveAspectFit
    sourceSize.width: Math.max(24, width * 2)
    sourceSize.height: Math.max(24, height * 2)
    visible: false
    cache: false
  }

  MultiEffect {
    anchors.fill: mark
    source: mark
    colorization: 1
    colorizationColor: root.foreground
  }
}
