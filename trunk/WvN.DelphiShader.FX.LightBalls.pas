unit WvN.DelphiShader.FX.LightBalls;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type

  // fuck that shit

  // By @paulofalcao
  //
  // Blobs

  TLightBalls = class(TShader)
    res: Vec2;
    points:array[0..27] of record fx,fy:double; end;
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
    function makePoint(index:integer;x, y:float): float; inline;
  end;

var
  LightBalls: TShader;

implementation

uses SysUtils, Math;

constructor TLightBalls.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TLightBalls.PrepareFrame;
begin
  res := Vec2.Create(1.0, resolution.y / resolution.x);

  points[ 0].fx := system.sin(time * 3.3)* 0.3 * 0.3;     points[ 0].fy := system.cos(time * 2.9)* 0.3;
  points[ 1].fx := system.sin(time * 1.9)* 0.4 * 0.4;     points[ 1].fy := system.cos(time * 2.0)* 0.4;
  points[ 2].fx := system.sin(time * 0.8)* 0.4 * 0.4;     points[ 2].fy := system.cos(time * 0.7)* 0.5;
  points[ 3].fx := system.sin(time * 2.3)* 0.6 * 0.6;     points[ 3].fy := system.cos(time * 0.1)* 0.3;
  points[ 4].fx := system.sin(time * 0.8)* 0.5 * 0.5;     points[ 4].fy := system.cos(time * 1.7)* 0.4;
  points[ 5].fx := system.sin(time * 0.3)* 0.4 * 0.4;     points[ 5].fy := system.cos(time * 1.0)* 0.4;
  points[ 6].fx := system.sin(time * 1.4)* 0.4 * 0.4;     points[ 6].fy := system.cos(time * 1.7)* 0.5;
  points[ 7].fx := system.sin(time * 1.3)* 0.6 * 0.6;     points[ 7].fy := system.cos(time * 2.1)* 0.3;
  points[ 8].fx := system.sin(time * 1.8)* 0.5 * 0.5;     points[ 8].fy := system.cos(time * 1.7)* 0.4;

  points[ 9].fx := system.sin(time * 1.2)* 0.3 * 0.3;     points[ 9].fy := system.cos(time * 1.9)* 0.3;
  points[10].fx := system.sin(time * 0.7)* 0.4 * 0.4;     points[10].fy := system.cos(time * 2.7)* 0.4;
  points[11].fx := system.sin(time * 1.4)* 0.4 * 0.4;     points[11].fy := system.cos(time * 0.6)* 0.5;
  points[12].fx := system.sin(time * 2.6)* 0.6 * 0.6;     points[12].fy := system.cos(time * 0.4)* 0.3;
  points[13].fx := system.sin(time * 0.7)* 0.5 * 0.5;     points[13].fy := system.cos(time * 1.4)* 0.4;
  points[14].fx := system.sin(time * 0.7)* 0.4 * 0.4;     points[14].fy := system.cos(time * 1.7)* 0.4;
  points[15].fx := system.sin(time * 0.8)* 0.4 * 0.4;     points[15].fy := system.cos(time * 0.5)* 0.5;
  points[16].fx := system.sin(time * 1.4)* 0.6 * 0.6;     points[16].fy := system.cos(time * 0.9)* 0.3;
  points[17].fx := system.sin(time * 0.7)* 0.5 * 0.5;     points[17].fy := system.cos(time * 1.3)* 0.4;

  points[18].fx := system.sin(time * 3.7)* 0.3 * 0.3;     points[18].fy := system.cos(time * 0.3)* 0.3;
  points[19].fx := system.sin(time * 1.9)* 0.4 * 0.4;     points[19].fy := system.cos(time * 1.3)* 0.4;
  points[20].fx := system.sin(time * 0.8)* 0.4 * 0.4;     points[20].fy := system.cos(time * 0.9)* 0.5;
  points[21].fx := system.sin(time * 1.2)* 0.6 * 0.6;     points[21].fy := system.cos(time * 1.7)* 0.3;
  points[22].fx := system.sin(time * 0.3)* 0.5 * 0.5;     points[22].fy := system.cos(time * 0.6)* 0.4;
  points[23].fx := system.sin(time * 0.3)* 0.4 * 0.4;     points[23].fy := system.cos(time * 0.3)* 0.4;
  points[24].fx := system.sin(time * 1.4)* 0.4 * 0.4;     points[24].fy := system.cos(time * 0.8)* 0.5;
  points[25].fx := system.sin(time * 0.2)* 0.6 * 0.6;     points[25].fy := system.cos(time * 0.6)* 0.3;
  points[26].fx := system.sin(time * 1.3)* 0.5 * 0.5;     points[26].fy := system.cos(time * 0.5)* 0.4;

end;

function TLightBalls.MakePoint(index:integer;x, y: float): float;
var
  xx, yy: float;
begin
  xx := x + points[index].fx;
  yy := y + points[index].fy;
  Exit(0.750 / system.sqrt(xx * xx + yy * yy));
end;

function TLightBalls.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  p  : Vec2;
  x  : float;
  y  : float;
  a  : float;
  b  : float;
  c  : float;
  d  : vec3;
  col: vec3;
begin
  p := (gl_FragCoord.xy / resolution.x)+0.5 - res;
  x := p.x * 1.5;
  y := p.y * 1.5;

  a := makePoint( 0, x, y)
     + makePoint( 1, x, y)
     + makePoint( 2, x, y)
     + makePoint( 3, x, y)
     + makePoint( 4, x, y)
     + makePoint( 5, x, y)
     + makePoint( 6, x, y)
     + makePoint( 7, x, y)
     + makePoint( 8, x, y);

  b := makePoint( 9, x, y)
     + makePoint(10, x, y)
     + makePoint(11, x, y)
     + makePoint(12, x, y)
     + makePoint(13, x, y)
     + makePoint(14, x, y)
     + makePoint(15, x, y)
     + makePoint(16, x, y)
     + makePoint(17, x, y);

  c := makePoint(18, x, y)
     + makePoint(19, x, y)
     + makePoint(20, x, y)
     + makePoint(21, x, y)
     + makePoint(22, x, y)
     + makePoint(23, x, y)
     + makePoint(24, x, y)
     + makePoint(25, x, y)
     + makePoint(26, x, y);

  d := vec3.Create(a * 1.5, b * 0.5, c * 5.0) / 128.0;

  col.x := d.x * d.x * d.x / d.y;
  col.y := 100*d.y * d.y * d.x / d.z ;//d.y
  col.z := d.z *d .z * d.z / d.x * d.y;

//  col.x := col.x * (&mod(gl_FragCoord.y, 2.0) * 4.4);
//  col.y := col.y * (&mod(gl_FragCoord.y + 1.0, 2.0) * 7.4);

  Result := TColor32(col);
end;

initialization

LightBalls := TLightBalls.Create;
Shaders.Add('LightBalls', LightBalls);

finalization

FreeandNil(LightBalls);

end.
