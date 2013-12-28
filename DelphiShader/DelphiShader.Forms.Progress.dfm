object frmProgress: TfrmProgress
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsToolWindow
  Caption = 'Progress'
  ClientHeight = 498
  ClientWidth = 443
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 437
    Height = 13
    Align = alTop
    Caption = 'Label1'
    ExplicitWidth = 31
  end
  object Label2: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 45
    Width = 437
    Height = 13
    Align = alTop
    Caption = 'Label1'
    ExplicitWidth = 31
  end
  object Label3: TLabel
    AlignWithMargins = True
    Left = 3
    Top = 87
    Width = 437
    Height = 13
    Align = alTop
    Caption = 'Label1'
    ExplicitWidth = 31
  end
  object barOverall: TProgressBar
    AlignWithMargins = True
    Left = 3
    Top = 22
    Width = 437
    Height = 17
    Align = alTop
    TabOrder = 0
  end
  object barFrames: TProgressBar
    AlignWithMargins = True
    Left = 3
    Top = 64
    Width = 437
    Height = 17
    Align = alTop
    TabOrder = 1
  end
  object BarLines: TProgressBar
    AlignWithMargins = True
    Left = 3
    Top = 106
    Width = 437
    Height = 17
    Align = alTop
    TabOrder = 2
  end
  object pb: TPaintBox32
    Left = 0
    Top = 126
    Width = 443
    Height = 372
    Align = alClient
    TabOrder = 3
  end
end
