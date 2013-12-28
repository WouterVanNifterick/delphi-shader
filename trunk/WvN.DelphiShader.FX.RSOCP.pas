unit WvN.DelphiShader.FX.RSOCP;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  Ray = record
    Origin: vec3;
    Direction: vec3;
  end;

  Intersection = record
    Intersected: bool;
    Intersection: vec3;
    Normal: vec3;
  end;

  Material = record
    Colour: vec3;
    Reflection: float;
    Specular: float;
    Sharpness: float;
  end;

  TRSOCP = class(TShader)
  const
    AMBIENT           = 0.01;
    GAMMA             = (1.0 / 2.2);
    TINY_AMOUNT       = 0.001;
    MAX_TRACE_DEPTH   = 6;
    FOCUS_DISTANCE    = 4.0;
    APERTURE          = 0.05;
    SAMPLES_PER_PIXEL = 2;

    vec3_1: vec3  = (x: 70; y: 70; z: 70);
    vec3_2: vec3  = (x: 0; y: 1; z: - 4);
    vec3_3: vec3  = (x: 0; y: 1; z: 0);
    vec3_4: vec3  = (x: 0; y: 1; z: 0);
    vec3_5: vec3  = (x: 0.4; y: 0.4; z: 0.4);
    vec3_6: vec3  = (x: 0.02; y: 0.02; z: 0.02);
    vec3_7: vec3  = (x: 0.01; y: 0.01; z: 0.1);
    vec3_8: vec3  = (x: 1.5; y: 0.4; z: 0);
    vec3_9: vec3  = (x: 0.1; y: 0.01; z: 0.01);
    vec3_10: vec3 = (x: 0; y: 0.4; z: 1.5);
    vec3_11: vec3 = (x: 0.01; y: 0.1; z: 0.01);
    vec3_12: vec3 = (x: - 1.5; y: 0.4; z: 0);
    vec3_13: vec3 = (x: 0.1; y: 0.1; z: 0.01);
    vec3_14: vec3 = (x: 0; y: 0.4; z: - 1.5);
    vec3_15: vec3 = (x: 0.1; y: 0.01; z: 0.1);
    vec4_16: vec4 = (x: 0; y: 0; z: 0; w: 0);
    vec2_17: vec2 = (x: 0.5; y: 0.5);
    vec4_18: vec4 = (x: 0; y: 0; z: 0; w: 0);
    vec4_19: vec4 = (x: 0; y: 0; z: 0; w: 0);
    vec4_20: vec4 = (x: - 1000; y: - 1000; z: - 1000; w: - 1000);

    function Rand(n: float): float;
    function RotateY(v: vec3; a: float): vec3;
    function CreatePrimaryRay2(t: float; const screen: vec2; n: int): Ray;
    function TracePlane(const r: Ray; var iSec: Intersection; const Normal: vec3; distance: float): float;
    function TraceSphere(r: Ray; var iSec: Intersection; const centre: vec3; radius: float): float;
    procedure Trace(const r: Ray; out iSec: Intersection; out m: Material);
    function CalcColour(const r: Ray; const iSec: Intersection; const m: Material): vec4;
    function TracePixel(Ray: Ray): vec4;
    function Main(var gl_FragCoord: vec2): TColor32;

  var
    LightPos: vec3;
    LightCol: vec3;
    Pixel   : vec2;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  RSOCP: TShader;

implementation

uses SysUtils, Math;

constructor TRSOCP.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TRSOCP.PrepareFrame;
begin
  LightPos := vec3.Create(5, 3, 2);
  LightCol := vec3_1;

  Pixel := vec2.Create(1 / resolution.x, 1 / resolution.y);

end;

function TRSOCP.Rand(n: float): float;
begin
  Exit(fract(system.sin(n) * 43758.5453123));
end;

function TRSOCP.RotateY(v: vec3; a: float): vec3;
var
  ca, sa: double;
begin
  ca       := system.Cos(a);
  sa       := system.sin(a);
  Result.x := v.x * ca - v.z * sa;
  Result.y := v.y;
  Result.z := v.x * sa + v.z * ca;
end;

function TRSOCP.CreatePrimaryRay2(t: float; const screen: vec2; n: int): Ray;
var
  r   : Ray;
  cYaw: float;
  a   : vec3;
  B   : vec3;

begin

  cYaw        := t * 0.25;
  r.Origin    := vec3_2;
  r.Direction := normalize(vec3.Create(screen.x, screen.y, 1));

  a := r.Origin;
  B := r.Origin + r.Direction * FOCUS_DISTANCE;

  a := a + APERTURE * vec3.Create(Rand(n + screen.x) - 0.5, Rand(n + screen.y) - 0.5, 0.0);

  r.Origin    := RotateY(a, cYaw);
  r.Direction := RotateY(normalize(B - a), cYaw);

  Exit(r);
end;

function TRSOCP.TracePlane(const r: Ray; var iSec: Intersection; const Normal: vec3; distance: float): float;
var
  d: float;
begin
  iSec.Intersected := false;

  if r.Direction.y = 0 then
    d := 0
  else
    d := -r.Origin.y / r.Direction.y;
  if d > 0 then
  begin
    iSec.Intersected  := true;
    iSec.Intersection := r.Origin + d * r.Direction;
    iSec.Normal       := vec3_3;
  end;

  Exit(d);
end;

function TRSOCP.TraceSphere(r: Ray; var iSec: Intersection; const centre: vec3; radius: float): float;
var
  t0, t1  : float;
  a       : float;
  B       : float;
  c       : float;
  disc    : float;
  distSqrt: float;
  q       : float;
  temp    : float;
begin
  iSec.Intersected := false;
  r.Origin         := r.Origin - centre;
  a                := dot(r.Direction, r.Direction);
  B                := 2 * dot(r.Direction, r.Origin);
  c                := dot(r.Origin, r.Origin) - (radius * radius);
  disc             := B * B - 4 * a * c;
  if disc < 0 then
    Exit(-1);
  distSqrt := system.sqrt(disc);

  if B < 0 then
    q := (-B - distSqrt) / 2
  else
    q := (-B + distSqrt) / 2;
  t0  := q / a;
  t1  := c / q;
  if t0 > t1 then
  begin
    temp := t0;
    t0   := t1;
    t1   := temp;
  end;

  if t1 < 0 then
    Exit(t0);

  iSec.Intersected  := true;
  iSec.Intersection := r.Origin + t0 * r.Direction + centre;
  iSec.Normal       := normalize(r.Origin + t0 * r.Direction);
  Exit(t0);
end;

procedure TRSOCP.Trace(const r: Ray; out iSec: Intersection; out m: Material);

var
  d, Dmin: float;
  iTemp  : Intersection;
  q      : float;
  a      : float;

begin
  iSec.Intersected := false;

  Dmin := 1e6;

  d := TracePlane(r, iTemp, vec3_4, 0);
  if iTemp.Intersected and (d < Dmin) then
  begin
    Dmin := d;
    q    := system.sin(iGlobalTime * 0.1) * 0.5;
    if ((fract(iTemp.Intersection.x) + q < 0.5) and (fract(iTemp.Intersection.z) + q < 0.5)) or ((fract(iTemp.Intersection.x) + q >= 0.5) and (fract(iTemp.Intersection.z) + q >= 0.5)) then
      m.Colour := vec3_5
    else
      m.Colour := vec3_6;

    m.Reflection := 0.2;
    m.Specular   := 0.3;
    m.Sharpness  := 2;
    iSec         := iTemp;
  end;

  d := TraceSphere(r, iTemp, vec3.Create(0, 1 + 0.4 * system.sin(iGlobalTime), 0), 0.6);
  if iTemp.Intersected and (d < Dmin) then
  begin
    Dmin         := d;
    m.Colour     := vec3_7;
    m.Reflection := 0.6;
    m.Specular   := 0.6;
    m.Sharpness  := 50;
    iSec         := iTemp;
    iSec.Normal  := iSec.Normal + (vec3.Create(Rand(iSec.Intersection.x), Rand(iSec.Intersection.y), Rand(iSec.Intersection.z)) * 0.1 - 0.05);
    iSec.Normal  := normalize(iSec.Normal);
  end;

  d := TraceSphere(r, iTemp, vec3_8, 0.4);
  if iTemp.Intersected and (d < Dmin) then
  begin
    Dmin         := d;
    m.Colour     := vec3_9;
    m.Reflection := 0.6;
    m.Specular   := 0.6;
    m.Sharpness  := 50;
    iSec         := iTemp;
    iSec.Normal  := iSec.Normal + (vec3.Create(0, system.sin(iSec.Intersection.y * 150 + 10 * iGlobalTime), 0) * 0.05 - 0.025);
    iSec.Normal  := normalize(iSec.Normal);
  end;

  d := TraceSphere(r, iTemp, vec3_10, 0.4);
  if iTemp.Intersected and (d < Dmin) then
  begin
    Dmin         := d;
    m.Colour     := vec3_11;
    m.Reflection := 0.6;
    m.Specular   := 0.6;
    m.Sharpness  := 50;
    iSec         := iTemp;
  end;

  d := TraceSphere(r, iTemp, vec3_12, 0.4);
  if iTemp.Intersected and (d < Dmin) then
  begin
    Dmin         := d;
    m.Colour     := vec3_13;
    m.Reflection := 0.6;
    m.Specular   := 0.6;
    m.Sharpness  := 50;
    iSec         := iTemp;
    iSec.Normal  := iSec.Normal + (vec3.Create(system.sin(iSec.Intersection.x * 150), 0, system.Cos(iSec.Intersection.y * 150)) * 0.05 - 0.025);
    iSec.Normal  := normalize(iSec.Normal);
  end;

  d := TraceSphere(r, iTemp, vec3_14, 0.4);
  if iTemp.Intersected and (d < Dmin) then
  begin
    Dmin         := d;
    m.Colour     := vec3_15;
    m.Reflection := 0.6;
    m.Specular   := 0.6;
    m.Sharpness  := 50;
    iSec         := iTemp;
  end;

  a := iGlobalTime * 2;
  d := TraceSphere(r, iTemp, vec3.Create(2 * system.Cos(a), 0.2, 2 * system.sin(a)), 0.2);
  if iTemp.Intersected and (d < Dmin) then
  begin
    m.Colour     := vec3.Create(system.sin(a), system.sin(a + 2.1), system.sin(a + 4.2)) * 0.1 + 0.3;
    m.Reflection := 0.1;
    m.Specular   := 0.6;
    m.Sharpness  := 50;
    iSec         := iTemp;
  end;

end;

function TRSOCP.CalcColour(const r: Ray; const iSec: Intersection; const m: Material): vec4;
var
  lDir   : vec3;
  c      : vec3;
  sr     : Ray;
  si     : Intersection;
  sm     : Material;
  lFactor: float;
  rDir   : vec3;

begin
  lDir := normalize(LightPos - iSec.Intersection);

  // Ambient
  c := m.Colour * AMBIENT;



  // Shadow ray

  sr.Origin    := iSec.Intersection + lDir * TINY_AMOUNT;
  sr.Direction := lDir;

  Trace(sr, si, sm);

  lFactor := 1 / pow(length(LightPos - iSec.Intersection), 2);

  if not si.Intersected then
  begin

    // diffuse
    c := c + (m.Colour * lFactor * LightCol * clamp(dot(iSec.Normal, lDir), 0, 1));

    // specular
    rDir := reflect(r.Direction, iSec.Normal);
    c    := c + (m.Specular * lFactor * LightCol * pow(clamp(dot(lDir, rDir), 0, 1), m.Sharpness));
  end;

  Exit(vec4(c));
end;

function TRSOCP.TracePixel(Ray: Ray): vec4;
var
  coefficient: float;
  col        : vec4;
  mat        : Material;
  iSec       : Intersection;
  i          : integer;

begin
  coefficient := 1;
  col         := vec4_16;

  for i := 0 to MAX_TRACE_DEPTH - 1 do
  begin
    Trace(Ray, iSec, mat);
    if iSec.Intersected then
      col := col + (coefficient * CalcColour(Ray, iSec, mat));

    if isNaN(mat.Reflection) then
      mat.Reflection := 0;

    coefficient := coefficient * (mat.Reflection);
    if (not iSec.Intersected) or (coefficient < 0.01) then
      break;
    Ray.Direction    := reflect(Ray.Direction, iSec.Normal);
    Ray.Origin       := iSec.Intersection + TINY_AMOUNT * Ray.Direction;
    iSec.Intersected := false;
  end;

  Exit(col);
end;

function TRSOCP.Main(var gl_FragCoord: vec2): TColor32;
var
  screen     : vec2;
  c          : vec4;
  avg, oldAvg: vec4;
  s          : integer;
  AAscreen   : vec2;
  primaryRay : Ray;

begin
  screen   := gl_FragCoord.xy / resolution.xy - vec2_17;
  screen.x := screen.x * (resolution.x / resolution.y);
  c        := vec4_18;
  avg      := vec4_19;
  oldAvg   := vec4_20;

  for s := 0 to SAMPLES_PER_PIXEL - 1 do
  begin
    AAscreen   := screen + 0.3 * Pixel * vec2.Create(Rand(s * 3.14 + screen.x), Rand(s) * 1.863 + screen.y);
    primaryRay := CreatePrimaryRay2(iGlobalTime, AAscreen, s);
    c          := c + TracePixel(primaryRay);
    avg        := c / (s + 1);

    if (s > 3) and (length(oldAvg - avg) < 0.02) then
      break;
    oldAvg := avg;
  end;

  Result := TColor32(pow(avg.xyz, vec3(GAMMA)));
end;

initialization

RSOCP := TRSOCP.Create;
Shaders.Add('RSOCP', RSOCP);

finalization

FreeandNil(RSOCP);

end.
