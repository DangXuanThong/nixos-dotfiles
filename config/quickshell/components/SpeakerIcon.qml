import Quickshell.Services.Pipewire
import QtQuick

StatusIcon {
    id: speakerRoot
    implicitWidth: 18
    implicitHeight: 18

    PwObjectTracker {
        objects: [sink]
    }

    property var sink: Pipewire.defaultAudioSink
    property real volume: sink ? sink.audio.volume : 0
    property bool muted: !sink || sink.audio.muted || volume <= 0

    property string iconSource: {
        if (muted) return "../assets/volume_mute.svg";
        if (volume <= 0.30) return "../assets/volume_low.svg";
        if (volume <= 0.60) return "../assets/volume_med.svg";
        return "../assets/volume_high.svg";
    }

    Image {
        source: speakerRoot.iconSource
        sourceSize.width: 18
        sourceSize.height: 18
        width: 18
        height: 18
    }

    tooltipText: {
        if (!sink) return "No output device";
        var name = sink.description || sink.nickname;
        var pct = Math.round(sink.audio.volume * 100) + "%";
        return name + " • " + pct;
    }
}
