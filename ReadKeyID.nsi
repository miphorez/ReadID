;ROVALANT
;инсталлятор к программе ReadKeyID

;---------------------
;Включаем необходимые модули

  !include "MUI2.nsh"       				; - это модуль, необходимый для использования нового интерфейса
  !include "Sections.nsh"  				; - модуль для работы с секциями инсталлятора
  !include "InstallOptions.nsh"  				; - модуль для работы с секциями инсталлятора
  !include LogicLib.nsh
  !include "FileFunc.nsh"
  !include "WinMessages.nsh"
  !include "WordFunc.nsh"
;--------------------------------
;Конфигурация                     в этом разделе содержатся главные настройки инсталлятора

  ;Главная
  SetCompressor lzma          				; - сжимаем инсталлятор алгоритмом Lzma
  SetDatablockOptimize on     				; - оптимизация блока данных
  Name "«Считыватель ID пропусков»"			; - название инсталлятора
  OutFile "Install_ReadKeyID.exe"       			; - выходной файл с инсталлятором после выполнения компиляции
  AllowRootDirInstall false   				; - отменяем возможность установки программы в корень
  AutoCloseWindow false       				; - отмена автозакрытия инсталлятора после выполнения всех действий
  CRCCheck off                				; - отмена проверки контрольной суммы инсталлятора
  SetFont Tahoma 8            				; - основной шрифт инсталлятора - Tahoma размером в 8pt
  WindowIcon off              				; - выключаем иконку у окна инсталлятора
  XPStyle on                  					; - включаем использование стиля XP
  SetOverwrite on             				; - возможность перезаписи файлов включена

  ;Папка для инсталляции по умолчанию
  InstallDir "$PROGRAMFILES\Rovalant\ReadKeyID"

;запоминаем ини-файл по-умолчании  
ReserveFile "ReadKeyID.ini"
ReserveFile "ReadKeyID_install.ini"
ReserveFile "${NSISDIR}\Plugins\InstallOptions.dll"
;--------------------------------
;Variables

  Var MUI_TEMP                                			 ; - две переменные для хранения пути для ярлыков в меню Пуск
  Var STARTMENU_FOLDER
  Var FL_OLDVER
  Var OLDDIR

!define TEMP1 $R0 					; временная переменная -  регистр R0

;--------------------------------
;Настройки интерфейса

;   !define MUI_ABORTWARNING                    		; - выдаем предупреждение при нажатии на кнопку отмена
   !define MUI_ICON "C:\Source\ReadID\Img\big.ico"              			; - иконка файла - инсталлятора
   !define MUI_UNICON "C:\Source\ReadID\Img\bigun.ico"           			; - иконка файла - деинсталлятора
;--------------------------------
;Pages

  !insertmacro MUI_PAGE_COMPONENTS            		; - страница с выбором компонентов для установки
  !insertmacro MUI_PAGE_DIRECTORY              		; - страница с выбором папки для установки
  Page custom SetupPageEnter ValidateCustom				; - страница с выбором
 
  Page instfiles UninstPrevVer
  !insertmacro MUI_UNPAGE_CONFIRM              		; - страница с подтверждением удаления (деинсталлятор)
  !insertmacro MUI_UNPAGE_INSTFILES            		; - страница с подробностями удаления (деинсталлятор)
;--------------------------------
;Языки
 
  !insertmacro MUI_LANGUAGE "Russian"      		; - задаем язык как "русский"


;--------------------------------
;Секции компонентов для установки

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Section "!Программа" Program     			; секция "Программа". Знак "!" означает, что пункт жирным текстом

  SectionIn RO     					; секция только для чтения (не отключить)

  SetOutPath "$INSTDIR"              			; папка для выполнения операций
  File "ReadKeyID.exe"    		; сохраняем нужные файлы
  File "232.dll"
  File "485.dll"
  File "TimerMan.dll"
;  File "ReadKeyID.pdf"  

;Создаем uninstall'ятор и записываем его в папку, куда устанавливаем программу
  WriteUninstaller "$INSTDIR\Uninstall.exe"

;нужна ли автозагрузка?
ReadINIStr $1 "$PLUGINSDIR\ReadKeyID.ini" "Mode" "AutoExec"
StrCmp $1 0 noAuto
MessageBox MB_OK  "Внимание!!!$\nПрограмма будет автоматически запускаться при загрузке Windows!"
WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Run" "ReadKeyID" "$INSTDIR\ReadKeyID.exe"
noAuto:

;Создание ярлыков
StrCpy $STARTMENU_FOLDER "РОВАЛЭНТ\Считыватель ID пропусков"
    CreateDirectory "$SMPROGRAMS\$STARTMENU_FOLDER"
    CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Считыватель ID пропусков.lnk" "$INSTDIR\ReadKeyID.exe"
;    CreateShortCut "$SMPROGRAMS\РОВАЛЭНТ\$STARTMENU_FOLDER\Руководство пользователя.lnk" "$INSTDIR\ReadKeyID.pdf"
    CreateShortCut "$SMPROGRAMS\$STARTMENU_FOLDER\Удалить.lnk" "$INSTDIR\Uninstall.exe"

;записываем в реестр для работы штатного uninstaller-а
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "DisplayName" "Считыватель ID пропусков"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "UninstallString" "$INSTDIR\Uninstall.exe"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "InstallLocation" "$INSTDIR"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "DisplayIcon" "$INSTDIR\ReadKeyID.exe"
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "Publisher" "ROVALANT"
WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "NoModify" 0x00000001
WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "NoRepair" 0x00000001
WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID" "URLInfoAbout" "http://www.rovalant.com"

  ;вернуть ини-файл
  IfFileExists  $PLUGINSDIR\ReadKeyID.ini 0 secend 		                 
  CopyFiles  $PLUGINSDIR\ReadKeyID.ini $INSTDIR\ReadKeyID.ini
secend:
SectionEnd       

 Section /o "Драйвер AIU-USB" AIUUSB 	
  SetOutPath "$INSTDIR\Driver AIU-USB"                    		                 
  File "c:\Source\Cfg777Plus\ver\distrCfg777\Driver AIU-USB\*.*"  
 SectionEnd                           

;--------------------------------
;Descriptions

; в этой секции написаны макросы, которые позволяют при наведении на компонент для установки показывать его
; описание

  LangString DESC_Program ${LANG_RUSSIAN} "Файл программы и модули для работы «Считывателя ID пропусков»."
  LangString DESC_AIUUSB ${LANG_RUSSIAN} "Драйвер АИУ (USB) для обеспечения работы «Считывателя ID пропусков» через СОМ-порт."

   !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN

    !insertmacro MUI_DESCRIPTION_TEXT ${Program} $(DESC_Program)
    !insertmacro MUI_DESCRIPTION_TEXT ${AIUUSB} $(DESC_AIUUSB)

  !insertmacro MUI_FUNCTION_DESCRIPTION_END
 
;--------------------------------
;Installer Functions

LangString TEXT_IO_TITLE1 ${LANG_ENGLISH} "Копирование файлов"
LangString TEXT_IO_SUBTITLE1 ${LANG_ENGLISH} "Подождите, идет копирование файлов установочного комплекта программы..."

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Function .onInit
;взять предыдущую папку установки, если была
Call GetProgramInstPath
  InitPluginsDir
;перед удалением сохранить ини-файл если есть
  IfFileExists  $INSTDIR\ReadKeyID.ini 0 noinif 		                 
  CopyFiles $INSTDIR\ReadKeyID.ini $PLUGINSDIR\ReadKeyID.ini
  goto noinif1

noinif:
;если нет скопировать по умолчании из инсталлятора
;перезапись ини-файла в папку ТЕМР с дальнейшим автоматическим уничтожением
  File /oname=$PLUGINSDIR\ReadKeyID.ini "ReadKeyID.ini"
noinif1:
  File /oname=$PLUGINSDIR\ReadKeyID_install.ini "ReadKeyID_install.ini"

;сделать изменения в ReadKeyID_install.ini по ReadKeyID.ini

;СОМ-порт
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID.ini" "Net" "COM"
  StrCpy $1 "COM$1"
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 3" "State" $1

;Автозагрузка программы при запуске Windows
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID.ini" "Mode" "AutoExec"
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 4" "State" $1

;"Старт" чтения пропуска при запуске программы
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID.ini" "Mode" "StartMode"
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 5" "State" $1

;Проигрывать звук при считывании пропуска
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID.ini" "Mode" "Sound"
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 6" "State" $1

;Время "жизни" в буфере ID пропуска
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID.ini" "Time" "TOLife"
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 8" "State" $1

;Тип пропуска
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID.ini" "Mode" "TypeKey"
  StrCmp $1 0 tp1
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 10" "State" 0
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 11" "State" 1
goto tp2
tp1:
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 10" "State" 1
  WriteINIStr "$PLUGINSDIR\ReadKeyID_install.ini" "Field 11" "State" 0
tp2:

;перед инсталляцией выгрузить запущенную программу
  IfFileExists  $INSTDIR\ReadKeyID.exe 0 onInitexit 		                 
   StrCpy $2 "$INSTDIR\ReadKeyID.exe"
   Exec '"$2" -d'
   Delete $2

onInitexit:
FunctionEnd

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
LangString TEXT_IO_TITLE ${LANG_ENGLISH} "Настройка параметров работы программы"
LangString TEXT_IO_SUBTITLE ${LANG_ENGLISH} "Установленные параметры будут записаны в настроечный файл программы"

;функция инициализации окна с предварительными установками из ини-файла
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
;сделать изменения в ReadKeyID.ini по ReadKeyID_install.ini только при выходе из страницы
  ReadINIStr $0 "$PLUGINSDIR\ReadKeyID_install.ini" "Settings" "State"
  StrCmp $0 0 validate  ; Next button?
  Abort
validate:

;СОМ-порт
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID_install.ini" "Field 3" "State"
  StrCpy $1 $1 "" 3 #
  WriteINIStr "$PLUGINSDIR\ReadKeyID.ini" "Net" "COM" $1

;Автозагрузка программы при запуске Windows
   ReadINIStr $1 "$PLUGINSDIR\ReadKeyID_install.ini" "Field 4" "State"
  WriteINIStr "$PLUGINSDIR\ReadKeyID.ini" "Mode" "AutoExec" $1

;"Старт" чтения пропуска при запуске программы
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID_install.ini" "Field 5" "State"
  WriteINIStr "$PLUGINSDIR\ReadKeyID.ini" "Mode" "StartMode" $1

;Проигрывать звук при считывании пропуска
 ReadINIStr $1  "$PLUGINSDIR\ReadKeyID_install.ini" "Field 6" "State"
 WriteINIStr  "$PLUGINSDIR\ReadKeyID.ini" "Mode" "Sound" $1

;Время "жизни" в буфере ID пропуска
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID_install.ini" "Field 8" "State"
  WriteINIStr "$PLUGINSDIR\ReadKeyID.ini" "Time" "TOLife" $1

;Тип пропуска
  ReadINIStr $1 "$PLUGINSDIR\ReadKeyID_install.ini" "Field 10" "State"
  StrCmp $1 0 tp11
  WriteINIStr "$PLUGINSDIR\ReadKeyID.ini" "Mode" "TypeKey" 0
goto tp21
tp11:
  WriteINIStr "$PLUGINSDIR\ReadKeyID.ini" "Mode" "TypeKey" 1
tp21:
FunctionEnd


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;взять путь предыдущей инсталляции, если была
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
;нужна ли загрузка программы?
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
  ;удалить старую версию
  ;MessageBox MB_YESNO|MB_ICONQUESTION "Внимание!!!$\nПредыдущая установка программы будет удалена.$\n> Продолжить?" IDYES newinst1
  ;Abort
;newinst1:
  ;удаление старой версии $INSTDIR
  StrCmp $FL_OLDVER 0 secprg1			    	;если не было старой версии - продолжить, иначе - удалить
  
   StrCpy $2 "$OLDDIR\Uninstall.exe"
   ExecWait '"$2" /S'
   Delete $2
;MessageBox MB_OK $INSTDIR

; немного подождать
            Banner::show /set 76 "Удаление предыдущей версии..." ""
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


Section "Uninstall"  ; данная секция необходима для описания деинсталлятора

StrCpy $MUI_TEMP "РОВАЛЭНТ\Считыватель ID пропусков"
;  !insertmacro MUI_STARTMENU_GETFOLDER Application $MUI_TEMP    		; выдираем из реестра путь к значкам
  Delete "$SMPROGRAMS\$MUI_TEMP\Считыватель ID пропусков.lnk"       	; и удаляем их
;  Delete "$SMPROGRAMS\$MUI_TEMP\Руководство пользователя.lnk"       	
  Delete "$SMPROGRAMS\$MUI_TEMP\Удалить.lnk"
 
  ;Удаляем ненужные пункты меню Пуск
  StrCpy $MUI_TEMP "$SMPROGRAMS\$MUI_TEMP"
 
  startMenuDeleteLoop:
    RMDir $MUI_TEMP
    GetFullPathName $MUI_TEMP "$MUI_TEMP\.."
    
    IfErrors startMenuDeleteLoopDone
  
    StrCmp $MUI_TEMP $SMPROGRAMS startMenuDeleteLoopDone startMenuDeleteLoop
  startMenuDeleteLoopDone:

  RMDir "$SMPROGRAMS\$MUI_TEMP"        	; удаляем ненужные папки

  ;удаляем все...
  Delete "$INSTDIR\Driver AIU-USB\*.*"
  Delete "$INSTDIR\*.*"
  RMDir "$INSTDIR\Driver AIU-USB"
  RMDir "$INSTDIR" 

;найти и попытаться удалить папку РОВАЛЭНТ
  ${WordFind} "$INSTDIR" "\" "-2{*" $INSTDIR
  RMDir "$INSTDIR" 
 ;MessageBox MB_OK  $R0


  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\ReadKeyID"
  DeleteRegValue  HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Run"  "ReadKeyID"
SectionEnd

Function un.onInit
;перед инсталляцией выгрузить запущенную программу
  IfFileExists  $INSTDIR\ReadKeyID.exe 0 onunitexit 		                 
   StrCpy $2 "$INSTDIR\ReadKeyID.exe"
   Exec '"$2" -d'
   Delete $2

onunitexit:
FunctionEnd
