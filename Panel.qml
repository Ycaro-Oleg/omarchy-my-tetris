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
  property int soundVolume: 55
  property int musicVolume: 15
  property string theme: "piano"
  property string look: "nes"
  property bool musicMuted: false
  readonly property var soundOptions: [
    { value: "thock", label: "Thock" },
    { value: "click", label: "Click" },
    { value: "chip", label: "Chip" },
    { value: "hush", label: "Hush" }
  ]
  readonly property var themeOptions: [
    { value: "piano", label: "Piano" },
    { value: "strings", label: "Strings" },
    { value: "music-box", label: "Box" }
  ]
  readonly property var lookOptions: [
    { value: "nes", label: "NES" },
    { value: "flat", label: "Flat" },
    { value: "brick", label: "Brick" },
    { value: "blocks", label: "Blocks" }
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

  function removeFromBar() {
    root.close()
    if (barProc.running) barProc.running = false
    barProc.command = ["omarchy", "plugin", "disable", "terminal.tetris"]
    barProc.running = true
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
    var nextTheme = String(data.theme || "piano")
    var themeOk = false
    for (var j = 0; j < themeOptions.length; j++)
      if (themeOptions[j].value === nextTheme) themeOk = true
    root.theme = themeOk ? nextTheme : "piano"
    var nextLook = String(data.look || "nes")
    var lookOk = false
    for (var k = 0; k < lookOptions.length; k++)
      if (lookOptions[k].value === nextLook) lookOk = true
    root.look = lookOk ? nextLook : "nes"
    root.musicMuted = data.music_muted === true
    var legacy = parseInt(data.volume, 10)
    var nextSoundVol = parseInt(data.sound_volume, 10)
    if (!isFinite(nextSoundVol) && isFinite(legacy)) nextSoundVol = legacy
    root.soundVolume = isFinite(nextSoundVol) ? Math.max(0, Math.min(100, nextSoundVol)) : 55
    var nextMusicVol = parseInt(data.music_volume, 10)
    root.musicVolume = isFinite(nextMusicVol) ? Math.max(0, Math.min(100, nextMusicVol)) : 15
  }

  function persist() {
    var payload = JSON.stringify({
      sound: root.sound,
      sound_volume: root.soundVolume,
      music_volume: root.musicVolume,
      theme: root.theme,
      look: root.look,
      music_muted: root.musicMuted
    }, null, 2) + "\n"
    configFile.setText(payload)
  }

  function preview() {
    if (previewProc.running) previewProc.running = false
    previewProc.command = [root.gamePath, "--preview", "--sound", root.sound, "--volume", String(root.soundVolume)]
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

  Process {
    id: barProc
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
          iconComponent: Component {
            TetrisMark {
              implicitWidth: Style.font.display
              implicitHeight: Style.font.display
              foreground: root.contentForeground
            }
          }
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
          text: "Look"
          foreground: root.contentForeground
          fontFamily: root.contentFontFamily
        }

        ButtonGroup {
          width: parent.width
          options: root.lookOptions
          value: root.look
          foreground: root.contentForeground
          background: root.bar ? root.bar.background : Color.background
          accent: Color.accent
          fontFamily: root.contentFontFamily
          onChanged: function(next) {
            root.look = next
            root.persist()
          }
        }

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
          text: root.soundVolume === 0 ? "Game  off" : "Game  " + root.soundVolume + "%"
          foreground: root.contentForeground
          fontFamily: root.contentFontFamily
        }

        PanelSlider {
          width: parent.width
          bar: root.bar
          value: root.soundVolume
          minimum: 0
          maximum: 100
          step: 5
          integer: true
          onReleased: function(next) {
            root.soundVolume = Math.round(next)
            root.persist()
            root.preview()
          }
        }

        PanelSectionHeader {
          text: "Music"
          foreground: root.contentForeground
          fontFamily: root.contentFontFamily
        }

        ButtonGroup {
          width: parent.width
          options: root.themeOptions
          value: root.theme
          foreground: root.contentForeground
          background: root.bar ? root.bar.background : Color.background
          accent: Color.accent
          fontFamily: root.contentFontFamily
          onChanged: function(next) {
            root.theme = next
            root.persist()
          }
        }

        PanelSectionHeader {
          text: root.musicMuted || root.musicVolume === 0 ? "Music level  off" : "Music level  " + root.musicVolume + "%"
          foreground: root.contentForeground
          fontFamily: root.contentFontFamily
        }

        PanelSlider {
          width: parent.width
          bar: root.bar
          value: root.musicVolume
          minimum: 0
          maximum: 100
          step: 5
          integer: true
          onReleased: function(next) {
            root.musicVolume = Math.round(next)
            root.persist()
          }
        }

        Toggle {
          width: parent.width
          label: "Mute music"
          description: "Leaves landing and score sounds on"
          checked: root.musicMuted
          foreground: root.contentForeground
          fontFamily: root.contentFontFamily
          onClicked: {
            root.musicMuted = !root.musicMuted
            root.persist()
          }
        }

        PanelSeparator { foreground: root.contentForeground }

        Button {
          width: parent.width
          text: "Remove from bar"
          foreground: root.contentForeground
          fontFamily: root.contentFontFamily
          onClicked: root.removeFromBar()
        }
      }
    }
  }
}
