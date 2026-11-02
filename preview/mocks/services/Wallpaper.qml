pragma Singleton
import QtQuick
import Quickshell

Singleton {
    property string path: ""
    property var files: []
    function set(file) {
        path = file;
    }
    function random() {
    }
    function generateTheme(file) {
    }
}
