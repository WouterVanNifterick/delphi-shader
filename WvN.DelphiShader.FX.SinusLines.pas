unit WvN.DelphiShader.FX.SinusLines;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TSinusLines = class(TShader)
  const
    Lines = 10;
    L2    = 15;
    d     = 1/390; // set glow size
    thresh = d*4;
  var
    tmp: double;
    uposy:float;
    a:array of array of double;

    constructor Create; override;
    procedure PrepareFrame;
    procedure OnLine(y: Integer);
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  SinusLines: TShader;

implementation

uses SysUtils, Math;

constructor TSinusLines.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
  LineProc  := OnLine;
end;

procedure TSinusLines.OnLine(y: Integer);
begin
  uPosY := (y / resolution.y) - 0.5;
end;

procedure TSinusLines.PrepareFrame;
var w,x,line:integer;
begin
  w := round(Resolution.x);
  setlength(a,Lines, w);
  for line := 0 to Lines-1 do
    for x := 0 to w-1 do
    begin
      a[line,x] := sinLarge( (x/w) * (line + 1) + time + line * 0.2) * (1/Lines);
    end;
end;

function TSinusLines.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
//  uPos            : Vec2;
  color           : vec3;
  ftemp, vertColor: float;
  i               : Integer;
begin
  // uPos := (gl_FragCoord.xy / resolution.xy) - 0.5; // normalize wrt y axis
  // suPos -= vec2((resolution.x/resolution.y)/2.0, 0.0);//shift origin to center

//  uPosY := (gl_FragCoord.y / resolution.y) - 0.5;
  color     := vec3Black;
  vertColor := 0;
  for i     := 0 to Lines - 1 do
  begin
    // t := time * 0.9;
//    uPos.y    := uPos.y + sinLarge(uPos.x * (i + 1) + time + i * 0.2) * 0.1;
    uPosy    := uPosy + a[i, round(gl_FragCoord.x)];
    ftemp     := System.abs(d / uPosy);

    if fTemp>thresh then
    begin
      vertColor := vertColor + ftemp;

      color.x   := color.x + ftemp * (L2 - i) / Lines;
      color.y   := color.y + ftemp * i / Lines;
      color.z   := color.z + power(ftemp, 0.99) * 1.5;
    end;

  end;

  Result := TColor32(color);
end;

initialization

SinusLines := TSinusLines.Create;
Shaders.Add('SinusLines', SinusLines);

finalization

FreeandNil(SinusLines);

end.
