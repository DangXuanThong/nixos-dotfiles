import Quickshell.Services.Pipewire

StatusIcon {
    property var sink: Pipewire.defaultAudioSink

    text: "\uf028"

    tooltipText: {
        if (!sink) return "No output device";
        var name = sink.description || sink.nickname;
        var pct = Math.round(sink.audio.volume * 100) + "%";
        return name + " • " + pct;
    }
}
