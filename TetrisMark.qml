import QtQuick

Item {
  id: root
  property color foreground: "#ffffff"
  readonly property bool useWhite: {
    var c = root.foreground
    return (c.r * 0.2126 + c.g * 0.7152 + c.b * 0.0722) > 0.5
  }

  Image {
    anchors.fill: parent
    source: Qt.resolvedUrl(root.useWhite ? "icon-white.svg" : "icon.svg")
    fillMode: Image.PreserveAspectFit
    sourceSize.width: Math.max(24, width * 2)
    sourceSize.height: Math.max(24, height * 2)
    cache: false
    asynchronous: true
  }
}
