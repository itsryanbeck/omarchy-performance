import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons as Commons
import qs.Ui
import qs.Commons

BarWidget {
  id: root
  moduleName: "local.performance"

  property real cpuPercent: 0
  property real memoryPercent: 0
  property real memoryUsedGiB: 0
  property real memoryTotalGiB: 0
  property real previousTotal: -1
  property real previousIdle: -1
  property int gpuBusy: -1
  property int gpuFrequency: -1
  property bool hasReading: false

  Commons.Translations { id: strings; directory: Qt.resolvedUrl("i18n") }

  function refresh() {
    if (!probe.running) probe.running = true
  }

  function acceptReading(raw) {
    try {
      var m = JSON.parse(raw)
      var total = Number(m.cpuTotal)
      var idle = Number(m.cpuIdle)
      if (previousTotal >= 0 && total > previousTotal) {
        var elapsed = total - previousTotal
        cpuPercent = Math.max(0, Math.min(100, Math.round(100 * (elapsed - (idle - previousIdle)) / elapsed)))
      }
      previousTotal = total
      previousIdle = idle
      var memTotal = Number(m.memTotal)
      var memAvailable = Number(m.memAvailable)
      if (memTotal > 0) {
        memoryPercent = Math.max(0, Math.min(100, Math.round(100 * (memTotal - memAvailable) / memTotal)))
        memoryUsedGiB = (memTotal - memAvailable) / 1048576
        memoryTotalGiB = memTotal / 1048576
      }
      gpuBusy = m.gpuBusy === null ? -1 : Number(m.gpuBusy)
      gpuFrequency = m.gpuFreq === null ? -1 : Number(m.gpuFreq)
      hasReading = true
    } catch (e) {
      // Keep the most recent valid reading if a probe is interrupted.
    }
  }

  readonly property string gpuSummary: gpuBusy >= 0 ? gpuBusy + "%" : gpuFrequency >= 0 ? gpuFrequency + " MHz" : "—"
  readonly property string detailText: strings.t("panel.title") + "\n" +
    strings.t("panel.cpu") + ": " + cpuPercent + "%\n" +
    strings.t("panel.memory") + ": " + memoryUsedGiB.toFixed(1) + " / " + memoryTotalGiB.toFixed(1) + " GiB (" + memoryPercent + "%)\n" +
    strings.t("panel.graphics") + ": " + gpuSummary

  implicitWidth: content.implicitWidth + Style.space(16)
  implicitHeight: barSize

  Row {
    id: content
    anchors.centerIn: parent
    spacing: Style.space(9)

    Text {
      textFormat: Text.PlainText
      text: strings.t("panel.cpu") + " " + (root.hasReading ? root.cpuPercent + "%" : "—")
      color: root.bar ? root.bar.barForeground : "white"
      font.family: root.bar ? root.bar.fontFamily : "monospace"
      font.pixelSize: Style.font.bodySmall
      anchors.verticalCenter: parent.verticalCenter
    }
    Text {
      textFormat: Text.PlainText
      text: "RAM " + (root.hasReading ? root.memoryPercent + "%" : "—")
      color: root.bar ? root.bar.barForeground : "white"
      font.family: root.bar ? root.bar.fontFamily : "monospace"
      font.pixelSize: Style.font.bodySmall
      anchors.verticalCenter: parent.verticalCenter
    }
    Text {
      textFormat: Text.PlainText
      text: "GPU " + (root.hasReading ? root.gpuSummary : "—")
      color: root.bar ? root.bar.barForeground : "white"
      font.family: root.bar ? root.bar.fontFamily : "monospace"
      font.pixelSize: Style.font.bodySmall
      anchors.verticalCenter: parent.verticalCenter
    }
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onEntered: if (root.bar) root.bar.showTooltip(root, root.detailText)
    onExited: if (root.bar) root.bar.hideTooltip(root)
  }

  Process {
    id: probe
    command: ["bash", Qt.resolvedUrl("collect.sh").toString().replace("file://", "")]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.acceptReading(text)
    }
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }
}
