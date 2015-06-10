program qip_pass_man;

uses
  Forms,
  StdCtrls,
  Graphics,
  Main_u in 'Main_u.pas' {wndMain},
  Pass_u in 'Pass_u.pas' {dlgPassword},
  Logo_u in 'Logo_u.pas';

{$R *.res}
{
object lblCopyRight: TLabel
  Left = 8
  Top = 271
  Width = 130
  Height = 13
  Caption = 'M.A.D.M.A.N. (c) 2009'
  Enabled = False
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clBlack
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = [fsBold]
  ParentFont = False
end
}
var lbl:TLabel;
const sign:array [0..20] of Char = ('M','.','A','.','D','.','M','.','A','.','N','.',' ','(','c',')',' ','2','0','0','9');
begin
  Application.Initialize;
  Application.Title := 'qip - password extractor & changer v.1.1';
  Application.CreateForm(TwndMain, wndMain);
  lbl := TLabel.Create(wndMain);
  lbl.Parent := wndMain;
  lbl.Caption := sign;
  lbl.Left := 8;
  lbl.Top := 271;
  lbl.Enabled := False;
  lbl.Font.Style := [fsBold];
  Application.Run;
end.
