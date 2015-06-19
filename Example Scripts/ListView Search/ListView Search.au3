#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <GuiListView.au3>
#include <GuiEdit.au3>
#include <File.au3>
#include <SQLite.au3>
#include <Array.au3>

Global $FileList, $iRows, $iColumns

_SQLite_Startup()

_SQLite_Open("karalist.db")

_SQLite_GetTable2d(-1, "SELECT * FROM song LIMIT 69; ORDER BY id", $FileList , $iRows, $iColumns)

_ArrayDelete($FileList,0)


$Form1 = GUICreate("Karaoke Search - Huỳnh Phúc Huy", 572, 400, 192, 124)
$ListView1 = GUICtrlCreateListView("ID|Song|Artist", 8, 50, 554, 326)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 0, 60)
GUICtrlSendMsg(-1, $LVM_SETCOLUMNWIDTH, 1, 300)
$Input1 = GUICtrlCreateInput("", 8, 10, 554, 21)
GUICtrlSendMsg(-1, $EM_SETCUEBANNER, True, "Search ...")
GUICtrlSetState($Input1, $GUI_FOCUS)
GUISetState(@SW_SHOW)


If IsArray($FileList) Then
    For $i = 0 To Ubound($FileList)-1
        $ListView1_1 = GUICtrlCreateListViewItem($FileList[$i][0]&"|"&$FileList[$i][1]&"|"&$FileList[$i][5], $ListView1)
    Next
Else
    Exit
EndIf


GUIRegisterMsg($WM_COMMAND, "_WM_COMMAND")

While 1

    Switch GUIGetMsg()
        Case $GUI_EVENT_CLOSE
            Exit
    EndSwitch
WEnd


Func _WM_COMMAND($hWnd, $MsgID, $wParam, $lParam)

    Local $nID = BitAND($wParam, 0xFFFF)
    Local $nNotifyCode = BitShift($wParam, 16)

    If $nNotifyCode = $EN_CHANGE Then
        If $nID = $Input1 Then

            $sText = GUICtrlRead($Input1)

             _GUICtrlListView_BeginUpdate($ListView1)

			If  $sText<>"" Then


            $iIndexs = _ArrayFindAll($FileList, $sText,0,0,0,1,1) ; Convert to 0-based

			_GUICtrlListView_DeleteAllItems($ListView1)

			for $i=0 to Ubound($iIndexs)-1
				 _GUICtrlListView_AddItem($ListView1,$FileList[$iIndexs[$i]][0])
				 _GUICtrlListView_AddSubItem($ListView1, $i, $FileList[$iIndexs[$i]][1], 1)
				 _GUICtrlListView_AddSubItem($ListView1, $i, $FileList[$iIndexs[$i]][5], 2)
            next


            ControlSend($Form1, "", $Input1, "{END}")

		    Else

			_GUICtrlListView_DeleteAllItems($ListView1)

			for $i=0 to Ubound($FileList)-1
				 _GUICtrlListView_AddItem($ListView1,$FileList[$i][0])
				 _GUICtrlListView_AddSubItem($ListView1, $i, $FileList[$i][1], 1)
				 _GUICtrlListView_AddSubItem($ListView1, $i, $FileList[$i][5], 2)
			next

			EndIf

            sleep(100)
            GUICtrlSetState($Input1, $GUI_FOCUS)
            ControlSend($Form1, "", $Input1, "{END}")

            _GUICtrlListView_EndUpdate($ListView1)
	EndIf
    EndIf

    Return $GUI_RUNDEFMSG
EndFunc
