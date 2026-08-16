import QtQuick
import qs.Commons

Item {
  id: root
  property color foreground: "#ffffff"
  readonly property bool darkTheme: {
    var c = Color.background
    return (c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722) < 0.45
  }

  Image {
    anchors.fill: parent
    source: Qt.resolvedUrl(root.darkTheme ? "icon-white.svg" : "icon.svg")
    fillMode: Image.PreserveAspectFit
    sourceSize.width: Math.max(24, width * 2)
    sourceSize.height: Math.max(24, height * 2)
    cache: true
    asynchronous: true
  }
}
