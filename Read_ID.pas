unit Read_ID;

interface

uses
  Windows, Messages, Controls, Classes, Forms, MMSystem, Menus,
  StdCtrls, ExtCtrls, IniFiles, TMImport, Graphics, Inter485, KeyID,
  ClipBrd, Buttons, ShellAPI, ImgList, SysUtils, Registry;

const
  INI_FILE_NAME = 'ReadKeyID.ini';
  WM_ASYNCNOTIFY = WM_USER+101;
  WM_ICOMESSAGE  = WM_USER+102;
  WM_HIDE        = WM_USER+103;
  WM_TWOEXEC     = WM_USER+104;
  CtReadID = 100;
  CtAuto = 2700;
  CtFile = 5400;

type
  TAppMode = (
               amDebug, amNoCard, amCard
              );

type
  TfrmAgentMA = class(TForm)
    p_global: TPanel;
    p_stat: TPanel;
    p_left: TPanel;
    p_right: TPanel;
    p_center: TPanel;
    p_2: TPanel;
    p_4: TPanel;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    tKey0: TMenuItem;
    tKey1: TMenuItem;
    tSound: TMenuItem;
    iPrio: TMenuItem;
    tPrio0: TMenuItem;
    tPrio1: TMenuItem;
    tPrio2: TMenuItem;
    tPrio3: TMenuItem;
    Panel1: TPanel;
    btnStart: TButton;
    Bevel1: TBevel;
    iCom: TMenuItem;
    COM11: TMenuItem;
    COM21: TMenuItem;
    COM31: TMenuItem;
    COM41: TMenuItem;
    COM51: TMenuItem;
    COM61: TMenuItem;
    COM71: TMenuItem;
    COM81: TMenuItem;
    COM91: TMenuItem;
    N4: TMenuItem;
    N6: TMenuItem;
    TrayIcon1: TTrayIcon;
    ppm_IconMenu: TPopupMenu;
    im_Exit: TMenuItem;
    N7: TMenuItem;
    N8: TMenuItem;
    N9: TMenuItem;
    N10: TMenuItem;
    ipCom: TMenuItem;
    ipPrio: TMenuItem;
    tpSound: TMenuItem;
    tpKey0: TMenuItem;
    tpKey1: TMenuItem;
    COM12: TMenuItem;
    COM22: TMenuItem;
    COM32: TMenuItem;
    COM42: TMenuItem;
    COM52: TMenuItem;
    COM62: TMenuItem;
    COM72: TMenuItem;
    COM82: TMenuItem;
    COM92: TMenuItem;
    Realtime1: TMenuItem;
    High1: TMenuItem;
    Normal1: TMenuItem;
    Low1: TMenuItem;
    N15: TMenuItem;
    iStart: TMenuItem;
    iStop: TMenuItem;
    iOpen: TMenuItem;
    IconList: TImageList;
    OneIcon: TImageList;
    iAuto: TMenuItem;
    tpAuto: TMenuItem;
    procedure WMEndSession(var Msg: TWMEndSession);  message WM_ENDSESSION;
    procedure WMQueryEndSession(var Msg: TWMQueryEndSession);  message WM_QUERYENDSESSION;
    procedure WMCommandArrived(var Msg: TMessage);  message WM_TWOEXEC;
    function  ReadStringFromMailslot: string;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure rg_PrioritetClick(Sender: TObject);
    procedure tKey0Click(Sender: TObject);
    procedure tKey1Click(Sender: TObject);
    procedure tPrio0Click(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure COM11Click(Sender: TObject);
    procedure WMAsyncNotify(var MSg : TMessage); message WM_ASYNCNOTIFY;
    procedure WMHide(var MSg : TMessage); message WM_HIDE;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure im_ExitClick(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormMinimize(Sender: TObject);
    procedure tSoundClick(Sender: TObject);
    procedure iAutoClick(Sender: TObject);
  private
    timerLife, timerAuto, timerRead : THandle;
    procedure TimerNotifyEvent(Sender : TObject; Msg,UserParam : dword);
    procedure ShowTimer(Num: integer);
    procedure SendID;
  protected
  public
    { Public declarations }
  end;

var
  frmAgentMA: TfrmAgentMA;
  ServerMailslotHandle: THandle;

implementation

uses
  EventWaitThread;

{$R *.dfm}
var

  CurrentDir: array[0..255] of Char;
  FullIniFileName: string;

{ Initial values from ".ini" }
  numCOM, mWork, mKey, mSound, mAuto,
  mStart, mSave, mPrioritet: Integer;
  tReadID, tAuto, tLife: integer;
  SoundFile: string;
  AppMode: TAppMode;

  KeyID: TKeyID;
  flWait:boolean;
  flExit: boolean;
  flHide: boolean;
  mysound: pointer;


procedure TfrmAgentMA.btnStartClick(Sender: TObject);
var
  IniFile: TIniFile;
begin
IniFile := TIniFile.Create(FullIniFileName);
if mStart=1 then begin
  mStart:=0;
  btnStart.Caption:= 'Старт';
  p_stat.Caption:= 'работа приостановлена...';
  tmStopTimer(timerAuto);
  tmStopTimer(timerRead);
  //подключить иконку - "не работает"
  TrayIcon1.Animate:=false;
  TrayIcon1.Icons:=OneIcon;
  TrayIcon1.IconIndex:=0;
  iStart.Checked:= false;
  iStop.Checked:= true;
end else begin
  mStart:=1;
  btnStart.Caption:= 'Стоп';
  p_stat.Caption:= '...';
  tmSetTimerInterval(timerAuto, tAuto);
  tmStartTimer(timerAuto);
  tmSetTimerInterval(timerRead, tReadID);
  tmStartTimer(timerRead);
  flWait:=false;
  //подключить список иконок
  TrayIcon1.Animate:=false;
  TrayIcon1.Icons:=IconList;
  TrayIcon1.IconIndex:=0;
   iStart.Checked:= true;
  iStop.Checked:= false;
end;
IniFile.WriteInteger('Mode','StartMode',mStart);
IniFile.Free;
TrayIcon1.Refresh;
if not flHide then p_Stat.SetFocus;
end;

procedure TfrmAgentMA.COM11Click(Sender: TObject);
var
  IniFile: TIniFile;
  i:integer;
  ErrorCode: integer;
begin
numCOM:= (Sender as TMenuItem).MenuIndex+1;
IniFile := TIniFile.Create(FullIniFileName);
IniFile.WriteInteger('Net','COM', numCOM);
IniFile.Free;
for i:=0 to 8 do iCom.Items[i].Checked:= false;
iCom.Items[(Sender as TMenuItem).MenuIndex].Checked:= true;
for i:=0 to 8 do ipCom.Items[i].Checked:= false;
ipCom.Items[(Sender as TMenuItem).MenuIndex].Checked:= true;

if mWork=0 then begin
try
  mStart:=1; btnStartClick(self);
  FreeCard(numCOM);
  ErrorCode := CreateCard(numCOM,1,0,57600,300);
  if ErrorCode<>0 then begin
    p_stat.Font.Color:= clMaroon;
    AppMode:= amNoCard;
    mStart:=1; btnStartClick(self);
    btnStart.Enabled:=false;
    p_stat.Caption:= 'Ошибка! АИУ не подключен';
  end else begin
    p_stat.Font.Color:= clNavy;
    p_stat.Caption:= 'АИУ подключен';
    AppMode:= amCard;
    btnStart.Enabled:=true;
  end;
except
    p_stat.Font.Color:= clMaroon;
    AppMode:= amNoCard;
    mStart:=1; btnStartClick(self);
    btnStart.Enabled:=false;
    p_stat.Caption:= 'Ошибка! АИУ не подключен';
end;
end else begin
    p_stat.Font.Color:= clBlack;
    p_stat.Caption:= 'Режим автогенерации ID';
    AppMode:= amDebug;
    btnStart.Enabled:=true;
end;
if not flHide then p_Stat.SetFocus;
end;


procedure TfrmAgentMA.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  KeyID.Free;
  ClipBoard.Clear;
end;

procedure TfrmAgentMA.FormCreate(Sender: TObject);
var
  iStr: String;
  i, ErrorCode: integer;
  IniFile: TIniFile;
  Reg: TRegistry;
begin
Application.OnMinimize := FormMinimize;

  // установить CurrentDir
  iStr:= ParamStr(0);
  for i:= length(iStr) downto 1 do
      if (iStr[i]='\') or (i=1) then break;
  Delete(iStr,i+1,length(iStr)-i);
  iStr:= LowerCase(iStr);
  StrPCopy(CurrentDir,iStr);
  FullIniFileName:= StrPas(CurrentDir);
  Insert(INI_FILE_NAME,FullIniFileName,length(FullIniFileName)+length(INI_FILE_NAME));

IniFile := TIniFile.Create(FullIniFileName);

//определение СОМ-порта
numCOM := IniFile.ReadInteger('Net','COM',-1);
//если ком не определен - установить 1
if numCOM=-1 then begin
   numCOM:=1;
   IniFile.WriteInteger('Net','COM',1);
end;
for i:=0 to 8 do iCom.Items[i].Checked:= false;
iCom.Items[numCOM-1].Checked:= true;
for i:=0 to 8 do ipCom.Items[i].Checked:= false;
ipCom.Items[numCOM-1].Checked:= true;

//определение режима работы
mWork := IniFile.ReadInteger('Mode','WorkMode',-1);
//если WorkMode не определен - установить основной
if mWork=-1 then begin
   mWork:=0;
   IniFile.WriteInteger('Mode','WorkMode',mWork);
end;

//определение стартового режима
mStart := IniFile.ReadInteger('Mode','StartMode',-1);
//если WorkMode не определен - установить выключено
if mStart=-1 then begin
   mStart:=0;
   IniFile.WriteInteger('Mode','StartMode',mStart);
end;

//определение типа считывателя
mKey := IniFile.ReadInteger('Mode','TypeKey',-1);
//если TypeKey не определен - установить 0 - Touch Memory
if mKey=-1 then begin
   mKey:=0;
   IniFile.WriteInteger('Mode','TypeKey',mKey);
end;
if mKey=0 then begin
          tKey0.Checked:= true;
          tKey1.Checked:= false;
          tpKey0.Checked:= true;
          tpKey1.Checked:= false;
          end else begin
          tKey0.Checked:= false;
          tKey1.Checked:= true;
          tpKey0.Checked:= false;
          tpKey1.Checked:= true;
          end;

//определение наличие звука
mSound := IniFile.ReadInteger('Mode','Sound',-1);
//если Sound не выводитсс - установить 0
if mSound=-1 then begin
   mSound:=0;
   IniFile.WriteInteger('Mode','Sound',mSound);
end;
if mSound=0 then begin
            tSound.Checked:= false;
            tpSound.Checked:= false;
            end else begin
            tSound.Checked:= true;
            tpSound.Checked:= true;
            end;

//определение наличия автозагрузки
mAuto := IniFile.ReadInteger('Mode','AutoExec',-1);
//если AutoExec не выводится - установить 1 - да
if mAuto=-1 then begin
   mAuto:=1;
   IniFile.WriteInteger('Mode','AutoExec',mAuto);
end;
//проверяем регистр на автозагрузку
Reg:= TRegistry.Create;
Reg.RootKey:= HKEY_LOCAL_MACHINE;
Reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run',false);
if Reg.ValueExists('ReadKeyID') then begin
   if mAuto=0 then begin
      mAuto:=1;
      IniFile.WriteInteger('Mode','AutoExec',mAuto);
   end;
end else begin
   if mAuto=1 then begin
      mAuto:=0;
      IniFile.WriteInteger('Mode','AutoExec',mAuto);
   end;
end;
Reg.Free;

if mAuto=0 then begin
            iAuto.Checked:= false;
            tpAuto.Checked:= false;
            end else begin
            iAuto.Checked:= true;
            tpAuto.Checked:= true;
            end;

//определение режима сохранения ИД
mSave := IniFile.ReadInteger('Mode','SaveMode',-1);
//если SaveMode не определен - установить 0 - сохранение в файл
if mSave=-1 then begin
   mSave:=1;
   IniFile.WriteInteger('Mode','SaveMode',mSave);
end;
//if mSave=0 then begin
//          tSave0.Checked:= true;
//          tSave1.Checked:= false;
//          end else begin
//          tSave0.Checked:= false;
//          tSave1.Checked:= true;
//          end;

//определение файла сохранения ИД
SoundFile := IniFile.ReadString('Mode','SoundFile','');
//по умолчании сохранять здесь же
if SoundFile='' then begin
   IniFile.WriteString('Mode','SoundFile',SoundFile);
end;

//определение приоритета программы
mPrioritet := IniFile.ReadInteger('Mode','Prioritet',-1);
//по умолчании сохранять здесь же
if mPrioritet=-1 then begin
   mPrioritet:=2;
   IniFile.WriteInteger('Mode','Prioritet',mPrioritet);
end;
for i:=0 to 3 do iPrio.Items[i].Checked:= false;
iPrio.Items[mPrioritet].Checked:= true;
for i:=0 to 3 do ipPrio.Items[i].Checked:= false;
ipPrio.Items[mPrioritet].Checked:= true;

//определение периодичности чтения ключа
tReadID := IniFile.ReadInteger('Time','ReadID',-1);
//по умолчании 100mc
if tReadID=-1 then begin
   tReadID:=CtReadID;
   IniFile.WriteInteger('Time','ReadID',tReadID);
end;

//определение периодичности генерации ключа в авторежиме
tAuto := IniFile.ReadInteger('Time','TOAuto',-1);
//по умолчании 2c
if tAuto=-1 then begin
   tAuto:=CtAuto;
   IniFile.WriteInteger('Time','TOAuto',CtAuto);
end;

//определение времени жизни файла
tLife := IniFile.ReadInteger('Time','TOLife',-1);
//по умолчании 5c
if tLife=-1 then begin
   tLife:=CtFile;
   IniFile.WriteInteger('Time','TOLife',CtFile);
end;

IniFile.Free;

if mWork=0 then begin
  FreeCard(numCOM);
  ErrorCode := CreateCard(numCOM,1,0,57600,300);
  if ErrorCode<>0 then begin
    p_stat.Font.Color:= clMaroon;
    AppMode:= amNoCard;
    mStart:=1; btnStartClick(self);
    btnStart.Enabled:=false;
    p_stat.Caption:= 'Ошибка! АИУ не подключен';
  end else begin
    p_stat.Font.Color:= clNavy;
    p_stat.Caption:= 'АИУ подключен';
    AppMode:= amCard;
  end;
end else begin
    p_stat.Font.Color:= clBlack;
    p_stat.Caption:= 'Режим автогенерации ID';
    AppMode:= amDebug;
end;
//запустить таймер 1 - период удержания файла с ИД ключа 5 сек
  timerLife := tmCreateIntervalTimer(TimerNotifyEvent, tLife, tmStartStop,
      false, dword(pchar('')), 1);
//запустить таймер 2 - период разрешения чтения таймера в режиме генерации
  timerAuto := tmCreateIntervalTimer(TimerNotifyEvent, tAuto, tmPeriod,
      false, dword(pchar('')), 2);
//запустить таймер 3 - период чтения ИД ключа 100 мс
  timerRead := tmCreateIntervalTimer(TimerNotifyEvent, tReadID, tmPeriod,
      false, dword(pchar('')), 3);
  KeyID := TKeyID.Create;

//запуск периода обращения за ключом
  if mStart = 1 then begin
  tmSetTimerInterval(timerAuto, tAuto);
  tmStartTimer(timerAuto);
  tmSetTimerInterval(timerRead, tReadID);
  tmStartTimer(timerRead);
  iStart.Checked:= true;
  iStop.Checked:= false;
  end else begin
  iStart.Checked:= false;
  iStop.Checked:= true;
  end;
  
  flWait:=false;
  flExit:= false;
  PostMessage(Handle, WM_HIDE, 0, 0);
//  IconList.GetIcon(0,Application.Icon);
  flHide:= true;
  // Создаём нить для ожидания получения сообщения
  TEventWaitThread.Create(False);
end;

procedure TfrmAgentMA.FormShow(Sender: TObject);
begin
  if mStart = 1 then begin
  btnStart.Caption:= 'Стоп';
  p_stat.Caption:= '...';
  //подключить список иконок
  TrayIcon1.Icons:=IconList;
  TrayIcon1.IconIndex:=0;
  end else begin
  //таймеры не запускаются
  btnStart.Caption:= 'Старт';
  p_stat.Caption:= 'работа приостановлена...';
  //подключить иконку - "не работает"
  TrayIcon1.Icons:=OneIcon;
  TrayIcon1.IconIndex:=0;
  end;
  TrayIcon1.Refresh;
if not flHide then p_Stat.SetFocus;
end;

procedure TfrmAgentMA.iAutoClick(Sender: TObject);
var
  IniFile: TIniFile;
  Reg: TRegistry;
begin
Reg:= TRegistry.Create;
Reg.RootKey:= HKEY_LOCAL_MACHINE; //HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Run
Reg.OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Run',true);
if mAuto=0 then begin
            mAuto:= 1;
            iAuto.Checked:= true;
            tpAuto.Checked:= true;
            Reg.WriteString('ReadKeyID', ParamStr(0));
            end else begin
            mAuto:= 0;
            iAuto.Checked:= false;
            tpAuto.Checked:= false;
            Reg.DeleteValue('ReadKeyID');
            end;
Reg.Free;
IniFile := TIniFile.Create(FullIniFileName);
IniFile.WriteInteger('Mode','AutoExec',mAuto);
IniFile.Free;
end;

procedure TfrmAgentMA.im_ExitClick(Sender: TObject);
begin
flExit:= true;
Close;
end;

// Чтение очередного сообщения из почтового ящика
function TfrmAgentMA.ReadStringFromMailslot: string;
var
  MessageSize: DWORD;
begin
  // Получаем размер следующего сообщения в почтовом ящике
  GetMailslotInfo(ServerMailslotHandle, nil, MessageSize, nil, nil);
  // Если сообщения нет, возвращаем пустую строку
  if MessageSize = MAILSLOT_NO_MESSAGE then begin
    Result := '';
    Exit;
  end;
  // Выделяем для сообщения буфер и читаем его в этот буфер
  SetLength(Result, MessageSize);
  ReadFile(ServerMailslotHandle, Result[1], MessageSize, MessageSize, nil);
end;

procedure TfrmAgentMA.rg_PrioritetClick(Sender: TObject);
var hProcess : THandle;
  IniFile: TIniFile;
begin
IniFile := TIniFile.Create(FullIniFileName);
IniFile.WriteInteger('Mode','Prioritet',(Sender as TRadioGroup).ItemIndex);
IniFile.Free;
  hProcess := GetCurrentProcess;
  case (Sender as TRadioGroup).ItemIndex of
    0 : SetPriorityClass(hProcess, REALTIME_PRIORITY_CLASS);
    1 : SetPriorityClass(hProcess, HIGH_PRIORITY_CLASS);
    2 : SetPriorityClass(hProcess, NORMAL_PRIORITY_CLASS);
    3 : SetPriorityClass(hProcess, IDLE_PRIORITY_CLASS);
  end;
end;


procedure TfrmAgentMA.TimerNotifyEvent(Sender : TObject; Msg,UserParam : dword);
begin
  PostMessage(Handle, WM_ASYNCNOTIFY, UserParam, 0);
end;

procedure TfrmAgentMA.tKey0Click(Sender: TObject);
var
  IniFile: TIniFile;
begin
          tKey0.Checked:= true;
          tKey1.Checked:= false;
          tpKey0.Checked:= true;
          tpKey1.Checked:= false;
          mKey:= 0;
IniFile := TIniFile.Create(FullIniFileName);
IniFile.WriteInteger('Mode','TypeKey',mKey);
IniFile.Free;
end;

procedure TfrmAgentMA.tKey1Click(Sender: TObject);
var
  IniFile: TIniFile;
begin
          tKey0.Checked:= false;
          tKey1.Checked:= true;
          tpKey0.Checked:= false;
          tpKey1.Checked:= true;
          mKey:= 1;
IniFile := TIniFile.Create(FullIniFileName);
IniFile.WriteInteger('Mode','TypeKey',mKey);
IniFile.Free;
end;

procedure TfrmAgentMA.tPrio0Click(Sender: TObject);
var hProcess : THandle;
  IniFile: TIniFile;
  i:integer;
begin
IniFile := TIniFile.Create(FullIniFileName);
IniFile.WriteInteger('Mode','Prioritet',(Sender as TMenuItem).MenuIndex);
IniFile.Free;
  hProcess := GetCurrentProcess;
  case (Sender as TMenuItem).MenuIndex of
    0 : SetPriorityClass(hProcess, REALTIME_PRIORITY_CLASS);
    1 : SetPriorityClass(hProcess, HIGH_PRIORITY_CLASS);
    2 : SetPriorityClass(hProcess, NORMAL_PRIORITY_CLASS);
    3 : SetPriorityClass(hProcess, IDLE_PRIORITY_CLASS);
  end;
for i:=0 to 3 do iPrio.Items[i].Checked:= false;
iPrio.Items[(Sender as TMenuItem).MenuIndex].Checked:= true;
for i:=0 to 3 do ipPrio.Items[i].Checked:= false;
ipPrio.Items[(Sender as TMenuItem).MenuIndex].Checked:= true;
end;


procedure TfrmAgentMA.tSoundClick(Sender: TObject);
var
  IniFile: TIniFile;
begin
if mSound=0 then begin
            mSound:= 1;
            tSound.Checked:= true;
            tpSound.Checked:= true;
            end else begin
            mSound:= 0;
            tSound.Checked:= false;
            tpSound.Checked:= false;
            end;
IniFile := TIniFile.Create(FullIniFileName);
IniFile.WriteInteger('Mode','Sound',mSound);
IniFile.Free;
end;

procedure TfrmAgentMA.WMAsyncNotify(var Msg : TMessage);
begin
  ShowTimer(MSg.WParam);
end;

procedure TfrmAgentMA.WMCommandArrived(var Msg: TMessage);
var
  Letter: string;
begin
// Пока есть команды, читаем их и выполняем
  Letter := ReadStringFromMailslot;
  while Letter <> '' do begin
    // Анализируем и выполняем команду.
    // Команда "s" не требует никаких действий
    // на передний план, поэтому здесь мы её не учитываем
    case Letter[1] of
      'd': begin
           flExit:=true;
           Close;
      end;
    end;
    Letter := ReadStringFromMailslot;
  end;
end;

procedure TfrmAgentMA.WMHide(var MSg: TMessage);
begin
  Hide;
end;

procedure TfrmAgentMA.WMQueryEndSession(var Msg: TWMQueryEndSession);
begin
flExit:=true;
Close;
Msg.Result:=1;
end;

procedure TfrmAgentMA.WMEndSession(var Msg: TWMEndSession);
begin
flExit:=true;
Close;
Msg.Result:=1;
end;

procedure TfrmAgentMA.ShowTimer(Num: integer);
var
   codErr:integer;
begin
Case num of
     //обработка по 1 таймеру - удалить данные
     1:begin
       ClipBoard.Open;
       ClipBoard.Clear;
       ClipBoard.Close;
       flWait:= false;
       TrayIcon1.Animate:= false;
       TrayIcon1.IconIndex:=0;
       TrayIcon1.Refresh;
       p_stat.Caption:='...';
     end;
     //обработка по 2 таймеру - работа в режиме отладки
     2:begin
          if (mWork<>0) then
          if (p_stat.Caption='')or(p_stat.Caption='...') then begin
             if mWork<>0 then begin
             KeyID.InitRandom;
             SendID;
             end;
          end else begin
              p_stat.Caption:='...';
              TrayIcon1.Animate:= false;
              TrayIcon1.IconIndex:=0;
              TrayIcon1.Refresh;
          end;
     end;
     //обработка по 3 таймеру - чтение ключа
     3:begin
       if (mWork=0)and(not flWait)and(mStart=1) then begin
         try
         codErr:= ReadID(numCOM, KeyID.Ptr);
         if codErr = 0 then SendID else begin
         p_stat.Font.Color:= clMaroon;
           if codErr<>1 then begin
           FreeCard(numCOM);
           AppMode:= amNoCard;
           mStart:=1; btnStartClick(self);
           btnStart.Enabled:=false;
           p_stat.Caption:= 'Ошибка! АИУ не подключен';
           end;
         p_stat.Font.Color:= clNavy;
         end;
         except
         FreeCard(numCOM);
         p_stat.Font.Color:= clMaroon;
         AppMode:= amNoCard;
         mStart:=1; btnStartClick(self);
         btnStart.Enabled:=false;
         p_stat.Caption:= 'Ошибка! АИУ не подключен';
         end;
       end;
     end;
End;
end;

procedure TfrmAgentMA.SendID;
begin
if mKey<>0 then KeyID.noCodVer;
//запись в тестовое окно статуса программы
p_stat.Caption:= KeyID.Str;
TrayIcon1.Animate:= true;

//вывод звука
if mSound=1 then
 if SoundFile='' then begin
      sndPlaySound(mysound,SND_MEMORY or SND_ASYNC);
 end else begin
   if FileExists(SoundFile) then
      PlaySound(PChar(SoundFile),0,SND_ASYNC) else
      sndPlaySound(mysound,SND_MEMORY or SND_ASYNC);
 end;

//вывод ИД
   ClipBoard.Open;
   ClipBoard.Clear;
   ClipBoard.AsText:= p_stat.Caption;
   ClipBoard.Close;
   //запуск таймера жизни данных
   if not flWait then  begin
      tmSetTimerInterval(timerLife, tLife);
      tmStartTimer(timerLife);
      flWait:= true;
   end else begin
      tmResetTimer(timerLife);
   end;
end;

procedure TfrmAgentMA.TrayIcon1DblClick(Sender: TObject);
begin
  WindowState:= wsNormal;
  Show;
  Application.Restore;
  Application.BringToFront;
  flHide:= false;
p_Stat.SetFocus;
end;

procedure TfrmAgentMA.FormMinimize(Sender: TObject);
begin
Close;
end;

procedure TfrmAgentMA.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
if not flExit then begin
   CanClose:=false;
   flHide:= true;
   Hide;
end else begin
   TrayIcon1.Visible:= false;
   CanClose:=true;
end;
end;

initialization
  mysound:= LockResource(LoadResource(hInstance,
  (FindResource(hInstance, 'mysound', 'WAVE'))));
end.
