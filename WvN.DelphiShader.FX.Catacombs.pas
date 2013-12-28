unit WvN.DelphiShader.FX.Catacombs;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TCatacombs = class(TShader)
    res:double;
    time: float;
    mo:vec2;
    ce, ro, ta: vec3;
    roll      : float;
    cw, cp, cu, cv: vec3;
    lpos            : array [0 .. 6] of vec3;
    lcol            : array [0 .. 6] of vec4;
const
  c1: vec3 = (x: 1.00; y: 0.80; z: 0.60);
  c2: vec3 = (x: 1.00; y: 0.30; z: 0.05);
  c3: vec3 = (x: 0.25; y: 0.20; z: 0.20);
  c4: vec3 = (x: 0.35; y: 0.20; z: 0.10);
  c5: vec3 = (x: 0.10; y: 0.30; z: 0.00);
  eps_1_0_0 : vec3 = (x:0.001; y:0.000;z:0.000);
  eps_0_1_0 : vec3 = (x:0.000; y:0.001;z:0.000);
  eps_0_0_1 : vec3 = (x:0.000; y:0.000;z:0.001);
  v3_7_7_7: vec3 = (x: 0.70; y: 0.70; z: 0.70);
  vec3_3_15_15: vec3=(x: 0.30; y: 0.15; z: 0.15);
    constructor Create; override;
    procedure PrepareFrame;
    function fbm(p: vec3; const n: vec3): float;
    function doBumpMap(const pos: vec3; const nor: vec3): vec3;
    function render(const ro: vec3; const rd: vec3): vec3;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
    function calcNormal(const pos: vec3): vec3;
    function calcColor(const pos: vec3; const nor: vec3; const sid: float): vec3;
  end;

var
  Catacombs: TShader;

implementation

uses SysUtils, Math;

constructor TCatacombs.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TCatacombs.PrepareFrame;
var
  i: Integer;
  ilpos: Vec2;
  flpos: Vec2;
  li              : float;
  h: Double;
  c: vec3;
begin
  time := iGlobalTime;
  // camera
  ce   := vec3.Create(0.5, 0.25, 1.5);
  ro   := ce + vec3.Create(1.3 * system.cos(0.11 * time + 6 * mo.x), 0.65 * (1- mo.y), 1.3 * system.sin(0.11 * time + 6 * mo.x));
  ta   := ce + vec3.Create(0.95 * system.cos(1.2 + 0.08 * time), 0.4 * 0.25 + 0.75 * ro.y, 0.95 * system.sin(2 + 0.07 * time));
  roll := -0.15 * system.sin(0.1 * time);

  // camera tx
  cw := normalize(ta - ro);
  cp := vec3.Create(system.sin(roll), system.cos(roll), 0);
  cu := normalize(cross(cw, cp));
  cv := normalize(cross(cu, cw));

  res := Resolution.x / Resolution.y;
  mo  := iMouse.xy / Resolution.xy;

  // move lights

  for i := low(lpos) to high(lpos) do
  begin
    lpos[i].x := 0.5 + 2.2 * system.cos(0.22 + 0.2 * iGlobalTime + 17 * i);
    lpos[i].y := 0.25;
    lpos[i].z := 1.5 + 2.2 * system.cos(2.24 + 0.2 * iGlobalTime + 13 * i);

    // make the lights avoid the columns
    ilpos := floor(lpos[i].xz);
    flpos := lpos[i].xz - ilpos;
    flpos := flpos - 0.5;
    if length(flpos) < 0.2 then
      flpos := 0.2 * normalize(flpos);

    lpos[i].xz := ilpos + flpos;

    li := system.sqrt(0.5 + 0.5 * system.sin(2 * iGlobalTime + 23.1 * i));

    h       := i / 8;
    c       := mix(c1, c2, 0.5 + 0.5 * system.sin(40 * h));
    lcol[i] := vec4.Create(c, li);
  end;


end;

function distToBox(const p, abc: vec3): float;
var
  di: vec3;
begin
  di := max(abs(p) - abc, 0);
  Exit(dot(di, di));
end;

const
  v3_1: vec3 = (x: 0.10 * 0.85; y: 1.00; z: 0.10 * 0.85);
  v3_2: vec3 = (x: 0.12; y: 0.40; z: 0.12);
  v3_3: vec3 = (x: 0.05; y: 0.35; z: 0.14);
  v3_4: vec3 = (x: 0.14; y: 0.35; z: 0.05);
  v3_5: vec3 = (x: 0.10 * 0.7071; y: 0.10 * 0.7071; z: 0.12);
  v3_6: vec3 = (x: 0.12; y: 0.10 * 0.7071; z: 0.10 * 0.7071);
  v3_7: vec3 = (x: 0.10 * 0.7071; y: 0.10 * 0.7071; z: 0.14);
  v3_8: vec3 = (x: 0.14; y: 0.10 * 0.7071; z: 0.10 * 0.7071);
  v3_9: vec3 = (x: 0.14; y: 0.02; z: 0.14);

function column(x, y, z: float): Vec2;
var
  p                                          : vec3;
  y2, y3, y4                                 : float;
  di1, di2, di3, di4, di5, di6, di7, di8, di9: float;
  dm                                         : float;
  res                                        : Vec2;
const c = 0.7071;
begin
  p := vec3.Create(x, y, z);

  y2 := y - 0.40;
  y3 := y - 0.35;
  y4 := y - 1.00;

  di1 := distToBox(p, v3_1);
  di2 := distToBox(p, v3_2);
  di3 := distToBox(p, v3_3);
  di4 := distToBox(p, v3_4);
  di5 := distToBox(vec3.Create((x - y2) * c, (y2 + x) * c, z           ), v3_5);
  di6 := distToBox(vec3.Create( x          , (y2 + z) * c, (z - y2) * c), v3_6);
  di7 := distToBox(vec3.Create((x - y3) * c, (y3 + x) * c, z           ), v3_7);
  di8 := distToBox(vec3.Create( x          , (y3 + z) * c, (z - y3) * c), v3_8);
  di9 := distToBox(vec3.Create( x          ,  y4         , z           ), v3_9);

  dm    := Math.min(
           Math.min(
           Math.min(di9, di2),
           Math.min(di3, di4)),
           Math.min(
           Math.min(di5, di6),
           Math.min(di7, di8)));
  res.x := dm;
  res.y := 3;
  if di1 < res.x then
  begin
    res.x := di1;
    res.y := 2;
  end;

  Result.x := system.sqrt(res.x);
  Result.y := res.y;
end;

function map(const pos: vec3): vec3;
var
  sid, dis: float;
  mindist : float;
  x, z, y : float;
  fxc, fzc: float;
  dis2    : Vec2;
  dsp     : float;
begin

  sid := 0;

  // floor
  mindist := pos.y;

  // ceilin
  x   := fract(pos.x + 128) - 0.5;
  z   := fract(pos.z + 128) - 0.5;
  y   := 1 - pos.y;
  dis := -system.sqrt(y * y + min(x * x, z * z)) + 0.4;
  dis := Math.max(dis, y);
  if dis < mindist then
  begin
    mindist := dis;
    sid     := 1;
  end;

  // columns
  fxc  := fract(pos.x + 128.5) - 0.5;
  fzc  := fract(pos.z + 128.5) - 0.5;
  dis2 := column(fxc, pos.y, fzc);

  if dis2.x < mindist then
  begin
    mindist := dis2.x;
    sid     := dis2.y;
  end;

  dsp     := clamp(pos.y, 0, 1) * abs(
                                     system.sin(6   * pos.y) *
                                     system.sin(50  * pos.x) *
                                     system.sin(4*2 * pi * pos.z));
  mindist := mindist - (dsp * 0.03);

  Result := vec3.Create(mindist, sid, dsp);
end;

function castRay(const ro: vec3; const rd: vec3; const precis: float; const startf: float; const maxd: float): vec3;
var
  h  : float;
  t  : float;
  dsp: float;
  sid: float;
  i  : integer;
  res: vec3;
begin
  h := precis * 2;

  t     := startf;
  dsp   := 0;
  sid   := -1;
  for i := 0 to 50 - 1 do
  begin
    if (abs(h) < precis) or (t > maxd) then
      break;
    t   := t + (h);
    res := map(ro + rd * t);
    h   := res.x;
    sid := res.y;
    dsp := res.z;
  end;

  if t > maxd then
    sid := -1;

  Result.x := t;
  Result.y := sid;
  Result.z := dsp;
end;

function softshadow(const ro: vec3; const rd: vec3; const mint: float; const maxt: float; const k: float): float;
var
  i: integer;
  res, dt, t, h: float;
begin
  res   := 1;
  dt    := 0.02;
  t     := mint;
  for i := 0 to 31 do
    if t < maxt then
    begin
      h   := map(ro + rd * t).x;
      res := min(res, k * h / t);
      t   := t + (max(0.05, dt));
    end;
  Result := clamp(res, 0, 1);
end;

function TCatacombs.calcNormal(const pos: vec3): vec3;
begin
  Result.x := map(pos + eps_1_0_0).x -
              map(pos - eps_1_0_0).x;

  Result.y := map(pos + eps_0_1_0).x -
              map(pos - eps_0_1_0).x;

  Result.z := map(pos + eps_0_0_1).x -
              map(pos - eps_0_0_1).x;

  Result.NormalizeSelf;
end;

function calcAO(const pos: vec3; const nor: vec3): float;
var
  totao: float;
  sca  : float;
  aoi  : integer;
  hr   : float;
  aopos: vec3;
  dd   : float;
begin
  totao   := 0;
  sca     := 15;
  for aoi := 0 to 4 do
  begin
    hr    := 0.01 + 0.015 * aoi * aoi;
    aopos := nor * hr + pos;
    dd    := map(aopos).x;
    totao := totao + (-(dd - hr) * sca);
    sca   := sca * 0.5;
  end;

  Exit(1 - clamp(totao, 0, 1));
end;

function TCatacombs.render(const ro: vec3; const rd: vec3): vec3;
var
  col, res     : vec3;
  t               : float;
  pos, nor        : vec3;
  ao              : float;
  brdf, spe, lig  : vec3;
  llig            : float;
  im, dif, at, at2: float;
  sh, dif2, pp    : float;
  lv              : vec3;
  ll, dle         : float;
  i: Integer;

begin

  col := vec3Black;
  res := castRay(ro, rd, 0.001, 0.025, 20);
  t   := res.x;
  if res.y > -0.5 then
  begin
    pos := ro + t * rd;
    nor := calcNormal(pos);
    col := calcColor(pos, nor, res.y);

    nor := doBumpMap(pos, nor);

    ao := calcAO(pos, nor);
    ao := ao * (0.7 + 0.6 * res.z);
    // lighting
    brdf  := 0.03 * ao * c3 * (0.5 + 0.5 * nor.y);
    spe   := vec3Black;
    for i := 0 to 6 do
    begin
      lig  := lpos[i] - pos;
      llig := dot(lig, lig);
      im   := inversesqrt(llig);
      lig  := lig * im;
      dif  := dot(nor, lig);
      dif  := clamp(dif, 0, 1);
      at   := 2 * exp2(-2.3 * llig) * lcol[i].w;
      dif  := dif * (at);
      at2  := exp2(-0.35 * llig);

      sh := 0;
      if dif > 0.02 then
      begin
        sh  := softshadow(pos, lig, 0.02, system.sqrt(llig), 32);
        dif := dif * sh;
      end;

      dif2 := clamp(dot(nor, normalize(vec3.Create(-lig.x, 0, -lig.z))), 0, 1);
      brdf := brdf + (0.2 * ao * dif2 * c4 * at2);
      brdf := brdf + (2.5 * ao * dif * lcol[i].xyz);

      pp  := clamp(dot(reflect(rd, nor), lig), 0, 1);
      spe := spe + (ao * lcol[i].xyz * at * sh * (pow(pp, 16) + 0.5 * pow(pp, 4)));
    end;

    // material
    col := mix(col, c5, system.sqrt(max(1 - ao, 0)) * smoothstep(-0.5, -0.1, nor.y));
    col := mix(col, c5, (1 - smoothstep(0, 0.12, abs(nor.y) - 0.1 * (1 - smoothstep(-0.1, 0.3, pos.y)))) * (1 - smoothstep(0.5, 1, pos.y)));

    col := col * brdf;

    col := col + (3 * spe * vec3.Create(1, 0.6, 0.2));
  end;

  col := col * (exp(-0.055 * t * t));

  // lights
  for i := 0 to 6 do
  begin
    lv := lpos[i] - ro;
    ll := length(lv);
    if ll < t then
    begin
      dle := clamp(dot(rd, lv / ll), 0, 1);
      dle := (1 - smoothstep(0, 0.2 * (0.7 + 0.3 * lcol[i].w), acos(dle) * ll));
      col := col + (dle * 6 * lcol[i].w * lcol[i].xyz * dle * exp(-0.07 * ll * ll));
    end;

  end;

  Exit(vec3(col));
end;

function TCatacombs.calcColor(const pos: vec3; const nor: vec3; const sid: float): vec3;
var
  col   : vec3;
  kk    : float;
  peldxz: Vec2;
  de    : float;
  peld  : float;
  FX    : float;
  fz    : float;
  p     : float;
  l     : float;
begin
  col := vec3White;

  kk := fbm(4 * pos, nor);

  if sid < 0.5 then
  begin
    peldxz := fract(12 * pos.xz);
    peldxz := 4 * peldxz * (1 - peldxz);
    de     := 20 * length(fwidth(pos.xz));
    peld   := smoothstep(0.15 - de, 0.15 + de, Math.min(peldxz.x, peldxz.y));
    col    := 0.05 + 0.95 * vec3(peld);
  end;

  if (sid > 0.5) and (sid < 1.5) then
  begin
    FX := fract(pos.x + 128);
    fz := fract(pos.z + 128);

    col := v3_7_7_7;

    p   := (smoothstep(0.02, 0.03, abs(FX - 0.1))) *
           (smoothstep(0.02, 0.03, abs(FX - 0.9))) *
           (smoothstep(0.02, 0.03, abs(fz - 0.1))) *
           (smoothstep(0.02, 0.03, abs(fz - 0.9))) ;
    col := mix(0.75 * vec3_3_15_15, col, p);
  end;

  if (sid > 1.5) and (sid < 2.5) then
  begin
    l    := fract(12 * pos.y);
    peld := smoothstep(0.1, 0.2, l);
    col  := 0.05 + 0.95 * vec3(peld);
  end;

  col := col * (2 * kk);

  Exit(col);
end;

function TCatacombs.doBumpMap(const pos: vec3; const nor: vec3): vec3;
var
  e, b, ref : float;
  tgrad, gra: vec3;
begin
  e := 0.0015;
  b := 0.01;

  ref := fbm(48 * pos, nor);
  gra := -b * vec3.Create(fbm(48 * vec3.Create(pos.x + e, pos.y, pos.z), nor) - ref, fbm(48 * vec3.Create(pos.x, pos.y + e, pos.z), nor) - ref, fbm(48 * vec3.Create(pos.x, pos.y, pos.z + e), nor) - ref) / e;

  tgrad := gra - nor * dot(nor, gra);
  Exit(normalize(nor - tgrad));

end;

function TCatacombs.fbm(p: vec3; const n: vec3): float;
var
  x: float;
  y: float;
  z: float;
begin
  p := p * (0.15);

  x := texture2D(tex[1], p.yz).x;
  y := texture2D(tex[1], p.zx).x;
  z := texture2D(tex[1], p.xy).x;
  {

    x := 1;
    y := 1;
    z := 1;
  }
  Result := x * abs(n.x) + y * abs(n.y) + z * abs(n.z);
end;

function TCatacombs.RenderPixel(var gl_FragCoord: vec2): TColor32;
var
  q, p   : vec2;
  rd, col: vec3;
begin
  q   := gl_FragCoord.xy / Resolution.xy;
  p   := -1 + 2 * q;
  p.x := p.x * res;

  rd  := p.x * cu + p.y * cv + 1.5 * cw;
  rd.NormalizeSelf;
  col := render(ro, rd);
  col := sqrt(col);

  // vigneting
  col := col * (0.25 + 0.75 * pow(16 * q.x * q.y * (1 - q.x) * (1 - q.y), 0.15));

  Result := TColor32(col);
end;

initialization

Catacombs := TCatacombs.Create;
Shaders.Add('Catacombs', Catacombs);

finalization

FreeandNil(Catacombs);

end.
