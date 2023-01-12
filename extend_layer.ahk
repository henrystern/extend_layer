#NoEnv
#installkeybdhook
#MaxHotkeysPerInterval 200
SendMode Input
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
CoordMode, Pixel, Screen
SetMouseDelay, -1
Process, Priority,, H

; ## Read Settings and initialize class objects
DetectSettingsFile()
Global ExtendState := new ExtendLayerState
Global SessionMarks := new Marks
Global MouseController := new MouseControls
Global HelpImage := new ContextAndHelpImageState

; ## Trigger Configuration
Hotkey, % "*" ExtendState.settings.extend_key, % ExtendState.settings.trigger_mode

; ## Layer Mappings
LShift & RShift::CapsLock

#If, ExtendState.IsActive() and not ExtendState.IsAwaitingInput()
    ; ### Help Shortcut
    ^sc002::HelpImage.ToggleHelp() ; Caps+Ctrl+1
    
    ;  ### Row 0 - function keys
    F1::Volume_Mute
    F2::Volume_Down
    F3::Volume_Up
    F4::Media_Play_Pause
    F5::Media_Prev
    F6::Media_Next
    F7::Return 
    F8::Return 
    F9::Return 
    F10::Return
    F11::Return

    ;  ### Row 1 - number row
    ;  ||`     |1     |2     |3     |4     |5     |6     |7     |8     |9     |0     |-     |=     |Back  ||
    ;  ||sc029 |sc002 |sc003 |sc004 |sc005 |sc006 |sc007 |sc008 |sc009 |sc00a |sc00b |sc00c |sc00d |sc00e ||
    sc029::SessionMarks.GoToMark("all_monitors")
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

    ;  ### Row 2 - upper letter row
    ;  ||Tab     |Q     |W     |E     |R     |T     |Y     |U     |I     |O     |P     |[     |]     ||
    ;  ||RWWc00f |sc010 |sc011 |sc012 |sc013 |sc014 |sc015 |sc016 |sc017 |sc018 |sc019 |sc01a |sc01b ||
    sc010::Home
    sc011::Up
    sc012::End
    sc013::Delete
    sc014::Esc
    sc015::PgUp
    *sc016::Return ; change scrollwheel keys in the MoveScrollWheel method
    *sc017::Return ; change mouse keys in the MoveCursor method
    *sc018::Return
    sc019::^Delete
    sc01a::^+Tab
    sc01b::^Tab

    ;  ### Row 3 - home row
    ;  ||Caps  |A     |S     |D     |F     |G     |H     |J     |K     |L     |;     |'     |\     ||
    ;  ||sc03a |sc01e |sc01f |sc020 |sc021 |sc022 |sc023 |sc024 |sc025 |sc026 |sc027 |sc028 |sc02b ||
    sc01e::Left
    sc01f::Down
    sc020::Right
    sc021::Backspace
    sc022::Appskey
    sc023::PgDn
    *sc024::Return
    *sc025::Return
    *sc026::Return
    sc027::^Backspace
    sc028::SessionMarks.GoToMark("usage_marks")
    +sc028::SessionMarks.GoToMark("all_monitors")

    ;  ### Row 4 - lower letter row
    ;  ||LS/GT |Z     |X     |C     |V     |B     |N     |M     |,     |.     |/     |Enter |Space ||
    ;  ||sc056 |sc02c |sc02d |sc02e |sc02f |sc030 |sc031 |sc032 |sc033 |sc034 |sc035 |sc01c |sc039 ||
    sc056::^z
    sc02c::^z ; would recommend changing to ctrl-x on an iso keyboard
    sc02d::^c
    *sc02e::
        Click, left, down
        KeyWait % SubStr(A_ThisHotkey, 2) ; substr is ugly but necessary to escape the * modifier
        Click, left, up
        if (SessionMarks.settings.auto_mark and A_TimeSinceThisHotkey < 300) { ; users probably don't want to mark the endpoint of long clicks
            SessionMarks.SetMark()
        }
        Return
    sc02f::^v
    sc030::MButton
    sc031::RButton
    sc032::Shift
    sc033::Ctrl
    sc034::Alt
    sc035::
        ExtendState.SetAwaitingInput(True)
        ClearModifiers()
        SessionMarks.SetMark(Marks.settings.mark_priority, 1)
        ExtendState.SetAwaitingInput(False)
        Return
    
    ; ### Row 5 - spacebar 
    sc039::Enter

#If

; ## Functions

ClearModifiers() {
    ; release modifiers if they were still being held down when extend was released
    If GetKeyState("Shift")
        send {Shift up}
    If GetKeyState("Ctrl")
        send {Ctrl up}
    If GetKeyState("Alt")
        send {Alt up}
    If GetKeyState("sc022e", "P")
        send {LButton up}
    If GetKeyState("sc030", "P")
        send {RButton up}
    Return
}

IsNum(str) {
    if str is number
        return True
    return False
}

StrToBoolIfBool(str) {
    lower_str := Format("{:L}", str)
    if (lower_str == "true")
        return True
    if (lower_str == "false")
        return False
    return str
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

ReadSettings(settings_category) {
    IniRead, raw_settings, settings.ini, % settings_category
    settings := {}
    Loop, Parse, raw_settings, "`n"
    {
        Array := StrSplit(A_LoopField, "=")
        settings[Array[1]] := StrToBoolIfBool(Trim(Array[2]))
    }
    return settings 
}

Hold() {
    ExtendState.Activate()
    KeyWait % ExtendState.settings.extend_key
    ExtendState.Deactivate()
}

PureToggle() {
    if (not ExtendState.IsActive()) {
        ExtendState.Activate()
        ToolTip, Extend_Layer On, % A_ScreenWidth / 2, A_ScreenHeight 
    }
    else {
        KeyWait % ExtendState.settings.extend_key
        ExtendState.Deactivate()
        ToolTip
    }
}

TapToggle() {
    if (not ExtendState.IsActive()) {
        ExtendState.Activate()
        KeyWait % ExtendState.settings.extend_key
        if (A_PriorKey == ExtendState.settings.extend_key and A_TimeSinceThisHotkey < ExtendState.settings.tap_sensitivity) { 
            ; only toggle on a trigger press without any other keypresses
            ToolTip, Extend_Layer On, % A_ScreenWidth / 2, A_ScreenHeight 
        }
        else {
            ExtendState.Deactivate()
        }
    }
    else {
        KeyWait % ExtendState.settings.extend_key
        ExtendState.Deactivate()
        ToolTip
    }
}

; ## Classes

Class ExtendLayerState
{
    __New() {
        this.settings := ReadSettings("TRIGGER_SETTINGS")
        this.awaiting_input := False
        this.active := False
    }

    IsActive() {
        return this.active
    }

    IsAwaitingInput() {
        return this.awaiting_input
    }

    SetActive(status) {
        this.active := status
    }

    SetAwaitingInput(status) {
        this.awaiting_input := status
    }

    Activate() {
        MouseController.SetTimer("cursor_timer", MouseController.settings.mouse_interval)
        MouseController.SetTimer("scroll_wheel_timer", MouseController.settings.scroll_interval)
        this.active := True
    }

    Deactivate() {
        MouseController.SetTimer("cursor_timer", "off")
        MouseController.SetTimer("scroll_wheel_timer", "off")
        ClearModifiers()
        this.active := False
    }

}

Class MouseControls
{
    __New() {
        this.settings := ReadSettings("MOUSE_SETTINGS")
        this.velocity_x := 0
        this.velocity_y := 0
        this.scroll_wheel_timer := ObjBindMethod(this, "MoveScrollWheel")
        this.cursor_timer := ObjBindMethod(this, "MoveCursor")
    }

    SetTimer(timer_id, period) {
        timer := this[timer_id]
        SetTimer % timer, % period
    }

    MoveScrollWheel(){
        if (ExtendState.IsAwaitingInput() or not ExtendState.IsActive()){
            return
        }
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
        if (ExtendState.IsAwaitingInput() or not ExtendState.IsActive())
            return

        up := 0 - GetKeyState("sc017", "P")
        left := 0 - GetKeyState("sc024", "P")
        down := 0 + GetKeyState("sc025", "P")
        right := 0 + GetKeyState("sc026", "P")

        this.velocity_x := this.Accelerate(this.velocity_x, left, right)
        this.velocity_y := this.Accelerate(this.velocity_y, up, down)

        ; store per-monitor DPI
        RestoreDPI := DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr") 
        MouseMove, this.velocity_x, this.velocity_y, 0, R
        ; restore previous DPI awareness -- this is necessary for mousemove to work as expected when windows scaling != 100%
        DllCall("SetThreadDpiAwarenessContext", "ptr", RestoreDPI, "ptr") 
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
        this.settings := ReadSettings("MARK_SETTINGS")
        this.key_order := this.ReadKeyOrder()
        this.lengthened_marks := this.IncreaseMarkLength()
        this.screen_dimension := this.GetScreenDimensions()
        this.mark_arrays := {}
        this.mark_arrays.usage_marks := this.RestoreMarks()
        for mon_number, value in this.screen_dimension {
            if (mon_number == 0) { ; 0 is for usage marks
                continue
            }
            this.mark_arrays[mon_number] := this.GenerateMarks([value])
        }
        monitor_dimensions := this.screen_dimension.Clone()
        monitor_dimensions.Delete(0)
        this.mark_arrays.all_monitors := this.GenerateMarks(monitor_dimensions)
    }

    GenerateMarks(dimensions) {
        ; TODO this generates incorrect marks if screen scaling != 100
        i := 1
        mark_array := {}
        Loop, % dimensions.Length() {
            x_splits := (this.lengthened_marks.Length() // Min(dimensions.Length(), this.lengthened_marks.Length() // this.settings.y_splits)) // this.settings.y_splits

            ; -20 adjusts for button width and height -- would need to be changed if font or fontsize changes
            y_locations := this.SplitRange(dimensions[A_Index].top, dimensions[A_Index].height - 2*this.settings.starting_height - 20, this.settings.y_splits) 
            x_locations := this.SplitRange(dimensions[A_Index].left, dimensions[A_Index].width - 2*this.settings.starting_width - 20, x_splits)

            for key, y_val in y_locations {
                for key, x_val in x_locations {
                    mark_array[this.lengthened_marks[i]] := {x: x_val + this.settings.starting_width, y: y_val + this.settings.starting_height}
                    i++
                }
            }
        }
        Return mark_array
    }

    SplitRange(range_start, range_end, splits) {
        split_array := [range_start]
        abs_range := (range_start + range_end) - range_start
        Loop, % splits - 1 {
            split_array.Push(range_start + (A_Index) * (abs_range / (splits - 1)))
        }
        return split_array
    }

    ReadKeyOrder() {
        IniRead, raw_key_order, settings.ini, MARK_ORDER, key_order , Q|W|E|R|T|Y|U|I|O|P|[|]|A|S|D|F|G|H|J|K|L|;|Z|X|C|V|B|N|M|,|.|/
        key_order := []
        Loop, Parse, raw_key_order, |
        {
            key_order.Push(A_LoopField)
        }
        return key_order
    }

    IncreaseMarkLength() {
        ; takes a list of available keys and permutates to create strings of length mark_length
        ; returns the lengthened mark names
        lengthened_mark_keys := this.key_order.Clone()
        if (this.settings.longer_marks) {
            temp := []
            For _, key_1 in lengthened_mark_keys {
                For _, key_2 in this.key_order {
                    temp.Push(key_1 key_2)
                }
            }
            lengthened_mark_keys := temp.Clone()
            }
        return lengthened_mark_keys 
    }

    RestoreMarks() {
        ; load saved marks from previous sessions
        IniRead, raw_saved_marks, saved_marks.ini, MARKS
        saved_marks := {}
        Loop, Parse, raw_saved_marks, "`n"
        {
            Array := StrSplit(A_LoopField, "=")
            coords := StrSplit(Array[2], "|")
            Array[1] := StrReplace(Array[1], "usage_mark-") ; necessary because otherwise ini wouldn't work for [, ], and ;
            saved_marks[Array[1]] := {x:coords[1], y:coords[2], priority:this.settings.mark_priority, time_set:0}
        }
        return saved_marks
    }

    GetScreenDimensions() {
        ; gets dimensions for the overall screen area and the individual dimensions for each monitor
        ; returns associative array with 0 for overall screen 
        SysGet, num_monitors, MonitorCount
        screen_dimension := {0: {top: 0, bottom: 0, left: 0, right: 0}}
        loop % num_monitors {
            SysGet, mon, Monitor, %A_Index%
            screen_dimension[A_Index] := {top: monTop, bottom: monBottom, left: monLeft, right: monRight}
            screen_dimension[A_Index].width := screen_dimension[A_Index].right - screen_dimension[A_Index].left
            screen_dimension[A_Index].height := screen_dimension[A_Index].bottom - screen_dimension[A_Index].top
            if (monLeft < screen_dimension[0].left) {
                screen_dimension[0].left := monLeft
            }
            if (monRight > screen_dimension[0].right) {
                screen_dimension[0].right := monRight
            }
            if (monTop < screen_dimension[0].top) {
                screen_dimension[0].top := monTop
            }
            if (monBottom > screen_dimension[0].bottom) {
                screen_dimension[0].bottom := monBottom
            }
        }
        screen_dimension[0].width := screen_dimension[0].right - screen_dimension[0].left
        screen_dimension[0].height := screen_dimension[0].bottom - screen_dimension[0].top
        Return screen_dimension
    }

    ShowGUI(array_to_use:="usage_marks") {
        Gui, Color, EEAA99
        Gui, Font, % "S" this.settings.font_size, % this.settings.font
        For key, value in this.mark_arrays[array_to_use]{
            if (key == "'") {
                last_x_position := value.x - 5 - this.screen_dimension[0].left
                last_y_position := value.y - 5 - this.screen_dimension[0].top
                continue
            }
            ; these adjustments are because 0, 0 is always the top left of the gui but the mark position can be negative
            x_position := value.x - 5 - this.screen_dimension[0].left 
            y_position := value.y - 5 - this.screen_dimension[0].top
            Gui, Add, button, x%x_position% y%y_position%, %key%
        } 
        if last_x_position {
            ; this makes ' mark appear over any other marks
            Gui, Add, button, x%last_x_position% y%last_y_position%, '
        }

        Gui -Caption +LastFound +AlwaysOnTop +ToolWindow ; Lastfound is necessary for WinSet
        WinSet, TransColor, EEAA99
        Gui, Show, % " x" this.screen_dimension[0].left " y" this.screen_dimension[0].top " w" this.screen_dimension[0].width " h" this.screen_dimension[0].height " NoActivate"
    }

    HideGUI() {
        Gui, destroy
    }

    SetMark(mark_priority := 0, user_set := False) {
        MouseGetPos, cur_x, cur_y
        if (user_set and not this.settings.auto_assign_mark) {
            ToolTip, Set Mark
            Input, mark_to_use, L1 E, {esc}
            ToolTip
        }
        else {
            mark_to_use := this.NearbyMark(cur_x, cur_y)
            nearby_mark := True
            if not mark_to_use {
                mark_to_use := this.FindLowestPriorityMark()
                nearby_mark := False
            }
        }
        if mark_to_use {
            StringUpper, mark_to_use, mark_to_use ; uppercase reduces ambiguity
            this.mark_arrays.usage_marks[mark_to_use] := {x:cur_x, y:cur_y}
            if not nearby_mark {
                this.mark_arrays.usage_marks[mark_to_use].priority := mark_priority
                this.mark_arrays.usage_marks[mark_to_use].time_set := A_TickCount
            }
            if (user_set) {
                IniWrite, % cur_x "|" cur_y, saved_marks.ini, MARKS, % "usage_mark-" mark_to_use
                ToolTip, Set Mark at %mark_to_use%
                Sleep, % 2 * this.settings.mark_move_delay
                ToolTip
            }
        }
    }

    NearbyMark(x, y) {
        For key, value in this.mark_arrays.usage_marks {
            if (abs(x - value.x) < this.settings.x_threshold and abs(y - value.y) < this.settings.y_threshold) { 
                ; if the approximate location is already marked then just update the location of that mark
                if (key != "'") { 
                    ; should still create mark if the close key is the last jump mark
                    Return key
                }
            }
        }
    }

    FindLowestPriorityMark() {
        min_priority := 100 ; the starting priority at which to consider replacing the mark
        For index, key in this.key_order {
            if not this.mark_arrays.usage_marks.haskey(key) { ; use unused marks first
                Return key
            }
            if (this.mark_arrays.usage_marks[key].priority <= min_priority) {
                if (this.mark_arrays.usage_marks[key].priority != min_priority 
                    or this.mark_arrays.usage_marks[key].time_set < this.mark_arrays.usage_marks[lowest_priority].time_set) {
                    ; for marks of the same priority prefer to overwrite the older mark
                    lowest_priority := key
                }
                min_priority := this.mark_arrays.usage_marks[key].priority
            }
        }
        Return lowest_priority
    }

    MoveCursor(mark_to_use, array_to_use:="usage_marks") {
        MouseGetPos, prev_x, prev_y
        original_x := prev_x
        original_y := prev_y
        ; looping brute forces through monitor walls without having to compare monitor dimensions
        ; not very elegant but seems fast enough
        While (prev_x != this.mark_arrays[array_to_use][mark_to_use].x or prev_y != this.mark_arrays[array_to_use][mark_to_use].y) { 
            MouseMove, this.mark_arrays[array_to_use][mark_to_use].x, this.mark_arrays[array_to_use][mark_to_use].y, 0
            MouseGetPos, prev_x, prev_y
            if (A_Index == 15) {
                break ; in case display settings have changed since marks were generated
            }
        }
        this.mark_arrays[array_to_use][mark_to_use].priority += 5 ; protects the mark from being overwritten by AutoMark if it is frequently used
        this.mark_arrays["usage_marks"]["'"] := { x : original_x, y : original_y}
    }

    GoToMark(array_to_use:="usage_marks") {
        this.ShowGUI(array_to_use)
        ExtendState.SetAwaitingInput(True)
        ClearModifiers()
        if (array_to_use == "usage_marks" or not this.settings.longer_marks) {
            Input, chosen_mark, L1 E, {esc}
        }
        else {
            Input, chosen_mark, L2 E, {esc}, 1,2,3,4,5,6,7,8,9,0
        }
        if (IsNum(chosen_mark)) {
            this.HideGUI()
            this.GoToMark(chosen_mark)
            Return
        }
        this.MoveCursor(chosen_mark, array_to_use)
        Sleep, this.settings.mark_move_delay
        this.HideGUI()
        ExtendState.SetAwaitingInput(False)
    }
}

Class ContextAndHelpImageState
{
    __New() {
        this.status := False
        this.image_path := ".\defaults.png"
        this.image_dimensions := this.GetImageSize(this.image_path)
        this.bg_colour := "FFFFFF"
        this.AddContextMenu()
    }

    AddContextMenu() {
        Menu, Tray, NoStandard
        Menu, Tray, Add
        Menu, Tray, Add, Show Help Image, ShowHelp
        Menu, Tray, Add, Change Settings, OpenSettings
        Menu, Tray, Add, Edit Script, EditScript
        Menu, Tray, Add
        Menu, Tray, Add, Reload Script, ReloadScript
        Menu, Tray, Add, Exit, ExitScript
        Return

        ShowHelp:
            HelpImage.ToggleHelp()
            Return

        OpenSettings:
            Run, % "open " A_ScriptDir "\settings.ini"
            Return

        EditScript:
            Run, % "edit " A_ScriptFullPath

        ReloadScript:
            Reload
            Sleep 1000 ; If successful, the reload will close this instance during the Sleep, so the line below will never be reached.
            MsgBox, 4,, The script could not be reloaded. Would you like to open it for editing?
            IfMsgBox, Yes, Edit
            Return

        ExitScript:
            ExitApp
            Return
    }

    ToggleHelp() {
        this.status := not this.status
        Menu, Tray, ToggleCheck, Show Help Image
        if this.status {
            Gui, help:New
            Gui, Add, Picture,, % this.image_path
            Gui, Color, % colour
            Gui, +LastFound -Caption +AlwaysOnTop +ToolWindow -Border
            Gui, Show, % "x" (A_ScreenWidth / 2) - (this.image_dimensions.x / 2) " y" A_ScreenHeight - (this.image_dimensions.y + 50) " NoActivate"

            ; Enable GUI Dragging
            ; from joedf at https://www.autohotkey.com/boards/viewtopic.php?t=67
            ; TODO dragging doesn't work when clicked through the extend layer maybe do a key_wait for left click
            Sleep, 50
            WinGetPos,,,A_w,A_h, % A_ScriptName 
            Gui, help:Add, Text, x0 y0 w%A_w% h%A_h% +BackgroundTrans gGUI_Drag
            return
            
            GUI_Drag:
                SendMessage 0xA1,2  ;-- Goyyah/SKAN trick
                ;http://autohotkey.com/board/topic/80594-how-to-enable-drag-for-a-gui-without-a-titlebar
                return
            }

        else 
            Gui, help:Destroy
    }

    GetImageSize(image) {
        if FileExist(image) {
            Gui, Add, Picture, hwndpic, % image
            ControlGetPos,,, width, height,, ahk_id %pic%
            Gui, Destroy
        }
        else 
            height := width := 0
        return {x: width, y: height}
    }
}