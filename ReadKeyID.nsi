;ROVALANT
;����������� � ��������� ReadKeyID

;---------------------
;�������� ����������� ������

  !include "MUI2.nsh"       				; - ��� ������, ����������� ��� ������������� ������ ����������
  !include "Sections.nsh"  				; - ������ ��� ������ � �������� ������������
  !include "InstallOptions.nsh"  				; - ������ ��� ������ � �������� ������������
  !include LogicLib.nsh
  !include "FileFunc.nsh"
  !include "WinMessages.nsh"
  !include "WordFunc.nsh"
;--------------------------------
;������������                     � ���� ������� ���������� ������� ��������� ������������

  ;�������
  SetCompressor lzma          				; - ������� ����������� ���������� Lzma
  SetDatablockOptimize on     				; - ����������� ����� ������
  Name "������������ ID ���������"			; - �������� ������������
  OutFile "Install_ReadKeyID.exe"       			; - �������� ���� � ������������� ����� ���������� ����������
  AllowRootDirInstall false   				; - �������� ����������� ��������� ��������� � ������
  AutoCloseWindow false       				; - ������ ������������ ������������ ����� ���������� ���� ��������
  CRCCheck off                				; - ������ �������� ����������� ����� ������������
  SetFont Tahoma 8            				; - �������� ����� ������������ - Tahoma �������� � 8pt
  WindowIcon off              				; - ��������� ������ � ���� ������������
  XPStyle on                  					; - �������� ������������� ����� XP
  SetOverwrite on             				; - ����������� ���������� ������ ��������

  ;����� ��� ����������� �� ���������
  InstallDir "$PROGRAMFILES\Rovalant\ReadKeyID"

;���������� ���-���� ��-���������  
ReserveFile "ReadKeyID.ini"
ReserveFile "ReadKeyID_install.ini"
ReserveFile "${NSISDIR}\Plugins\InstallOptions.dll"
;--------------------------------
;Variables

  Var MUI_TEMP                                			 ; - ��� ���������� ��� �������� ���� ��� ������� � ���� ����
  Var STARTMENU_FOLDER
  Var FL_OLDVER
  Var OLDDIR

!define TEMP1 $R0 					; ��������� ���������� -  ������� R0

;--------------------------------
;��������� ����������

;   !define MUI_ABORTWARNING                    		; - ������ �������������� ��� ������� �� ������ ������
   !define MUI_ICON "C:\Source\ReadID\Img\big.ico"              			; - ������ ����� - ������������
   !define MUI_UNICON "C:\Source\ReadID\Img\bigun.ico"           			; - ������ ����� - ��������������
;--------------------------------
;Pages

  !insertmacro MUI_PAGE_COMPONENTS            		; - �������� � ������� ����������� ��� ���������
  !insertmacro MUI_PAGE_DIRECTORY              		; - �������� � ������� ����� ��� ���������
  Page custom SetupPageEnter ValidateCustom				; - �������� � �������
 
  Page instfiles UninstPrevVer
  !insertmacro MUI_UNPAGE_CONFIRM              		; - �������� � �������������� �������� (�������������)
  !insertmacro MUI_UNPAGE_INSTFILES            		; - �������� � ������������� �������� (�������������)
;--------------------------------
;�����
 
  !insertmacro MUI_LANGUAGE "Russian"      		; - ������ ���� ��� "�������"


;--------------------------------
;������ ����������� ��� ���������

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Section "!���������" Program     			; ������ "���������". ���� "!" ��������, ��� ����� ������ �������

  SectionIn RO     					; ������ ������ ��� ������ (�� ���������)

  SetOutPath "$INSTDIR"              			; ����� ��� ���������� ��������
  File "ReadKeyID.exe"    		; ��������� ������ �����
  File "232.dll"
  File "485.dll"
  File "TimerMan.dll"
;  File "ReadKeyID.pdf"  

;������� uninstall'���� � ���������� ��� � �����, ���� ������������� ���������
  WriteUninstaller "$INSTDIR\Uninstall.exe"

;����� �� ������������?
ReadINIStr $1 "$PLUGINSDIR\ReadKeyID.ini" "Mode" "AutoExec"
StrCmp $1 0 noAuto
MessageBox MB_OK  "��������!!!$\n��������� ����� ������������� ����������� ��� �������� Windows!"
WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "ReadKeyID" "$INSTDIR\ReadKeyID.exe"
noAuto:

;�������� �������
StrCpy $STARTMENU_FOLDER "��������\����������� ID ���������"
    CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"
    CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\����������� ID ���������.lnk" "$INSTDIR\ReadKeyID.exe"
;    CreateShortCut "$SMPROGRAMS\��������\$STARTMENU_FOLDER\����������� ������������.lnk" "$INSTDIR\ReadKeyID.pdf"
    CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\�������.lnk" "$INSTDIR\Uninstall.exe"

;���������� � ������ ��� ������ �������� uninstaller-�
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "DisplayName" "����������� ID ���������"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "UninstallString" "$INSTDIR\Uninstall.exe"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "InstallLocation" "$INSTDIR"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "DisplayIcon" "$INSTDIR\ReadKeyID.exe"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "Publisher" "ROVALANT"
WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "NoModify" 0x00000001
WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "NoRepair" 0x00000001
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "URLInfoAbout" "http://www.rovalant.com"

  ;������� ���-����
  IfFileExists  $PLUGINSDIR\ReadKeyID.ini 0 secend 		                 
  CopyFiles  $PLUGINSDIR\ReadKeyID.ini $INSTDIR\ReadKeyID.ini
secend:
SectionEnd       

 Section /o "������� AIU-USB" AIUUSB 	
  SetOutPath "$INSTDIR\Driver AIU-USB"                    		                 
  File "c:\Source\Cfg777Plus\ver\distrCfg777\Driver AIU-USB\*.*"  
 SectionEnd                           

;--------------------------------
;Descriptions

; � ���� ������ �������� �������, ������� ��������� ��� ��������� �� ��������� ��� ��������� ���������� ���
; ��������

  LangString DESC_Program ${LANG_RUSSIAN} "���� ��������� � ������ ��� ������ ������������ ID ���������."
  LangString DESC_AIUUSB ${LANG_RUSSIAN} "������� ��� (USB) ��� ����������� ������ ������������ ID ��������� ����� ���-����."

   !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN

    !insertmacro MUI_DESCRIPTION_TEXT ${Program} $(DESC_Program)
    !insertmacro MUI_DESCRIPTION_TEXT ${AIUUSB} $(DESC_AIUUSB)

  !insertmacro MUI_FUNCTION_DESCRIPTION_END
 
;--------------------------------
;Installer Functions

LangString TEXT_IO_TITLE1 ${LANG_ENGLISH} "����������� ������"
LangString TEXT_IO_SUBTITLE1 ${LANG_ENGLISH} "���������, ���� ����������� ������ ������������� ��������� ���������..."

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Function .onInit
;����� ���������� ����� ���������, ���� ����
Call GetProgramInstPath
  InitPluginsDir
;����� ��������� ��������� ���-���� ���� ����
  IfFileExists  $INSTDIR\ReadKeyID.ini 0 noinif 		                 
  CopyFiles $INSTDIR\ReadKeyID.ini $PLUGINSDIR\ReadKeyID.ini
  goto noinif1

noinif:
;���� ��� ����������� �� ��������� �� ������������
;���������� ���-����� � ����� ���� � ���������� �������������� ������������
  File /oname=$PLUGINSDIR\ReadKeyID.ini "ReadKeyID.ini"
noinif1:
  File /oname=$PLUGINSDIR\ReadKeyID_install.ini "ReadKeyID_install.ini"

;������� ��������� � ReadKeyID_install.ini �� ReadKeyID.ini

;���-����
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID.ini" "Net" "COM"
  StrCpy $1 "COM$1"
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 3" "State" $1

;������������ ��������� ��� ������� Windows
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID.ini" "Mode" "AutoExec"
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 4" "State" $1

;"�����" ������ �������� ��� ������� ���������
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID.ini" "Mode" "StartMode"
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 5" "State" $1

;����������� ���� ��� ���������� ��������
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID.ini" "Mode" "Sound"
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 6" "State" $1

;����� "�����" � ������ ID ��������
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID.ini" "Time" "TOLife"
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 8" "State" $1

;��� ��������
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID.ini" "Mode" "TypeKey"
  StrCmp $1 0 tp1
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 10" "State" 0
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 11" "State" 1
goto tp2
tp1:
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 10" "State" 1
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 11" "State" 0
tp2:

;����� ������������ ��������� ���������� ���������
  IfFileExists  $INSTDIR\ReadKeyID.exe 0 onInitexit 		                 
   StrCpy $2 "$INSTDIR\ReadKeyID.exe"
   Exec '"$2" -d'
   Delete $2

onInitexit:
FunctionEnd

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LangString TEXT_IO_TITLE ${LANG_ENGLISH} "��������� ���������� ������ ���������"
LangString TEXT_IO_SUBTITLE ${LANG_ENGLISH} "������������� ��������� ����� �������� � ����������� ���� ���������"

;������� ������������� ���� � ���������������� ����������� �� ���-�����
Function SetupPageEnter
  !insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE)" "$(TEXT_IO_SUBTITLE)"
  InstallOptions::initDialog "$PLUGINSDIR\ReadKeyID_install.ini"
  ; In this mode InstallOptions returns the window handle so we can use it
  Pop $0
  ; Now show the dialog and wait for it to finish
  InstallOptions::show
  ; Finally fetch the InstallOptions status value (we don't care what it is though)
  Pop $0
FunctionEnd

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Function ValidateCustom
;������� ��������� � ReadKeyID.ini �� ReadKeyID_install.ini ������ ��� ������ �� ��������
  ReadINIStr $0 "$PLUGINSDIR\ReadKeyID_install.ini" "Settings" "State"
  StrCmp $0 0 validate  ; Next button?
  Abort
validate:

;���-����
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID_install.ini" "Field 3" "State"
  StrCpy $1 $1 "" 3 #
  WriteINIStr "$PLUGINSDIR\ReadKeyID.ini" "Net" "COM" $1

;������������ ��������� ��� ������� Windows
   ReadINIStr $1 "$PLUGINSDIR\ReadKeyID_install.ini" "Field 4" "State"
  WriteINIStr "$PLUGINSDIR\ReadKeyID.ini" "Mode" "AutoExec" $1

;"�����" ������ �������� ��� ������� ���������
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID_install.ini" "Field 5" "State"
  WriteINIStr "$PLUGINSDIR\ReadKeyID.ini" "Mode" "StartMode" $1

;����������� ���� ��� ���������� ��������
 ReadINIStr $1  "$PLUGINSDIR\ReadKeyID_install.ini" "Field 6" "State"
 WriteINIStr  "$PLUGINSDIR\ReadKeyID.ini" "Mode" "Sound" $1

;����� "�����" � ������ ID ��������
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID_install.ini" "Field 8" "State"
  WriteINIStr "$PLUGINSDIR\ReadKeyID.ini" "Time" "TOLife" $1

;��� ��������
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID_install.ini" "Field 10" "State"
  StrCmp $1 0 tp11
  WriteINIStr "$PLUGINSDIR\ReadKeyID.ini" "Mode" "TypeKey" 0
goto tp21
tp11:
  WriteINIStr "$PLUGINSDIR\ReadKeyID.ini" "Mode" "TypeKey" 1
tp21:
FunctionEnd


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;����� ���� ���������� �����������, ���� ����
Function GetProgramInstPath
 StrCpy $FL_OLDVER 0
 ReadRegStr $0 HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "InstallLocation"
  StrCmp $0 "" getpath
  StrCpy $INSTDIR $0 
  StrCpy $OLDDIR $0 
  StrCpy $FL_OLDVER 1
  getpath:
FunctionEnd

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Function .onInstSuccess
;����� �� �������� ���������?
ReadINIStr $1 "$PLUGINSDIR\ReadKeyID_install.ini" "Field 12" "State"
StrCmp $1 0 noStart
   StrCpy $2 "$INSTDIR\ReadKeyID.exe"
   Exec '"$2"'
   Delete $2
noStart:
FunctionEnd

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Function UninstPrevVer
  !insertmacro MUI_HEADER_TEXT "$(TEXT_IO_TITLE1)" "$(TEXT_IO_SUBTITLE1)"
  ;������� ������ ������
  ;MessageBox MB_YESNO|MB_ICONQUESTION "��������!!!$\n���������� ��������� ��������� ����� �������.$\n> ����������?" IDYES newinst1
  ;Abort
;newinst1:
  ;�������� ������ ������ $INSTDIR
  StrCmp $FL_OLDVER 0 secprg1			    	;���� �� ���� ������ ������ - ����������, ����� - �������
  
   StrCpy $2 "$OLDDIR\Uninstall.exe"
   ExecWait '"$2" /S'
   Delete $2
;MessageBox MB_OK $INSTDIR

; ������� ���������
            Banner::show /set 76 "�������� ���������� ������..." ""
	Banner::getWindow
	Pop $1

	StrCpy $3 0
	again:
		IntOp $3 $3 + 1
		Sleep 100
		IfFileExists $INSTDIR\Uninstall.exe 0 +2
		StrCmp $3 7 0 again

	StrCpy $3 0
	again2:
		IntOp $3 $3 + 1
		Sleep 1
		StrCmp $3 100 again2

	Banner::destroy

  Sleep 100
  secprg1:
FunctionEnd

;###################################################################
;Uninstaller Section


Section "Uninstall"  ; ������ ������ ���������� ��� �������� ��������������

StrCpy $MUI_TEMP "��������\����������� ID ���������"
;  !insertmacro MUI_STARTMENU_GETFOLDER Application $MUI_TEMP    		; �������� �� ������� ���� � �������
  Delete "$SMPROGRAMS\$MUI_TEMP\����������� ID ���������.lnk"       	; � ������� ��
;  Delete "$SMPROGRAMS\$MUI_TEMP\����������� ������������.lnk"       	
  Delete "$SMPROGRAMS\$MUI_TEMP\�������.lnk"
 
  ;������� �������� ������ ���� ����
  StrCpy $MUI_TEMP "$SMPROGRAMS\$MUI_TEMP"
 
  startMenuDeleteLoop:
    RMDir $MUI_TEMP
    GetFullPathName $MUI_TEMP "$MUI_TEMP\.."
    
    IfErrors startMenuDeleteLoopDone
  
    StrCmp $MUI_TEMP $SMPROGRAMS startMenuDeleteLoopDone startMenuDeleteLoop
  startMenuDeleteLoopDone:

  RMDir "$SMPROGRAMS\$MUI_TEMP"        	; ������� �������� �����

  ;������� ���...
  Delete "$INSTDIR\Driver AIU-USB\*.*"
  Delete "$INSTDIR\*.*"
  RMDir "$INSTDIR\Driver AIU-USB"
  RMDir "$INSTDIR" 

;����� � ���������� ������� ����� ��������
  ${WordFind} "$INSTDIR" "\" "-2{*" $INSTDIR
  RMDir "$INSTDIR" 
 ;MessageBox MB_OK  $R0


  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID"
  DeleteRegValue  HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"  "ReadKeyID"
SectionEnd

Function un.onInit
;����� ������������ ��������� ���������� ���������
  IfFileExists  $INSTDIR\ReadKeyID.exe 0 onunitexit 		                 
   StrCpy $2 "$INSTDIR\ReadKeyID.exe"
   Exec '"$2" -d'
   Delete $2

onunitexit:
FunctionEnd
