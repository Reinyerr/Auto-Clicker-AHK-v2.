#Requires AutoHotkey v2.0

; Clicking Loop Variables
global clickRunning := false
global defaultHotKey := "F1" ; Default Hotkey
Hotkey(defaultHotKey, ToggleClicker)
global clickHotKey := defaultHotKey
gToggle := ToggleClicker

; Creating GUI for AutoClicker
MyGui := Gui("+AlwaysOnTop", "AutoClicker Setup")
MyGui.SetFont("s10")

; Grabbing User Input 
MyGui.Add("Text", "xm w30", "Hours:")
editHours := MyGui.Add("Edit", "x+5 w40", "0")

MyGui.Add("Text", "x+5 w30", "Minutes:")
editMinutes := MyGui.Add("Edit", "x+5 w40", "0")

MyGui.Add("Text", "x+5 w30", "Seconds:")
editSeconds := MyGui.Add("Edit", "x+5 w40", "0")

MyGui.Add("Text", "x+5 w30", "Milliseconds:")
editMS := MyGui.Add("Edit", "x+5 w40", "0")



; Start/Stop Toggle Button
btnToggle := MyGui.Add("Button", "xm y+20 w100 h30", "Start")
btnToggle.OnEvent("Click", ToggleClicker)


; Hotkey input
MyGui.Add("Text", "xm w80", "HotKey: ")
btnSetHotkey := MyGui.Add("Button", "xm y+5 w80 h25", "Set Hotkey")
btnSetHotkey.OnEvent("Click", SetCustomHotkey)


MyGui.Show()
; Exiting The Script
MyGui.OnEvent("Close", (*) => ExitApp())
MyGui.OnEvent("Escape", (*) => ExitApp())



;After Start Is Clicked
ToggleClicker(*)
{
    global clickRunning, btnToggle

    if(clickRunning)
    {
        SetTimer(DoClick, 0)
        clickRunning := false
        btnToggle.Text := "Start"
        MsgBox("AutoClicker stopped")
    }
    else{
    totalMS := GetIntervalMS()
         if(totalMS < 1)
    {
        MsgBox("Please enter a valid interval (> 0 ms).")
        return
    }

    SetTimer(DoClick, totalMS)
    clickRunning := true
    btnToggle.Text := "Stop"
    MsgBox("AutoClicker starting")

    }
}

; Clicks For You
DoClick()
{
    Click
}

; Determines The Time Between Each Click
GetIntervalMS()
{
    global editHours, editMinutes, editSeconds, editMS
    hours := editHours.Value
    seconds := editSeconds.Value
    minutes := editMinutes.Value
    ms := editMS.Value

    return ((hours * 3600000) + (minutes*60000) + (seconds*1000) + ms)

}



; Setting Custom Hot Key (removes old one first)
SetCustomHotkey(*) {
    global clickHotKey, btnSetHotkey, defaultHotKey

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

    ; Create new mapping -> send the default key
    clickHotKey := newKey
    btnSetHotkey.Text := "Hotkey: " clickHotKey
    Hotkey(clickHotKey, (*) => Send("{" defaultHotKey "}"))
}


