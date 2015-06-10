object wndMain: TwndMain
  Left = 192
  Top = 114
  AlphaBlend = True
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'qip - password extractor & changer v.1.1'
  ClientHeight = 297
  ClientWidth = 377
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnActivate = FormActivate
  OnClose = FormClose
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object bvlLine: TBevel
    Left = 8
    Top = 56
    Width = 361
    Height = 9
    Shape = bsTopLine
  end
  object lblCheck: TLabel
    Left = 8
    Top = 112
    Width = 176
    Height = 13
    Caption = 'Change accounts for reset password:'
    Visible = False
  end
  object pnlLogo: TPanel
    Left = 8
    Top = 8
    Width = 362
    Height = 42
    BevelOuter = bvLowered
    TabOrder = 0
    object imgLogo: TImage
      Left = 1
      Top = 1
      Width = 360
      Height = 40
      Align = alClient
      OnMouseDown = imgLogoMouseDown
      OnMouseMove = imgLogoMouseMove
      OnMouseUp = imgLogoMouseUp
    end
  end
  object leFile: TLabeledEdit
    Left = 8
    Top = 80
    Width = 333
    Height = 21
    EditLabel.Width = 93
    EditLabel.Height = 13
    EditLabel.Caption = 'qip infium file (*.qip):'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    TabOrder = 1
    OnChange = leFileChange
  end
  object btnBrows: TButton
    Left = 348
    Top = 80
    Width = 21
    Height = 21
    Caption = '...'
    TabOrder = 2
    OnClick = btnBrowsClick
  end
  object btnFindPasswords: TButton
    Left = 216
    Top = 264
    Width = 75
    Height = 25
    Caption = 'Find'
    Enabled = False
    TabOrder = 4
    OnClick = btnFindPasswordsClick
  end
  object btnNext: TButton
    Left = 296
    Top = 264
    Width = 75
    Height = 25
    Caption = 'Next >'
    Enabled = False
    TabOrder = 5
    OnClick = btnNextClick
  end
  object mmoLog: TMemo
    Left = 8
    Top = 112
    Width = 361
    Height = 145
    Color = clBtnFace
    Font.Charset = RUSSIAN_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'MS Sans Serif'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssVertical
    TabOrder = 3
  end
  object lvAccounts: TListView
    Left = 8
    Top = 128
    Width = 361
    Height = 129
    Checkboxes = True
    Columns = <
      item
        Caption = 'Account'
        Width = 130
      end
      item
        Caption = 'Password'
        Width = 200
      end>
    ReadOnly = True
    RowSelect = True
    TabOrder = 6
    ViewStyle = vsReport
    Visible = False
  end
  object dlgOpen: TOpenDialog
    Filter = 'qip files (*.qip)|*.QIP'
    Title = 'Open QIP account file'
    Left = 16
    Top = 16
  end
  object tmrRain: TTimer
    Enabled = False
    Interval = 1
    OnTimer = tmrRainTimer
    Left = 48
    Top = 16
  end
end
