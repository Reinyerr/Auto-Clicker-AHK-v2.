#Requires AutoHotkey v2.0

; ------------------- Variables -------------------
global clickRunning := false
global defaultHotKey := "F1" ; Default action key
Hotkey(defaultHotKey, ToggleClicker)
global clickHotKey := defaultHotKey

; ------------------- GUI -------------------
MyGui := Gui("+AlwaysOnTop", "AutoClicker Setup")
MyGui.SetFont("s10")

; Time inputs
MyGui.Add("Text", "xm w30", "Hours:")
editHours := MyGui.Add("Edit", "x+5 w40", "0")

MyGui.Add("Text", "x+5 w30", "Minutes:")
editMinutes := MyGui.Add("Edit", "x+5 w40", "0")

MyGui.Add("Text", "x+5 w30", "Seconds:")
editSeconds := MyGui.Add("Edit", "x+5 w40", "0")

MyGui.Add("Text", "x+5 w30", "Milliseconds:")
editMS := MyGui.Add("Edit", "x+5 w40", "0")

; Start/Stop Button
btnToggle := MyGui.Add("Button", "xm y+20 w100 h30", "Start")
btnToggle.OnEvent("Click", ToggleClicker)

; Hotkey input
txtHotkey := MyGui.Add("Text", "xm w120", "HotKey: " clickHotKey)
btnSetHotkey := MyGui.Add("Button", "xm y+5 w100 h25", "Set Hotkey")
btnSetHotkey.OnEvent("Click", SetCustomHotkey)

MyGui.Show()

; Close GUI = Exit script
MyGui.OnEvent("Close", (*) => ExitApp())
MyGui.OnEvent("Escape", (*) => ExitApp())


; Toggle start/stop from GUI or hotkey
ToggleClicker(*) {
    global clickRunning, btnToggle

    if (clickRunning) {
        SetTimer(DoClick, "Off")    ; stop
        clickRunning := false
        btnToggle.Text := "Start"
        MsgBox("AutoClicker stopped")
    } else {
        totalMS := GetIntervalMS()
        if (totalMS < 1) {
            MsgBox("Please enter a valid interval (> 0 ms).")
            return
        }
        SetTimer(DoClick, totalMS)  ; start
        clickRunning := true
        btnToggle.Text := "Stop"
        MsgBox("AutoClicker starting")
    }
}

; Perform the click
DoClick() {
    Click
}

; Calculate interval in ms
GetIntervalMS() {
    global editHours, editMinutes, editSeconds, editMS
    hours := editHours.Value
    minutes := editMinutes.Value
    seconds := editSeconds.Value
    ms := editMS.Value

    return ((hours * 3600000) + (minutes * 60000) + (seconds * 1000) + ms)
}

; Custom hotkey mapping
SetCustomHotkey(*) {
    global clickHotKey, defaultHotKey, btnSetHotkey, txtHotkey

    ih := InputHook("L1 V", "{Enter}")
    ih.Start()
    ih.Wait()

    newKey := GetKeyName(ih.Input)

    if (newKey = "" || newKey = "Enter") {
        MsgBox("Invalid hotkey.")
        return
    }

    ; Remove old mapping
    if (clickHotKey != "" && clickHotKey != defaultHotKey) {
        try Hotkey(clickHotKey)  ; unmap previous custom key
    }

    ; Set new mapping -> send the default hotkey
    clickHotKey := newKey
    Hotkey(clickHotKey, (*) => Send("{" defaultHotKey "}"))

    ; Update GUI text
    txtHotkey.Text := "HotKey: " clickHotKey " (→ " defaultHotKey ")"
}


; ------------------- Hotkeys -------------------

; Pause clicker
F3:: {
    global clickRunning, btnToggle
    SetTimer(DoClick, "Off") ; always stop
    if (clickRunning) {
        clickRunning := false
        btnToggle.Text := "Start"
        MsgBox("AutoClicker paused")
    }
}
