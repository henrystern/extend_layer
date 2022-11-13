#NoEnv
SendMode Input
SetWorkingDir %A_ScriptDir%
#installkeybdhook

;; *** Mouse Settings
;;

global FORCE := 1.5 ; acceleration
global RESISTANCE := .95 ; limits acceleration and top speed

;; *** Default Cursor Marks
;; TODO: easier way for users to save cursor locations between sessions

global MARKS := { m : { x : (A_ScreenWidth // 2), y : (A_ScreenHeight // 2) } }
global awaiting_input = 0

;; *** Extend trigger settings
;; Modify the lines marked ----- to change the extend trigger

*CapsLock::SetTimer, MoveCursor, 10 ; -------------------
LShift & RShift::CapsLock

; release modifiers if they are still held when extend is released
CapsLock up:: ; -------------------
    SetTimer, MoveCursor, off
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
    return


;; *** Mappings
;;

#If, GetKeyState("CapsLock", "P") and awaiting_input == 0 ; ------------------------

;;  *** Row 0 - function keys
;;

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

;;  *** Row 1 - number row
;;  ||`     |1     |2     |3     |4     |5     |6     |7     |8     |9     |0     |-     |=     |Back  ||
;;  ||sc029 |sc002 |sc003 |sc004 |sc005 |sc006 |sc007 |sc008 |sc009 |sc00a |sc00b |sc00c |sc00d |sc00e ||

;sc029::
sc002::F1
sc003::F2
sc004::F3
sc005::F4
sc006::F5
sc007::F6
;sc008::
;sc009::
;sc00a::
;sc00b::
;sc00c::
;sc00d::

;sc00e::

;;  *** Row 2 - upper letter row
;;  ||Tab     |Q     |W     |E     |R     |T     |Y     |U     |I     |O     |P     |[     |]     ||
;;  ||RWWc00f |sc010 |sc011 |sc012 |sc013 |sc014 |sc015 |sc016 |sc017 |sc018 |sc019 |sc01a |sc01b ||

sc010::Home
sc011::Up
sc012::End
sc013::Delete
sc014::Esc
sc015::PgUp
sc016::send {WheelUp 1}
sc017::Return
+sc017::JumpTopEdge()
sc018::send {WheelDown 1}
sc019::^t
sc01a::^+Tab
sc01b::^Tab

;;  *** Row 3 - home row
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
sc028::
    tooltip, go to mark
    awaiting_input = 1
    Input, letter, L1 E
    tooltip, went to mark at %letter%
    SetTimer, RemoveToolTip, 2000
    GoToMark(letter)
    awaiting_input = 0
    Return
;sc02b::

;;  *** Row 4 - lower letter row
;;  ||LS/GT |Z     |X     |C     |V     |B     |N     |M     |,     |.     |/     |Enter |Space ||
;;  ||sc056 |sc02c |sc02d |sc02e |sc02f |sc030 |sc031 |sc032 |sc033 |sc034 |sc035 |sc01c |sc039 ||

;sc056::^z
sc02c::^x
sc02d::^Ins
sc02e::LButton
sc02f::+Ins
sc030::RButton
;sc031::
sc032::Shift
sc033::Ctrl
sc034::Alt
sc035::
    tooltip, set mark
    awaiting_input = 1
    Input, letter, L1
    tooltip, set mark at %letter%
    SetTimer, RemoveToolTip, 2000
    SetMark(letter)
    awaiting_input = 0
    Return

;sc01c::
sc039::Enter

;; *** Mouse Buttons
;;

;XButton1::^c
;XButton2::^v

;; *** Functions
;;
;;

#If

;; *** Cursor Marks Functions
;;

SetMark(letter) {
    MouseGetPos, cur_x, cur_y
    MARKS[(letter)] := {x:cur_x, y:cur_y}
}

GoToMark(letter) {
    MouseGetPos, prev_x, prev_y
    MouseMove, MARKS[letter].x, MARKS[letter].y
    ObjRawSet(MARKS, "'", { x : prev_x, y : prev_y })
}

RemoveToolTip:
    tooltip
    return

;; *** Mouse Functions
;; Credit to https://github.com/4strid/mouse-control.autohotkey

global VELOCITY_X := 0
global VELOCITY_Y := 0

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
  SetMouseDelay, -1  ; Makes movement smoother.
  MouseMove, %VELOCITY_X%, %VELOCITY_Y%, 0, R
}

MonitorLeftEdge() {
  mx := 0
  CoordMode, Mouse, Screen
  MouseGetPos, mx
  monitor := (mx // A_ScreenWidth)

  return monitor * A_ScreenWidth
}

JumpLeftEdge() {
  x := MonitorLeftEdge() + 50
  y := 0
  CoordMode, Mouse, Screen
  MouseGetPos,,y
  SetMouseDelay, -1
  MouseMove, x,y
}

JumpBottomEdge() {
  x := 0
  CoordMode, Mouse, Screen
  MouseGetPos, x
  SetMouseDelay, -1
  MouseMove, x,(A_ScreenHeight - 50)
}

JumpTopEdge() {
  x := 0
  CoordMode, Mouse, Screen
  MouseGetPos, x
  SetMouseDelay, -1
  MouseMove, x,20
}

JumpRightEdge() {
  x := MonitorLeftEdge() + A_ScreenWidth - 50
  y := 0
  CoordMode, Mouse, Screen
  MouseGetPos,,y
  SetMouseDelay, -1
  MouseMove, x,y
}
