import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "ycarooleg.tetris"

  readonly property string gamePath: Quickshell.env("HOME") + "/.config/omarchy/plugins/ycarooleg.tetris/omarchy-tetris"

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function launch() {
    if (!root.bar) return
    root.bar.run("omarchy-launch-or-focus-tui --app-id=org.omarchy.tetris " + root.gamePath)
  }

  IpcHandler {
    target: "ycarooleg.tetris"

    function open(): void {
      root.broadcast("launch")
    }

    function toggle(): void {
      root.broadcast("launch")
    }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "\uf11b"
    slotSize: Style.bar.iconSlot
    fontSize: Style.font.caption
    tooltipText: "Tetris"
    onPressed: root.launch()
  }
}
