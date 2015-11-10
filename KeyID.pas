unit KeyID;

interface
type
{ TKeyID }

  TKeyIDRec = packed record
    Version: Byte;
    ID: array[0..5] of Byte;
    CRC: Byte;
  end;

  TKeyID = class
  private
    FKeyIDRec: TKeyIDRec;
    function GetPtr: Pointer;
    function GetStr: String;
    procedure SetStr(const Value: String);
    function GetIsZero: Boolean;
    function GetBytes(Index: Integer): Byte;
    procedure SetBytes(Index: Integer; Value: Byte);
  public
    procedure InitRandom;
    property Rec: TKeyIDRec read FKeyIDRec write FKeyIDRec;
    property Ptr: Pointer read GetPtr;
    property Str: String read GetStr write SetStr;
    property IsZero: Boolean read GetIsZero;
    property Bytes[Index: Integer]: Byte read GetBytes write SetBytes;
    procedure noCodVer;
  end;

implementation

uses
  SysUtils;
{ TKeyID }

function TKeyID.GetPtr: Pointer;
begin
  Result := @FKeyIDRec;
end;

function TKeyID.GetStr: String;
begin
  Result := IntToHex(FKeyIDRec.Version,2) +
    IntToHex(FKeyIDRec.ID[0],2) +
    IntToHex(FKeyIDRec.ID[1],2) +
    IntToHex(FKeyIDRec.ID[2],2) +
    IntToHex(FKeyIDRec.ID[3],2) +
    IntToHex(FKeyIDRec.ID[4],2) +
    IntToHex(FKeyIDRec.ID[5],2);
end;

procedure TKeyID.SetStr(const Value: String);
begin
  FKeyIDRec.Version := StrToInt('$'+Value[1]+Value[2]);
  FKeyIDRec.ID[0] := StrToInt('$'+Value[4]+Value[5]);
  FKeyIDRec.ID[1] := StrToInt('$'+Value[7]+Value[8]);
  FKeyIDRec.ID[2] := StrToInt('$'+Value[10]+Value[11]);
  FKeyIDRec.ID[3] := StrToInt('$'+Value[13]+Value[14]);
  FKeyIDRec.ID[4] := StrToInt('$'+Value[16]+Value[17]);
  FKeyIDRec.ID[5] := StrToInt('$'+Value[19]+Value[20]);
end;

procedure TKeyID.noCodVer;
begin
  FKeyIDRec.ID[3] := 0;
  FKeyIDRec.ID[4] := 0;
  FKeyIDRec.ID[5] := 0;
end;

function TKeyID.GetIsZero: Boolean;
type
  PByteArray = ^TByteArray;
  TByteArray = array[0..7] of Byte;
var
  I: Integer;
begin
  Result := True;
  for I := 0 to 6 do
    if PByteArray(@FKeyIDRec)^[I] <> 0 then
    begin
      Result := False;
      Break;
    end;
end;

function TKeyID.GetBytes(Index: Integer): Byte;
type
  PByteArray = ^TByteArray;
  TByteArray = array[0..7] of Byte;
begin
  Result := PByteArray(@FKeyIDRec)^[Index];
end;

procedure TKeyID.SetBytes(Index: Integer; Value: Byte);
type
  PByteArray = ^TByteArray;
  TByteArray = array[0..7] of Byte;
begin
  PByteArray(@FKeyIDRec)^[Index] := Value;
end;

procedure TKeyID.InitRandom;
type
  PByteArray = ^TByteArray;
  TByteArray = array[0..7] of Byte;
var
  Z,I: Integer;
begin
  for I := 0 to 6 do begin
    Z:=0;
    while Z=0 do Z:=Random(256);
    PByteArray(@FKeyIDRec)^[I] := Z;
  end;
end;

end.
