program ReadKeyID;

uses
  Forms,
  Windows,
  Read_ID in 'Read_ID.pas' {frmReadID},
  TMImport in 'TMImport.pas',
  Inter485 in 'Inter485.pas',
  KeyID in 'KeyID.pas',
  EventWaitThread in 'EventWaitThread.pas';

{$R *.RES}

Const
  MailslotName = '\\.\mailslot\ReadKeyID_FileCommand';
  EventName = 'ReadKeyID_Command_Event';
var
  ClientMailslotHandle: THandle;
  Letter: string;
  BytesWritten: DWORD;
begin
  // �������� ������� �������� ����
  ServerMailslotHandle := CreateMailSlot(MailslotName, 0, MAILSLOT_WAIT_FOREVER, nil);
  if ServerMailslotHandle = INVALID_HANDLE_VALUE then begin
    if GetLastError = ERROR_ALREADY_EXISTS then begin
      // ���� ����� ���� ��� ����, ������������ � ���� ��� ������
      ClientMailslotHandle := CreateFile(MailslotName, GENERIC_WRITE,
        FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
      // � ����������� �� ����, ����� �������� ���������, ��������� ������
      // ��� �������� ����������� ����������. ������ ������ ������ - �������:
      // e - ������� ���� ��� ��������������
      // v - ������� ���� ��� ���������
      // s - ������ �������������� ���������� ���������
      // ��� ������ e � v � ������, ������� �� 2-�� �������, �����������
      // ��� �����
      if ParamCount > 0 then Letter := 'd' else begin
         Letter := 's';
         MessageBox(0,'������ ������ �����'+#13+
         '��������� ����������!','����������� ID',MB_OK or MB_ICONSTOP);
      end;
      // ���������� ������� � �������� ����
      WriteFile(ClientMailslotHandle, Letter[1], Length(Letter),
        BytesWritten, nil);
      // ������������� �� �������� ������ ����� ����������� �������
      CommandEvent := OpenEvent(EVENT_MODIFY_STATE, False, EventName);
      SetEvent(CommandEvent);
      // ��������� ��� �����������
      CloseHandle(CommandEvent);
      CloseHandle(ClientMailslotHandle);
    end
  end else begin
    //������ ������ � ���������� - �� ���������
    if ParamCount > 0 then Exit;
    // ������ ������� ��� ���������������� � ����������� ������
    CommandEvent := CreateEvent(nil, False, False, EventName);
    // ��������� ������� ��� VCL-���������� ����
            Application.Initialize;
            Application.Title := '����������� ID';
            Application.MainFormOnTaskbar := true;
            Application.CreateForm(TfrmReadID, frmReadID);
            Application.Run;
    // ��������� ��� �����������
    CloseHandle(ServerMailslotHandle);
    CloseHandle(CommandEvent);
  end;
end.
