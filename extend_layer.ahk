#NoEnv
#installkeybdhook
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
SetMouseDelay, -1

;; ## Mouse Settings
;;

global acceleration := 4
global top_speed := 22

;; ## Default Cursor Marks
;; TODO: easier way for users to save cursor locations between sessions probably read and write to file

global marks := {}
global easymotion_marks := {} ; Easymotion style grid

key_order := ["q", "w", "f", "p", "a", "r", "s", "t", "x", "c", "d", "l", "u", "y", "n", "e", "i", "h", ",", "."] ; alter depending on layout and preference, max 20 items can appear as tooltips but more can be defined
y_splits = 4 ; number of horizontal gridlines per monitor
GenerateMarks(key_order, y_splits)

global awaiting_input = 0

;; ## Mappings
;; Change 'CapsLock' in the lines marked ----- to change the extend trigger

*CapsLock:: ; -------------------
    SetTimer, MoveCursor, 10  ; this will also adjust cursor speed and smoothness
    SetTimer, SmoothScrollWheel, 40 ; this adjusts scrollwheel speed
    return

LShift & RShift::CapsLock

*CapsLock up:: ; -------------------
    SetTimer, MoveCursor, off
    SetTimer, SmoothScrollWheel, off
    ClearModifiers()
    return

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

sc029::GoToMark(easymotion_marks)
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
sc016::Return ; change scrollwheel keys in the SmoothScrollWheel function
sc017::Return ; change mouse keys in the MouseMove function
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
sc028::GoToMark(marks)
+sc028::GoToMark(easymotion_marks)
;sc02b::

;;  ### Row 4 - lower letter row
;;  ||LS/GT |Z     |X     |C     |V     |B     |N     |M     |,     |.     |/     |Enter |Space ||
;;  ||sc056 |sc02c |sc02d |sc02e |sc02f |sc030 |sc031 |sc032 |sc033 |sc034 |sc035 |sc01c |sc039 ||

sc056::^z
sc02c::^z ; would recommend changing to ctrl-x on an iso keyboard
sc02d::^c
sc02e::LButton
sc02f::^v
;sc030::
sc031::RButton
sc032::Shift
sc033::Ctrl
sc034::Alt
sc035::SetMark()

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

;; ### Misc
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

;; ### Cursor Marks Functions
;;
; Generate default marks TODO: more rational key orderings, maybe key_order as dict with key for number of screens or x_splits outer loop and group by 3s ie. q, a, x
GenerateMarks(key_order, y_splits) {
    global 
    SysGet, num_monitors, MonitorCount
    local i = 1 ; counts keys for all monitor marks

    Loop, % Min(num_monitors, key_order.length() // y_splits) {
        local mon_number := A_Index
        easymotion_marks_monitor_%mon_number% := {}
        SysGet, mon, Monitor, %mon_number%
        local mon_width := monRight - monLeft
        local mon_height := monBottom - monTop

        local j = 1 ; counts keys for that monitors marks
        local x_splits_mon := key_order.Length() // y_splits ; number of splits for that monitors marks ('+mon_number)
        local x_splits := (key_order.Length() // Min(num_monitors, key_order.length() // y_splits)) // y_splits ; number of splits for all monitor marks (")
        local y_mult = 0.5 ; changes starting height of marks - lower is higher
        local initial_y_mult := y_mult 

        Loop, % y_splits {
            local x_mult_mon = 1 ; changes starting x of marks - lower is left
            local initial_x_mult_mon := x_mult_mon

            Loop, % x_splits_mon {
                easymotion_marks_monitor_%mon_number%[(key_order[j])] := {x : monLeft + x_mult_mon*(mon_width / (4 * x_splits_mon)), y : monTop + y_mult*(mon_height // (2 * y_splits))}
                x_mult_mon += (4*x_splits_mon - 2*initial_x_mult_mon) / (x_splits_mon - 1)
                j++
            }            

            local x_mult = .75
            local initial_x_mult := x_mult

            Loop, % x_splits {
                easymotion_marks[(key_order[i])] := {x : monLeft + x_mult*(mon_width / (4 * x_splits)), y : monTop + y_mult*(mon_height // (2 * y_splits))}
                x_mult += (4*x_splits - 2*initial_x_mult) / (x_splits - 1)
                i++
            }

            y_mult += (2*y_splits - 2*initial_y_mult) // (y_splits - 1)
        }

    }
}

;; ## Mouse Settings
;;

; Associate a key with the current cursor location
SetMark() {
    ToolTip, set mark
    awaiting_input = 1
    Input, letter, L1

    ToolTip, set mark at %letter%
    MouseGetPos, cur_x, cur_y

    MARKS[(letter)] := {x:cur_x, y:cur_y}

    awaiting_input = 0
    RemoveToolTip(1)
}

; Move cursor to mark location
GoToMark(array) {
    ClearModifiers()
    awaiting_input = 1
    i = 1

    For key, value in array{
        if (i == 21) ; tooltip window limit is 20
            break
        ToolTip, % key, % value.x, % value.y, % i
        i++
    }

    Input, letter, L1 E

    if (IsNum(letter)) {
        awaiting_input = 0
        RemoveToolTip(i-1)
        GoToMark(easymotion_marks_monitor_%letter%)
    }

    else {
        MouseGetPos, prev_x, prev_y
        original_x := prev_x
        original_y := prev_y
        While (prev_x != array[letter].x or prev_y != array[letter].y) { ; looping brute forces through monitor walls without having to compare monitor dimensions
            MouseMove, array[letter].x, array[letter].y, 0
            MouseGetPos, prev_x, prev_y
            if (A_Index == 15) {
                break ; in case display settings have changed since marks were generated
            }
        }
        marks["'"] := { x : original_x, y : original_y}
    }

    awaiting_input = 0
    RemoveToolTip(i-1)
}

IsNum(str) {
	if str is number
		return true
	return false
}

; Clears mark location tooltips
RemoveToolTip(i) {
    Loop % i {
        ToolTip, , , , % A_Index
    }
}

;; ### Mouse Functions
;; inspired by https://github.com/4strid/mouse-control.autohotkey

global velocity_x := 0
global velocity_y := 0

; Scroll Wheel -function and time is smoother than mapping directly
SmoothScrollWheel(){
    if GetKeyState("sc016", "P")
        send {WheelUp}
    else if GetKeyState("sc018", "P")
        send {WheelDown}
}

Accelerate(velocity, pos, neg) {
    new_velocity := velocity + acceleration * (pos + neg)
    if (Abs(new_velocity) <= Abs(velocity)) {
        return 0
    }
    else {
        return (pos + neg) * Min(Abs(new_velocity), Abs(top_speed))
    }
}

MoveCursor() {
    up := 0 - GetKeyState("sc017", "P")
    left := 0 - GetKeyState("sc024", "P")
    down := 0 + GetKeyState("sc025", "P")
    right := 0 + GetKeyState("sc026", "P")
  
    velocity_x := Accelerate(velocity_x, left, right)
    velocity_y := Accelerate(velocity_y, up, down)

    RestoreDPI := DllCall("SetThreadDpiAwarenessContext", "ptr", -3, "ptr") ; store per-monitor DPI
    MouseMove, %velocity_x%, %velocity_y%, 0, R
    DllCall("SetThreadDpiAwarenessContext", "ptr", RestoreDPI, "ptr") ; restore previous DPI awareness -- not sure if this does anything or if I'm imagining it, keeping it for people with different monitor setups
}
