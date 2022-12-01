#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%

Global marks := RestoreMarks()

; SetTimer, UpdateGUI, 500

F1::ShowMarks()
F2::HideGuis()

; UpdateGUI:
    ; MouseGetPos, x, y
    ; GuiAtPosition(x, y)

RestoreMarks() {
    IniRead, saved_marks, saved_marks.ini, MARKS
    marks := {}
    Loop, Parse, saved_marks, "`n"
    {
        Array := StrSplit(A_LoopField, "=")
        coords := StrSplit(Array[2], "|")
        marks[Array[1]] := {x:coords[1], y:coords[2], priority:100, time_set:0}
    }
    return marks
}

; SysGet, mon, MonitorWorkArea
; x := monLeft
; y := monTop
; Gui, Show, x%x% y%y% NoActivate

GuiAtPosition(key, x, y) {
    Gui, %key%:New
    Gui, Font, S10, Arial Bold
    Gui, Color, FFFFFF
    Gui, Add, Text, cblack x8 y2, %key%
    Gui -Caption +LastFound +AlwaysOnTop +ToolWindow ; Lastfound for WinSet
    ; WinSet, TransColor, EEAA99 ; makes all EEAA99 colors invisible
    Gui, Show, x%x% y%y% w20 h20 NoActivate
    Return
}

HideGuis(){
    For key, value in marks{
        Gui, %key%: Hide
    }
}

ShowMarks() {
    For key, value in marks{
        GuiAtPosition(key, value.x - 7, value.y -7)
    }
}
