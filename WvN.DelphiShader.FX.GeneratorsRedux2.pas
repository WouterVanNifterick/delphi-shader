unit WvN.DelphiShader.FX.GeneratorsRedux2;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

{$DEFINE ENABLE_POSTPROCESS}

type
  TGeneratorsReflux = class(TShader)
  const
    RAY_STEPS           = 30;
    SHADOW_STEPS        = 1;
    LIGHT_COLOR: vec3   = (x: 0.85; y: 0.9; z: 1);
    AMBIENT_COLOR: vec3 = (x: 0.8; y: 0.83; z: 1);
    FLOOR_COLOR: vec3   = (x: 1; y: 0.7; z: 0.9);
    ENERGY_COLOR: vec3  = (x: 1; y: 0.7; z: 0.4);
    BRIGHTNESS          = 0.9;
    GAMMA               = 1.4;
    SATURATION          = 0.85;
    detail              = 0.0001;
    vec3_12: vec3       = (x: 0.4; y: -0.3; z:-1);
    vec3_13: vec3       = (x: 0; y: 0; z: 1);
    vec3_14: vec3       = (x: 0   ;y: 3.11; z: 0   );
    vec3_15: vec3       = (x: 0.01;y: 0.01; z: 0.01);
    vec3_16: vec3       = (x:-0.02;y: 1.98;z:-0.02);
    vec4_17: vec4       = (x: 0.5; y: 1  ; z: 0.4; w: 0);
    vec3_18: vec3       = (x: 0.1; y: 5;   z: 0.1);
    vec3_19: vec3       = (x: 0  ; y: 0  ; z: 0  );
    vec3_20: vec3       = (x: 3  ; y: 3  ; z: 3  );
    vec3_21: vec3       = (x: 0  ; y: 1  ; z: 0  );
    vec3_22: vec3       = (x: 1  ; y: 1  ; z: 1  );
    vec2_23: vec2       = (x: 1  ; y: 0  );
    vec3_24: vec3       = (x: 0  ; y: 0  ; z: 0  );
    vec3_25: vec3       = (x: 0  ; y: 0.01;z: 0  );
    vec3_26: vec3       = (x: 1  ; y:   1; z: 1  );
    vec3_27: vec3       = (x: 0  ; y: 0  ; z: 0  );
    vec3_28: vec3       = (x: 1.5; y: 1.5; z: 1.5);

  var
    t: double;

    lightdir, ambdir, origin, energy: vec3;
    vibration, det                  : float;
    pth1                            : vec3;

    constructor Create; override;
    procedure PrepareFrame;
    function rot(a: float): mat2;
    procedure prepFrame;
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
    function main(var gl_FragCoord: vec2): TColor32;
  end;

var
  GeneratorsReflux: TShader;

implementation

uses SysUtils, Math;

constructor TGeneratorsReflux.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := main;
end;

procedure TGeneratorsReflux.PrepareFrame;
begin
  t := time * 0.25;
end;

function TGeneratorsReflux.rot(a: float): mat2;
begin
  Exit(mat2.Create(cos(a), sin(a), -sin(a), cos(a)));
end;

procedure TGeneratorsReflux.prepFrame;
begin
  lightdir := normalize(vec3_12);
  ambdir   := normalize(vec3_13);
  origin   := vec3_14;
  energy   := vec3_15;
{$IFDEF ENABLE_VIBRATION}
  vibration := sin(time * 60) * 0.0013;
{$ELSE }
  vibration := 0;
{$ENDIF }
  det := 0;
end;

function TGeneratorsReflux.path(ti: float): vec3;
begin
  Exit(vec3.Create(sin(ti), 0.3 - sin(ti * 0.632) * 0.3, cos(ti * 0.5)) * 0.5);
end;

function TGeneratorsReflux.Sphere(const p, rd: vec3; r: float): float;
var
  b, inner: float;
begin
  b     := dot(-p, rd);
  inner := b * b - dot(p, p) + r * r;
  if inner < 0 then
    Exit(-1);
  Exit(b - System.sqrt(inner));
end;

function TGeneratorsReflux.de(const pos: vec3): vec2;
var
  hid      : float;
  tpos     : vec3;
  p        : vec4;
  y        : float;
  i        : int;
  fl, fr, d: float;
begin
  hid     := 0;
  tpos    := pos;
  tpos.xz := abs(0.5 - &mod(tpos.xz, 1));
  p       := vec4.Create(tpos, 1);
  y       := max(0, 0.35 - abs(pos.y - 3.35)) / 0.35;
  for i   := 0 to 6 do
  begin // LOWERED THE ITERS
    p.xyz := abs(p.xyz) - vec3_16;
    p     := p * (2 + vibration * y) / clamp(dot(p.xyz, p.xyz), 0.4, 1) - vec4_17;
    p.xz  := p.xz * (mat2.Create(-0.416, -0.91, 0.91, -0.416));
  end;
  fl := pos.y - 3.013;
  fr := (length(max(abs(p.xyz) - vec3_18, vec3_19)) - 0.05) / p.w;
  // fr := length(p.xyz)/p.w;
  d := Math.min(fl, fr);
  d := Math.min(d, -pos.y + 3.95);
  if abs(d - fl) < 0.001 then
    hid := 1;
  Exit(vec2.Create(d, hid));
end;

function TGeneratorsReflux.normal(const p: vec3): vec3;
var
  e: vec3;
begin
  e        := vec3.Create(0, det, 0);
  Result.x := de(p + e.yxx).x - de(p - e.yxx).x;
  Result.y := de(p + e.xyx).x - de(p - e.xyx).x;
  Result.z := de(p + e.xxy).x - de(p - e.xxy).x;

  Result.NormalizeSelf;
end;

function TGeneratorsReflux.shadow(const pos, sdir: vec3): float;
var
  sh, totdist, dist, t1: float;
  sphglowNorm          : vec3;
  steps                : int;
  p                    : vec3;
begin
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
  begin
    if (totdist < 0.6) and (dist > detail) then
    begin
      p       := pos - totdist * sdir;
      dist    := de(p).x;
      sh      := min(sh, max(50 * dist / totdist, 0));
      totdist := totdist + (max(0.01, dist));
    end;
  end;
  Exit(clamp(sh, 0.1, 1));
end;

function TGeneratorsReflux.calcAO(const pos, nor: vec3): float;
var
  aodet, totao, sca: float;
  aoi              : int;
  hr               : float;
  aopos            : vec3;
  dd               : float;
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
    sca   := sca * (0.7);
  end;
  Exit(clamp(1 - 5 * totao, 0, 1));
end;

function TGeneratorsReflux.texture(p: vec3): float;
var
  c    : vec3;
  es, l: float;
  i    : int;
  pl   : float;
begin
  p     := abs(0.5 - fract(p * 10));
  c     := vec3_20;
  es    := 0;
  l     := 0;
  for i := 0 to 9 do
  begin
    p := abs(p + c) - abs(p - c) - p;
    p := p / (clamp(dot(p, p), 0, 1));
    p := p * -1.5 + c;
    if Odd(i) then
    begin
      pl := l;
      l  := length(p);
      es := es + (exp(-1 / abs(l - pl)));
    end;
  end;
  Exit(es);
end;

function TGeneratorsReflux.light(const p, dir, n: vec3; const hid: float): vec3;
var
  sh, ao, diff, y: float;
  amb, r         : vec3;
  spec           : float;
  col            : vec3;
  energysource, k: float;
begin
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
    amb := amb + (max(0.2, dot(vec3_21, -n)) * FLOOR_COLOR * pow(max(0, 0.2 - abs(3 - p.y)) / 0.2, 1.5) * 2);
    amb := amb + (energy * pow(max(0, 0.4 - abs(y)) / 0.4, 2) * max(0.2, dot(vec3.Create(0, -Math.sign(y), 0), -n)) * 2);
  end;
  r            := reflect(lightdir, n);
  spec         := power(Math.max(0, dot(dir, -r)) * sh, 10);
  energysource := pow(max(0, 0.04 - abs(y)) / 0.04, 4) * 2;
  if hid > 1.5 then
  begin
    col  := vec3_22;
    spec := spec * spec;
  end
  else
  begin
    k   := texture(p) * 0.23 + 0.2;
    k   := min(k, 1.5 - energysource);
    col := mix(vec3.Create(k, k * k, k * k * k), vec3(k), 0.3);
    if abs(hid - 1) < 0.001 then
      col := col * (FLOOR_COLOR * 1.3);
  end;
  col := col * (amb + diff * LIGHT_COLOR) + spec * LIGHT_COLOR;
  if hid < 0.5 then
  begin
    col := max(col, energy * 2 * energysource);
  end;
  col := col * (min(1, ao + length(energy) * 0.5 * max(0, 0.1 - abs(y)) / 0.1));
  Exit(col);
end;

function TGeneratorsReflux.raymarch(from, dir: vec3): vec3;
var
  ey, glow, eglow, ref, sphdist, totdist : float;
  d                                      : vec2;
  p, col, origdir, origfrom, sphNorm, wob: vec3;
  t1, tg                                 : float;
  sphglowNorm                            : vec3;
  i                                      : int;
  glw, l                                 : float;
  backg, norm, lglow, sphlight           : vec3;
begin
  ey      := &mod(t * 0.5, 1);
  glow    := 0;
  eglow   := 0;
  totdist := 0;
  ref     := 0;
  sphdist := 0;
  p       := vec3_24;
  col     := vec3_24;
  origdir := dir;
  // FAKING THE SQUISHY BALL BY MOVING A RAY TRACED BALL
  wob := cos(dir * 500 * length(from - pth1) + (from - pth1) * 250 + time * 10) * 0.0005;
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
      energy  := ENERGY_COLOR * (1.5 + sin(time * 20 + p.z * 10)) * 0.25;
      if d.x < 0.015 then
        glow := glow + (max(0, 0.015 - d.x) * exp(-totdist));
      if (d.y < 0.5) and (d.x < 0.03) then
      begin // ONLY DOING THE GLOW WHEN IT IS CLOSE ENOUGH
        glw   := math.min(abs(3.35 - p.y - ey), abs(3.35 - p.y + ey));
        eglow := eglow + (max(0, 0.03 - d.x) / 0.03 * (pow(max(0, 0.05 - glw) / 0.05, 5) + power(max(0, 0.15 - abs(3.35 - p.y)) / 0.15, 8)) * 1.5);
      end;
    end;
  end;
  l     := pow(Math.max(0, dot(normalize(-dir.xz), normalize(lightdir.xz))), 2);
  l     := l * (max(0.2, dot(-dir, lightdir)));
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

function TGeneratorsReflux.move(out rotview1, rotview2: mat2): vec3;
var
  go, adv, advec: vec3;
  an            : float;
begin
  go       := path(t);
  adv      := path(t + 0.7);
  advec    := normalize(adv - go);
  an       := atan(advec.x, advec.z);
  rotview1 := mat2.Create(cos(an), sin(an), -sin(an), cos(an));
  an       := advec.y * 1.7;
  rotview2 := mat2.Create(cos(an), sin(an), -sin(an), cos(an));
  Exit(go);
end;

function TGeneratorsReflux.main(var gl_FragCoord: vec2): TColor32;
var
  uv, uv2, mouse        : vec2;
  rotview1, rotview2    : mat2;
  from, dir, color, rain: vec3;
begin
  pth1 := path(t + 0.3) + origin + vec3_25;
  uv   := gl_FragCoord.xy / resolution.xy * 2 - 1;
  uv2  := uv;
{$IFDEF ENABLE_POSTPROCESS}
  uv := uv * (1 + pow(length(uv2 * uv2 * uv2 * uv2), 4) * 0.07);
{$ENDIF }
  uv.y  := uv.y * (resolution.y / resolution.x);
  mouse := (mouse.xy / resolution.xy - 0.5) * 3;
  if mouse.x < 1 then
    mouse := vec2Black;
  from    := origin + move(rotview1, rotview2);
  dir     := normalize(vec3.Create(uv * 0.8, 1));
  dir.yz  := dir.yz * (rot(mouse.y));
  dir.xz  := dir.xz * (rot(mouse.x));
  dir.yz  := dir.yz * (rotview2);
  dir.xz  := dir.xz * (rotview1);
  color   := raymarch(from, dir);
  color   := clamp(color, vec3_27, vec3_26);
  color   := pow(color, vec3(GAMMA)) * BRIGHTNESS;
  color   := mix(vec3.Create(length(color)), color, SATURATION);
{$IFDEF ENABLE_POSTPROCESS}
  rain    := vec3.Create(0); // pow(texture2D(iChannel0,uv2+iGlobalTime*7.25468).rgb,vec3_28);
  color   := mix(rain, color, clamp(time * 0.5 - 0.5, 0, 1));
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

GeneratorsReflux := TGeneratorsReflux.Create;
Shaders.Add('GeneratorsReflux', GeneratorsReflux);

finalization

FreeandNil(GeneratorsReflux);

end.
