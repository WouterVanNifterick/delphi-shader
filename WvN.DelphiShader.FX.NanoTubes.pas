unit WvN.DelphiShader.FX.NanoTubes;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TNanoTubes = class(TShader)
  const
    MAX_MARCH    = 100;
    MAX_DISTANCE = 100;
    RADIUS       = 0.25;
    vec3_1: vec3 = (x: 0; y: 0; z: 0);
    vec3_2: vec3 = (x: 0; y: 1; z: 0);
    vec3_3: vec3 = (x: 0.025; y: 0.025; z: 0.02);

  var
    camPos, camTarget, camDir, camUp, camSide: vec3;
    focus                                    : float;
    r                                        : vec3;

    function rand(n: vec3): float;
    function map(p: vec3): vec2;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  NanoTubes: TShader;

implementation

uses SysUtils, Math;

constructor TNanoTubes.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TNanoTubes.PrepareFrame;
var t:double;
begin
  t := iGlobalTime * 0.3;
  camPos    := vec3.Create(cosLarge(t),
                           sinLarge(t), 3.5);
  camTarget := vec3_1;

  camDir  := normalize(camTarget - camPos);
  camUp   := normalize(vec3_2);
  camSide := cross(camDir, camUp);
  focus   := 1.8;
  r.x     := 0;
  r.y     := 0;
  r.z     := iGlobalTime / 2;
end;

// With tweaks from fernlightning
function TNanoTubes.rand(n: vec3): float;
begin
  n := floor(n);
  Exit(fract(sinLarge((n.x + n.y * 1E2 + n.z * 1E4) * 1E-4) * 1E5));
end;

// .x is distance, .y = colour
function TNanoTubes.map(p: vec3): vec2;
var
  f : vec3;
  d : float;
  cr: float;
  cd: float;
  rr: float;
  rn: float;
  rm: float;
  rd: float;
begin
  // cylinder
  f  := fract(p) - 0.5;
  d  := length(f.xy);
  cr := rand(p);
  cd := d - cr * RADIUS;

  // end - calc (rand) radius at more stable pos
  p.z := p.z - 0.5;
  rr  := rand(p);
  rn  := d - rr * RADIUS;
  rm  := System.abs(fract(p.z) - 0.5); // offset so at end of cylinder

  rd := system.sqrt(rn * rn + rm * rm); // end with ring

  if cd < rd then
  begin
    Result.x := cd;
    Result.y := cr;
  end
  else
  begin
    Result.x := rd;
    Result.y := rr;
  end;

end;

function TNanoTubes.Main(var gl_FragCoord: vec2): TColor32;
var
  pos         : vec2;
  rayDir, ray : vec3;
  m           : float;
  d           : vec2;
  total_d     : float;
  i           : integer;
  c           : float;
begin
  pos := (gl_FragCoord.xy * 2 - resolution.xy) / resolution.y;

  rayDir := normalize(camSide * pos.x + camUp * pos.y + camDir * focus);
  ray    := camPos;
  m      := 0.32;
  total_d      := 0;

  for i := 0 to MAX_MARCH - 1 do
  begin
    d       := map(ray - r);
    total_d := total_d + (d.x);
    ray     := ray + (rayDir * d.x);
    m       := m + 1;
    if System.abs(d.x) < 0.01 then
      break;

    if total_d > MAX_DISTANCE then
    begin
      total_d := MAX_DISTANCE;
      break;
    end;
  end;

  c      := total_d * 0.0001;
  Result := TColor32((1 - c - vec3_3 * (m * 0.8)) * d.y);
end;

initialization

NanoTubes := TNanoTubes.Create;
Shaders.Add('NanoTubes', NanoTubes);

finalization

FreeandNil(NanoTubes);

end.
