unit EventWaitThread;

interface

uses
  Windows, Classes;

type
  TEventWaitThread = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

var
  CommandEvent: THandle;

implementation

uses
  Read_ID;

{ TEventWaitThread }

procedure TEventWaitThread.Execute;
begin
  while True do
  begin
    if WaitForSingleObject(CommandEvent, INFINITE) <> WAIT_OBJECT_0 then Exit;
    PostMessage(frmReadID.Handle, WM_TWOEXEC, 0, 0);
  end;
end;

end.
