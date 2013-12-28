unit WvN.DelphiShader.FX.PlasmaGroovy;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TPlasmaGroovy = class(TShader)
  const
    vec3_1: Vec3 = (x: 1; y: 0; z: 0);
    vec3_2: Vec3 = (x: 1; y: 1; z: 0);
    num    = 4;

  var
    pi    : float;
    color1: Vec3;
    color2: Vec3;
    scale : float;
    pos   : vec2;
    ls    : float;
    sz    : vec2;
    y    : float;
    ar:array of Vec2;
    function wave2(const pos: vec2; i: int): float;inline;
    constructor Create; override;
    procedure PrepareFrame;
    procedure PrepareLine(aY:integer);inline;
    function RenderPixel(var gl_FragCoord: vec2): TColor32;
  end;

var
  PlasmaGroovy: TShader;

implementation

uses SysUtils, Math;

constructor TPlasmaGroovy.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
  LineProc := PrepareLine;

  setlength(ar,num);
end;

procedure TPlasmaGroovy.PrepareFrame;
var i :integer;
begin
  color1 := vec3_1;
  color2 := vec3_2;
  scale  := 1.0;
  ls     := length(resolution);
  sz     := resolution * 0.5;
  for I := 0 to High(ar) do
  begin
    ar[I].x := Resolution.x * 0.4 * system.cos(0.0737 * time * (i + 1 + 0.34) + i);
    ar[I].y := Resolution.y * 0.4 * system.sin(0.0876 * time * (i + 1 + 0.56) + i);
  end;

end;

function TPlasmaGroovy.wave2(const pos: vec2; i: int): float;
var
  me    : vec2;
  diff  : vec2;
  angle2: float;
  dist  : float;
begin
  me     := ar[i];
  diff   := pos - me;
  angle2 := atan(diff.y, diff.x);
  dist   := length(diff);
  Result := (3.0 + i * 2) * angle2 + 20.0 * system.sin(6.0 * dist / ls) * system.sin(0.5 * time + ((i + 3) * 2.34)) + time;
end;

procedure TPlasmaGroovy.PrepareLine(aY: Integer);
begin
  y := aY / resolution.y;
end;

function TPlasmaGroovy.RenderPixel(var gl_FragCoord: vec2): TColor32;
var
  amp  : float;
  i    : integer;
  c    : float;
  color: Vec3;
begin
  pos := gl_FragCoord.xy / scale - sz;

  amp   := 0.0;
  for i := 0 to num - 1 do
    amp := amp + (wave2(pos, i));

  c      := pow(clamp(system.sin(amp)), 0.2);
  color  := color1 + (color2 - color1) * clamp((c + y) * 0.6);
  Result := TColor32(color);
end;

initialization

PlasmaGroovy := TPlasmaGroovy.Create;
Shaders.Add('PlasmaGroovy', PlasmaGroovy);

finalization

FreeandNil(PlasmaGroovy);

end.
