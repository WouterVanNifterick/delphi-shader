unit WvN.DelphiShader.FX.Sierpkinki;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

const
  v3: vec3      = (x: 1E20; y: 0.57735; z: 0);
  vec3_1: vec3  = (x: 0; y: 0.57735; z: 0);
  vec3_2: vec3  = (x: 1; y: 0.7; z: 0.9);
  vec2_3: vec2  = (x: 0.5; y: 0.5);
  vec3_4: vec3  = (x: 0; y: - 0.5; z: 0);
  vec3_5: vec3  = (x: 0; y: 1; z: 0);
  vec3_6: vec3  = (x: 0; y: 0; z: 0);
  vec3_7: vec3  = (x: 0; y: 0; z: 0);
  vec3_8: vec3  = (x: 0; y: 0; z: 0);
  vec3_9: vec3  = (x: 0.5; y: 0.5; z: 0.5);
  vec3_10: vec3 = (x: 0; y: 1; z: 2);
  vec3_11: vec3 = (x: 0; y: 0; z: 0);
  vec3_12: vec3 = (x: 1; y: 1.2; z: 1.5);
  vec3_13: vec3 = (x: 1.00; y: 0.90; z: 0.70);
  vec3_14: vec3 = (x: 0.30; y: 0.35; z: 0.40);
  vec3_15: vec3 = (x: 0.45; y: 0.45; z: 0.45);

type
  TSierpkinki = class(TShader)
  var
    m                        : vec2;
    pow_4_7, pow_2_7, an, res: double;

    ro, rd, ta, ww, uu, vv   : vec3;

    function map(aP: vec3): vec2;
    function intersect: vec3;
    function calcNormal(const pos: vec3): vec3;
    function softshadow(const ro, rd: vec3; mint, k: float): float;
    function occlusion(const pos, nor: vec3): float;
    function Main(var gl_FragCoord: vec2): TColor32;

  var
    va    : vec3;
    vb    : vec3;
    vc    : vec3;
    vd    : vec3;
    precis: float;
    lig   : vec3;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Sierpkinki: TShader;

implementation

uses SysUtils, Math;

constructor TSierpkinki.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;

  va        := vec3_1;
  vb        := vec3.Create(0, -1, 1.15470);
  vc        := vec3.Create(1, -1, -0.57735);
  vd        := vec3.Create(-1, -1, -0.57735);
  precis    := 0.001;
  lig       := normalize(vec3_2);
  pow_2_7   := pow(2, 7);
  pow_4_7   := pow(4, 7);
end;

function dot2(const pp: vec3): float; inline;
begin
  Result := pp.x * pp.x + pp.y * pp.y + pp.z * pp.z;
end;

// return distance and address
function TSierpkinki.map(aP: vec3): vec2;
var
  a         : float;
  c         : vec3;
  dist, d, t: float;
  i         : integer;
  p, pp     : vec3;
begin
  p := aP;
  if p.x > 1E+6 then
    Exit;
  if p.x < -1E+6 then
    Exit;

  a      := 0;

  for i  := 0 to 6 do
  begin
    pp   := p - va;    d    := dot2(pp);    c    := va;    dist := d;    t    := 0;
    pp   := p - vb;    d    := dot2(pp);    if d < dist then
    begin
      c    := vb;
      dist := d;
      t    := 1;
    end;

    pp := p - vc;    d  := dot2(pp);    if d < dist then
    begin
      c    := vc;
      dist := d;
      t    := 2;
    end;

    pp := p - vd;    d  := dot2(pp);    if d < dist then
    begin
      c    := vd;
      t    := 3;
    end;

    p := c + 2 * (p - c);
    a := t + a * 4;
  end;

  Result.x := (length(p) - 1.41) / pow_2_7;
  Result.y := a / pow_4_7;
end;

function TSierpkinki.intersect: vec3;
var
  tp  : float;
  maxd: float;
  h1  : float;
  h   : vec2;
  t   : float;
  m   : float;
  i   : integer;
begin
  Result := v3;

  // plane
  tp := (-1 - ro.y) / rd.y;
  if tp > 0 then
  begin
    Result.x := tp;
    Result.y := 1;
    Result.z := 0;
  end;

  // sierpinski
  maxd  := Math.min(Result.x, 8);
  h1    := 1;
  t     := 0;
  m     := 0;
  for i := 0 to 79 do
    if (h1 > precis) and (t < maxd) then
    begin
      h := map(ro + rd * t);
      m := h.y;
      t := t + h.x;
    end;

  if (t < maxd) and (t < Result.x) then
  begin
    Result.x := t;
    Result.y := 2;
    Result.z := m;
  end;
end;

function TSierpkinki.calcNormal(const pos: vec3): vec3;
var
  eps: vec3;

begin
  eps    := vec3.Create(precis * 10, 0, 0);

  Result := normalize(vec3.Create(map(pos + eps.xyy).x - map(pos - eps.xyy).x,
    map(pos + eps.yxy).x - map(pos - eps.yxy).x, map(pos + eps.yyx).x -
    map(pos - eps.yyx).x));
end;

function TSierpkinki.softshadow(const ro, rd: vec3; mint, k: float): float;
var
  res: float;
  t  : float;
  i  : integer;
  h  : float;

begin
  res   := 1;
  t     := mint;
  for i := 0 to 39 do
  begin
    h   := map(ro + rd * t).x;
    res := min(res, k * h / t);
    t   := t + (clamp(h, 0.01, 1));
  end;

  Result := clamp(res, 0, 1);
end;

function TSierpkinki.occlusion(const pos, nor: vec3): float;
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
  for aoi := 0 to 7 do
  begin
    hr    := 0.01 + 1.2 * pow(aoi / 8, 1.5);
    aopos := nor * hr + pos;
    dd    := map(aopos).x;
    totao := totao + (-(dd - hr) * sca);
    sca   := sca * 0.85;
  end;

  Exit(clamp(1 - 0.6 * totao, 0, 1));
end;

procedure TSierpkinki.PrepareFrame;
begin
  // Created by inigo quilez - iq/2013
  // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
  res := resolution.x / resolution.y;

  m   := vec2_3;
  if iMouse.z > 0 then
    m := iMouse.xy / resolution.xy;

  // camera
  an := 3.2 + 0.5 * iGlobalTime - 6.2831 * (m.x - 0.5);
  ro := vec3.Create(2.51 * sinLarge(an), 0, 2.5 * cosLarge(an));
  ta := vec3_4;
  ww := normalize(ta - ro);
  uu := normalize(cross(ww, vec3_5));
  vv := normalize(cross(uu, ww));

end;

function TSierpkinki.Main(var gl_FragCoord: vec2): TColor32;
var
  q, p                       : vec2;
  col, tm, pos, nor, maa, lin: vec3;
  occ, amb, dif, sha, att    : float;
begin
  q   := gl_FragCoord.xy / resolution.xy;
  p   := -1 + 2 * q;
  p.x := p.x * res;

  rd  := normalize(p.x * uu + p.y * vv + 2.5 * ww);

  // render
  col := vec3_6;

  // raymarch
  tm := intersect;
  if tm.y > 0.5 then
  begin
    // geometry
    pos := ro + tm.x * rd;
    nor := vec3_7;
    maa := vec3_8;

    occ := 1;

    if tm.y < 1.5 then
    begin
      nor := vec3.Create(0, 1, 0);
      maa := vec3_9;
    end
    else
    begin
      nor := calcNormal(pos);
      maa := 0.5 + 0.5 * cos(&mod(6.2831 * tm.z + vec3_10,2*pi));
      occ := occ * (0.5 + 0.5 * clamp((pos.y + 1) / 0.5, 0, 1));
    end;

    occ := occ * occlusion(pos, nor);

    // lighting
    amb   := (0.5 + 0.5 * nor.y) * (1 - smoothstep(10, 40, length(pos.xz)));
    dif   := Math.max(dot(nor, lig), 0);
    sha   := 0;
    if dif > 0.01 then
      sha := softshadow(pos + 0.01 * nor, lig, 0.0005, 32);
    att   := 1 - smoothstep(1.5, 2.5, length(pos.xz));
    // lights
    lin   := vec3_11;
    lin   := lin + (1.5 * dif * vec3_13 * pow(vec3(sha * att), vec3_12));
    lin   := lin + (0.4 * amb * vec3_14 * occ);

    // surface-light interacion
    col := maa * lin;

  end;

  // gamma
  col    := pow(clamp(col, 0, 1), vec3_15);

  Result := TColor32(col);
end;

initialization

Sierpkinki := TSierpkinki.Create;
Shaders.Add('Sierpkinki', Sierpkinki);

finalization

FreeandNil(Sierpkinki);

end.
