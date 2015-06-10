unit Pass_u;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, exUtils;

type
  TdlgPassword = class(TForm)
    lePassword: TLabeledEdit;
    btnOk: TButton;
    btnCancel: TButton;
    bvlLine: TBevel;
    procedure lePasswordKeyPress(Sender: TObject; var Key: Char);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dlgPassword: TdlgPassword;

implementation

const
  ValidAsciiChars = ['a'..'z', 'A'..'Z', '0'..'9',
                     '~', '`', '!', '@', '#', '%',
                     '^', '&', '*', '(', ')', '-',
                     '=', '_', '+', '[', ']', '{',
                     '}', ';', '''', ',', '.', '/',
                     ':', '"', '<', '>', '?',#8,#46];

{$R *.dfm}

procedure TdlgPassword.lePasswordKeyPress(Sender: TObject; var Key: Char);
begin
  if Length(lePassword.Text) >= 8 then
    exShowWinMsg(lePassword.Handle,'Max 8 symbols!','Error',3,True);
  if not (Key in ValidAsciiChars) then
  begin
    exShowWinMsg(lePassword.Handle,'Invalid symbol!','Error',2,True);
    Key := #0;
  end;
end;

end.
