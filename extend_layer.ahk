#NoEnv
#installkeybdhook
#MaxHotkeysPerInterval 200
SendMode Input
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
SetMouseDelay, -1
Process, Priority,, H

;; ## Read Settings and initialize class objects
;;

DetectSettingsFile()
Marks := new Marks
MouseController := new MouseControls

;; ## Mappings
;; Change 'CapsLock' in the lines marked ----- to change the extend trigger

global awaiting_input = 0 ; used to disable hotkeys while setting or going to mark

LShift & RShift::CapsLock

*CapsLock:: ; -------------------
    MouseController.SetTimer("cursor_timer", MouseController.settings.mouse_interval)
    MouseController.SetTimer("scroll_wheel_timer", MouseController.settings.scroll_interval)
    Return

*CapsLock up:: ; -------------------
    MouseController.SetTimer("cursor_timer", "off")
    MouseController.SetTimer("scroll_wheel_timer", "off")
    ClearModifiers()
    Return

#If, GetKeyState("CapsLock", "P") and awaiting_input == 0 ; ------------------------

    ;;  ### Row 0 - function keys

    F1::Volume_Mute
    F2::Volume_Down
    F3::Volume_Up
    F4::Media_Play_Pause
    F5::Media_Prev
    F6::Media_Next
    ;F7::
    ;F8::
    ;F9::
    ;F10::
    ;F11::
    ;F12::

    ;;  ### Row 1 - number row
    ;;  ||`     |1     |2     |3     |4     |5     |6     |7     |8     |9     |0     |-     |=     |Back  ||
    ;;  ||sc029 |sc002 |sc003 |sc004 |sc005 |sc006 |sc007 |sc008 |sc009 |sc00a |sc00b |sc00c |sc00d |sc00e ||

    sc029::Return ; go to all monitor marks
    sc002::F1
    sc003::F2
    sc004::F3
    sc005::F4
    sc006::F5
    sc007::F6
    sc008::F7
    sc009::F8
    sc00a::F9
    sc00b::F10
    sc00c::^w
    sc00d::^t

    ;sc00e::

    ;;  ### Row 2 - upper letter row
    ;;  ||Tab     |Q     |W     |E     |R     |T     |Y     |U     |I     |O     |P     |[     |]     ||
    ;;  ||RWWc00f |sc010 |sc011 |sc012 |sc013 |sc014 |sc015 |sc016 |sc017 |sc018 |sc019 |sc01a |sc01b ||

    sc010::Home
    sc011::Up
    sc012::End
    sc013::Delete
    sc014::Esc
    sc015::PgUp
    sc016::Return ; change scrollwheel keys in the MoveScrollWheel method
    sc017::Return ; change mouse keys in the MoveCursor method
    sc018::Return
    sc019::^Delete
    sc01a::^+Tab
    sc01b::^Tab

    ;;  ### Row 3 - home row
    ;   ||Caps  |A     |S     |D     |F     |G     |H     |J     |K     |L     |;     |'     |\     ||
    ;;  ||sc03a |sc01e |sc01f |sc020 |sc021 |sc022 |sc023 |sc024 |sc025 |sc026 |sc027 |sc028 |sc02b ||

    sc01e::Left
    sc01f::Down
    sc020::Right
    sc021::Backspace
    sc022::Appskey
    sc023::PgDn
    sc024::Return
    sc025::Return
    sc026::Return
    sc027::^Backspace
    sc028::
        Marks.ShowGUI()
        awaiting_input = 1
        ClearModifiers()
        Input, mark_to_use, L1 E, {esc}
        Marks.GoToMark(mark_to_use)
        Sleep, Marks.settings.mark_move_delay
        Marks.HideGUI()
        awaiting_input = 0
        Return
    +sc028::Return ; go to all monitor marks
    ;sc02b::

    ;;  ### Row 4 - lower letter row
    ;;  ||LS/GT |Z     |X     |C     |V     |B     |N     |M     |,     |.     |/     |Enter |Space ||
    ;;  ||sc056 |sc02c |sc02d |sc02e |sc02f |sc030 |sc031 |sc032 |sc033 |sc034 |sc035 |sc01c |sc039 ||

    sc056::^z
    sc02c::^z ; would recommend changing to ctrl-x on an iso keyboard
    sc02d::^c
    *sc02e::
        Click, left, down
        KeyWait % SubStr(A_ThisHotkey, 2) ; substr is ugly but necessary to escape the * modifier
        Click, left, up
        if (Marks.settings.auto_mark == 1 and A_TimeSinceThisHotkey < 300) { ; users probably don't want to mark the endpoint of long clicks
            Marks.SetMark()
        }
        Return
    sc02f::^v
    sc030::MButton
    sc031::RButton
    sc032::Shift
    sc033::Ctrl
    sc034::Alt
    sc035::
        awaiting_input = 1
        ClearModifiers()
        Marks.SetMark(Marks.settings.mark_priority, 1)
        awaiting_input = 0
        Return

    ;sc01c::
    sc039::Enter

;; ### Mouse Buttons
;;

;XButton1::^c
;XButton2::^v

#If

;; ## Functions
;;
;;

; release modifiers if they were still being held down when extend was released
ClearModifiers() {
    If GetKeyState("sc032", "P")
        send {Shift up}
    If GetKeyState("sc033", "P")
        send {Ctrl up}
    If GetKeyState("sc034", "P")
        send {Alt up}
    If GetKeyState("sc02e", "P")
        send {LButton up}
    If GetKeyState("sc030", "P")
        send {RButton up}
}

IsNum(str) {
    if str is number
        return true
    return false
}

DetectSettingsFile() {
    if not FileExist("settings.ini") {
        FileCopy, default_settings.ini, settings.ini, 0
        MsgBox, 4,, A default settings file has been created.`n`nWould you like to change the default settings?

        IfMsgBox No
        return

        Run, open "settings.ini"
        WinWait, settings.ini
        WinWaitClose
        MsgBox, 4,, Reload extend_layer.ahk?
        IfMsgBox Yes
        Reload
    }
    return
}



; 
; to add to class
; 

; Generate default marks TODO: more rational key orderings, maybe key_order as dict with key for number of screens or x_splits outer loop and group by 3s ie. q, a, x
; TODO reduce complexity and eliminate reliance on globals
GenerateMarks() {
    global
    SysGet, num_monitors, MonitorCount
    local i = 1 ; counts keys for all monitor marks
    local y_splits := mark_settings.y_splits

    Loop, % Min(num_monitors, key_order.length() // y_splits) {
        local mon_number := A_Index
        easymotion_marks_monitor_%mon_number% := {}
        SysGet, mon, Monitor, %mon_number%
        local mon_width := monRight - monLeft
        local mon_height := monBottom - monTop

        local j = 1 ; counts keys for that monitors marks
        local x_splits_mon := key_order.Length() // y_splits ; number of splits for that monitors marks ('+mon_number)
        local x_splits := (key_order.Length() // Min(num_monitors, key_order.length() // y_splits)) // y_splits ; number of splits for all monitor marks (")
        local y_mult = mark_settings.y_mult ; changes starting height of marks - lower is higher
        local initial_y_mult := y_mult

        Loop, % y_splits {
            local x_mult_mon = mark_settings.x_mult_mon ; changes starting x of marks - lower is left
            local initial_x_mult_mon := x_mult_mon

            Loop, % x_splits_mon {
                easymotion_marks_monitor_%mon_number%[(key_order[j])] := {x : monLeft + x_mult_mon*(mon_width / (4 * x_splits_mon)), y : monTop + y_mult*(mon_height / (2 * y_splits))}
                x_mult_mon += (4*x_splits_mon - 2*initial_x_mult_mon) / (x_splits_mon - 1)
                j++
            }

            local x_mult = mark_settings.x_mult
            local initial_x_mult := x_mult

            Loop, % x_splits {
                easymotion_marks[(key_order[i])] := {x : monLeft + x_mult*(mon_width / (4 * x_splits)), y : monTop + y_mult*(mon_height / (2 * y_splits))}
                x_mult += (4*x_splits - 2*initial_x_mult) / (x_splits - 1)
                i++
            }

            y_mult += (2*y_splits - 2*initial_y_mult) / (y_splits - 1)
        }

    }
}

;; ## Classes
;;
;;

Class MouseControls
{
;; inspired by https://github.com/4strid/mouse-control.autohotkey
    __New() {
        this.settings := this.ReadMouseSettings()
        this.velocity_x := 0
        this.velocity_y := 0
        this.scroll_wheel_timer := ObjBindMethod(this, "MoveScrollWheel")
        this.cursor_timer := ObjBindMethod(this, "MoveCursor")
    }

    SetTimer(timer_id, period) {
		timer := this[timer_id]
		SetTimer % timer, % period
    }

    ReadMouseSettings() {
        IniRead, raw_mouse_settings, settings.ini, MOUSE_SETTINGS
        mouse_settings := {}
        Loop, Parse, raw_mouse_settings, "`n"
        {
            Array := StrSplit(A_LoopField, "=")
            mouse_settings[Array[1]] := Array[2]
        }
        ; normalize acceleration and top_speed for mouse_interval - TODO this didn't work very well
        ; mouse_settings["acceleration"] := mouse_settings["acceleration"] // (1000 / mouse_settings["mouse_interval"])
        ; mouse_settings["top_speed"] := mouse_settings["top_speed"] // (1000 / mouse_settings["mouse_interval"])
        return mouse_settings
    }

    ; Scroll Wheel -function and time is smoother than mapping directly
    MoveScrollWheel(){
        if (awaiting_input == 1)
            return
        else if GetKeyState("sc016", "P") {
            if GetKeyState("Shift", "P")
                send {WheelLeft}
            else
                send {WheelUp}
        }
        else if GetKeyState("sc018", "P") {
            if GetKeyState("Shift", "P")
                send {WheelRight}
            else
                send {WheelDown}
        }
    }


    MoveCursor() {
        if (awaiting_input == 1)
            return

        up := 0 - GetKeyState("sc017", "P")
        left := 0 - GetKeyState("sc024", "P")
        down := 0 + GetKeyState("sc025", "P")
        right := 0 + GetKeyState("sc026", "P")

        this.velocity_x := this.Accelerate(this.velocity_x, left, right)
        this.velocity_y := this.Accelerate(this.velocity_y, up, down)
        ; MsgBox, % this.velocity_x


        RestoreDPI := DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr") ; store per-monitor DPI
        MouseMove, this.velocity_x, this.velocity_y, 0, R
        DllCall("SetThreadDpiAwarenessContext", "ptr", RestoreDPI, "ptr") ; restore previous DPI awareness -- not sure if this does anything or if I'm imagining it, keeping it for people with different monitor setups
    }

    Accelerate(velocity, pos, neg) {
        new_velocity := velocity + this.settings.acceleration * (pos + neg)
        if (Abs(new_velocity) <= Abs(velocity)) {
            return 0
        }
        else {
            return (pos + neg) * Min(Abs(new_velocity), Abs(this.settings.top_speed))
        }
    }
}

Class Marks
{

    __New() {
        this.settings := this.ReadSettings()
        this.key_order := this.ReadKeyOrder()
        this.usage_marks := this.RestoreMarks()
        this.screen_dimension := this.GetScreenDimension()
    }

    ReadSettings() {
        IniRead, raw_mark_settings, settings.ini, MARK_SETTINGS
        mark_settings := {}
        Loop, Parse, raw_mark_settings, "`n"
        {
            Array := StrSplit(A_LoopField, "=")
            mark_settings[Array[1]] := Array[2]
        }
        return mark_settings
    }

    ReadKeyOrder() {
        IniRead, raw_key_order, settings.ini, MARK_ORDER, key_order , q|w|e|r|a|s|d|z|x|c|u|i|o|p|j|k|l|m|,|.
        key_order := []
        Loop, Parse, raw_key_order, |
        {
            key_order.Push(A_LoopField)
        }
        return key_order

    }

    RestoreMarks() {
        IniRead, raw_saved_marks, saved_marks.ini, MARKS
        saved_marks := {}
        Loop, Parse, raw_saved_marks, "`n"
        {
            Array := StrSplit(A_LoopField, "=")
            coords := StrSplit(Array[2], "|")
            saved_marks[Array[1]] := {x:coords[1], y:coords[2], priority:this.settings.mark_priority, time_set:0}
        }
        return saved_marks
    }

    GetScreenDimension() { 
        SysGet, count_monitors, MonitorCount
        screen_dimension := {top: 0, bottom: 0, left: 0, right: 0}
        loop % count_monitors {
            SysGet, mon, Monitor, %A_Index%
            if (monLeft < screen_dimension.left) {
                screen_dimension.left := monLeft
            }
            if (monRight > screen_dimension.right) {
                screen_dimension.right := monRight
            }
            if (monTop < screen_dimension.top) {
                screen_dimension.top := monTop
            }
            if (monBottom > screen_dimension.bottom) {
                screen_dimension.bottom := monBottom
            }
        }
        screen_dimension.monWidth := screen_dimension.right - screen_dimension.left
        screen_dimension.monHeight := screen_dimension.bottom - screen_dimension.top
        Return screen_dimension 
    }

    ShowGUI(array_to_use:="usage_marks") {
        Gui, Color, EEAA99
        Gui, Font, S10 w500, Consolas ; todo user setting
        For key, value in this[array_to_use]{
            StringUpper, key, key
            x_position := value.x - 5 - this.screen_dimension.left ; TODO confirm this fix works for other monitor layouts
            y_position := value.y - 5 - this.screen_dimension.top
            Gui, Add, button, x%x_position% y%y_position%, %key%
        } ; TODO make ' mark appear over any other marks
        
        Gui -Caption +LastFound +AlwaysOnTop +ToolWindow ; Lastfound is for WinSet
        WinSet, TransColor, EEAA99 ; makes all EEAA99 colors invisible
        Gui, Show, % " x" this.screen_dimension.left " y" this.screen_dimension.top " w" this.screen_dimension.monWidth " h" this.screen_dimension.monHeight " NoActivate"
    }

    HideGUI() {
        Gui, destroy
    }

    SetMark(mark_priority := 0, user_set := 0) {
        MouseGetPos, cur_x, cur_y
        if (user_set == 1 and this.settings.auto_assign_mark == 0) {
            ToolTip, Set Mark
            Input, mark_to_use, L1 E, {esc}
            ToolTip
        }
        else {
            mark_to_use := this.NearbyMark(cur_x, cur_y)
            nearby_mark = 1
            if not mark_to_use {
                mark_to_use := this.FindLowestPriorityMark()
                nearby_mark = 0
            }
        }
        if mark_to_use {
            this.usage_marks[mark_to_use] := {x:cur_x, y:cur_y}
            if not nearby_mark {
                this.usage_marks[mark_to_use].priority := mark_priority
                this.usage_marks[mark_to_use].time_set := A_TickCount
            }
            if (user_set == 1) {
                IniWrite, % cur_x "|" cur_y, saved_marks.ini, MARKS, %mark_to_use%
                ToolTip, Set Mark at %mark_to_use%
                Sleep, % this.settings.mark_move_delay
                ToolTip
            }
        }
    }

    NearbyMark(x, y, x_threshold:=50, y_threshold:=50) {
        For key, value in this.usage_marks {
            if (abs(x - value.x) < x_threshold and abs(y - value.y) < y_threshold) { ; if the approximate location is already marked then just update the location of that mark
                if (key != "'") { ; should still create mark if the close key is the last jump mark
                    Return key
                }
            }
        }
        Return
    }

    FindLowestPriorityMark() {
        min_priority := 100 ; the starting priority at which to consider replacing the mark
        For index, key in this.key_order {
            if not this.usage_marks.haskey(key) { ; use unused marks first
                Return key
            }
            if (this.usage_marks[key].priority <= min_priority) {
                if (this.usage_marks[key].priority != min_priority or this.usage_marks[key].time_set < this.usage_marks[lowest_priority].time_set) { ; for marks of the same priority prefer to overwrite the older mark
                    lowest_priority := key
                }
                min_priority := this.usage_marks[key].priority
            }
        }
        Return lowest_priority
    }

    GoToMark(mark_to_use, array_to_use:="usage_marks") {
        MouseGetPos, prev_x, prev_y
        original_x := prev_x
        original_y := prev_y
        While (prev_x != this[array_to_use][mark_to_use].x or prev_y != this[array_to_use][mark_to_use].y) { ; looping brute forces through monitor walls without having to compare monitor dimensions
            MouseMove, this[array_to_use][mark_to_use].x, this[array_to_use][mark_to_use].y, 0
            MouseGetPos, prev_x, prev_y
            if (A_Index == 15) {
                break ; in case display settings have changed since marks were generated
            }
        }
        this[array_to_use][mark_to_use].priority += 5 ; protects the mark from being overwritten by AutoMark if it is frequently used
        this[array_to_use]["'"] := { x : original_x, y : original_y}
    }
}