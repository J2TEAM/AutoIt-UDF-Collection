#include <GDIPlus.au3>
#include <GUIConstantsEx.au3>
#include <Sound.au3>
#include <WindowsConstants.au3>

_GDIPlus_Startup()
Local Const $iWidth = 530, $iHeight = 512, $iBgColor = 0x303030

Local $hGUI = GUICreate("Yagami Raito", $iWidth, $iHeight,-1,-1,BitOR($WS_SYSMENU, $WS_CAPTION))
GUISetBkColor($iBgColor, $hGUI)
GUISetState(@SW_SHOW)

Local $hGraphics = _GDIPlus_GraphicsCreateFromHWND($hGUI)
Local $hBitmap = _GDIPlus_BitmapCreateFromMemory(InetRead("http://beonefood.com/upload/8328/20131228/47.png"))
Local $iW = _GDIPlus_ImageGetWidth($hBitmap), $iH = _GDIPlus_ImageGetHeight($hBitmap)
_GDIPlus_GraphicsDrawImage($hGraphics, $hBitmap, ($iWidth - $iW) / 2, ($iHeight - $iH) / 2)

$hBrush = _GDIPlus_BrushCreateSolid(0xFFFFFFFF)
$hFormat = _GDIPlus_StringFormatCreate()
$hFamily = _GDIPlus_FontFamilyCreate("Consolas")
$hFont = _GDIPlus_FontCreate($hFamily, 18, 3)
$tLayout = _GDIPlus_RectFCreate(10, 20, 520, 100)
_GDIPlus_GraphicsDrawStringEx($hGraphics,"Chai dầu là đầu câu chuyện :))", $hFont, $tLayout, $hFormat, $hBrush)

Do
Until GUIGetMsg() = $GUI_EVENT_CLOSE

_GDIPlus_BitmapDispose($hBitmap)
_GDIPlus_GraphicsDispose($hGraphics)
_GDIPlus_Shutdown()
GUIDelete($hGUI)

