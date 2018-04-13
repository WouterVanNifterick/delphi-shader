unit DelphiShader.Forms.Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GR32, GR32_Image, Types, Vcl.ExtCtrls,
  GR32_ExtImage, GR32_Resamplers, GR32_Backends, PngImage, GIFImg,
  Generics.Collections,
  Generics.Defaults,
  IoUtils, GraphUtil,
  WvN.DelphiShader.Shader,
  System.Diagnostics, DateUtils,
  Vcl.StdCtrls, Vcl.AppEvnts, Vcl.ComCtrls, Vcl.ImgList, uxTheme,
  System.ImageList;

const
  THUMBNAIL_SIZE = 24;

type

  TfrmMain = class(TForm)
    pb: TPaintBox32;
    Timer1: TTimer;
    ApplicationEvents1: TApplicationEvents;
    Panel2: TPanel;
    ThumbnailsLarge: TImageList;
    ThumbnailsSmall: TImageList;
    Splitter1: TSplitter;
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    Label1: TLabel;
    scrQuality: TScrollBar;
    ListView1: TListView;
    Edit1: TButtonedEdit;
    ProgressBar1: TProgressBar;
    Button1: TButton;
    procedure pbPaintBuffer(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure scrQualityChange(Sender: TObject);
    // procedure Timer2Timer(Sender: TObject);
    procedure pbMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure FormDestroy(Sender: TObject);
    procedure ListView1Click(Sender: TObject);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure ApplicationEvents1Exception(Sender: TObject; E: Exception);
    procedure RenderFiles(Sender: TObject);
    procedure pbMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure pbMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure StatusBar1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
    procedure ListView1Data(Sender: TObject; Item: TListItem);
    procedure Edit1Change(Sender: TObject);
    procedure ListView1AdvancedCustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      Stage: TCustomDrawStage; var DefaultDraw: Boolean);
    procedure Button1Click(Sender: TObject);
    procedure ListView1DblClick(Sender: TObject);
    procedure pbDblClick(Sender: TObject);
  private
    procedure UpdateShader;
    procedure OnProgress(p, t: Integer);
    procedure OnProgressShowOnImage(p, t: Integer);
    procedure Render(name: string; _s: TShader; Resolution:Vec2;AA:Integer);
    procedure CreateAllThumbnails;
    procedure FilterShaderList;
    procedure Freeze;
  public
    DrawingBuffer   : TBitmap32;
    Shader          : TShader;
    q               : Integer;
    ThumbnailShaders: TShaderList;
    VisibleShaders  : TList<TShader>;
  end;
  {
    TThumbnailThread = class(TThread)
    private
    ThumbnailSize : integer;
    Flames : TStringList;
    FileName : string;
    Initialized : boolean;
    public
    constructor Create(SourceFile : string; FlameNames : TstringList);
    destructor Destroy; override;
    procedure Execute; override;
    end;
  }

var
  frmMain: TfrmMain;

implementation

uses Math, DelphiShader.Forms.Progress;

{$R *.dfm}

procedure TfrmMain.ApplicationEvents1Exception(Sender: TObject; E: Exception);
begin
  // Timer1.Enabled := False;
  // Timer3.Enabled := False;
  StatusBar1.SimpleText := E.Message;
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Timer1.Enabled := False;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  // disable theme on statbusbar, so we can paint a custom one
  ThumbnailsLarge.Width  := THUMBNAIL_SIZE;
  ThumbnailsLarge.Height := THUMBNAIL_SIZE;


  SetWindowTheme(StatusBar1.Handle, '', '');

  DrawingBuffer                    := TBitmap32.Create;
  DrawingBuffer.ResamplerClassName := 'TLinearResampler';
  DrawingBuffer.SetSize(512, 288);
  ListView1.Clear;

  // Shader := ReliefTunnel;
  {
    thread := TThumbnailThread.Create(FileName, FFlames);
    case sel of
    0: MainForm.ListView1.Selected := MainForm.ListView1.Items[MainForm.ListView1.Items.Count - 1];
    1: MainForm.ListView1.Selected := MainForm.ListView1.Items[0];
    2: // do nothing
    end;
    thread.Resume;
  }

  Sleep(100);
  VisibleShaders := TList<TShader>.Create;
  CreateAllThumbnails;

end;

procedure TfrmMain.FormDestroy(Sender: TObject);
begin
  // Shader.Free;
  DrawingBuffer.Free;
  ThumbnailShaders.Free;
end;

procedure TfrmMain.Render(name: string; _s: TShader; Resolution:Vec2; AA:integer);
// const
// sz_x=512;
// sz_y=sz_x;
// aa=2;
var
  framecount      : Integer;
  folder          : string;
  b               : TBitmap32;
  bmp, bmp2       : TBitmap;
  png             : TPngImage;
  gif             : TGIFImage;
  Frame           : Integer;
  sw              : TStopwatch;
  PxPerSec        : Int64;
  PerfStatFileName: string;
  sz_x, sz_y  : Integer;
//  ThreadedShader  : TThreadedShader;
begin
//  ThreadedShader := TThreadedShader.Create(_s);


  shader := _s.Create;

  sz_x           := round(Resolution.x);  // StrToInt(string(cmbResolution.Text).Split(['x'])[0].Trim)
  sz_y           := round(Resolution.y);
  // if cmbAA.Text = 'none' then AA := 1 else AA   := StrToInt(string(cmbAA.Text).Split([' '])[0].Trim);
  folder := format('%dx%d', [sz_x, sz_y]);
  TDirectory.CreateDirectory(folder);
  framecount := 60;
  if sz_x * AA < 256 then
    framecount := 120;
  if sz_x * AA > 1000 then
    framecount := 1;

  b := TBitmap32.Create;
  try
    b.SetSize(sz_x * AA, sz_y * AA);
    if TFile.Exists(folder + '\' + name + '.png') then
      exit;
    sw                             := TStopwatch.StartNew;
    png                            := TPngImage.Create;
    gif                            := TGIFImage.Create;
    gif.Animate                    := framecount > 1;
    gif.AnimateLoop                := glContinously;
    gif.AnimationSpeed             := 15;
    frmProgress.barFrames.Position := 0;
    frmProgress.barFrames.Max      := framecount * sz_y * AA;
    frmProgress.BarLines.Max       := sz_y * AA;

    for Frame := 0 to framecount - 1 do
    begin
      if not frmProgress.Visible then
        exit;

      if Application.Terminated then
        exit;

      frmProgress.barFrames.Position := Frame * frmProgress.BarLines.Max;
      frmProgress.barFrames.Tag      := frmProgress.barFrames.Position;
      frmProgress.Label2.Caption     := format('Frame %d of %d', [Frame + 1, framecount]);
      frmProgress.Repaint;

      if sz_x * AA > 32 then
        Shader.OnProgress := OnProgress;
      Shader.SetSize(b.Width, b.Height);
      Shader.Mouse.X     := 0.4;
      Shader.Mouse.Y     := 0.4;
      Shader.iMouse.X    := Round(b.Width / 1.8);
      Shader.iMouse.Y    := Round(b.Height / 1.8);
      Shader.Time        := 2000000 + Frame / 5;
      Shader.iGlobalTime := Shader.Time;
      Shader.Render;
      Shader.Image.Bitmap.DrawTo(b,0,0);

//      Shader.RenderTo(b);

      // TThread.Synchronize(TThread.CurrentThread,
      // procedure begin

      bmp := TBitmap.Create;
      try
        bmp.Assign(b);
        bmp2 := TBitmap.Create;
        if AA = 1 then
          bmp2.SetSize(bmp.Width, bmp.Height);
        try
          if AA > 1 then
            ScaleImage(bmp, bmp2, 1 / AA)
          else
            bmp2.Canvas.Draw(0, 0, bmp);

          png.Assign(bmp2);
          png.Resize(bmp2.Width, bmp2.Height);
          png.Canvas.Draw(0, 0, bmp2);

          png.Draw(frmProgress.pb.Canvas, frmProgress.pb.Canvas.ClipRect);
          gif.Add(png);
          // end
          // );
        finally
          bmp2.Free;
        end;
      finally
        bmp.Free;
      end;
      Application.ProcessMessages;
    end;

    // TThread.Synchronize(TThread.CurrentThread,
    // procedure begin
    if gif.Images.Count > 1 then
      gif.SaveToFile(folder + '\' + name + '.gif');
    gif.Free;
    png.SaveToFile(folder + '\' + name + '.png');
    png.Free;

    PxPerSec         := Round((framecount * sz_x * sz_y) / sw.ElapsedMilliseconds * 1000);
    PerfStatFileName := format('%s\%s.p%.6d', [folder, name, PxPerSec]);

    TFile.WriteAllText(PerfStatFileName, format('Shader: %s', [name]) + sLineBreak + format('Milliseconds: %d', [sw.ElapsedMilliseconds]) + sLineBreak + format('Pixels: %d', [framecount * sz_x * sz_y]) + sLineBreak + format('Frames: %d', [framecount]) + sLineBreak + format('Width: %d', [sz_x]) + sLineBreak + format('Height: %d', [sz_y]) + sLineBreak + format('FrameSize: %d', [sz_x * sz_y]) + sLineBreak + format('px per sec: %d', [PxPerSec]));
  finally
    b.Free;
  end;
  // end
  // );

end;


procedure TfrmMain.RenderFiles(Sender: TObject);
type
  TShaderPair = TPair<string, TShader>;
  TShaderList = TList<TShaderPair>;
const
  threads = 1;
var
  // sa:array[0..threads-1] of TShaderList;
  // j:integer;
  // ShaderKey:TSp;
  // l:TShaderList;
  ShaderPair: TShaderPair;
  LRes: vec2;
  AA: Integer;
begin
  Timer1.Enabled := False;
  ListView1.Enabled := False;
  {
    s := Shaders.ExtractPair('Catacombs');
    Render(s.Key, s.Value);
  }
  frmProgress.Show;
  frmProgress.barOverall.Max := Shaders.Count;

  LRes.x := StrToInt(string(frmProgress.cmbResolution.Text).Split(['x'])[0].Trim);
  LRes.y := StrToInt(string(frmProgress.cmbResolution.Text).Split(['x'])[0].Trim);

  if frmProgress.cmbAA.Text = 'none' then
    AA := 1
  else
    AA     := StrToInt(string(frmProgress.cmbAA.Text).Split([' '])[0].Trim);


  for ShaderPair in Shaders do
  begin
    frmProgress.Label1.Caption := ShaderPair.Key;
    frmProgress.Repaint;
    Render(ShaderPair.Key, ShaderPair.Value, lRes, AA);
    ShaderPair.Value.OnProgress  := nil;
    frmProgress.barOverall.Position := frmProgress.barOverall.Position + 1;
    frmProgress.barOverall.Tag      := frmProgress.barOverall.Position;
    frmProgress.Repaint;
  end;
  frmProgress.Hide;

  {
    for j := 0 to threads-1 do
    begin
    sa[j] := TShaderList.Create;
    end;

    j := 0;

    for ShaderKey in Shaders do
    begin
    sa[j mod threads].Add(ShaderKey);
    Inc(j);
    end;

    TThread.CreateAnonymousThread(
    procedure var l:TShaderList; s:TSp;
    begin
    l := sa[0];
    for s in l  do Render(s.Key, s.Value);
    end).Start;

    TThread.CreateAnonymousThread(
    procedure var l:TShaderList; s:TSp;
    begin
    l := sa[1];
    for s in l  do Render(s.Key, s.Value);
    end).Start;

    TThread.CreateAnonymousThread(
    procedure var l:TShaderList; s:TSp;
    begin
    l := sa[2];
    for s in l  do Render(s.Key, s.Value);
    end).Start;

  }
  Timer1.Enabled := True;
  ListView1.Enabled := True;
end;

procedure TfrmMain.ListView1AdvancedCustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  Stage: TCustomDrawStage; var DefaultDraw: Boolean);
var LRect:System.Types.TRect; idx:Integer;
begin
    if SubItem=1 then  begin

    LRect := Item.DisplayRect( TDisplayCode.drBounds );
    for Idx := 0 to SubItem -1 do
       LRect.Left := LRect.Left + Sender.Column[Idx].Width;

    LRect.Inflate(-8, -2);
    Sender.Canvas.Font.Size := 12;
    Sender.Canvas.Font.Style := [fsBold];
    Sender.Canvas.TextOut( LRect.Left, LRect.Top + 4, Item.Caption);
    Sender.Canvas.TextOut( LRect.Left, LRect.Top + 20, 'Item:'+IntToStr(Item.Index) );
    DefaultDraw := False;
  end;

end;

procedure TfrmMain.ListView1Click(Sender: TObject);
begin
  if ListView1.ItemIndex < 0 then
    exit;

  Shaders.TryGetValue(ListView1.Selected.Caption, Shader);
  q := 24;
  UpdateShader;
end;

procedure TfrmMain.ListView1Data(Sender: TObject; Item: TListItem);
var index:integer;
begin
  index := item.Index;
  if Index<0 then Exit;
  if Index>VisibleShaders.Count-1 then Exit;

  Item.Data := VisibleShaders[Index];
  Item.Caption := VisibleShaders[Index].Name;
  Item.SubItems.Add(Format('%0.0f',[VisibleShaders[Index].PixelsPerSecond]));
  Item.ImageIndex := VisibleShaders[Index].ThumbnailIndex;
end;

procedure TfrmMain.ListView1DblClick(Sender: TObject);
begin
  Freeze;
end;

procedure TfrmMain.ListView1SelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Item = nil then exit;
  if not Selected then exit;

  Shaders.TryGetValue(Item.Caption, Shader);
  q := 24;
  UpdateShader;
  Timer1.Enabled := True;

end;

var
  LastStatusUpdate: TDateTime;

procedure TfrmMain.OnProgress(p, t: Integer);
begin
  if now - LastStatusUpdate < OneMillisecond * 100 then
    exit;

  frmProgress.Label3.Caption     := format('Line %d of %d', [p, t]);
  frmProgress.BarLines.Position  := p;
  frmProgress.barFrames.Position := frmProgress.barFrames.Tag + p;
  frmProgress.Repaint;
  Application.ProcessMessages;
  LastStatusUpdate := now;
end;

procedure TfrmMain.OnProgressShowOnImage(p, t: Integer);
begin

  if now - LastStatusUpdate < OneMillisecond * 100 then
    if p < t-1 then
      exit;

  StatusBar1.Panels[2].Text := format('Line %d of %d', [p, t]);
  ProgressBar1.Max := t;
//  ProgressBar1.Position := (p mod (t div 4))*4;
  ProgressBar1.Position := p;
  ProgressBar1.Repaint;

  pb.Repaint;

//  DrawingBuffer.DrawTo(pb.Canvas.Handle, pb.Canvas.ClipRect, DrawingBuffer.ClipRect);

  LastStatusUpdate := now;
  Application.ProcessMessages
end;

procedure TfrmMain.pbDblClick(Sender: TObject);
begin
  Freeze
end;

procedure TfrmMain.pbMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then
  begin
    Shader.iMouse.z := (X / pb.Width) * DrawingBuffer.Width;
    Shader.iMouse.w := ((pb.Height - Y) / pb.Height) * DrawingBuffer.Height;
  end;
end;

procedure TfrmMain.pbMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if not Assigned(Shader) then
    exit;

  if ssLeft in Shift then
  begin
    Shader.iMouse.X := (X / pb.Width) * DrawingBuffer.Width;
    Shader.iMouse.Y := ((pb.Height - Y) / pb.Height) * DrawingBuffer.Height;
  end;
  Shader.Mouse.X := (X / pb.Width);
  Shader.Mouse.Y := (1 - (Y / pb.Height));

end;

procedure TfrmMain.pbMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if ssLeft in Shift then
  begin
    Shader.iMouse.z := -System.Abs(Shader.iMouse.z);
    Shader.iMouse.w := -System.Abs(Shader.iMouse.w);
  end;
end;

// var LastChange:TDateTime;
procedure TfrmMain.UpdateShader;
var Ratio:Double;
begin
  StatusBar1.Panels[0].Text := format('%d x %d', [q, q]);
  if (DrawingBuffer.Width = q) and (DrawingBuffer.Height = q) then
    exit;

  // if MilliSecondsBetween(now,LastChange)>100 then
  // begin
  Ratio := q / DrawingBuffer.Width;
  Shader.iMouse := Shader.iMouse * Ratio;

  DrawingBuffer.SetSize(q, q);
  Shader.SetSize(DrawingBuffer.Width, DrawingBuffer.Height);
  // LastChange := now;
  // end;
end;

procedure TfrmMain.pbPaintBuffer(Sender: TObject);
var
  fps    : Double;
  fpsText: String;
  r,r2:TRect;
begin

//  pb.Buffer.Canvas.Brush.Style := bsClear;
//  pb.Buffer.Canvas.Font.Size   := 16;
//  pb.Buffer.Canvas.Font.Color  := clRed;


  if Shader = nil then
    exit;

  DrawingBuffer.DrawTo(pb.Buffer, pb.ClientRect);

  if not Timer1.Enabled  then
  begin
    // src
    r := Shader.Image.Bitmap.ClipRect;
    r.Bottom := round(Shader.Image.Bitmap.Height*(Progressbar1.Position/ProgressBar1.Max));

    // dst
    r2 := pb.ClientRect;
    r2.Bottom := round(pb.Height*(Progressbar1.Position/ProgressBar1.Max));

    pb.Buffer.Draw(r2,r,Shader.Image.Bitmap);

//    Shader.Image.Bitmap.DrawTo(pb.Buffer,r2,r);
  end;

  pb.Buffer.HorzLineS( 0, round(pb.Height*(Progressbar1.Position/ProgressBar1.Max)) , pb.Width-1, setAlpha(clWhite32, 127));

  fps := Shader.fps;
  if fps > 10 then
    fpsText := IntToStr(Round(fps)) + ' FPS'
  else if fps > 1 then
    fpsText := FormatFloat('0.00', fps) + ' FPS'
  else
    fpsText := FormatFloat('0.000', fps) + ' FPS';

  // pb.Buffer.Canvas.TextOut(10,10, fpsText )
  StatusBar1.Panels[1].Text := fpsText;
end;

procedure TfrmMain.scrQualityChange(Sender: TObject);
begin
  //
end;

procedure TfrmMain.StatusBar1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
begin
  with StatusBar.Canvas do
  begin
    Brush.Color := clRed;
    FillRect(Rect);
    TextOut(Rect.Left, Rect.Top, 'Panel ' + IntToStr(Panel.Index));
  end;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
const
  GROW_SPEED         = 1.1;
  SHRINK_SPEED       = 1.1;
  MIN_RESOLUTION     = 32;
  MAX_MAX_RESOLUTION = 800;
var
  MaxResolution: Integer;

begin
  if Shader = nil then
    exit;

  MaxResolution := min(min(MAX_MAX_RESOLUTION, pb.Width), pb.Height);

  if Shader.fps < scrQuality.Position - 5 then
  begin
    q := (q + min(MaxResolution, Max(MIN_RESOLUTION, Round(q / SHRINK_SPEED)))) div 2;
    UpdateShader;
  end
  else if Shader.fps > scrQuality.Position + 5 then
  begin
    q := (q + min(MaxResolution, Max(MIN_RESOLUTION, Round(q * GROW_SPEED)))) div 2;
    UpdateShader;
  end;
  Shader.ResetFPS;

  Shader.SetTimeToSystemClock;
  Shader.Render;
  Shader.Image.Bitmap.DrawTo(DrawingBuffer);

  ListView1.Selected.Update;

  pb.Repaint;
end;

procedure TfrmMain.Edit1Change(Sender: TObject);
begin
  FilterShaderList;
end;

type TShaderPair=TPair<string, TShader>;

procedure TfrmMain.Button1Click(Sender: TObject);
begin
  RenderFiles(self);
end;

procedure TfrmMain.CreateAllThumbnails;
var
  ShaderPair: TShaderPair;
  n:integer;
begin
  ListView1.Items.Clear;
  ProgressBar1.Max := Shaders.Count;
  ProgressBar1.Position := 0;

  ThumbnailShaders := TShaderList.Create;
  for n := 0 to Shaders.Count-1 do
    ThumbnailsLarge.Add(nil,nil);

  for ShaderPair in Shaders do
    ThumbnailShaders.Add(ShaderPair.Key, ShaderPair.Value.Create);

  TThread.CreateAnonymousThread(
    procedure
    var
      b: TBitmap32;
      s: TPair<string, TShader>;
      li: TListItem;
    begin
      // create a copy of the main shaderlist, so that we can calculate
      // thumbnails in a separate thread
   //   sleep(200);

      b := TBitmap32.Create;
      try
        b.ResamplerClassName := 'TLinearResampler';
        b.SetSize(THUMBNAIL_SIZE, THUMBNAIL_SIZE);

        for s in ThumbnailShaders do
        begin
          TThread.Synchronize(TThread.CurrentThread,
            procedure
            begin
              li := ListView1.Items.Add;
//              li.Data := s.Value;
            end);

          with li do
          begin
            TThread.Synchronize(TThread.CurrentThread,
              procedure
              begin
                Caption := s.Key;
                s.Value.SetSize(b.Width, b.Height);
                s.Value.iGlobalTime := 200000;
                s.Value.Time := s.Value.iGlobalTime;
              end);

            s.Value.Render;
            s.Value.Image.Bitmap.DrawTo(b);


            TThread.Synchronize(TThread.CurrentThread,
              procedure
              var
                bmp: TBitmap;
              begin
                bmp := TBitmap.Create;
                bmp.SetSize(ThumbnailsLarge.Width, ThumbnailsLarge.Height);
                b.DrawTo(bmp.Canvas.Handle, bmp.Canvas.ClipRect, b.ClipRect);
                ThumbnailsLarge.Replace(s.Value.ThumbnailIndex, bmp, nil );
                s.Value.Time := 0;
                s.Value.iGlobalTime := 0;
                // ThumbnailsLarge.Add(bmp, nil);
                //ImageIndex := ListView1.Items.Count - 1;
                FilterShaderList;
                ProgressBar1.Position := ProgressBar1.Position + 1;
                if Progressbar1.Position >= ProgressBar1.Max then
                  Progressbar1.Hide;

              end);
          end;
          TThread.Synchronize(TThread.CurrentThread,
            procedure begin
              FilterShaderList;
            end);
        end;
      finally
        b.Free;
      end;
    end).Start;
end;

procedure TfrmMain.FilterShaderList;
type
  TP = System.Generics.Collections.TPair<string, TShader>;
var
  index: Integer;
  ShadersAr:TArray<TP>;
  p: TP;
begin
  VisibleShaders.Clear;
  Index := 0;
  ShadersAr := Shaders.ToArray;

  {
  TArray.Sort<TP>(ShadersAr,
    TComparer<TP>.Construct(
    function (const L,R:TP):Integer
    begin
      Result := CompareValue(L.Value.PixelsPerSecond,R.Value.PixelsPerSecond);
    end
   ));
}

  for p in ShadersAr do
  begin
    if (trim(Edit1.Text) = '') or (p.Key.ToLower.Contains(string(Edit1.Text).ToLower)) then
    begin
      p.Value.ThumbnailIndex := index;
      VisibleShaders.Add(p.Value);
    end;
    inc(Index);
  end;
  ListView1.Items.Count := VisibleShaders.Count;
  ListView1.Refresh;
end;

procedure TfrmMain.Freeze;
var bmp:TBitmap32;
begin
  if Shader=nil then
    exit;

  if Timer1.Enabled = False then
  begin
    q := 32;
    Shader.OnProgress := nil;
    UpdateShader;
    Timer1.Enabled := True
  end
  else
  begin
    Timer1.Enabled := False;
    q := pb.Width {* 2};
    bmp := TBitmap32.Create;
    bmp.Assign(DrawingBuffer);
    Shader.OnProgress := OnProgressShowOnImage;
    UpdateShader;
    bmp.DrawTo( DrawingBuffer, DrawingBuffer.ClipRect, bmp.ClipRect );
//    Shader.RenderToBlocks(DrawingBuffer);
    Shader.Render;
    Shader.Image.Bitmap.DrawTo(DrawingBuffer);
    pb.Repaint;
    bmp.Free;
  end;
end;


end.
