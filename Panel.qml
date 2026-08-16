import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "terminal.tetris"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  readonly property var barIdentity: hostWidget || root

  readonly property color contentForeground: bar ? bar.foreground : Color.foreground
  readonly property string contentFontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property string pluginDir: String(Qt.resolvedUrl(".")).replace(/^file:\/\//, "").replace(/\/$/, "")
  readonly property string gamePath: pluginDir + "/omarchy-tetris"
  readonly property string configPath: Quickshell.env("HOME") + "/.local/state/omarchy/tetris.json"

  property string sound: "thock"
  property int volume: 55
  readonly property var soundOptions: [
    { value: "thock", label: "Thock" },
    { value: "click", label: "Click" },
    { value: "chip", label: "Chip" },
    { value: "hush", label: "Hush" }
  ]

  function open() {
    configFile.reload()
    root.controller.show()
  }

  function close() {
    root.controller.hide()
  }

  function toggle() {
    if (root.opened) root.close()
    else root.open()
  }

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  function play() {
    if (!root.bar) return
    root.close()
    root.bar.run("omarchy-launch-or-focus-tui --app-id=org.omarchy.tetris " + root.gamePath)
  }

  function applyConfig(raw) {
    var data = {}
    try { data = JSON.parse(raw || "{}") } catch (e) { data = {} }
    if (!data || typeof data !== "object") data = {}
    var nextSound = String(data.sound || "thock")
    var known = false
    for (var i = 0; i < soundOptions.length; i++)
      if (soundOptions[i].value === nextSound) known = true
    root.sound = known ? nextSound : "thock"
    var nextVolume = parseInt(data.volume, 10)
    root.volume = isFinite(nextVolume) ? Math.max(0, Math.min(100, nextVolume)) : 55
  }

  function persist() {
    var payload = JSON.stringify({ sound: root.sound, volume: root.volume }, null, 2) + "\n"
    configFile.setText(payload)
  }

  function preview() {
    if (previewProc.running) previewProc.running = false
    previewProc.command = [root.gamePath, "--preview", "--sound", root.sound, "--volume", String(root.volume)]
    previewProc.running = true
  }

  FileView {
    id: configFile
    path: root.configPath
    watchChanges: true
    atomicWrites: true
    printErrors: false
    onLoaded: root.applyConfig(text())
    onLoadFailed: root.applyConfig("{}")
    onFileChanged: reload()
  }

  Process {
    id: previewProc
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(320))
    contentHeight: panel.fittedContentHeight(content.implicitHeight)

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }
      Keys.onReturnPressed: root.play()
      Keys.onEnterPressed: root.play()

      Column {
        id: content
        width: parent.width
        spacing: Style.space(10)

        PanelHero {
          title: "Tetris"
          meta: "Classic · Sprint · Ultra"
          foreground: root.contentForeground
          fontFamily: root.contentFontFamily
        }

        Button {
          width: parent.width
          text: "Play"
          foreground: root.contentForeground
          fontFamily: root.contentFontFamily
          onClicked: root.play()
        }

        PanelSeparator { foreground: root.contentForeground }

        PanelSectionHeader {
          text: "Landing"
          foreground: root.contentForeground
          fontFamily: root.contentFontFamily
        }

        ButtonGroup {
          width: parent.width
          options: root.soundOptions
          value: root.sound
          foreground: root.contentForeground
          background: root.bar ? root.bar.background : Color.background
          accent: Color.accent
          fontFamily: root.contentFontFamily
          onChanged: function(next) {
            root.sound = next
            root.persist()
            root.preview()
          }
        }

        PanelSectionHeader {
          text: root.volume === 0 ? "Volume  off" : "Volume  " + root.volume + "%"
          foreground: root.contentForeground
          fontFamily: root.contentFontFamily
        }

        PanelSlider {
          width: parent.width
          bar: root.bar
          value: root.volume
          minimum: 0
          maximum: 100
          step: 5
          integer: true
          onReleased: function(next) {
            root.volume = Math.round(next)
            root.persist()
            root.preview()
          }
        }
      }
    }
  }
}
