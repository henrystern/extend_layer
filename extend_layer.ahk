#NoEnv
#installkeybdhook
SendMode Input
SetWorkingDir %A_ScriptDir%
CoordMode, Mouse, Screen
CoordMode, ToolTip, Screen
SetMouseDelay, -1

;; ## Mouse Settings
;;

global FORCE := 1.5 ; acceleration
global RESISTANCE := .95 ; limits acceleration and top speed

;; ## Default Cursor Marks
;; TODO: easier way for users to save cursor locations between sessions probably read and write to file

global MARKS := {}
global EM_MARKS := {} ; Easymotion style grid

GenerateMarks()
global awaiting_input = 0

;; ## Mappings
;; Change 'CapsLock' in the lines marked ----- to change the extend trigger

*CapsLock:: ; -------------------
    SetTimer, MoveCursor, 10
    SetTimer, SmoothScrollWheel, 40
    return

LShift & RShift::CapsLock

CapsLock up:: ; -------------------
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

sc029::GoToMark(EM_MARKS)
;sc002::F1
;sc003::F2
;sc004::F3
;sc005::F4
;sc006::F5
;sc007::F6
;sc008::
;sc009::
;sc00a::
;sc00b::
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
sc016::Return
sc017::Return
+sc017::JumpTopEdge()
sc018::Return
;sc019::
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
+sc024::JumpLeftEdge()
sc025::Return
+sc025::JumpBottomEdge()
sc026::Return
+sc026::JumpRightEdge()
sc027::^Backspace
sc028::GoToMark(MARKS)
+sc028::GoToMark(EM_MARKS)
;sc02b::

;;  ### Row 4 - lower letter row
;;  ||LS/GT |Z     |X     |C     |V     |B     |N     |M     |,     |.     |/     |Enter |Space ||
;;  ||sc056 |sc02c |sc02d |sc02e |sc02f |sc030 |sc031 |sc032 |sc033 |sc034 |sc035 |sc01c |sc039 ||

sc056::^z
sc02c::^x
sc02d::^Ins
sc02e::LButton
sc02f::+Ins
sc030::RButton
;sc031::
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
; Generate default marks TODO: a loop would be neater. Also need to improve compatibility for different monitor setups (primary on right) requires logic 
GenerateMarks() {
    global 
    SysGet, num_monitors, MonitorCount
    Loop, % Min(num_monitors, 10) {
        EM_MARKS_MON_%A_Index% := {}
        SysGet, mon, Monitor, %A_Index%
        mon_width := monRight - monLeft
        mon_height := monBottom - monTop
        EM_MARKS_MON_%A_Index%["q"] := {x : monLeft + 1*(mon_width // 12), y : monTop + 1*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["w"] := {x : monLeft + 3*(mon_width // 12), y : monTop + 1*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["f"] := {x : monLeft + 5*(mon_width // 12), y : monTop + 1*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["a"] := {x : monLeft + 1*(mon_width // 12), y : monTop + 3*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["r"] := {x : monLeft + 3*(mon_width // 12), y : monTop + 3*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["s"] := {x : monLeft + 5*(mon_width // 12), y : monTop + 3*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["x"] := {x : monLeft + 1*(mon_width // 12), y : monTop + 5*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["c"] := {x : monLeft + 3*(mon_width // 12), y : monTop + 5*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["d"] := {x : monLeft + 5*(mon_width // 12), y : monTop + 5*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["l"] := {x : monLeft + 7*(mon_width // 12), y : monTop + 1*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["u"] := {x : monLeft + 9*(mon_width // 12), y : monTop + 1*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["y"] := {x : monLeft + 11*(mon_width // 12), y : monTop + 1*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["n"] := {x : monLeft + 7*(mon_width // 12), y : monTop + 3*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["e"] := {x : monLeft + 9*(mon_width // 12), y : monTop + 3*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["i"] := {x : monLeft + 11*(mon_width // 12), y : monTop + 3*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["h"] := {x : monLeft + 7*(mon_width // 12), y : monTop + 5*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%[","] := {x : monLeft + 9*(mon_width // 12), y : monTop + 5*(mon_height // 6)}
        EM_MARKS_MON_%A_Index%["."] := {x : monLeft + 11*(mon_width // 12), y : monTop + 5*(mon_height // 6)}
    }
    if (num_monitors == 1) {
        EM_MARKS["q"] := {x : 1*(A_ScreenWidth // 12), y : 1*(A_ScreenHeight // 6)}
        EM_MARKS["w"] := {x : 3*(A_ScreenWidth // 12), y : 1*(A_ScreenHeight // 6)}
        EM_MARKS["f"] := {x : 5*(A_ScreenWidth // 12), y : 1*(A_ScreenHeight // 6)}
        EM_MARKS["a"] := {x : 1*(A_ScreenWidth // 12), y : 3*(A_ScreenHeight // 6)}
        EM_MARKS["r"] := {x : 3*(A_ScreenWidth // 12), y : 3*(A_ScreenHeight // 6)}
        EM_MARKS["s"] := {x : 5*(A_ScreenWidth // 12), y : 3*(A_ScreenHeight // 6)}
        EM_MARKS["x"] := {x : 1*(A_ScreenWidth // 12), y : 5*(A_ScreenHeight // 6)}
        EM_MARKS["c"] := {x : 3*(A_ScreenWidth // 12), y : 5*(A_ScreenHeight // 6)}
        EM_MARKS["d"] := {x : 5*(A_ScreenWidth // 12), y : 5*(A_ScreenHeight // 6)}
        EM_MARKS["l"] := {x : 7*(A_ScreenWidth // 12), y : 1*(A_ScreenHeight // 6)}
        EM_MARKS["u"] := {x : 9*(A_ScreenWidth // 12), y : 1*(A_ScreenHeight // 6)}
        EM_MARKS["y"] := {x : 11*(A_ScreenWidth // 12), y : 1*(A_ScreenHeight // 6)}
        EM_MARKS["n"] := {x : 7*(A_ScreenWidth // 12), y : 3*(A_ScreenHeight // 6)}
        EM_MARKS["e"] := {x : 9*(A_ScreenWidth // 12), y : 3*(A_ScreenHeight // 6)}
        EM_MARKS["i"] := {x : 11*(A_ScreenWidth // 12), y : 3*(A_ScreenHeight // 6)}
        EM_MARKS["h"] := {x : 7*(A_ScreenWidth // 12), y : 5*(A_ScreenHeight // 6)}
        EM_MARKS[","] := {x : 9*(A_ScreenWidth // 12), y : 5*(A_ScreenHeight // 6)}
        EM_MARKS["."] := {x : 11*(A_ScreenWidth // 12), y : 5*(A_ScreenHeight // 6)}
    }
    else if (num_monitors == 2) {
        SysGet, mon1, Monitor, 1
        mon1_width := mon1Right - mon1Left
        mon1_height := mon1Bottom - mon1Top
        SysGet, mon2, Monitor, 2
        mon2_width := mon2Right - mon2Left
        mon2_height := mon2Bottom - mon2Top
        EM_MARKS["q"] := {x : 1*(mon1_width // 12), y : 1*(mon1_height // 6)}
        EM_MARKS["w"] := {x : 6*(mon1_width // 12), y : 1*(mon1_height // 6)}
        EM_MARKS["f"] := {x : 11*(mon1_width // 12), y : 1*(mon1_height // 6)}
        EM_MARKS["a"] := {x : 1*(mon1_width // 12), y : 3*(mon1_height // 6)}
        EM_MARKS["r"] := {x : 6*(mon1_width // 12), y : 3*(mon1_height // 6)}
        EM_MARKS["s"] := {x : 11*(mon1_width // 12), y : 3*(mon1_height // 6)}
        EM_MARKS["x"] := {x : 1*(mon1_width // 12), y : 5*(mon1_height // 6)}
        EM_MARKS["c"] := {x : 6*(mon1_width // 12), y : 5*(mon1_height // 6)}
        EM_MARKS["d"] := {x : 11*(mon1_width // 12), y : 5*(mon1_height // 6)}
        EM_MARKS["l"] := {x : mon1_width + 1*(mon2_width // 12), y : mon2Top + 1*(mon2_height // 6)}
        EM_MARKS["u"] := {x : mon1_width + 6*(mon2_width // 12), y : mon2Top + 1*(mon2_height // 6)}
        EM_MARKS["y"] := {x : mon1_width + 11*(mon2_width // 12), y : mon2Top + 1*(mon2_height // 6)}
        EM_MARKS["n"] := {x : mon1_width + 1*(mon2_width // 12), y : mon2Top + 3*(mon2_height // 6)}
        EM_MARKS["e"] := {x : mon1_width + 6*(mon2_width // 12), y : mon2Top + 3*(mon2_height // 6)}
        EM_MARKS["i"] := {x : mon1_width + 11*(mon2_width // 12), y : mon2Top + 3*(mon2_height // 6)}
        EM_MARKS["h"] := {x : mon1_width + 1*(mon2_width // 12), y : mon2Top + 5*(mon2_height // 6)}
        EM_MARKS[","] := {x : mon1_width + 6*(mon2_width // 12), y : mon2Top + 5*(mon2_height // 6)}
        EM_MARKS["."] := {x : mon1_width + 11*(mon2_width // 12), y : mon2Top + 5*(mon2_height // 6)}
    }
    else {
        SysGet, VirtualScreenWidth, 78
        SysGet, VirtualScreenHeight, 79
        EM_MARKS["q"] := {x : 1*(VirtualScreenWidth // 12), y : 1*(VirtualScreenHeight // 6)}
        EM_MARKS["w"] := {x : 3*(VirtualScreenWidth // 12), y : 1*(VirtualScreenHeight // 6)}
        EM_MARKS["f"] := {x : 5*(VirtualScreenWidth // 12), y : 1*(VirtualScreenHeight // 6)}
        EM_MARKS["a"] := {x : 1*(VirtualScreenWidth // 12), y : 3*(VirtualScreenHeight // 6)}
        EM_MARKS["r"] := {x : 3*(VirtualScreenWidth // 12), y : 3*(VirtualScreenHeight // 6)}
        EM_MARKS["s"] := {x : 5*(VirtualScreenWidth // 12), y : 3*(VirtualScreenHeight // 6)}
        EM_MARKS["x"] := {x : 1*(VirtualScreenWidth // 12), y : 5*(VirtualScreenHeight // 6)}
        EM_MARKS["c"] := {x : 3*(VirtualScreenWidth // 12), y : 5*(VirtualScreenHeight // 6)}
        EM_MARKS["d"] := {x : 5*(VirtualScreenWidth // 12), y : 5*(VirtualScreenHeight // 6)}
        EM_MARKS["l"] := {x : 7*(VirtualScreenWidth // 12), y : 1*(VirtualScreenHeight // 6)}
        EM_MARKS["u"] := {x : 9*(VirtualScreenWidth // 12), y : 1*(VirtualScreenHeight // 6)}
        EM_MARKS["y"] := {x : 11*(VirtualScreenWidth // 12), y : 1*(VirtualScreenHeight // 6)}
        EM_MARKS["n"] := {x : 7*(VirtualScreenWidth // 12), y : 3*(VirtualScreenHeight // 6)}
        EM_MARKS["e"] := {x : 9*(VirtualScreenWidth // 12), y : 3*(VirtualScreenHeight // 6)}
        EM_MARKS["i"] := {x : 11*(VirtualScreenWidth // 12), y : 3*(VirtualScreenHeight // 6)}
        EM_MARKS["h"] := {x : 7*(VirtualScreenWidth // 12), y : 5*(VirtualScreenHeight // 6)}
        EM_MARKS[","] := {x : 9*(VirtualScreenWidth // 12), y : 5*(VirtualScreenHeight // 6)}
        EM_MARKS["."] := {x : 11*(VirtualScreenWidth // 12), y : 5*(VirtualScreenHeight // 6)}
    }
}

; for troubleshooting
;SysGet, MonitorCount, MonitorCount
;SysGet, MonitorPrimary, MonitorPrimary
;MsgBox, Monitor Count:`t%MonitorCount%`nPrimary Monitor:`t%MonitorPrimary%
;Loop, %MonitorCount%
;{
;    SysGet, MonitorName, MonitorName, %A_Index%
;    SysGet, Monitor, Monitor, %A_Index%
;    SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
;    MsgBox, Monitor:`t#%A_Index%`nName:`t%MonitorName%`nLeft:`t%MonitorLeft% (%MonitorWorkAreaLeft% work)`nTop:`t%MonitorTop% (%MonitorWorkAreaTop% work)`nRight:`t%MonitorRight% (%MonitorWorkAreaRight% work)`nBottom:`t%MonitorBottom% (%MonitorWorkAreaBottom% work)
;}

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
            Break
        ToolTip, % key, % value.x, % value.y, % i
        i++
    }
    Input, letter, L1 E
    if (IsNum(letter)) {
        awaiting_input = 0
        RemoveToolTip(i-1)
        GoToMark(EM_MARKS_MON_%letter%)
    }
    else {
        MouseGetPos, prev_x, prev_y
        MouseMove, array[letter].x, array[letter].y
        MARKS["'"] := { x : prev_x, y : prev_y }
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
;; With credit to https://github.com/4strid/mouse-control.autohotkey

global VELOCITY_X := 0
global VELOCITY_Y := 0

; Scroll Wheel -function and time is smoother than mapping directly
SmoothScrollWheel(){
    if GetKeyState("sc016", "P")
        send {WheelUp}
    else if GetKeyState("sc018", "P")
        send {WheelDown}
}

Accelerate(velocity, pos, neg) {
  If (pos + neg == 0) {
    Return 0
  }
  Else {
    Return velocity * RESISTANCE + FORCE * (pos + neg)
  }
}

MoveCursor() {
  UP := 0
  LEFT := 0
  DOWN := 0
  RIGHT := 0
  
  UP := UP - GetKeyState("sc017", "P")
  LEFT := LEFT - GetKeyState("sc024", "P")
  DOWN := DOWN + GetKeyState("sc025", "P")
  RIGHT := RIGHT + GetKeyState("sc026", "P")
  
  VELOCITY_X := Accelerate(VELOCITY_X, LEFT, RIGHT)
  VELOCITY_Y := Accelerate(VELOCITY_Y, UP, DOWN)

  RestoreDPI:=DllCall("SetThreadDpiAwarenessContext","ptr",-3,"ptr") ; enable per-monitor DPI awareness
  MouseMove, %VELOCITY_X%, %VELOCITY_Y%, 0, R
}

;TODO these functions only work on the primary monitor should change to get active monitor

MonitorLeftEdge() {
  mx := 0
  MouseGetPos, mx
  monitor := (mx // A_ScreenWidth)

  return monitor * A_ScreenWidth
}

JumpLeftEdge() {
  x := MonitorLeftEdge() + 50
  y := 0
  MouseGetPos,,y
  MouseMove, x,y
}

JumpBottomEdge() {
  x := 0
  MouseGetPos, x
  MouseMove, x,(A_ScreenHeight - 50)
}

JumpTopEdge() {
  x := 0
  MouseGetPos, x
  MouseMove, x,20
}

JumpRightEdge() {
  x := MonitorLeftEdge() + A_ScreenWidth - 50
  y := 0
  MouseGetPos,,y
  MouseMove, x,y
}
