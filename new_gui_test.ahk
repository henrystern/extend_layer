#NoEnv
#SingleInstance, Force
SendMode, Input
SetBatchLines, -1
SetWorkingDir, %A_ScriptDir%
CoordMode, Mouse, Screen
SetMouseDelay, -1
Process, Priority,, H

gui_obj := New MarkGUI()

'::
    gui_obj.MakeGUI()
    mark_to_use := gui_obj.GetInput()
    gui_obj.GoToMark(mark_to_use)
    gui_obj.HideGUI()
    Return

F4::gui_obj.HideGUI()

Class MarkGUI
{

    __New() {
        this.marks := this.RestoreMarks()
        this.screen_dimension := this.GetScreenDimension()
    }

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

    GetScreenDimension() { 
        SysGet, count_monitors, MonitorCount
        screen_dimension := {top: 0, bottom: 0, left: 0, right: 0}
        loop % count_monitors {
            SysGet, mon, Monitor, %A_Index%
            if (monLeft < left) {
                screen_dimension.left := monLeft
            }
            if (monRight > right) {
                screen_dimension.right := monRight
            }
            if (monTop < top) {
                screen_dimemension.top := monTop
            }
            if (monBottom > bottom) {
                screen_dimension.bottom := monBottom
            }
        }
        screen_dimension.monWidth := screen_dimension.right - screen_dimension.left
        screen_dimension.monHeight := screen_dimension.bottom - screen_dimension.top
        Return screen_dimension 
    }

    MakeGUI() {
        Gui, Color, EEAA99
        Gui, Font, S10 w500, Lucida Console
        For key, value in this.marks{
            StringUpper, key, key
            x_position := value.x - 5
            y_position := value.y - 5 - this.screen_dimension.top
            Gui, Add, button, x%x_position% y%y_position%, %key%
        }
        
        Gui -Caption +LastFound +AlwaysOnTop +ToolWindow ; Lastfound for WinSet
        WinSet, TransColor, EEAA99 ; makes all EEAA99 colors invisible
        Gui, Show, % " x" this.screen_dimension.left " y" this.screen_dimension.top " w" this.screen_dimension.monWidth " h" this.screen_dimension.monHeight " NoActivate"
    }

    HideGUI() {
        Gui, hide
    }

    NearbyMark(x_threshold:=50, y_threshold:=50 ) {
        MouseGetPos, cur_x, cur_y
        For key, value in marks {
            if (abs(cur_x - value.x) < x_threshold and abs(cur_y - value.y) < y_threshold) { ; if the approximate location is already marked then just update the location of that mark
                if (key != "'") { ; should still create mark if the close key is the last jump mark
                    Return key
                }
            }
        }
        Return
    }

    LowestPriorityMark() {
        For index, key in key_order {
            if not marks.haskey(key) { ; use unused marks first
                Return key
            }
            if (marks[key].priority <= min_priority) {
                if (marks[key].priority != min_priority or marks[key].time_set < marks[lowest_priority].time_set) { ; for marks of the same priority prefer to overwrite the older mark
                    lowest_priority := key
                }
                min_priority := marks[key].priority
            }
        }
        Return lowest_priority
    }

    AutoMark(mark_priority := 0, user_set := 0, manual_mark := 0) {
        if (user_set == 1 and manual_mark == 1) {
            mark_to_use := this.GetInput()
        }
        else {
            mark_to_use := this.NearbyMark()
            if not mark_to_use {
                mark_to_use := this.LowestPriorityMark()
            }
        }
        marks[mark_to_use] := {x:cur_x, y:cur_y, priority:mark_priority, time_set:A_TickCount}
        if (user_set == 1) {
            IniWrite, % cur_x "|" cur_y, saved_marks.ini, MARKS, %mark_to_use%
            ToolTip, set mark at %mark_to_use%
            ; sleep, mark_settings.mark_move_delay
            this.HideGUI()
        }
    }

    GetInput() {
        Input, letter, L1 E, {esc}

        if (IsNum(letter)) {
            MsgBox, make number handler ; TODO
        }
        else {
            return letter
        }
    }

    GoToMark(mark_to_use) {
        MouseGetPos, prev_x, prev_y
        original_x := prev_x
        original_y := prev_y
        While (prev_x != this.marks[mark_to_use].x or prev_y != this.marks[mark_to_use].y) { ; looping brute forces through monitor walls without having to compare monitor dimensions
            MouseMove, this.marks[mark_to_use].x, this.marks[mark_to_use].y, 0
            MouseGetPos, prev_x, prev_y
            if (A_Index == 15) {
                break ; in case display settings have changed since marks were generated
            }
        }
        this.marks[mark_to_use].priority += 5 ; protects the mark from being overwritten by AutoMark if it is frequently used
        this.marks["'"] := { x : original_x, y : original_y}
    }
}

IsNum(str) {
    if str is number
        return true
    return false
}