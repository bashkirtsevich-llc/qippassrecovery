unit exUtils;

(*****************************************************************************
  (c) 2006, 5190@mail.ru
*****************************************************************************)

interface

uses StdCtrls, Windows, Messages, SysUtils, ShellApi, OSCARMd5, Classes;

type
  PEditBallonTip = ^TEditBallonTip;
  TEditBallonTip = packed record
    cbStruct: DWORD;
    pszTitle: PWideChar;
    pszText: PWideChar;
    ttiIcon: Integer;
  end;

const
  ECM_FIRST = $1500;
  EM_SHOWBALLOONTIP = (ECM_FIRST + 3);
  TTI_NONE = 0;
  TTI_INFO = 1;
  TTI_WARNING = 2;
  TTI_ERROR = 3;  

procedure exShowWinMsg(EditCtl: HWnd; Text: string; Caption: string; Icon: Integer; Balloon: Boolean);
procedure exDisableSysMenuItem(Handle: THandle; const Item: Integer);
function  exIsWinXPMin: Boolean;
procedure exUpdateSysMenu(Handle: THandle; Cmd1: Integer; const Menu: string);
function  exIsValidCharacters(Value: string): Boolean;
function  exScreenNameIsIcqNumber(SN: string): Boolean;
function  exNormalizeScreenName(SN: string) :string;
function  exNormalizeIcqNumber(SN: string) :string;
function  exUpdateHandCursor: HCURSOR;
function  exIsValidMD5(MD5Hex: string): Boolean;
function  exNowTime: string;
function GetNewestMd5Hash(Value: string): string;


implementation

procedure exDisableSysMenuItem(Handle: THandle; const Item: Integer);
var
  SysMenu: HMenu;
begin
  SysMenu := GetSystemMenu(Handle, False);
  EnableMenuItem(SysMenu, Item, MF_DISABLED or MF_GRAYED);
end;

{*****************************************************************************}
function StrToWChar(Source: string; var Dest: PWideChar): Integer;
begin
  Result := (Length(Source) * SizeOf(WideChar)) + 1;
  GetMem(Dest, Result);
  Dest := StringToWideChar(Source, Dest, Result);
end;

{*****************************************************************************}
procedure exShowWinMsg(EditCtl: HWnd; Text: string; Caption: string; Icon: Integer; Balloon: Boolean);
var
  ebt: TEditBallonTip;
  btn: Integer;
  l1, l2: Integer;
begin
  if Balloon then
  begin
    FillChar(ebt, sizeof(ebt), 0);
    l1 := StrToWChar(Caption, ebt.pszTitle);
    l2 := StrToWChar(Text, ebt.pszText);
    ebt.ttiIcon := Icon;
    ebt.cbStruct := sizeof(ebt);
    SendMessage(EditCtl, EM_SHOWBALLOONTIP, 0, LongInt(@ebt));
    FreeMem(ebt.pszTitle, l1);
    FreeMem(ebt.pszText, l2);
  end else
  begin
    case Icon of
      TTI_INFO: btn := MB_ICONINFORMATION;
      TTI_WARNING: btn := MB_ICONWARNING;
      TTI_ERROR: btn := MB_ICONERROR;
    else
      btn := 0;
    end;
    MessageBox(EditCtl, PChar(Text), PChar(Caption), btn);
  end;
end;  

{*****************************************************************************}
function exIsWinXPMin: Boolean;
var
  oi: TOSVersionInfo;
begin
  FillChar(oi, SizeOf(oi), 0);
  oi.dwOSVersionInfoSize := SizeOf(oi);
  GetVersionEx(oi);
  Result := (oi.dwPlatformId = VER_PLATFORM_WIN32_NT) and (oi.dwMajorVersion >= 5) and (oi.dwMinorVersion >= 1);
end;

{*****************************************************************************}
procedure exUpdateSysMenu(Handle: THandle; Cmd1: Integer; const Menu: string);
begin
  AppendMenu(GetSystemMenu(Handle, False), MF_SEPARATOR, 0, #0);
  AppendMenu(GetSystemMenu(Handle, False), MF_BYCOMMAND and MF_GRAYED, Cmd1, PChar(Menu));
end;

{*****************************************************************************}
function  exIsValidCharacters(Value: string): Boolean;
const
  ValidAsciiChars = ['a'..'z', 'A'..'Z', '0'..'9',
                     '~', '`', '!', '@', '#', '%',
                     '^', '&', '*', '(', ')', '-',
                     '=', '_', '+', '[', ']', '{',
                     '}', ';', '''', ',', '.', '/',
                     ':', '"', '<', '>', '?'];
var
  i: Integer;
begin
  Result := True;
  for i := 1 to Length(Value) do
    if not (Value[i] in ValidAsciiChars) then
    begin
      Result := False;
      Exit;
    end;
end;

{*****************************************************************************}
function exScreenNameIsIcqNumber(SN: string): Boolean;
var 
  I: Real; 
  E: Integer; 
begin 
  Val(SN, I, E); 
  Result := E = 0; 
  E := Trunc(I); 
end;

{*****************************************************************************}
function exNormalizeScreenName(SN: string) :string;

  function DeleteSpaces(const Value: string): string;
  var
    Counter, i: integer;
  begin
    Counter := 0;
    SetLength(Result, Length(Value));
    for i := 1 to Length(Value) do
      if Value[i] <> ' ' then
      begin
        Inc(Counter);
        Result[Counter] := Value[i];
      end;
    SetLength(Result, Counter);
    end;
    
begin
  Result := AnsiLowerCase(DeleteSpaces(SN));
end;


{*****************************************************************************}
function exNormalizeIcqNumber(SN: string) :string;

  function DeleteDashes(const Value: string): string;
  var
    Counter, i: integer;
  begin
    Counter := 0;
    SetLength(Result, Length(Value));
    for i := 1 to Length(Value) do
      if Value[i] <> '-' then
      begin
        Inc(Counter);
        Result[Counter] := Value[i];
      end;
    SetLength(Result, Counter);
    end;
    
begin
  Result := DeleteDashes(SN);
end;

{*****************************************************************************}
function exUpdateHandCursor: HCURSOR;
begin
 Result := LoadCursor(0, IDC_HAND);
end;

{*****************************************************************************}
function exIsValidMD5(MD5Hex: string): Boolean;
var
  i: Byte;
begin
  Result := False;
  if Length(MD5Hex) <> 32 then Exit;
  for i := 1 to Length(MD5Hex) do
    if not (MD5Hex[i] in ['0'..'f']) then Exit;
  Result := True;
end;

{*****************************************************************************}
function exNowTime: string;
begin
  Result := FormatDateTime('hh:mm:ss', Now);
end;

{*****************************************************************************}
function GetNewestMd5Hash(Value: string): string;
var
  Md5C: MD5Context;
  Md5D: MD5Digest;
begin
  MD5Init(Md5C);
  MD5Append(Md5C, PChar(Value), Length(Value));
  MD5Final(Md5C, Md5D);
  SetLength(Result, 32);
  BinToHex(PChar(@Md5D), PChar(Result) , 16);
end;


end.
