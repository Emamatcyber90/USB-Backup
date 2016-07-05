
#include "BinaryCall.au3"
#include "USB-Backup_Tools_bin_sync.au3"
#include "USB-Backup_Tools_bin_7zip_x64.au3"
#include "USB-Backup_Tools_bin_vscsc_x64.au3"

; #FUNCTION# ====================================================================================================================
; Name ..........: DoBackup_PrepareExefiles
; Description ...: Stellt die passende vscsc.exe usw. zur Verf�gung und l�dt auch die benutzten Dll Files
; Syntax ........: DoBackup_PrepareExefiles($sTempPath)
; Author ........: Tino Reichardt
; Modified ......: 17.04.2014
; ===============================================================================================================================
Func DoBackup_PrepareExefiles($sTempPath)
	If Not FileExists($sTempPath & "vscsc.exe") Then _vscscx64exe(True, $sTempPath)
	If Not FileExists($sTempPath & "sync.exe") Then _syncexe(True, $sTempPath)
	If Not FileExists($sTempPath & "7z.dll") Then _7z_x64dll(True, $sTempPath)
	If Not FileExists($sTempPath & "7zg-mini.exe") Then _7zgminiexe2(True, $sTempPath)
EndFunc   ;==>DoBackup_PrepareExefiles

Func _WinAPI_Base64Decode($sB64String)
	Local $aCrypt = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "ptr", 0, "dword*", 0, "ptr", 0, "ptr", 0)
	If @error Or Not $aCrypt[0] Then Return SetError(1, 0, "")
	Local $bBuffer = DllStructCreate("byte[" & $aCrypt[5] & "]")
	$aCrypt = DllCall("Crypt32.dll", "bool", "CryptStringToBinaryA", "str", $sB64String, "dword", 0, "dword", 1, "struct*", $bBuffer, "dword*", $aCrypt[5], "ptr", 0, "ptr", 0)
	If @error Or Not $aCrypt[0] Then Return SetError(2, 0, "")
	Return DllStructGetData($bBuffer, 1)
EndFunc   ;==>_WinAPI_Base64Decode

Func ASM_DecompressLZMAT($Data)
	Local Const $MEM_COMMIT = 4096, $PAGE_EXECUTE_READWRITE = 64, $MEM_RELEASE = 32768
	If @AutoItX64 Then
		Local $Code = "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"
		$Code &= "5/o1kEQsAf7ChQJKEWf+KPU06QsjULCtlHGUMyrwiJMbCggKTje0+TgXdGmQGXisYu9BxgKaIwr4HApKAQw/fMgSArJnA8oeSdHJqVNxagiueGUCImaKKhdshPB5iEkCHQnGQAMYF+nk0TdpgoAK8OuH/JE5agKytTp0np6Md2oBNUARWlgo5ukqCBEPM8DqFFEU4sX7H0lHQRVGyjMdg+gB5l6gi9M1J/HokAOWAfx2ZkGJJMMQiQIWuiDb/YIUHMFqySVhq4Q/EoD5Ib0MLCkZJjioUnA8/SgzlwEgZ+l9+kmBIKC0SwEvhHYkd/kuc1LVL4gDxlvdTLhpnpUVrlgn0tgHBqF6VvdwlLTPoJJ25AaLKogBuFfhaNsouwhkkD30gC3PKfdMOUUXg6RCPEWE5GmqAgGJ34M5dDgBRS4MLEkU5osYwO0ICfUwg8MkMfbrGC6J3jNUMPudSzS61JpAOsDuDkQJ1uWIN6HSnU1B2MYJ/ggfdJxF1O1noN92jOjoIHOIFu14FBrh3UCvPDk0dbGeRUnrwDOA0IQkEmvC5TiHZDxswO9VBGiYGv/Q1z2Uv0e3v8aGuFuA7/qDMecDPuoC3f/PO4A1wZASAyFgkAEpOdKgg1TWthyYWinmP54MgPQ1rpzBR+OdCEYCHEO1BcMDOcaC9fR5oBo8GGDxgnnegRnF2iZt6RmJwkbrjn4p8qoMCSAYRQ6cvNeaxiJiGCSvOZAFRYXbkA70MXZ1sTmh0KG2oM9Bt5W+SEs/+hTR6rtEiKKLuvOtooQEl+AwB6Sx8Mb1KK6aJBq4YaVSQDXA6wSRHIq227VjhUtlKx3UBa18GgWXOfkOr+nyMcp0ZSdGEbZc1CMS4wQlSgtC30Omp/KB+1oPKnRQ9EQShmkMl24oN7gEjZ+pwxjrLDDTqDNh1hKn5n9lRwVE6bcp2xQSMVB1sGCmVDoaAtoCuIKBAW5VeSOErdLKzbsNjZ8RTZmcApMQdecB3HP+FAg/JJ+NmvzUTHOjIt7TkJgYBb9/EUQhUO/8PnQEJDQ/sBD4jRJdaLEkJ5wDdiOD7unrB7ILGRdBcdoxdoGIBEeLFBAsbWhG0TzMfyziHYvp8ajvXg6NsmoEqsjRi+nXKl+X0QMJB/nqHkS5Qo10HoCvOfFyf6I9r6rpHxgxHDB1vqaa+0OlDh2qtDIng0TpiGhjPsVSGmVkO6kF9olT69UaI5FKwyILSDvNuBQ4vvLDsAuJAjMxwB+4vj8769/2oQfYYkoFt3Qw+wqswICLAfaIoUIRAx3rvNQQBxe1VwyMzwbQlQD+/POqX2DDAA=="
	Else
		Local $Code = "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"
		$Code &= "/id8kUgoGcQx6d+KOQN0d42I71gbLXDqiaQjkCShGg8y0SwBdmp/IAxNAuyIAxEMjZ1rWqFq5KNJslERd1oWbQJAg8rwiFZAKkYDpA6gQ+m+0DV3jICU8LqooVCJssR4BJCC6UOvryGF5gG/funUP/0JA3VnuSrYwlk7kUyTCc7NZTuRQY/pjfmmZn0gdJowKggWDjLA6hRWhKlwjUclqiIz1Yh3mr816TY1iU36JAPdLd+EZAqzN5cUEPdH9UCZavcmEkP+bTBBCK9U0y2OyBEwBArp7/grkhiJkXCOQLEbRwGbJIJYoJJfEukL+jQ/zCX1IYgGYvT4RXnKmbLed054IOL8uUuTuCXnyU5ilktxoulxgIVVMe1XVr6hUVNskdyszpdIJyPGOOVSiG1pIYbi6yAG0ynROc7MVRS9jx6E21zTO1DWMd0xPhQyLB9UTYjeJPIdMURi0Bf3o+sqwFwnRTMl598XV8HjArXaiBHrRp5N62KZAwh0kNBkGWyJ6UbRRnnpe/EnhnmJS+Acg3HxM7I4FBd4GTXJgIvBhNIpdaZaY+uwS3YcS9KPjYaQLwySxhsUU9mpCbcMMSMxCctzEks9Mly+xH37cTEg2OuYNHP595luKIJo7gwaA8gSnmQBCnPv44nZLFY/nKHzHIjkTgfqgPLOrNVAr5mElhwKIeOpH/vyILUvgcMDOcFwo/TEF40UD9dmgsiNtD4LhgrIgcKDCusBKcrLagESEE+YKO3Rx/uywkNwazfLYRk7QfEQdmjNFjGJEEOga1EAFtt14YvSEyAa6cH+wpPL0euIlaSbvNO61pOm+vWAldmB4f9BB9nBbGdwr6+KhVGBoa+qHkTr26S1KYVLlz/gHY1UMwFKORTcDsSCL1p0gGx0dotUhCQcMsZtpKV3JnvTZSWB+6KvdGeE9BJGhgyVvLgJuASef6p+mI/pgqq1sZ8cCIjBFhTp0v2U99kWQMt/kWCyOIiDoOmbQll20GeGdZlTVCilAoSAobMBjPXP/Ir6OrfRwiViCcEiIZJYdA7SZioLVNR4txuNmhFZIKYCWxBUzhNp1TE/TQsKTDP8dR3hopA4XAUzgRSD4n+O9BEEhxwSf4nQEdU8qF+VJHQw2Ql2LBl9621xUcdEaoNTDVAbxgSj0Z49Fw6LKlL8xkZcC4kpdeUBgOme/FneaKTJKBJUgrBBBAqshOmg/ZknRdMQzx/UFFTVA4MkoEEdRn5FgYwyJwY4j0TpxJeA8aADdEgrY6fF2h6zJKgaDmVUcEoTTBGNFowTQYEw6Tmmi8XkMWVaJl8MLH8xxG/ry4yDt4CBw5E2CenFJCy4jUBF5CjfRDSJAx32vBi4Ajvr4e/ahQfamHtUBzH7geLAiyANDBLpsaFCAxHrvN0QQQe1V71NEoXJF0hFiQxpxhcDsuYJCPfHA5BaCqpSSQoAdfaJysHpAh7886sW0V23xqpfwwA="
	EndIf
	Local $Opcode = String(_LZMAT_CodeDecompress($Code))
	Local $_LZMAT_Compress = (StringInStr($Opcode, "89C0") + 1) / 2
	Local $_LZMAT_Decompress = (StringInStr($Opcode, "89DB") + 1) / 2
	$Opcode = Binary($Opcode)
	Local $_LZMAT_CodeBufferMemory = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", 0, "ulong_ptr", BinaryLen($Opcode), "dword", $MEM_COMMIT, "dword", $PAGE_EXECUTE_READWRITE)
	$_LZMAT_CodeBufferMemory = $_LZMAT_CodeBufferMemory[0]
	Local $_LZMAT_CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $_LZMAT_CodeBufferMemory)
	DllStructSetData($_LZMAT_CodeBuffer, 1, $Opcode)
	Local $OutputLen = Int(BinaryMid($Data, 1, 4))
	$Data = BinaryMid($Data, 5)
	Local $InputLen = BinaryLen($Data)
	Local $Input = DllStructCreate("byte[" & $InputLen & "]")
	DllStructSetData($Input, 1, $Data)
	Local $Output = DllStructCreate("byte[" & $OutputLen & "]")
	Local $Ret = DllCallAddress("uint", DllStructGetPtr($_LZMAT_CodeBuffer) + $_LZMAT_Decompress, "struct*", $Input, "uint", $InputLen, "struct*", $Output, "uint*", $OutputLen)
	DllCall("kernel32.dll", "bool", "VirtualFree", "ptr", $_LZMAT_CodeBufferMemory, "ulong_ptr", 0, "dword", $MEM_RELEASE)
	Return BinaryMid(DllStructGetData($Output, 1), 1, $Ret[4])
EndFunc   ;==>ASM_DecompressLZMAT

Func _LZMAT_CodeDecompress($Code)
	Local Const $MEM_COMMIT = 4096, $PAGE_EXECUTE_READWRITE = 64, $MEM_RELEASE = 32768
	If @AutoItX64 Then
		Local $Opcode = "0x89C04150535657524889CE4889D7FCB28031DBA4B302E87500000073F631C9E86C000000731D31C0E8630000007324B302FFC1B010E85600000010C073F77544AAEBD3E85600000029D97510E84B000000EB2CACD1E8745711C9EB1D91FFC8C1E008ACE8340000003D007D0000730A80FC05730783F87F7704FFC1FFC141904489C0B301564889FE4829C6F3A45EEB8600D275078A1648FFC610D2C331C9FFC1E8EBFFFFFF11C9E8E4FFFFFF72F2C35A4829D7975F5E5B4158C389D24883EC08C70100000000C64104004883C408C389F64156415541544D89CC555756534C89C34883EC20410FB64104418800418B3183FE010F84AB00000073434863D24D89C54889CE488D3C114839FE0F84A50100000FB62E4883C601E8C601000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D3C1E20241885500EB7383FE020F841C01000031C083FE03740F4883C4205B5E5F5D415C415D415EC34863D24D89C54889CE488D3C114839FE0F84CA0000000FB62E4883C601E86401000083ED2B4080FD5077E2480FBEED0FB6042884C078D683E03F410845004983C501E964FFFFFF4863D24D89C54889CE488D3C114839FE0F84E00000000FB62E4883C601E81D01000083ED2B4080FD5077E2480FBEED0FB6042884C00FBED078D389D04D8D7501C1E20483E03041885501C1F804410845004839FE747B0FB62E4883C601E8DD00000083ED2B4080FD5077E6480FBEED0FB6042884C00FBED078D789D0C1E2064D8D6E0183E03C41885601C1F8024108064839FE0F8536FFFFFF41C7042403000000410FB6450041884424044489E84883C42029D85B5E5F5D415C415D415EC34863D24889CE4D89C6488D3C114839FE758541C7042402000000410FB60641884424044489F04883C42029D85B5E5F5D415C415D415EC341C7042401000000410FB6450041884424044489E829D8E998FEFFFF41C7042400000000410FB6450041884424044489E829D8E97CFEFFFF56574889CF4889D64C89C1FCF3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3"
	Else
		Local $Opcode = "0x89C0608B7424248B7C2428FCB28031DBA4B302E86D00000073F631C9E864000000731C31C0E85B0000007323B30241B010E84F00000010C073F7753FAAEBD4E84D00000029D97510E842000000EB28ACD1E8744D11C9EB1C9148C1E008ACE82C0000003D007D0000730A80FC05730683F87F770241419589E8B3015689FE29C6F3A45EEB8E00D275058A164610D2C331C941E8EEFFFFFF11C9E8E7FFFFFF72F2C32B7C2428897C241C61C389D28B442404C70000000000C6400400C2100089F65557565383EC1C8B6C243C8B5424388B5C24308B7424340FB6450488028B550083FA010F84A1000000733F8B5424388D34338954240C39F30F848B0100000FB63B83C301E8CD0100008D57D580FA5077E50FBED20FB6041084C00FBED078D78B44240CC1E2028810EB6B83FA020F841201000031C083FA03740A83C41C5B5E5F5DC210008B4C24388D3433894C240C39F30F84CD0000000FB63B83C301E8740100008D57D580FA5077E50FBED20FB6041084C078DA8B54240C83E03F080283C2018954240CE96CFFFFFF8B4424388D34338944240C39F30F84D00000000FB63B83C301E82E0100008D57D580FA5077E50FBED20FB6141084D20FBEC278D78B4C240C89C283E230C1FA04C1E004081189CF83C70188410139F374750FB60383C3018844240CE8EC0000000FB654240C83EA2B80FA5077E00FBED20FB6141084D20FBEC278D289C283E23CC1FA02C1E006081739F38D57018954240C8847010F8533FFFFFFC74500030000008B4C240C0FB60188450489C82B44243883C41C5B5E5F5DC210008D34338B7C243839F3758BC74500020000000FB60788450489F82B44243883C41C5B5E5F5DC210008B54240CC74500010000000FB60288450489D02B442438E9B1FEFFFFC7450000000000EB9956578B7C240C8B7424108B4C241485C9742FFC83F9087227F7C7010000007402A449F7C702000000740566A583E90289CAC1E902F3A589D183E103F3A4EB02F3A45F5EC3E8500000003EFFFFFF3F3435363738393A3B3C3DFFFFFFFEFFFFFF000102030405060708090A0B0C0D0E0F10111213141516171819FFFFFFFFFFFF1A1B1C1D1E1F202122232425262728292A2B2C2D2E2F3031323358C3"
	EndIf
	Local $AP_Decompress = (StringInStr($Opcode, "89C0") - 3) / 2
	Local $B64D_Init = (StringInStr($Opcode, "89D2") - 3) / 2
	Local $B64D_DecodeData = (StringInStr($Opcode, "89F6") - 3) / 2
	$Opcode = Binary($Opcode)
	Local $CodeBufferMemory = DllCall("kernel32.dll", "ptr", "VirtualAlloc", "ptr", 0, "ulong_ptr", BinaryLen($Opcode), "dword", $MEM_COMMIT, "dword", $PAGE_EXECUTE_READWRITE)
	$CodeBufferMemory = $CodeBufferMemory[0]
	Local $CodeBuffer = DllStructCreate("byte[" & BinaryLen($Opcode) & "]", $CodeBufferMemory)
	DllStructSetData($CodeBuffer, 1, $Opcode)
	Local $B64D_State = DllStructCreate("byte[16]")
	Local $Length = StringLen($Code)
	Local $Output = DllStructCreate("byte[" & $Length & "]")
	DllCallAddress("none", DllStructGetPtr($CodeBuffer) + $B64D_Init, "struct*", $B64D_State, "int", 0, "int", 0, "int", 0)
	DllCallAddress("int", DllStructGetPtr($CodeBuffer) + $B64D_DecodeData, "str", $Code, "uint", $Length, "struct*", $Output, "struct*", $B64D_State)
	Local $ResultLen = DllStructGetData(DllStructCreate("uint", DllStructGetPtr($Output)), 1)
	Local $Result = DllStructCreate("byte[" & ($ResultLen + 16) & "]"), $Ret
	If @AutoItX64 Then
		$Ret = DllCallAddress("uint", DllStructGetPtr($CodeBuffer) + $AP_Decompress, "ptr", DllStructGetPtr($Output) + 4, "struct*", $Result, "int", 0, "int", 0)
	Else
		$Ret = DllCall("user32.dll", "uint", "CallWindowProc", "ptr", DllStructGetPtr($CodeBuffer) + $AP_Decompress, "ptr", DllStructGetPtr($Output) + 4, "ptr", DllStructGetPtr($Result), "int", 0, "int", 0)
	EndIf
	DllCall("kernel32.dll", "bool", "VirtualFree", "ptr", $CodeBufferMemory, "ulong_ptr", 0, "dword", $MEM_RELEASE)
	Return BinaryMid(DllStructGetData($Result, 1), 1, $Ret[0])
EndFunc   ;==>_LZMAT_CodeDecompress
