import Quickshell.Services.Pipewire
import QtQuick

StatusIcon {
    property var sink: Pipewire.defaultAudioSink

    Text {
        text: "\uf028"
        color: "#ffffff"
        font.pixelSize: 13
        font.family: "JetBrainsMono Nerd Font"
        renderType: Text.NativeRendering
    }

    tooltipText: {
        if (!sink) return "No output device";
        var name = sink.description || sink.nickname;
        var pct = Math.round(sink.audio.volume * 100) + "%";
        return name + " • " + pct;
    }
}
