pragma Singleton

import QtQuick

QtObject {
    enum BluetoothState {
        DISABLED,
        ENABLED,
        SCANNING,
        CONNECTED
    }
}
