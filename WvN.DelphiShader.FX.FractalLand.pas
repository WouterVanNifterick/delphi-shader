unit WvN.DelphiShader.FX.FractalLand;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type

{x$DEFINE NYAN}
{x$DEFINE WAVES}
{x$DEFINE BORDER}
  TFractalLand = class(TShader)
  const

    RAY_STEPS  = 150;
    BRIGHTNESS = 1.2;
    GAMMA      = 1.4;
    SATURATION = 0.65;
    detail     = 0.001;

    vec3_02: vec3 = (x:0.2; y:0.2; z:0.2);
    vec3_10: vec3 = (x: - 1; y: 0.7; z: 0);
    vec4_11: vec4 = (x: 0; y: 0; z: 0; w: 0);
    vec4_12: vec4 = (x: 255; y: 43; z: 14; w: 255);
    vec4_13: vec4 = (x: 255; y: 168; z: 6; w: 255);
    vec4_14: vec4 = (x: 255; y: 244; z: 0; w: 255);
    vec4_15: vec4 = (x: 51; y: 234; z: 5; w: 255);
    vec4_16: vec4 = (x: 8; y: 163; z: 255; w: 255);
    vec4_17: vec4 = (x: 122; y: 85; z: 255; w: 255);
    vec4_18: vec4 = (x: 0; y: 0; z: 0; w: 1);
    vec4_19: vec4 = (x: 0; y: 0; z: 0; w: 1);
    vec4_20: vec4 = (x: 0; y: 0; z: 0; w: 0);
    vec2_21: vec2 = (x: 0.4; y: 1);
    vec3_22: vec3 = (x: 0; y: 0; z: 0);
    vec2_23: vec2 = (x: 0.6; y: 0.2);
    vec3_24: vec3 = (x: 1; y: 0.8; z: 0.15);
    vec3_25: vec3 = (x: 0.5; y: 0; z: 1);
    vec3_26: vec3 = (x: 1; y: 0.9; z: 0.1);
    vec3_27: vec3 = (x: 1; y: 0.9; z: 0.5);
    vec3_28: vec3 = (x: 1; y: 0.9; z: 0.3);
    vec3_29: vec3 = (x: 1; y: 0.9; z: 0.85);
    vec2_30: vec2 = (x: 0.8; y: 0.5);
    vec3_31: vec3 = (x: 0.2; y: 0.2; z: 0.2);
    vec2_32: vec2 = (x: 0; y: - 0.05);
    vec2_33: vec2 = (x: 1.05; y: 1.1);
    mp     : vec2 = (x:0.;y:-0.05);

  var
    t     : double;
    origin: vec3;
    det   : float;
    edge  : double;
    m:vec2;

    constructor Create; override;
    procedure PrepareFrame;
    function rot(a: float): mat2;
    function formula(p: vec4): vec4;
    function de(pos: vec3): float;
    function path(ti: float): vec3;
    function normal(const p: vec3): vec3;
    function rainbow(p: vec2): vec4;
    function nyan(const p: vec2): vec4;
    function raymarch(const from: vec3; dir: vec3): vec3;
    function move(out dir: vec3): vec3;
    function mainImage(var fragCoord: vec2): TColor32;
  end;

var
  FractalLand: TShader;

implementation

uses SysUtils, Math;

constructor TFractalLand.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
end;

procedure TFractalLand.PrepareFrame;
begin
  t := iGlobalTime * 0.5;
  m  := (iMouse.xy / resolution.xy - 0.5) * 3;
  if iMouse.z < 1 then
    m:=mp;

end;

function TFractalLand.rot(a: float): mat2;
begin
  Result := mat2.Create(cos(a), sin(a), -sin(a), cos(a));
end;

// "Amazing Surface" fractal
function TFractalLand.formula(p: vec4): vec4;
begin
  p.xz := abs(p.xz + 1) - abs(p.xz - 1) - p.xz;
  p.y  := p.y - 0.25;
  p.xy := p.xy * (rot(radians(35)));
  p    := p * 2 / clamp(dot(p.xyz, p.xyz), 0.2, 1);
  Exit(p);
end;

// Distance function
function TFractalLand.de(pos: vec3): float;
var
  tpos     : vec3;
  p        : vec4;
  i        : int;
  fr, ro, d: float;
begin
{$IFDEF WAVES}
  pos.y := pos.y + sinLarge(pos.z - t * 6) * 0.15;
{$ENDIF }
  tpos   := pos;
  tpos.z := abs(3 - &mod(tpos.z, 6));
  p      := vec4.Create(tpos, 1);
  for i  := 0 to 3 do
  begin
    p := formula(p);
  end;
  fr    := (length(max(vec2Black, p.yz - 1.5)) - 1) / p.w;
  ro    := max(abs(pos.x + 1) - 0.3, pos.y - 0.35);
  ro    := max(ro, -max(abs(pos.x + 1) - 0.1, pos.y - 0.5));
  pos.z := abs(0.25 - &mod(pos.z, 0.5));
  ro    := max(ro, -max(abs(pos.z) - 0.2, pos.y - 0.3));
  ro    := max(ro, -max(abs(pos.z) - 0.01, -pos.y + 0.32));
  d     := Math.min(fr, ro);
  Exit(d);
end;

// Camera path
function TFractalLand.path(ti: float): vec3;
begin
  ti := ti * 1.5;
  Result.x := sinLarge(ti)* 0.5;
  Result.y := ((1 - sinLarge(ti * 2)) * 0.5)* 0.5;
  Result.z := (-ti * 5) * 0.5;
end;

// Calc normals, and here is edge detection, set to variable "edge"
function TFractalLand.normal(const p: vec3): vec3;
var
  e                        : vec3;
  d1, d2, d3, d4, d5, d6, d: float;
begin
  e.x := 0; e.y := det * 5; e.z := 0;

  d1   := de(p - e.yxx);
  d2   := de(p + e.yxx);
  d3   := de(p - e.xyx);
  d4   := de(p + e.xyx);
  d5   := de(p - e.xxy);
  d6   := de(p + e.xxy);
  d    := de(p);
  edge := abs(d - 0.5 * (d2 + d1)) + abs(d - 0.5 * (d4 + d3)) + abs(d - 0.5 * (d6 + d5)); // edge finder
  edge := min(1, pow(edge, 0.55) * 15);
  Result := vec3.Create(d1 - d2, d3 - d4, d5 - d6);
  Result.NormalizeSelf;
end;

// Used Nyan Cat code by mu6k, with some mods
function TFractalLand.rainbow(p: vec2): vec4;
var
  s: float;
  c   : vec4;
begin
  s   := SinLarge(p.x * 7 + t * 70) * 0.08;
  p.y := p.y + (s);
  p.y := p.y * (1.1);
  if p.x > 0 then
    c := vec4_11
  else if (0 / 6 < p.y) and (p.y < 1 / 6) then c := vec4_12 / 255
  else if (1 / 6 < p.y) and (p.y < 2 / 6) then c := vec4_13 / 255
  else if (2 / 6 < p.y) and (p.y < 3 / 6) then c := vec4_14 / 255
  else if (3 / 6 < p.y) and (p.y < 4 / 6) then c := vec4_15 / 255
  else if (4 / 6 < p.y) and (p.y < 5 / 6) then c := vec4_16 / 255
  else if (5 / 6 < p.y) and (p.y < 6 / 6) then c := vec4_17 / 255
  else if (abs(p.y) - 0.05) < 0.0001      then c := vec4_18
  else if (abs(p.y - 1) - 0.05) < 0.0001  then c := vec4_19
  else                                         c := vec4_20;

  c.a   := c.a * (0.8 - min(0.8, abs(p.x * 0.08)));
  c.xyz := mix(c.xyz, vec3(length(c.xyz)), 0.15);
  Exit(c);
end;

function TFractalLand.nyan(const p: vec2): vec4;
var
  uv        : vec2;
  ns, nt, ny: float;
  color     : vec4;
begin
  ns    := 3;
  nt    := iGlobalTime * ns;
  nt    := nt - (&mod(nt, 240 / 256 / 6));
  nt    := &mod(nt, 240 / 256);
  ny    := &mod(iGlobalTime * ns, 1);
  ny    := ny - (&mod(ny, 0.75));
  ny    := ny * (-0.05);
  color := texture2D(tex[1], vec2.Create(uv.x / 3 + 210 / 256 - nt + 0.05, 0.5 - uv.y - ny));
  if uv.x < -0.3 then
    color.a := 0;
  if uv.x > 0.2 then
    color.a := 0;
  Exit(color);
end;


// Raymarching and 2D graphics

function TFractalLand.raymarch(const from: vec3; dir: vec3): vec3;
var
  p, norm                  : vec3;
  d, totdist               : float;
  i                        : int;
  col                      : vec3;
  sunsize, an, s, sb, sg, y: float;
  backg                    : vec3;
{$IFDEF NYAN}
  ncatpos                  : vec2;
  ncat : vec4;
  rain               : vec4;
{$ENDIF}
begin
  edge    := 0;
  d       := 100;
  totdist := 0;
  for i   := 0 to RAY_STEPS - 1 do
  begin
    if (d > det) and (totdist < 25) then
    begin
      p       := from + totdist * dir;
      d       := de(p);
      det     := detail * exp(0.13 * totdist);
      totdist := totdist + (d);
    end;
  end;
  col  := vec3_22;
  p    := p - ((det - d) * dir);
  norm := normal(p);
{$IFDEF SHOWONLYEDGES}
  col = 1 - vec3(edge); // show wireframe version
{$ELSE }
  col := (1 - abs(norm)) * max(0, 1 - edge * 0.8); // set normal as color with dark edges
{$ENDIF }
  totdist := clamp(totdist, 0, 26);
  dir.y   := dir.y - (0.02);
  sunsize  := 7-math.max(0,texture2D(tex[0],vec2_23).x)*5;
  an      := atan(dir.x, dir.y) + iGlobalTime * 1.5;
  s       := pow(clamp(1 - length(dir.xy) * sunsize - abs(0.2 - &mod(an, 0.4)), 0, 1), 0.1);
  sb      := pow(clamp(1 - length(dir.xy) * (sunsize - 0.2) - abs(0.2 - &mod(an, 0.4)), 0, 1), 0.1);
  sg      := pow(clamp(1 - length(dir.xy) * (sunsize - 4.5) - 0.5 * abs(0.2 - &mod(an, 0.4)), 0, 1), 3);
  y       := mix(0.45, 1.2, pow(smoothstep(0, 1, 0.75 - dir.y), 2)) * (1 - sb * 0.5);
  // set up background with sky and sun
  backg := vec3_25 * ((1 - s) * (1 - sg) * y + (1 - sb) * sg * vec3_24 * 3);
  backg := backg + (vec3_26 * s);
  backg := max(backg, sg * vec3_27);
  col   := mix(vec3_28, col, exp(-0.004 * totdist * totdist)); // distant fading to sun color
  if totdist > 25 then
    col := backg; // hit background
  col   := pow(col, vec3(GAMMA)) * BRIGHTNESS;
  col   := mix(vec3.Create(length(col)), col, SATURATION);
{$IFDEF SHOWONLYEDGES}
  col := 1 - vec3(length(col));
{$ELSE }
  col := col * vec3_29;
{$IFDEF NYAN}
  dir.yx  := dir.yx * (rot(dir.x));
  ncatpos := (dir.xy + vec2.Create(-3 + &mod(-t, 6), -0.27));
  ncat    := nyan(ncatpos * 5);
  if totdist > 8 then
    col := mix(col, max(vec3_02, rain.xyz), rain.a * 0.9);
  if totdist > 8 then
    col := mix(col, max(vec3_02, ncat.xyz), ncat.a * 0.9);
{$ENDIF }
{$ENDIF }
  result := col;
end;

function TFractalLand.move(out dir: vec3): vec3;
var
  go, adv: vec3;
  hd     : float;
  advec  : vec3;
  an     : float;
  sa,ca  : float;
begin
  // get camera position
  go     := path(t);
  adv    := path(t + 0.7);
  hd     := de(adv);
  advec  := normalize(adv - go);
  an     := adv.x - go.x;
  an     := an * (math.min(1, abs(adv.z - go.z)) * sign(adv.z - go.z) * 0.7);
  sa     := system.Sin(an);
  ca     := system.Cos(an);
  dir.xy := dir.xy * mat2.Create(ca, sa, -sa, ca);
  an     := advec.y * 1.7;
  sa     := system.Sin(an);
  ca     := system.Cos(an);
  dir.yz := dir.yz * mat2.Create(ca, sa, -sa, ca);
  an     := atan(advec.x, advec.z);
  sa     := system.Sin(an);
  ca     := system.Cos(an);
  dir.xz := dir.xz * mat2.Create(ca, sa, -sa, ca);
  Result := go;
end;

function TFractalLand.mainImage(var fragCoord: vec2): TColor32;
var
  uv, oriuv: vec2;
  fov             : float;
  dir, from, color: vec3;
begin
  uv    := fragCoord.xy / resolution.xy * 2 - 1;
  oriuv := uv;
  uv.y  := uv.y * (resolution.y / resolution.x);
  fov  := 0.9 - max(0, 0.7 - iGlobalTime * 0.3);
  dir    := normalize(vec3.Create(uv * fov, 1));
  dir.yz := dir.yz * (rot(m.y));
  dir.xz := dir.xz * (rot(m.x));
  from   := origin + move(dir);
  color  := raymarch(from, dir);
{$IFDEF BORDER}
{$ENDIF }
  Result := TColor32(color);
end;

initialization

FractalLand := TFractalLand.Create;
Shaders.Add('FractalLand', FractalLand);

finalization

FreeandNil(FractalLand);

end.
