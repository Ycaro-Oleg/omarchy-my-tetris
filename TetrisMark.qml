import QtQuick
import QtQuick.Effects

Item {
  id: root
  property color foreground: "#ffffff"

  Image {
    id: mark
    anchors.fill: parent
    source: Qt.resolvedUrl("icon.svg")
    fillMode: Image.PreserveAspectFit
    sourceSize.width: Math.max(24, width * 2)
    sourceSize.height: Math.max(24, height * 2)
    visible: false
    cache: true
  }

  MultiEffect {
    anchors.fill: mark
    source: mark
    colorization: 1
    colorizationColor: root.foreground
  }
}
