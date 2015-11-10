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
  // Пытаемся создать почтовый ящик
  ServerMailslotHandle := CreateMailSlot(MailslotName, 0, MAILSLOT_WAIT_FOREVER, nil);
  if ServerMailslotHandle = INVALID_HANDLE_VALUE then begin
    if GetLastError = ERROR_ALREADY_EXISTS then begin
      // Если такой ящик уже есть, подключаемся к нему как клиент
      ClientMailslotHandle := CreateFile(MailslotName, GENERIC_WRITE,
        FILE_SHARE_READ, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
      // В зависимости от того, какие переданы параметры, формируем строку
      // для передачи предыдущему экземпляру. Первый символ строки - команда:
      // e - открыть файл для редактирования
      // v - открыть файл для просмотра
      // s - просто активизировать предыдущий экземпляр
      // Для команд e и v к строке, начиная со 2-го символа, добавляется
      // имя файла
      if ParamCount > 0 then Letter := 'd' else begin
         Letter := 's';
         MessageBox(0,'Запуск второй копии'+#13+
         'программы недопустим!','Считыватель ID',MB_OK or MB_ICONSTOP);
      end;
      // Отправляем команду в почтовый ящик
      WriteFile(ClientMailslotHandle, Letter[1], Length(Letter),
        BytesWritten, nil);
      // Сигнализируем об отправке данных через специальное событие
      CommandEvent := OpenEvent(EVENT_MODIFY_STATE, False, EventName);
      SetEvent(CommandEvent);
      // Закрываем все дескрипторы
      CloseHandle(CommandEvent);
      CloseHandle(ClientMailslotHandle);
    end
  end else begin
    //первый запуск с параметром - не запускать
    if ParamCount > 0 then Exit;
    // Создаём событие для сигнализирования о поступлении данных
    CommandEvent := CreateEvent(nil, False, False, EventName);
    // Выполняем обычный для VCL-приложений цикл
            Application.Initialize;
            Application.Title := 'Считыватель ID';
            Application.MainFormOnTaskbar := true;
            Application.CreateForm(TfrmReadID, frmReadID);
            Application.Run;
    // Закрываем все дескрипторы
    CloseHandle(ServerMailslotHandle);
    CloseHandle(CommandEvent);
  end;
end.
