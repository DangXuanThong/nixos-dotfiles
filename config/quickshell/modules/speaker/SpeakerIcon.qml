import Quickshell.Services.Pipewire
import QtQuick
import "../../components"

StatusIcon {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property bool muted: !sink || sink.audio.muted || sink.audio.volume <= 0
    readonly property int volume: !muted ? Math.round(sink.audio.volume * 100) : 0

    readonly property double designWidth: 15
    readonly property double designHeight: 15
    readonly property double contentScale: height / designHeight

    implicitWidth: designWidth * contentScale
    implicitHeight: designHeight * contentScale

    tooltipText: {
        if (!sink) return "No output device";
        var name = sink.description || sink.nickname;
        return name + " • " + volume + "%";
    }

    PwObjectTracker {
        objects: [root.sink]
    }

    SpeakerVolume {
        level: root.volume
        anchors.fill: parent
    }
}
