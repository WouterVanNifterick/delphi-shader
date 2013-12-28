unit WvN.DelphiShader.FX.PerlinBlob;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  { playing with perlin... and with ba... }
  { v2 }
  { http://glsl.heroku.com/e#13025.0 }

  TPerlinBlob = class(TShader)
  public const
    maxSteps = 60;
    treshold = 0.001;
    maxdist  = 10.0;
    oid1     = 1;
    oid2     = 2;

    vec4_1: vec4 = (x: 0; y: 57; z: 21; w: 78);
    vec3_2: vec3 = (x: 1; y: 57; z: 21);
    vec2_3: vec2 = (x: 0.97; y: 1.1);
    vec2_4: vec2 = (x: 1.0; y: 1.0);
    vec3_5: vec3 = (x: 0.001; y: 0; z: 0);
    e_xyy: vec3  = (x: 0.001; y: 0; z: 0);
    e_yxy: vec3  = (x: 0; y: 0.001; z: 0);
    e_yyx: vec3  = (x: 0; y: 0; z: 0.001);

    vec2_6: vec2  = (x: 1; y: 1);
    vec3_7: vec3  = (x: 0; y: 0; z: - 3);
    vec3_8: vec3  = (x: 1; y: 1; z: - 1);
    vec3_9: vec3  = (x: 0; y: 0; z: 0);
    vec3_10: vec3 = (x: 0.10; y: 0.10; z: 0.10);
    vec3_11: vec3 = (x: 0.15; y: 0.15; z: 0.15);
    vec3_12: vec3 = (x: 0.80; y: 0.80; z: 0.80);
    vec3_13: vec3 = (x: 0.4; y: 0.4; z: 0.4);
    vec3_14: vec3 = (x: 0.2; y: 0.4; z: 0.8);
    vec3_15: vec3 = (x: 1; y: 1; z: 1);

  var
    speed      : float;
    ro, lig, rd: vec3;
    function rot(const k: vec2; t: float): vec2;
    function perlin(const p: vec3): float;
    function opU(const d1, d2: vec2): vec2;
    function sdPlane(const p: vec3): float;
    function sdCylinder(const p: vec3; const h: vec2): float;
    function map(const p: vec3): vec2;
    function cNor(const p: vec3): vec3;
    function calcAO(const pos, nor: vec3): float;
    function cShd(const ro, rd: vec3; mint, maxt, k: float): float;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  PerlinBlob: TShader;

implementation

uses SysUtils, Math;

constructor TPerlinBlob.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

function TPerlinBlob.rot(const k: vec2; t: float): vec2;
begin
  Exit(vec2.Create(
               system.cos(t) * k.x - system.sin(t) * k.y,
               system.sin(t) * k.x + system.cos(t) * k.y)
  );
end;

var
  i: vec3;

var
  a: vec4;
  f: vec3;

function TPerlinBlob.perlin(const p: vec3): float;
begin
  i    := floor(p);
  a    := dot(i, vec3_2) + vec4_1;
  f    := cos((p - i) * pi) * (-0.5) + 0.5;
  a    := mix(sin(cos(a) * a), sin(cos(1 + a) * (1 + a)), f.x);
  a.xy := mix(a.xz, a.yw, f.y);
  Exit(mix(a.x, a.y, f.z));
end;

function TPerlinBlob.opU(const d1, d2: vec2): vec2;
begin
  if d1.x < d2.x then
    Result := d1
  else
    Result := d2
end;

function TPerlinBlob.sdPlane(const p: vec3): float;
begin
  Result := p.y;
end;

function TPerlinBlob.sdCylinder(const p: vec3; const h: vec2): float;
begin
  Result := max(length(p.xz) - h.x, abs(p.y) - h.y);
end;

function TPerlinBlob.map(const p: vec3): vec2;
begin
  // Result := Vec2.Create( max( sdCylinder(p,vec2_4), -sdCylinder(p,vec2_3) ) ,oid2);
  Result.x := length(p) - length(cos(perlin(p + speed))) - 0.5;
  Result.y := oid2;
end;

function TPerlinBlob.cNor(const p: vec3): vec3;
begin
  Result.x := map(p + e_xyy).x - map(p - e_xyy).x;
  Result.y := map(p + e_yxy).x - map(p - e_yxy).x;
  Result.z := map(p + e_yyx).x - map(p - e_yyx).x;
  Result.NormalizeSelf;
end;

function TPerlinBlob.calcAO(const pos, nor: vec3): float;
var
  totao: float;
  sca  : float;
  aoi  : integer;
  hr   : float;
  aopos: vec3;
  dd   : float;

begin
  totao   := 0;
  sca     := 1;
  for aoi := 0 to 4 do
  begin
    hr    := 0.01 + 0.05 * aoi;
    aopos := nor * hr + pos;
    dd    := map(aopos).x;
    totao := totao + (-(dd - hr) * sca);
    sca   := sca * 0.75;
  end;

  Result := clamp(1 - 4 * totao);
end;

// softshadow
function TPerlinBlob.cShd(const ro, rd: vec3; mint, maxt, k: float): float;
var
  res: float;
  t  : float;
  i  : integer;
  h  : float;

begin
  res   := 1;
  t     := mint;
  for i := 0 to 29 do
  begin
    if t > maxt then
      break;
    h   := map(ro + rd * t).x;
    res := min(res, k * h / t);
    t   := t + 0.02;
  end;

  Exit(clamp(res, 0, 1));
end;

procedure TPerlinBlob.PrepareFrame;
begin

  speed := time * 0.4321;
  ro    := vec3_7;
  lig   := vec3_8;

  lig.xz := rot(lig.xz, mouse.x * 8);
  lig.xy := rot(lig.xy, mouse.y * 8);
  ro.xz  := rot(ro.xz, mouse.x * 8);
  ro.xy  := rot(ro.xy, mouse.y * 8);

end;

function TPerlinBlob.Main(var gl_FragCoord: vec2): TColor32;
var
  t, ps            : vec2;
  oc               : vec3;
  f                : float;
  i                : integer;
  col, pos, nor    : vec3;
  ao, amb, dif, bac: float;
  sh, spe, rim     : float;
begin
  ps    := (gl_FragCoord.xy / resolution.xy);
  rd.xy := (-1 + 2 * ps) * vec2_6;
  rd.z  := 1;
  rd.NormalizeSelf;
  rd.xz := rot(rd.xz, mouse.x * 8);
  rd.xy := rot(rd.xy, mouse.y * 8);

  // march
  f     := 0;
  t.x   := treshold;
  t.y   := f;
  for i := 1 to maxSteps do
  begin
    t   := map(ro + rd * t.x);
    f   := f + t.x;
    t.x := f;
    if (abs(t.x) < treshold) or (t.x > maxdist) then
      break;
  end;

  if t.x > maxdist then
    t.y := 0;

  // draw
  col := vec3_9;
  if t.y > 0.5 then
  begin

    lig := normalize(lig);
    pos := ro + rd * t.x;
    nor := cNor(pos);
    ao  := calcAO(pos, nor);

    amb := clamp(0.5 + 0.5 * nor.y);
    dif := clamp(dot(nor, lig));
    bac := clamp(dot(nor, -lig));

    sh := cShd(pos, lig, 0.001, 1, 0.5);

    col := 0.20 * amb * vec3_10 * ao; // 0.02
    col := col + (0.20 * bac * vec3_11 * ao);
    col := col + (1.00 * dif * vec3_12);

    spe := sh * pow(clamp(dot(lig, reflect(rd, nor)), 0, 1), 16);
    rim := ao * pow(clamp(1 + dot(nor, rd), 0, 5), 2);

    if t.y = oid1 then
      oc := vec3_13;
    if t.y = oid2 then
      oc := vec3_14;

    col := oc * col + vec3_15 * col * spe + 0.2 * rim * (0.5 + 0.5 * col);
  end;

  Result := TColor32(col);
end;

initialization

PerlinBlob := TPerlinBlob.Create;
Shaders.Add('PerlinBlob', PerlinBlob);

finalization

FreeandNil(PerlinBlob);

end.
