pragma Singleton

import QtQuick

QtObject {
    enum BatteryState {
        CHARGING,
        PROTECTED,
        POWERSAVE,
        UNKNOWN,
        DEFAULT
    }
}
