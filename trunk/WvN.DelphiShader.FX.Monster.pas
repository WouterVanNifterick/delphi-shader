unit WvN.DelphiShader.FX.Monster;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TMonster = class(TShader)
  const
    vec3_1: vec3  = (x: 43758.5453123; y: 22578.1459123; z: 19642.3490423);
    vec3_2: vec3  = (x: 0.4; y: 0.1; z: 3.4);
    vec3_3: vec3  = (x: 0.40; y: 0.30; z: 0.61);
    vec3_4: vec3  = (x: 0.11; y: 0.53; z: 0.48);
    vec3_5: vec3  = (x: 0.31; y: 0.24; z: 0.42);
    vec3_6: vec3  = (x: 0; y: 1; z: 2);
    vec3_7: vec3  = (x: 0.5; y: 0.3; z: 0);
    vec3_8: vec3  = (x: 0.5; y: 0.5; z: 0.2);
    vec3_9: vec3  = (x: 1; y: 0.9; z: 0.8);
    vec3_10: vec3 = (x: 1; y: 0.6; z: 0.1);
    vec3_2_2 : vec3= (x: 2.2; y: 2.2; z: 2.2);
    vec3_045 : vec3= (x: 0.45; y: 0.45; z: 0.45);
    s: float      = 1.1;

  var
    mm: Mat4;
    m    : Vec2;
    res: double;
    time : float;
    time1: float;
    time2: float;

  an   : float;
  cr   : float;
  ro   : vec3;
  ta   : vec3;
  ww   : vec3;
  uu   : vec3;
  vv   : vec3;

    function hash3(n: float): vec3;
    function noise(const x: float): vec3;
    function rotationMat(const xyz: vec3): Mat4;
    function map(p: vec3): vec3;
    function intersect(const ro, rd: vec3): vec3;
    function calcNormal(const pos: vec3; e: float): vec3;
    function softshadow(const ro, rd: vec3; mint, k: float): float;
    function calcAO(const pos, nor: vec3): float;
    function Main(var gl_FragCoord: Vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Monster: TShader;

implementation

uses SysUtils, Math;

constructor TMonster.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;


// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

function TMonster.hash3(n: float): vec3;
begin
  Exit(fract(sin(vec3.Create(n, n + 1, n + 2)) * vec3_1));
end;

function TMonster.noise(const x: float): vec3;
var
  p, f: float;
begin
  p      := Math.floor(x);
  f      := fract(x);
  f      := f * f * (3 - 2 * f);
  Result := mix(hash3(p + 0), hash3(p + 1), f);
end;

function TMonster.rotationMat(const xyz: vec3): Mat4;
var
  si: vec3;
  co: vec3;
begin
  si := sin(xyz);
  co := cos(xyz);

  Exit(Mat4.Create(co.y * co.z, co.y * si.z, -si.y, 0, si.x * si.y * co.z - co.x * si.z, si.x * si.y * si.z + co.x * co.z, si.x * co.y, 0, co.x * si.y * co.z + si.x * si.z, co.x * si.y * si.z - si.x * co.z, co.x * co.y, 0, 0, 0, 0, 1));
end;

function TMonster.map(p: vec3): vec3;
var
  k, m, d, h: float;
  i         : integer; // loop variable
begin
  // Exit(Vec3.Create( length(p)-0.5,1.0,1.0 )); // return a ball shape
  k     := 1;
  m     := 1E10;
  for i := 0 to 21 do
  begin
    m := min(m, dot(p, p) / (k * k));
    p := (mm * vec4.Create((abs(p)), 1)).xyz;
    k := k * s;
  end;

  d      := (length(p) - 0.25) / k;
  h      := p.z - 0.35 * p.x;
  Result := vec3.Create(d, m, h);
end;

function TMonster.intersect(const ro, rd: vec3): vec3;
var
  maxd  : float;
  precis: float;
  h     : float;
  t     : float;
  d     : float;
  m     : float;
  i     : integer; // loop variable
  res   : vec3;

begin
  maxd   := 10;
  precis := 0.0002;
  h      := 1;
  t      := 0;
  d      := 0;
  m      := 1;
  for i  := 0 to 127 do
  begin
{$IF true}
    if (h > precis) and (t < maxd) then
    begin
      t   := t + (h);
      res := map(ro + rd * t);
      h   := res.x;
      d   := res.y;
      m   := res.z;
    end;

{$ELSE}
    if (h < precis) or (t > maxd) then
      break;

    t   := t + (h);
    res := map(ro + rd * t);
    h   := res.x;
    d   := res.y;
    m   := res.z;
{$ENDIF }
  end;

  if t > maxd then
    m := -1;
  Exit(vec3.Create(t, d, m));
end;

function TMonster.calcNormal(const pos: vec3; e: float): vec3;
var
  eps: vec3;

begin
  eps := vec3.Create(e, 0, 0);
  Exit(normalize(vec3.Create(map(pos + eps.xyy).x - map(pos - eps.xyy).x, map(pos + eps.yxy).x - map(pos - eps.yxy).x, map(pos + eps.yyx).x - map(pos - eps.yyx).x)));
end;

function TMonster.softshadow(const ro, rd: vec3; mint, k: float): float;
var
  res: float;
  t  : float;
  i  : integer; // loop variable
  h  : float;

begin
  res   := 1;
  t     := mint;
  for i := 0 to 31 do
  begin
    h   := map(ro + rd * t).x;
    h   := Math.max(h, 0);
    res := min(res, k * h / t);
    t   := t + (clamp(h, 0.001, 0.1));
  end;

  Exit(clamp(res));
end;

function TMonster.calcAO(const pos, nor: vec3): float;
var
  totao: float;
  aoi  : integer; // loop variable
  aopos: vec3;
  dd   : float;

begin
  totao   := 0;
  for aoi := 0 to 15 do
  begin
    aopos := -1 + 2 * hash3(aoi) * 213.47;
    aopos := aopos * (Math.sign(dot(aopos, nor)));
    aopos := pos + nor * 0.01 + aopos * 0.04;
    dd    := clamp(map(aopos).x * 4);
    totao := totao + (dd);
  end;

  totao := totao / (16);

  Exit(clamp(totao * totao * 50));
end;

procedure TMonster.PrepareFrame;
begin
  res := (resolution.x / resolution.y);
  // animation
  time  := iGlobalTime;
  time  := time + (15 * smoothstep(15, 25, iGlobalTime));
  time  := time + (20 * smoothstep(65, 80, iGlobalTime));
  time  := time + (35 * smoothstep(105, 135, iGlobalTime));
  time  := time + (20 * smoothstep(165, 180, iGlobalTime));
  time  := time + (40 * smoothstep(220, 290, iGlobalTime));
  time  := time + (5 * smoothstep(320, 330, iGlobalTime));
  time1 := (time - 10) * 1.5 - 167;
  time2 := time;

  mm    := rotationMat(vec3_2 + 0.15 * sin(0.1 * vec3_3 * time1) + 0.15 * sin(0.1 * vec3_4 * time1));
  mm.r1 := mm.r1 * s;
  mm.r2 := mm.r2 * s;
  mm.r3 := mm.r3 * s;
  mm.r4 := vec3.Create(0.15, 0.05, -0.07) + 0.05 * sin(vec3_6 + 0.2 * vec3_5 * time1);

  m   := Vec2Gray;
  if iMouse.z > 0 then
    m := iMouse.xy / resolution.xy;


  // camera
  an := 1 + 0.1 * time2 - 6.2 * m.x;
  cr := 0.15 * system.sin(0.2 * time2);
  ro := (2.4 + 0.6 * smoothstep(10, 20, time2)) * vec3.Create(system.sin(an), 0.25, system.cos(an));
  ta := vec3.Create(0, 0 + 0.13 * system.cos(0.3 * time2), 0);
  ta := ta + (0.05 * noise(0 + 1 * time));
  ro := ro + (0.05 * noise(11.3 + 1 * time));
  ww := normalize(ta - ro);
  uu := normalize(cross(ww, vec3.Create(system.sin(cr), system.cos(cr), 0)));
  vv := normalize(cross(uu, ww));

end;


function TMonster.Main(var gl_FragCoord: Vec2): TColor32;
var
  q    : Vec2;
  p    : Vec2;
  rd   : vec3;
  tmat : vec3;
  col  : vec3;
  pos  : vec3;
  nor  : vec3;
  sor  : vec3;
  mate : vec3;
  occ  : float;
  i    : integer; // loop variable
  rr   : vec3;
  ds   : float;
  fre  : float;
  ref  : vec3;
  rs   : float;

begin
  q   := gl_FragCoord.xy / resolution.xy;
  p   := -1 + 2 * q;
  p.x := p.x * res;
  p := p * 0.2;

  rd := normalize(p.x * uu + p.y * vv + 3 * ww);

  // raymarch
  tmat := intersect(ro, rd);

  // shade
  col := vec3Black;
  if tmat.z > -0.5 then
  begin
    // geometry
    pos := ro + tmat.x * rd;
    nor := calcNormal(pos, 0.005);
    sor := calcNormal(pos, 0.010);

    // material
    mate := vec3(1);
    mate := mix(vec3_8, vec3_7, 0.5 + 0.5 * sin(4 + 8000 * tmat.y));
    mate := mix(vec3_9, mate, 0.5 + 0.5 * sin(4 + 20 * tmat.z));

    // lighting
    occ := 1.1 * calcAO(pos, nor);
    occ := occ * (0.75 + 0.25 * clamp(tmat.y * 400));

    // diffuse
    col   := vec3Black;
    for i := 0 to 31 do
    begin
      rr  := normalize(-1 + 2 * hash3(i) * 123.5463);
      rr  := normalize(nor + 7 * rr);
      rr  := rr * Math.sign(dot(nor, rr));
      ds  := occ; // softshadow( pos, rr, 0.01, 32.0 );
      col := col + (pow(textureCube(TShader.cubes[0], rr).xyz, vec3_2_2) * dot(rr, nor) * ds);
    end;

    col := col / (32);
    col := col * 1.6;

    // subsurface
    col := col * (1 + vec3_10 * pow(clamp(1 + dot(rd, sor)), 2) * vec3White);

    // specular
    fre := pow(clamp(1 + dot(rd, nor)), 5);
    ref := reflect(rd, nor);
    rs  := softshadow(pos, ref, 0.01, 32);
    col := col + (1.5 * (0.04 + 12 * fre) * occ * pow(textureCube(TShader.cubes[0], ref).xyz, vec3(2)) * rs);
    col := col * mate;
  end
  else
  begin
    // background
    col := pow(textureCube(TShader.cubes[0], rd).xyz, vec3(2.2));
  end;

  // gamma
  col := pow(clamp(col, 0, 1), vec3_045);

  // vigneting
  col := col * (0.5 + 0.5 * pow(16 * q.x * q.y * (1 - q.x) * (1 - q.y), 0.1));

  Result := TColor32(col);
end;

initialization

Monster := TMonster.Create;
Shaders.Add('Monster', Monster);

finalization

FreeandNil(Monster);

end.
