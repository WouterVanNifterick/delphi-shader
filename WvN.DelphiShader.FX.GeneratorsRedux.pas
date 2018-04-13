unit WvN.DelphiShader.FX.GeneratorsRedux;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type

  { .$define ENABLE_HARD_SHADOWS } // turn off to enable faster AO soft shadows ;
  { .$define ENABLE_VIBRATION }
  { .$define ENABLE_POSTPROCESS } // Works better on window view rather than full screen;

  TGeneratorsRedux = class(TShader)
  const
    detail = 0.00005;

    mat2_1:mat2 = (r1:(x:-0.416;y:-0.91);r2:(x:0.91;y:-0.416));

    vec2_16: vec2 = (x: 1   ; y: 0);

    vec3_1: vec3  = (x: 0.85; y: 0.9 ; z: 1  );
    vec3_2: vec3  = (x: 0.8 ; y: 0.83; z: 1  );
    vec3_3: vec3  = (x: 1   ; y: 0.7 ; z: 0.9);
    vec3_4: vec3  = (x: 1   ; y: 0.7 ; z: 0.4);
    vec3_5: vec3  = (x: 0.5 ; y:-0.3 ; z:-1  );
    vec3_6: vec3  = (x: 0   ; y: 0   ; z: 1  );
    vec3_7: vec3  = (x: 0   ; y: 3.11; z: 0  );
    vec3_8: vec3  = (x: 0.01; y: 0.01; z: 0.01);
    vec3_9: vec3  = (x:-0.02; y: 1.98; z:-0.02);
    vec3_11: vec3 = (x: 0.1 ; y: 5   ; z: 0.1);
    vec3_12: vec3 = (x: 0   ; y: 0   ; z: 0  );
    vec3_13: vec3 = (x: 3   ; y: 3   ; z: 3  );
    vec3_14: vec3 = (x: 0   ; y: 1   ; z: 0  );
    vec3_15: vec3 = (x: 1   ; y: 1   ; z: 1  );
    vec3_17: vec3 = (x: 0   ; y: 0   ; z: 0  );
    vec3_18: vec3 = (x: 0   ; y: 0   ; z: 0  );
    vec3_19: vec3 = (x: 0   ; y: 0.01; z: 0  );
    vec3_20: vec3 = (x: 1   ; y: 1   ; z: 1  );
    vec3_21: vec3 = (x: 0   ; y: 0   ; z: 0  );
    vec3_22: vec3 = (x: 1.5 ; y: 1.5 ; z: 1.5);

    vec4_10: vec4 = (x: 0.5 ; y: 1   ; z: 0.4; w: 0);

    RAY_STEPS           = 70;
    SHADOW_STEPS        = 50;
    LIGHT_COLOR: vec3   = (x: 0.85; y: 0.9; z: 1);
    AMBIENT_COLOR: vec3 = (x: 0.8; y: 0.83; z: 1);
    FLOOR_COLOR: vec3   = (x: 1; y: 0.7; z: 0.9);
    ENERGY_COLOR: vec3  = (x: 1; y: 0.7; z: 0.4);
    BRIGHTNESS          = 0.9;
    GAMMA               = 1.3;
    SATURATION          = 0.85;

    function rot(a: float): mat2;
    function path(ti: float): vec3;
    function Sphere(const p, rd: vec3; r: float): float;
    function de(const pos: vec3): vec2;
    function normal(const p: vec3): vec3;
    function shadow(const pos, sdir: vec3): float;
    function calcAO(const pos, nor: vec3): float;
    function texture(p: vec3): float;
    function light(const p, dir, n: vec3; const hid: float): vec3;
    function raymarch(from, dir: vec3): vec3;
    function move(out rotview1, rotview2: mat2): vec3;
    function Main(var gl_FragCoord: vec2): TColor32;

  var
    t        : double;
    lightdir : vec3;
    ambdir   : vec3;
    origin   : vec3;
    energy   : vec3;
    vibration: float;
    det      : float;
    pth1     : vec3;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  GeneratorsRedux: TShader;

implementation

uses SysUtils, Math;

constructor TGeneratorsRedux.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TGeneratorsRedux.PrepareFrame;
begin
  // "GENERATORS REDUX" by Kali

  // Reworked by eiffie to run faster and under ANGLE:
  //
  // -Made the sphere raytraced
  // -Soft AO shadows
  // -Various great optimizations
  //
  // Thanks eiffie not  not  not


  // Original description:
  // Same fractal as "Ancient Temple" + rotations, improved shading
  // (better coloring, AO and  shadows), some lighting effects, and a path for the camera
  // following a liquid metal ball.

  t := iGlobalTime * 0.25;

  lightdir := normalize(vec3_5);
  ambdir   := normalize(vec3_6);
  origin   := vec3_7;
  energy   := vec3_8;
{$IFDEF ENABLE_VIBRATION}
  vibration := sin(iGlobalTime * 60) * 0.0013;
{$ELSE }
  vibration := 0;
{$ENDIF }
  det := 0;

end;

function TGeneratorsRedux.rot(a: float): mat2;
var ca,sa:double;
begin
  sa := system.sin(a);
  ca := system.cos(a);
  Result.r1.x := ca;
  Result.r1.y := sa;
  Result.r2.x := -sa;
  Result.r2.y := ca;
end;

function TGeneratorsRedux.path(ti: float): vec3;
begin
  Result := vec3.Create(system.sin(ti), 0.3 - system.sin(ti * 0.632) * 0.3, system.cos(ti * 0.5)) * 0.5;
end;

function TGeneratorsRedux.Sphere(const p, rd: vec3; r: float): float;
var
  b    : float;
  inner: float;

begin
  // A RAY TRACED SPHERE
  b     := dot(-p, rd);
  inner := b * b - dot(p, p) + r * r;
  if inner < 0 then
    Exit(-1);

  Result := b - system.sqrt(inner);
end;

function TGeneratorsRedux.de(const pos: vec3): vec2;
var
  hid, y   : float;
  tpos     : vec3;
  p,p_xyz  : vec4;
  i        : integer;
  fl, fr, d: float;

begin
  hid     := 0;
  tpos    := pos;
  tpos.xz := abs(0.5 - &mod(tpos.xz, 1));
  p.x     := tpos.x;
  p.y     := tpos.y;
  p.z     := tpos.z;
  p.w     := 1;

  y       := max(0, 0.35 - System.abs(pos.y - 3.35)) / 0.35;
  for i   := 0 to 6 do
  begin // LOWERED THE ITERS
    p.xyz := abs(p.xyz) - vec3_9;
    p_xyz := p.xyz;
    p     := p * (2 + vibration * y) / clamp(dot(p_xyz, p_xyz), 0.4, 1) - vec4_10;
    p.xz  := p.xz * mat2_1;
  end;

  fl := pos.y - 3.013;
  fr := (length(max(abs(p.xyz) - vec3_11, vec3_12)) - 0.05) / p.w;
  // fr := length(p.xyz) / p.w;
  d  := Math.min(fl, fr);
  d  := Math.min(d, -pos.y + 3.95);
  if System.abs(d - fl) < 0.001 then
    hid := 1;
  Result.x := d;
  Result.y := hid;
end;

function TGeneratorsRedux.normal(const p: vec3): vec3;
var
  e: vec3;
  e1,e2,e3:vec3;
  r:vec3;
  t1,t2:vec2;
begin
  e := vec3.Create(0, det, 0);
  e1 := e.yxx;
  e2 := e.xyx;
  e3 := e.xxy;
  t1 := de(p + e1); t2 := de(p - e1);
  r.x := t1.x - t1.x;

  t1 := de(p + e2);
  t2 := de(p - e2);
  r.y := t1.x - t2.x;

  t1 := de(p + e3);
  t2 := de(p - e3);
  r.z := t1.x - t2.x;

  r.NormalizeSelf;
  Result := r;
end;

function TGeneratorsRedux.shadow(const pos, sdir: vec3): float;
var
  sh         : float;
  totdist    : float;
  dist       : float;
  t1         : float;
  sphglowNorm: vec3;
  steps      : integer;
  p          : vec3;

begin // THIS ONLY RUNS WHEN WITH HARD SHADOWS
  sh      := 1;
  totdist := 2 * det;
  dist    := 10;
  t1      := Sphere((pos - 0.005 * sdir) - pth1, -sdir, 0.015);
  if (t1 > 0) and (t1 < 0.5) then
  begin
    sphglowNorm := normalize(pos - t1 * sdir - pth1);
    sh          := 1 - pow(Math.max(0, dot(sphglowNorm, sdir)) * 1.2, 3);
  end;

  for steps := 0 to SHADOW_STEPS - 1 do
    if (totdist < 0.6) and (dist > detail) then
    begin
      p       := pos - totdist * sdir;
      dist    := de(p).x;
      sh      := min(sh, max(50 * dist / totdist, 0));
      totdist := totdist + max(0.01, dist);
    end;

  Result := clamp(sh, 0.1, 1);
end;

function TGeneratorsRedux.calcAO(const pos, nor: vec3): float;
var
  aodet: float;
  totao: float;
  sca  : float;
  aoi  : integer;
  hr   : float;
  aopos: vec3;
  dd   : float;

begin
  aodet   := detail * 40;
  totao   := 0;
  sca     := 14;
  for aoi := 0 to 4 do
  begin
    hr    := aodet * aoi * aoi;
    aopos := nor * hr + pos;
    dd    := de(aopos).x;
    totao := totao + (-(dd - hr) * sca);
    sca   := sca * 0.7;
  end;

  Exit(clamp(1 - 5 * totao));
end;

function TGeneratorsRedux.texture(p: vec3): float;
var
  c : vec3;
  es: float;
  l : float;
  i : integer;
  pl: float;
begin
  p     := abs(0.5 - fract(p * 10));
  c     := vec3_13;
  es    := 0;
  l     := 0;
  for i := 0 to 9 do
  begin
    p := abs(p + c) - abs(p - c) - p;
    p := p / (clamp(dot(p, p)));
    p := p * -1.5 + c;
    if i mod 2 < 1 then
    begin
      pl := l;
      l  := length(p);
      es := es + (exp(-1 / System.abs(l - pl)));
    end;
  end;
  Result := es;
end;

function TGeneratorsRedux.light(const p, dir, n: vec3; const hid: float): vec3;
var
  sh          : float;
  ao          : float;
  diff        : float;
  y           : float;
  amb         : vec3;
  r           : vec3;
  spec        : float;
  col         : vec3;
  energysource: float;
  k           : float;

begin // PASSING IN THE NORMAL
{$IFDEF ENABLE_HARD_SHADOWS}
  sh := shadow(p, lightdir);
{$ELSE }
  sh := calcAO(p, -2.5 * lightdir);
{$ENDIF }
  ao   := calcAO(p, n);
  diff := Math.max(0, dot(lightdir, -n)) * sh;
  y    := 3.35 - p.y;
  amb  := max(0.5, dot(dir, -n)) * 0.5 * AMBIENT_COLOR;
  if hid < 0.5 then
  begin
    amb := amb + (max(0.2, dot(vec3_14, -n)) * FLOOR_COLOR * pow(max(0, 0.2 - abs(3 - p.y)) / 0.2, 1.5) * 2);
    amb := amb + (energy * pow(max(0, 0.4 - abs(y)) / 0.4, 2) * max(0.2, dot(vec3.Create(0, -Math.sign(y), 0), -n)) * 2);
  end;

  r    := reflect(lightdir, n);
  spec := pow(Math.max(0, dot(dir, -r)) * sh, 10);

  energysource := pow(math.max(0, 0.04 - system.Abs(y)) / 0.04, 4) * 2;
  if hid > 1.5 then
  begin
    col  := vec3_15;
    spec := spec * spec;
  end
  else
  begin
    k   := texture(p) * 0.23 + 0.2;
    k   := min(k, 1.5 - energysource);
    col := mix(vec3.Create(k, k * k, k * k * k), vec3(k), 0.3);
    if System.abs(hid - 1) < 0.001 then
      col := col * (FLOOR_COLOR * 1.3);
  end;

  col := col * (amb + diff * LIGHT_COLOR) + spec * LIGHT_COLOR;

  if hid < 0.5 then
    col := max(col, energy * 2 * energysource);

  col := col * (min(1, ao + length(energy) * 0.5 * max(0, 0.1 - abs(y)) / 0.1));
  result := col;
end;

function TGeneratorsRedux.raymarch(from, dir: vec3): vec3;
var
  ey                                : float;
  glow, eglow, ref, sphdist, totdist: float;
  d                                 : vec2;
  p                                 : vec3;
  col                               : vec3;
  origdir, origfrom                 : vec3;
  sphNorm, sphglowNorm              : vec3;
  wob                               : vec3;
  t1, tg                            : float;
  i                                 : integer;
  glw                               : float;
  l                                 : float;
  backg                             : vec3;
  norm                              : vec3;
  lglow, sphlight                   : vec3;
begin
  ey      := &mod(t * 0.5, 1);
  glow    := 0;
  eglow   := 0;
  ref     := 0;
  sphdist := 0;
  totdist := 0;

  d        := vec2_16;
  p        := vec3_17;
  col      := vec3_18;
  origdir  := dir;
  origfrom := from;

  // FAKING THE SQUISHY BALL BY MOVING A RAY TRACED BALL
  wob := cos(dir * 500 * length(from - pth1) + (from - pth1) * 250 + iGlobalTime * 10) * 0.0005;
  t1  := Sphere(from - pth1 + wob, dir, 0.015);
  tg  := Sphere(from - pth1 + wob, dir, 0.02);
  if t1 > 0 then
  begin
    ref     := 1;
    from    := from + (t1 * dir);
    sphdist := t1;
    sphNorm := normalize(from - pth1 + wob);
    dir     := reflect(dir, sphNorm);
  end;

  if tg > 0 then
  begin
    sphglowNorm := normalize(from + tg * dir - pth1 + wob);
    glow        := glow + (pow(Math.max(0, dot(sphglowNorm, -dir)), 5));
  end;;

  for i := 0 to RAY_STEPS - 1 do
  begin
    if (d.x > det) and (totdist < 3) then
    begin
      p       := from + totdist * dir;
      d       := de(p);
      det     := detail * (1 + totdist * 60) * (1 + ref * 5);
      totdist := totdist + (d.x);
      energy  := ENERGY_COLOR * (1.5 + sin(iGlobalTime * 20 + p.z * 10)) * 0.25;
      if d.x < 0.015 then
        glow := glow + (max(0, 0.015 - d.x) * exp(-totdist));
      if (d.y < 0.5) and (d.x < 0.03) then
      begin
        // ONLY DOING THE GLOW WHEN IT IS CLOSE ENOUGH
        glw   := Math.min(System.abs(3.35 - p.y - ey), System.abs(3.35 - p.y + ey));
        eglow := eglow + (max(0, 0.03 - d.x) / 0.03 * (pow(max(0, 0.05 - glw) / 0.05, 5) + pow(max(0, 0.15 - System.abs(3.35 - p.y)) / 0.15, 8)) * 1.5);
      end;

    end;

  end;

  l     := pow(Math.max(0, dot(normalize(-dir.xz), normalize(lightdir.xz))), 2);
  l     := l * (Math.max(0.2, dot(-dir, lightdir)));
  backg := 0.5 * (1.2 - l) + LIGHT_COLOR * l * 0.7;
  backg := backg * (AMBIENT_COLOR);
  if d.x <= det then
  begin
    norm := normal(p - abs(d.x - det) * dir);
    col  := light(p - abs(d.x - det) * dir, dir, norm, d.y) * exp(-0.2 * totdist * totdist);
    col  := mix(col, backg, 1 - exp(-1 * pow(totdist, 1.5)));
  end
  else
  begin
    col := backg;
  end;

  lglow := LIGHT_COLOR * pow(l, 30) * 0.5;
  col   := col + (glow * (backg + lglow) * 1.3);
  col   := col + (pow(eglow, 2) * energy * 0.015);
  col   := col + (lglow * min(1, totdist * totdist * 0.3));
  if ref > 0.5 then
  begin
    sphlight := light(origfrom + sphdist * origdir, origdir, sphNorm, 2);
    col      := mix(col * 0.3 + sphlight * 0.7, backg, 1 - exp(-1 * pow(sphdist, 1.5)));
  end;

  Exit(col);
end;

function TGeneratorsRedux.move(out rotview1, rotview2: mat2): vec3;
var
  go   : vec3;
  adv  : vec3;
  advec: vec3;
  an   : float;
  sa,ca:float;
begin
  go    := path(t);
  adv   := path(t + 0.7);
  advec := normalize(adv - go);

  an       := atan(advec.x, advec.z);
  sa       := system.sin(an);
  ca       := system.cos(an);
  rotview1 := mat2.Create(ca, sa, -sa, ca);

  an       := advec.y * 1.7;
  sa       := system.sin(an);
  ca       := system.cos(an);
  rotview2 := mat2.Create(ca, sa, -sa, ca);
  Exit(go);
end;

function TGeneratorsRedux.Main(var gl_FragCoord: vec2): TColor32;
var
  uv                : vec2;
  uv2               : vec2;
  mouse             : vec2;
  rotview1, rotview2: mat2;
  from              : vec3;
  dir               : vec3;
  color             : vec3;
{$IFDEF ENABLE_POSTPROCESS}
  rain              : vec3;
{$ENDIF}
begin
  pth1 := path(t + 0.3) + origin + vec3_19;
  uv   := gl_FragCoord.xy / resolution.xy * 2 - 1;
  uv2  := uv;
{$IFDEF ENABLE_POSTPROCESS}
  uv := uv * (1 + pow(length(uv2 * uv2 * uv2 * uv2), 4) * 0.07);
{$ENDIF }
  uv.y  := uv.y * (resolution.y / resolution.x);
  mouse := (iMouse.xy / resolution.xy - 0.5) * 3;
  if iMouse.z < 1 then
    mouse := vec2Black;

  from   := origin + move(rotview1, rotview2);
  dir    := normalize(vec3.Create(uv * 0.8, 1));
  dir.yz := dir.yz * rot(mouse.y);
  dir.xz := dir.xz * rot(mouse.x);
  dir.yz := dir.yz * rotview2;
  dir.xz := dir.xz * rotview1;
  color  := raymarch(from, dir);
  color  := clamp(color, vec3_21, vec3_20);
  color  := pow(color, vec3(GAMMA)) * BRIGHTNESS;
  color  := mix(vec3.Create(length(color)), color, SATURATION);
{$IFDEF ENABLE_POSTPROCESS}
  rain    := pow(texture2D(tex[15], uv2 + iGlobalTime * 7.25468).rgb, vec3_22);
  color   := mix(rain, color, clamp(iGlobalTime * 0.5 - 0.5, 0, 1));
  color   := color * (1 - pow(length(uv2 * uv2 * uv2 * uv2) * 1.1, 6));
  uv2.y   := uv2.y * (resolution.y / 360);
  color.r := color.r * ((0.5 + abs(0.5 - &mod(uv2.y, 0.021) / 0.021) * 0.5) * 1.5);
  color.g := color.g * ((0.5 + abs(0.5 - &mod(uv2.y + 0.007, 0.021) / 0.021) * 0.5) * 1.5);
  color.b := color.b * ((0.5 + abs(0.5 - &mod(uv2.y + 0.014, 0.021) / 0.021) * 0.5) * 1.5);
  color   := color * (0.9 + rain * 0.35);
{$ENDIF }
  Result := TColor32(color);
end;

initialization

GeneratorsRedux := TGeneratorsRedux.Create;
Shaders.Add('GeneratorsRedux', GeneratorsRedux);

finalization

FreeandNil(GeneratorsRedux);

end.
