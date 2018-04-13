object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  Caption = 'Delphi Shader'
  ClientHeight = 307
  ClientWidth = 677
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
    Height = 288
    ResizeStyle = rsUpdate
    ExplicitLeft = 185
    ExplicitTop = 33
    ExplicitHeight = 414
  end
  object pb: TPaintBox32
    Left = 165
    Top = 0
    Width = 512
    Height = 288
    Align = alClient
    TabOrder = 0
    OnDblClick = pbDblClick
    OnMouseDown = pbMouseDown
    OnMouseMove = pbMouseMove
    OnMouseUp = pbMouseUp
    OnPaintBuffer = pbPaintBuffer
    ExplicitHeight = 512
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 161
    Height = 288
    Align = alLeft
    TabOrder = 1
    ExplicitHeight = 512
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
        Width = 50
        Height = 13
        Align = alTop
        Caption = 'Framerate'
        Layout = tlCenter
        OnClick = RenderFiles
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
    object ListView1: TListView
      Left = 1
      Top = 76
      Width = 159
      Height = 169
      Align = alClient
      BorderStyle = bsNone
      Columns = <
        item
          AutoSize = True
          Caption = 'Name'
        end
        item
          Caption = 'PPS'
          Width = 70
        end>
      DoubleBuffered = True
      FlatScrollBars = True
      GridLines = True
      HideSelection = False
      IconOptions.Arrangement = iaLeft
      IconOptions.AutoArrange = True
      LargeImages = ThumbnailsLarge
      OwnerData = True
      ReadOnly = True
      RowSelect = True
      ParentDoubleBuffered = False
      ShowColumnHeaders = False
      SmallImages = ThumbnailsLarge
      TabOrder = 1
      ViewStyle = vsReport
      OnClick = ListView1Click
      OnData = ListView1Data
      OnDblClick = ListView1DblClick
      OnSelectItem = ListView1SelectItem
      ExplicitHeight = 393
    end
    object Edit1: TButtonedEdit
      AlignWithMargins = True
      Left = 4
      Top = 52
      Width = 153
      Height = 21
      Align = alTop
      TabOrder = 2
      TextHint = 'All'
      OnChange = Edit1Change
    end
    object ProgressBar1: TProgressBar
      Left = 1
      Top = 270
      Width = 159
      Height = 17
      Hint = 'Progress of thumbnail rendering (background)'
      Align = alBottom
      ParentShowHint = False
      Smooth = True
      ShowHint = True
      TabOrder = 3
      ExplicitTop = 494
    end
    object Button1: TButton
      Left = 1
      Top = 245
      Width = 159
      Height = 25
      Align = alBottom
      Caption = 'Save images'
      TabOrder = 4
      OnClick = Button1Click
      ExplicitTop = 469
    end
  end
  object StatusBar1: TStatusBar
    Left = 0
    Top = 288
    Width = 677
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
    ExplicitTop = 512
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 1
    OnTimer = Timer1Timer
    Left = 80
    Top = 88
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
end
