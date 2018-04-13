unit WvN.DelphiShader.FX.RaytraceSpheres;

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
    LightPos: vec3;
    LightCol: vec3;
  end;

  TRaytraceSpheres = class(TShader)
  const
    AMBIENT         = 0.01;
    GAMMA           = 1 / 2.2;
    TINY_AMOUNT     = 0.001;
    MAX_TRACE_DEPTH = 4;

    vec3_1: vec3  = (x: 0; y: 1; z: 0);
    vec3_2: vec3  = (x: 0; y: 1; z: 0);
    vec3_3: vec3  = (x: 0; y: 0.7; z: 0);
    vec3_4: vec3  = (x: 0.01; y: 0.01; z: 0.1);
    vec3_5: vec3  = (x: 1.5; y: 0.4; z: 0);
    vec3_6: vec3  = (x: 0.1; y: 0.01; z: 0.01);
    vec3_7: vec3  = (x: 0; y: 0.4; z: 1.5);
    vec3_8: vec3  = (x: 0.01; y: 0.1; z: 0.01);
    vec3_9: vec3  = (x: - 1.5; y: 0.4; z: 0);
    vec3_10: vec3 = (x: 0.1; y: 0.1; z: 0.01);
    vec3_11: vec3 = (x: 0; y: 0.4; z: - 1.5);
    vec3_12: vec3 = (x: 0.1; y: 0.01; z: 0.1);
    vec2_13: vec2 = (x: 0.5; y: 0.5);
  var
    cYaw, t, ca,sa: float;

    function CreatePrimaryRay(const screen: vec2): Ray;
    function TracePlane(const r: Ray; out iSec: Intersection; const Normal: vec3; distance: float): float;
    function TraceSphere(r: Ray; out iSec: Intersection; const centre: vec3; radius: float): float;
    procedure Trace(const r: Ray; out iSec: Intersection; out m: Material);
    function CalcColour(const r: Ray; const iSec: Intersection; const m: Material): vec4;
    function TracePixel(var Ray: Ray): vec4;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  RaytraceSpheres: TShader;

implementation

uses SysUtils, Math;

constructor TRaytraceSpheres.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TRaytraceSpheres.PrepareFrame;
begin
  t := iGlobalTime;
  cYaw         := t * 0.25;
  ca := cosLarge(cYaw);
  sa := sinLarge(cYaw);

end;

function TRaytraceSpheres.CreatePrimaryRay(const screen: vec2): Ray;
var
  cameraOrigin: vec3;
begin
  cameraOrigin.x := 3 * sa;
  cameraOrigin.y := 1;
  cameraOrigin.z := -3 * ca;

  result.Origin     := cameraOrigin;
  result.Direction.x  := screen.x;
  result.Direction.y  := screen.y;
  result.Direction.z  := 1;

  result.Direction.NormalizeSelf;

  result.Direction.x := result.Direction.x * ca
                      - result.Direction.z * sa;
  result.Direction.y := result.Direction.y;
  result.Direction.z := result.Direction.x * sa
                      + result.Direction.z * ca;
end;

function TRaytraceSpheres.TracePlane(const r: Ray; out iSec: Intersection; const Normal: vec3; distance: float): float;
var
  d: float;
begin
  iSec := default(Intersection);

  iSec.Intersected := false;
  if IsNan(r.Direction.y) then
    Exit(0);

  if r.Direction.y = 0 then
    Exit(0);

  d := -r.Origin.y / r.Direction.y;
  if d > 0 then
  begin
    iSec.Intersected  := true;
    iSec.Intersection := r.Origin + d * r.Direction;
    iSec.Normal       := vec3_1;
  end;

  Exit(d);
end;

function TRaytraceSpheres.TraceSphere(r: Ray; out iSec: Intersection; const centre: vec3; radius: float): float;
var
  a, b, c, q, t0, t1: float;
  disc              : float;
  distSqrt          : float;

  temp: float;

begin
  iSec := default(Intersection);
  iSec.Intersected := false;
  if IsNan(r.Direction.x) then exit(-1);
  if r.Direction.x < -1e5 then exit(-1);
  if r.Direction.y < -1e5 then exit(-1);
  if r.Direction.z < -1e5 then exit(-1);
  if r.Direction.x > 1e5  then exit(-1);
  if r.Direction.y > 1e5  then exit(-1);
  if r.Direction.z > 1e5  then exit(-1);
  if IsZero(r.Origin.x)   then exit(-1);
  if IsZero(r.Origin.y)   then exit(-1);
  if IsZero(r.Origin.z)   then exit(-1);

  r.Origin         := r.Origin - centre;

  if r.Origin.x > 1e5 then
    exit(-1);
  if r.Origin.x < -1e5 then
    exit(-1);

  a                := dot(r.Direction, r.Direction);
  b                := 2 * dot(r.Direction, r.Origin);
  c                := dot(r.Origin, r.Origin) - (radius * radius);
  if IsInfinite(b) then
    Exit(-1);

  disc             := b * b - 4 * a * c;
  if isNan(disc) then
    Exit(-1);
  if disc < 0 then
    Exit(-1);
  distSqrt := system.sqrt(disc);

  if b < 0 then
    q := (-b - distSqrt) / 2
  else
    q := (-b + distSqrt) / 2;
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
  iSec.Intersected := true;
  r.Origin         := r.Origin + t0 * r.Direction + centre;
  iSec.Normal      := normalize(r.Origin + t0 * r.Direction);
  Exit(t0);
end;

procedure TRaytraceSpheres.Trace(const r: Ray; out iSec: Intersection; out m: Material);
var
  d, Dmin: float;
  iTemp  : Intersection;
begin
  Dmin := 1000000;
  iSec := Default(Intersection);
  m := Default(Material);

  d := TracePlane(r, iTemp, vec3_2, 0);
  if (iTemp.Intersected) and (d < Dmin) then
  begin
    Dmin := d;
    if ((fract(iTemp.Intersection.x) < 0.5) and (fract(iTemp.Intersection.z) < 0.5) or ((fract(iTemp.Intersection.x) >= 0.5) and (fract(iTemp.Intersection.z) >= 0.5))) then
      m.Colour := vec3(0.4)
    else
      m.Colour   := vec3(0.02);
    m.Reflection := 0.2;
    m.Specular   := 0.3;
    m.Sharpness  := 2;
    iSec         := iTemp;
  end;

  d := TraceSphere(r, iTemp, vec3_3, 0.6);
  if (iTemp.Intersected) and (d < Dmin) then
  begin
    Dmin         := d;
    m.Colour     := vec3_4;
    m.Reflection := 0.6;
    m.Specular   := 0.6;
    m.Sharpness  := 50;
    iSec         := iTemp;
  end;

  d := TraceSphere(r, iTemp, vec3_5, 0.4);
  if (iTemp.Intersected) and (d < Dmin) then
  begin
    Dmin         := d;
    m.Colour     := vec3_6;
    m.Reflection := 0.6;
    m.Specular   := 0.6;
    m.Sharpness  := 50;
    iSec         := iTemp;
  end;

  d := TraceSphere(r, iTemp, vec3_7, 0.4);
  if (iTemp.Intersected) and (d < Dmin) then
  begin
    Dmin         := d;
    m.Colour     := vec3_8;
    m.Reflection := 0.6;
    m.Specular   := 0.6;
    m.Sharpness  := 50;
    iSec         := iTemp;
  end;

  d := TraceSphere(r, iTemp, vec3_9, 0.4);
  if (iTemp.Intersected) and (d < Dmin) then
  begin
    Dmin         := d;
    m.Colour     := vec3_10;
    m.Reflection := 0.6;
    m.Specular   := 0.6;
    m.Sharpness  := 50;
    iSec         := iTemp;
  end;

  d := TraceSphere(r, iTemp, vec3_11, 0.4);
  if (iTemp.Intersected) and (d < Dmin) then
  begin
    m.Colour     := vec3_12;
    m.Reflection := 0.6;
    m.Specular   := 0.6;
    m.Sharpness  := 50;
    iSec         := iTemp;
  end;

end;

function TRaytraceSpheres.CalcColour(const r: Ray; const iSec: Intersection; const m: Material): vec4;
var
  lDir   : vec3;
  c      : vec3;
  sr     : Ray;
  si     : Intersection;
  sm     : Material;
  lFactor: float;
  rDir   : vec3;
  t: Double;

begin
  lDir := m.LightPos - iSec.Intersection;

  if lDir.x > 1e20 then lDir.x := 0;
  if lDir.y > 1e20 then lDir.y := 0;
  if lDir.z > 1e20 then lDir.z := 0;
  if lDir.x < -1e20 then lDir.x := 0;
  if lDir.y < -1e20 then lDir.y := 0;
  if lDir.z < -1e20 then lDir.z := 0;

  lDir.NormalizeSelf;



  // Ambient
  c := m.Colour * AMBIENT;



  // Shadow ray

  if IsInfinite(lDir.y) then
    exit;

  sr.Origin    := iSec.Intersection + lDir * TINY_AMOUNT;
  sr.Direction := lDir;

  Trace(sr, si, sm);

  if m.LightPos.x > 1e6 then
    exit;
  if iSec.Intersection.x > 1e6 then
    exit;
  if iSec.Intersection.x < -1e6 then
    exit;

  t := length(m.LightPos - iSec.Intersection);
  if t<>0 then
    t := 1
  else
    t := pow(t, 2);
  if IsZero(t) then
    lFactor := 0
  else
    lFactor := 1/t;

  if not si.Intersected then
  begin

    // diffuse
    c := c + (m.Colour * lFactor * m.LightCol * clamp(dot(iSec.Normal, lDir)));

    if IsZero(iSec.Normal.x) then
      Exit;
    if IsZero(iSec.Normal.y) then
      Exit;
    if IsZero(iSec.Normal.z) then
      Exit;
    // specular
    rDir := reflect(r.Direction, iSec.Normal);
    c    := c + (m.Specular * lFactor * m.LightCol * pow(clamp(dot(lDir, rDir)), m.Sharpness));
  end;

  Exit(vec4(c));
end;

function TRaytraceSpheres.TracePixel(var Ray: Ray): vec4;
var
  coefficient: float;
  col        : vec4;
  mat        : Material;
  iSec       : Intersection;
  i          : integer; // loop variable

begin

  coefficient := 1;
  col         := vec4Black;

  for i := 0 to MAX_TRACE_DEPTH do
  begin
    if Ray.Origin.y > 1e6 then
      continue;

    Trace(Ray, iSec, mat);
    if iSec.Intersected then
      col       := col + (coefficient * CalcColour(Ray, iSec, mat));

    coefficient := coefficient * (mat.Reflection);
    if (not iSec.Intersected) or (coefficient < 0.01) then
      break;
   if IsZero(iSec.Normal.x) then
     break;
   if IsZero(iSec.Normal.y) then
     break;
   if IsZero(iSec.Normal.z) then
     break;
   if iSec.Normal.x>1e6 then
     break;
   if iSec.Normal.y>1e6 then
     break;
   if iSec.Normal.z>1e6 then
     break;

    Ray.Direction    := reflect(Ray.Direction, iSec.Normal);
    Ray.Origin       := iSec.Intersection + TINY_AMOUNT * Ray.Direction;
    iSec.Intersected := false;
  end;

  Exit(col);
end;

function TRaytraceSpheres.Main(var gl_FragCoord: vec2): TColor32;
var
  screen    : vec2;
  primaryRay: Ray;
  c         : vec4;
begin
  screen     := gl_FragCoord.xy / resolution.xy - vec2_13;
  screen.x   := screen.x * (resolution.x / resolution.y);
  primaryRay := CreatePrimaryRay(screen);
  c          := TracePixel(primaryRay)*16;
  if isNan(c.r) then  c.r := 0 else if c.r<0 then c.r := 0;
  if isNan(c.g) then  c.g := 0 else if c.g<0 then c.g := 0;
  if isNan(c.b) then  c.b := 0 else if c.b<0 then c.b := 0;

  Result     := TColor32(vec4.Create(pow(c.xyz, vec3(GAMMA)), c.w));
end;

initialization

RaytraceSpheres := TRaytraceSpheres.Create;
Shaders.Add('RaytraceSpheres', RaytraceSpheres);

finalization

FreeandNil(RaytraceSpheres);

end.
