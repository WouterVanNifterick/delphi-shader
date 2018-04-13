unit WvN.DelphiShader.FX.FractalBlub;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TFractalBlub = class(TShader)
  const
    vec3_1: vec3 = (x: 0; y: 0; z: 0);
    vec3_2: vec3 = (x: 0; y: 1; z: 0);
    vec3_3: vec3 = (x: 0.025; y: 0.025; z: 0.02);

  var
    camPos   : vec3;
    camTarget: vec3;
    camDir   : vec3;
    camUp    : vec3;
    camSide  : vec3;
    focus    : float;

    function map(const p: vec3): float;
    function Main(var gl_FragCoord: Vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  FractalBlub: TShader;

implementation

uses SysUtils, Math;

constructor TFractalBlub.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TFractalBlub.PrepareFrame;
begin
  camPos    := vec3.Create(system.cos(time * 0.2), system.sin(time * 0.2), 2.5);
  camTarget := vec3_1;

  camDir  := normalize(camTarget - camPos);
  camUp   := normalize(vec3_2);
  camSide := cross(camDir, camUp);
  focus   := 1.8;
end;

function TFractalBlub.map(const p: vec3): float;
var
  MAX_ITER: int;
  BAILOUT : float;
  Power   : float;
  v       : vec3;
  c       : vec3;
  r       : float;
  d       : float;
  n       : integer; // loop variable
  theta   : float;
  phi     : float;
  zr      : float;

begin
  MAX_ITER := 10;
  BAILOUT  := 4;
  Power    := 8;

  v := p;
  c := v;

  r     := 0;
  d     := 1;
  for n := 0 to MAX_ITER - 1 do
  begin
    r := length(v);
    if r > BAILOUT then
      break;

    theta := acos(v.z / r);
    phi   := atan(v.y, v.x);
    d     := pow(r, Power - 1) * Power * d + 1;

    zr    := pow(r, Power);
    theta := theta * Power;
    phi   := phi * Power;
    v     := (vec3.Create(system.sin(theta) * system.cos(phi), system.sin(phi) * system.sin(theta), system.cos(theta)) * zr) + c;
  end;

  Exit(0.5 * log(r) * r / d);
end;

function TFractalBlub.Main(var gl_FragCoord: Vec2): TColor32;
var
  pos       : Vec2;
  rayDir    : vec3;
  ray       : vec3;
  m         : float;
  d, total_d: float;
  i         : integer;
  c         : float;
const
  MAX_MARCH    = 150;
  MAX_DISTANCE = 1000;

begin
  pos     := (gl_FragCoord.xy * 2.1 - resolution.xy) / resolution.y;
  rayDir  := normalize(camSide * pos.x + camUp * pos.y + camDir * focus);
  ray     := camPos;
  m       := 0;
  total_d := 0;
  for i   := 0 to MAX_MARCH - 1 do
  begin
    d       := map(ray);
    total_d := total_d + (d);
    ray     := ray + (rayDir * d);
    m       := m + (1);
    if d < 0.001 then
      break;

    if total_d > MAX_DISTANCE then
    begin
      total_d := MAX_DISTANCE;
      break;
    end;

  end;

  c      := total_d * 0.0001;
  result := TColor32(1 - vec3.Create(c, c, c) - vec3_3 * m * 0.8);
end;

initialization

FractalBlub := TFractalBlub.Create;
Shaders.Add('FractalBlub', FractalBlub);

finalization

FreeandNil(FractalBlub);

end.
