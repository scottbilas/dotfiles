; emulate term
^[::Send {Esc}

; below is adapted from https://autohotkey.com/board/topic/51959-using-capslock-as-another-modifier-key/

$*Capslock::
Gui, 99:+ToolWindow
Gui, 99:Show, NoActivate, Capslock Is Down
keywait, Capslock
Gui, 99:Destroy
return

#IfWinExist, Capslock Is Down
; vimish
h::Left
j::Down
k::Up
l::Right
; could try to be vimish on these, but can't really do $ with left pinky already on capslock
u::Home
m::End
i::PgUp
,::PgDn
BackSpace::Del
#IfWinExist

; work around accidental ctrl-shift-q in firefox
$^+q::
IfWinNotActive, ahk_exe firefox.exe
{
    Send ^+q ; this is not Firefox, so send the key again.
}
