object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'Delphi Shader'
  ClientHeight = 541
  ClientWidth = 687
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter1: TSplitter
    Left = 161
    Top = 0
    Width = 4
    Height = 522
    ResizeStyle = rsUpdate
    ExplicitLeft = 185
    ExplicitTop = 33
    ExplicitHeight = 414
  end
  object pb: TPaintBox32
    Left = 165
    Top = 0
    Width = 522
    Height = 522
    Align = alClient
    TabOrder = 0
    OnMouseDown = pbMouseDown
    OnMouseMove = pbMouseMove
    OnMouseUp = pbMouseUp
    OnPaintBuffer = pbPaintBuffer
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 161
    Height = 522
    Align = alLeft
    TabOrder = 1
    object Panel1: TPanel
      Left = 1
      Top = 1
      Width = 159
      Height = 48
      Align = alTop
      BevelOuter = bvNone
      BorderWidth = 4
      TabOrder = 0
      object Label1: TLabel
        AlignWithMargins = True
        Left = 7
        Top = 7
        Width = 145
        Height = 13
        Align = alTop
        Caption = 'Framerate'
        Layout = tlCenter
        OnClick = RenderFiles
        ExplicitWidth = 50
      end
      object scrQuality: TScrollBar
        Left = 4
        Top = 23
        Width = 151
        Height = 17
        Align = alTop
        Max = 60
        PageSize = 0
        Position = 20
        TabOrder = 0
        OnChange = scrQualityChange
      end
    end
    object Button1: TButton
      Left = 1
      Top = 496
      Width = 159
      Height = 25
      Align = alBottom
      Caption = 'Save Screenshots'
      TabOrder = 1
      OnClick = RenderFiles
    end
    object ListView1: TListView
      Left = 1
      Top = 49
      Width = 159
      Height = 406
      Align = alClient
      BorderStyle = bsNone
      Columns = <>
      FlatScrollBars = True
      IconOptions.AutoArrange = True
      LargeImages = ThumbnailsLarge
      SmallImages = ThumbnailsSmall
      TabOrder = 2
      OnClick = ListView1Click
      OnSelectItem = ListView1SelectItem
    end
    object Panel3: TPanel
      Left = 1
      Top = 455
      Width = 159
      Height = 41
      Align = alBottom
      BevelOuter = bvNone
      TabOrder = 3
      object Panel4: TPanel
        Left = 0
        Top = 0
        Width = 96
        Height = 41
        Align = alClient
        BevelOuter = bvNone
        TabOrder = 0
        object Label3: TLabel
          Left = 0
          Top = 6
          Width = 50
          Height = 13
          Caption = 'Resolution'
        end
        object cmbResolution: TComboBox
          Left = 0
          Top = 20
          Width = 96
          Height = 21
          Align = alBottom
          TabOrder = 0
          Text = 'cmbResolution'
        end
      end
      object Panel5: TPanel
        Left = 96
        Top = 0
        Width = 63
        Height = 41
        Align = alRight
        BevelOuter = bvNone
        TabOrder = 1
        object Label2: TLabel
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
          Text = 'cmbResolution'
        end
      end
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 522
    Width = 687
    Height = 19
    Panels = <
      item
        Width = 80
      end
      item
        Alignment = taRightJustify
        Width = 80
      end
      item
        Alignment = taRightJustify
        Width = 50
      end>
    SizeGrip = False
    OnDrawPanel = StatusBar1DrawPanel
  end
  object Timer1: TTimer
    Interval = 1
    OnTimer = Timer1Timer
    Left = 104
    Top = 104
  end
  object ApplicationEvents1: TApplicationEvents
    OnException = ApplicationEvents1Exception
    Left = 104
    Top = 160
  end
  object ThumbnailsLarge: TImageList
    Height = 64
    Masked = False
    Width = 64
    Left = 56
    Top = 272
  end
  object ThumbnailsSmall: TImageList
    Left = 56
    Top = 336
  end
  object Timer2: TTimer
    Enabled = False
    Interval = 10
    Left = 96
    Top = 224
  end
end
