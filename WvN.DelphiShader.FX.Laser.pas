unit WvN.DelphiShader.FX.Laser;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TLaser = class(TShader)
    points:array[0..27] of record fx,fy:double; end;
    function makePoint(index:integer; x, y: float): float;
    function Main(var gl_FragCoord: Vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Laser: TShader;

implementation

uses SysUtils, Math;

constructor TLaser.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TLaser.PrepareFrame;
begin

  points[ 0].fx := system.sin(time * 3.3);     points[ 0].fy := system.cos(time * 2.9);
  points[ 1].fx := system.sin(time * 1.9);     points[ 1].fy := system.cos(time * 2.0);
  points[ 2].fx := system.sin(time * 0.8);     points[ 2].fy := system.cos(time * 0.7);
  points[ 3].fx := system.sin(time * 2.3);     points[ 3].fy := system.cos(time * 0.1);
  points[ 4].fx := system.sin(time * 0.8);     points[ 4].fy := system.cos(time * 1.7);
  points[ 5].fx := system.sin(time * 0.3);     points[ 5].fy := system.cos(time * 1.0);
  points[ 6].fx := system.sin(time * 1.4);     points[ 6].fy := system.cos(time * 1.7);
  points[ 7].fx := system.sin(time * 1.3);     points[ 7].fy := system.cos(time * 2.1);
  points[ 8].fx := system.sin(time * 1.8);     points[ 8].fy := system.cos(time * 1.7);

  points[ 9].fx := system.sin(time * 1.2);     points[ 9].fy := system.cos(time * 1.9);
  points[10].fx := system.sin(time * 0.7);     points[10].fy := system.cos(time * 2.7);
  points[11].fx := system.sin(time * 1.4);     points[11].fy := system.cos(time * 0.6);
  points[12].fx := system.sin(time * 2.6);     points[12].fy := system.cos(time * 0.9);
  points[13].fx := system.sin(time * 0.7);     points[13].fy := system.cos(time * 1.4);
  points[14].fx := system.sin(time * 0.7);     points[14].fy := system.cos(time * 1.7);
  points[15].fx := system.sin(time * 0.8);     points[15].fy := system.cos(time * 0.5);
  points[16].fx := system.sin(time * 1.4);     points[16].fy := system.cos(time * 0.7);
  points[17].fx := system.sin(time * 0.7);     points[17].fy := system.cos(time * 1.3);

  points[18].fx := system.sin(time * 3.7);     points[18].fy := system.cos(time * 0.3);
  points[19].fx := system.sin(time * 1.9);     points[19].fy := system.cos(time * 1.3);
  points[20].fx := system.sin(time * 0.8);     points[20].fy := system.cos(time * 0.9);
  points[21].fx := system.sin(time * 1.2);     points[21].fy := system.cos(time * 1.7);
  points[22].fx := system.sin(time * 0.3);     points[22].fy := system.cos(time * 0.6);
  points[23].fx := system.sin(time * 0.3);     points[23].fy := system.cos(time * 0.3);
  points[24].fx := system.sin(time * 1.4);     points[24].fy := system.cos(time * 0.8);
  points[25].fx := system.sin(time * 0.2);     points[25].fy := system.cos(time * 0.6);
  points[26].fx := system.sin(time * 1.3);     points[26].fy := system.cos(time * 0.5);

end;

// By @paulofalcao
//
// Blobs

function TLaser.makePoint(index:integer; x, y: float): float;
var
  xx: float;
  yy: float;
  q : double;
begin
  xx := x * points[index].fx;
  yy := y * points[index].fy;
  q  := system.sqrt(length(xx + yy) + length(xx * yy));
  if q = 0 then
    Result := 0
  else
    Exit(2 / q);
end;

function TLaser.Main;
var
  p: Vec2;
  x: float;
  y: float;
  a: float;
  b: float;
  c: float;
  d: vec3;

begin

  p := (gl_FragCoord.xy / resolution.x) * 2.0 - Vec2.Create(1.0, resolution.y / resolution.x);

  x := p.x;
  y := p.y;

  a :=     makePoint( 0,x, y)
         + makePoint( 1,x, y)
         + makePoint( 2,x, y)
         + makePoint( 3,x, y)
         + makePoint( 4,x, y)
         + makePoint( 5,x, y)
         + makePoint( 6,x, y)
         + makePoint( 7,x, y)
         + makePoint( 8,x, y);

  b :=     makePoint( 9,x, y)
         + makePoint(10,x, y)
         + makePoint(11,x, y)
         + makePoint(12,x, y)
         + makePoint(13,x, y)
         + makePoint(14,x, y)
         + makePoint(15,x, y)
         + makePoint(16,x, y)
         + makePoint(17,x, y);

  c :=     makePoint(18,x, y)
         + makePoint(19,x, y)
         + makePoint(20,x, y)
         + makePoint(21,x, y)
         + makePoint(22,x, y)
         + makePoint(23,x, y)
         + makePoint(24,x, y)
         + makePoint(25,x, y)
         + makePoint(26,x, y);

  d := vec3.Create(a, b, c) * 0.01;

  Result := TColor32(d);
end;

initialization

Laser := TLaser.Create;
Shaders.Add('Laser', Laser);

finalization

FreeandNil(Laser);

end.
