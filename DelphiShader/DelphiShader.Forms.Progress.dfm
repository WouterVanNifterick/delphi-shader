object frmProgress: TfrmProgress
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'Progress'
  ClientHeight = 532
  ClientWidth = 400
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object pb: TPaintBox32
    Left = 0
    Top = 107
    Width = 400
    Height = 359
    Align = alClient
    TabOrder = 0
    ExplicitTop = 126
    ExplicitWidth = 443
    ExplicitHeight = 306
  end
  object Panel3: TPanel
    Left = 0
    Top = 466
    Width = 400
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 432
    ExplicitWidth = 443
    object Panel4: TPanel
      Left = 0
      Top = 0
      Width = 337
      Height = 41
      Align = alClient
      BevelOuter = bvNone
      TabOrder = 0
      ExplicitWidth = 380
      object Label4: TLabel
        Left = 0
        Top = 6
        Width = 50
        Height = 13
        Caption = 'Resolution'
      end
      object cmbResolution: TComboBox
        Left = 0
        Top = 20
        Width = 337
        Height = 21
        Align = alBottom
        TabOrder = 0
        ExplicitWidth = 380
      end
    end
    object Panel5: TPanel
      Left = 337
      Top = 0
      Width = 63
      Height = 41
      Align = alRight
      BevelOuter = bvNone
      TabOrder = 1
      ExplicitLeft = 380
      object Label5: TLabel
        Left = 0
        Top = 6
        Width = 55
        Height = 13
        Caption = 'AntiAliasing'
      end
      object cmbAA: TComboBox
        Left = 0
        Top = 20
        Width = 63
        Height = 21
        Align = alBottom
        TabOrder = 0
      end
    end
  end
  object Button1: TButton
    Left = 0
    Top = 507
    Width = 400
    Height = 25
    Align = alBottom
    Caption = 'Save Screenshots'
    TabOrder = 2
    ExplicitTop = 473
    ExplicitWidth = 443
  end
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 400
    Height = 107
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    BorderWidth = 4
    TabOrder = 3
    object Label1: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 7
      Width = 392
      Height = 13
      Margins.Left = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      ExplicitLeft = 3
      ExplicitTop = 3
      ExplicitWidth = 3
    end
    object Label2: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 40
      Width = 392
      Height = 13
      Margins.Left = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      ExplicitTop = 31
    end
    object Label3: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 73
      Width = 392
      Height = 13
      Margins.Left = 0
      Margins.Right = 0
      Margins.Bottom = 0
      Align = alTop
      ExplicitLeft = 3
      ExplicitTop = 87
      ExplicitWidth = 3
    end
    object barOverall: TProgressBar
      Left = 4
      Top = 20
      Width = 392
      Height = 17
      Align = alTop
      Smooth = True
      BarColor = clBtnShadow
      TabOrder = 0
    end
    object barFrames: TProgressBar
      Left = 4
      Top = 53
      Width = 392
      Height = 17
      Align = alTop
      Smooth = True
      BarColor = clBtnShadow
      TabOrder = 1
    end
    object BarLines: TProgressBar
      Left = 4
      Top = 86
      Width = 392
      Height = 17
      Align = alTop
      Smooth = True
      BarColor = clBtnShadow
      TabOrder = 2
    end
  end
end
