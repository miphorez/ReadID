unit TmImport;

interface

uses Windows;

const TimerMan = 'TimerMan.dll';

  tmPeriod    = $00;    // Autorestart timer
  tmStartStop = $01;    // Start-Stop timer (disable after first tick)
  tmSureSync  = $02;    // Synchronized periodical timer

  tnEvent       = 0;    // Use kernel object Event (SetEvent)
  tnThreadMsg   = 1;    // Use message to thread ID (PostThreadMessage)
  tnWinMsg      = 2;    // Use message to window HWND (PostMessage)
  tnCallBack    = 3;    // Asynchronous call user function TNotifierProc
  tnCallEvent   = 4;    // Asynchronous call object event handler TNotifierEvent

type TNotifierProc = procedure(Owner: THandle; Msg,UserParam : dword);
     TNotifierEvent = procedure(Sender : TObject; Msg,UserParam : dword) of object;

(*** Creating interval timer with object event handler ***)
function tmCreateIntervalTimer(
        hEventProc: TNotifierEvent;  // Client event handler
        Interval  : dword;    // Time interval, msec
        Mode      : byte;     // Timer mode
        Run       : boolean;  // Start timer immediately
        Msg,                  // Message code (2nd handler parameter)
        UserParam : dword     // User parameter (3rd handler parameter)
        ) : THandle;
         external TimerMan name 'tmCreateIntervalTimer';

(*** Creating interval timer ***)
function tmCreateIntervalTimerEx(
        hEventObj : THandle;  // Notify object handle
        Interval  : dword;    // Time interval, msec
        Mode      : byte;     // Timer mode
        Run       : boolean;  // Start timer immediately
        EventType : byte;     // Notify object type
        Msg,                  // Message code
        UserParam : dword     // User parameter for message
        ) : THandle;
         external TimerMan name 'tmCreateIntervalTimerEx';

(*** Closing timer ***)
procedure tmCloseTimer(hTimer : THandle);
         external TimerMan name 'tmCloseTimer';

(*** Starting timer (enable work) ***)
procedure tmStartTimer(hTimer : THandle);
         external TimerMan name 'tmStartTimer';

(*** Stopping timer (disable work) ***)
procedure tmStopTimer(hTimer : THandle);
         external TimerMan name 'tmStopTimer';

(*** Resetting timer ***)
procedure tmResetTimer(hTimer : THandle);
         external TimerMan name 'tmResetTimer';

(*** Set timer mode ***)
procedure tmSetTimerMode(hTimer : THandle; Mode : byte);
         external TimerMan name 'tmSetTimerMode';

(*** Modify timer interval ***)
procedure tmSetTimerInterval(hTimer : THandle; Interval : dword);
         external TimerMan name 'tmSetTimerInterval';

(*** Creating synchronized period timer with object event handler ***)
function tmCreateFixedTimer(
        hEventProc: TNotifierEvent;  // Client event handler
        TimeMask  : shortstring;// Time period in CRON format
        Mode      : byte;       // Timer mode
        Run       : boolean;    // Start timer immediately
        Msg,                    // Message code
        UserParam : dword       // User parameter for message
        ) : THandle;
         external TimerMan name 'tmCreateFixedTimer';

(*** Creating synchronized period timer ***)
function tmCreateFixedTimerEx(
        hEventObj : THandle;    // Notify object handle
        TimeMask  : shortstring;// Time period in CRON format
        Mode      : byte;       // Timer mode
        Run       : boolean;    // Start timer immediately
        EventType : byte;       // Notify object type
        Msg,                    // Message code
        UserParam : dword       // User parameter for message
        ) : THandle;
         external TimerMan name 'tmCreateFixedTimerEx';

(*** Modify fixed timer CRON mask ***)
procedure tmSetTimerMask(hTimer : THandle; TimeMask : shortstring);
         external TimerMan name 'tmSetTimerMask';

(*** Load fixed timer LastTime ***)
procedure tmSetLastTime(hTimer : THandle; var LastTime : TSystemTime);
         external TimerMan name 'tmSetLastTime';

(*** Save fixed timer LastTime ***)
procedure tmGetLastTime(hTimer : THandle; var LastTime : TSystemTime);
         external TimerMan name 'tmGetLastTime';

(*** Get fixed timer NextTime ***)
procedure tmGetNextTime(hTimer : THandle; var NextTime : TSystemTime);
         external TimerMan name 'tmGetNextTime';

implementation

end.
