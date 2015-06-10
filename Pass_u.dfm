object dlgPassword: TdlgPassword
  Left = 192
  Top = 124
  ActiveControl = lePassword
  BorderStyle = bsDialog
  Caption = 'New password!'
  ClientHeight = 97
  ClientWidth = 337
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poOwnerFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object bvlLine: TBevel
    Left = 8
    Top = 56
    Width = 321
    Height = 9
    Shape = bsTopLine
  end
  object lePassword: TLabeledEdit
    Left = 8
    Top = 24
    Width = 321
    Height = 21
    EditLabel.Width = 73
    EditLabel.Height = 13
    EditLabel.Caption = 'New password:'
    MaxLength = 8
    TabOrder = 2
    OnKeyPress = lePasswordKeyPress
  end
  object btnOk: TButton
    Left = 176
    Top = 64
    Width = 73
    Height = 25
    Caption = 'Ok'
    Default = True
    ModalResult = 1
    TabOrder = 0
  end
  object btnCancel: TButton
    Left = 256
    Top = 64
    Width = 73
    Height = 25
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 1
  end
end
