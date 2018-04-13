unit WvN.DelphiShader.FX.WetStone;

interface

uses GR32, Types, WvN.DelphiShader.Shader, Math;

type

  // "Wet stone" by Alexander Alekseev aka TDM - 2014
  // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
  // Mahmud Yuldashev modification mahmud9935@gmail.com
  // Gold Nugget modifications by I.G.P. - 12/2014

{$DEFINE SMOOTH}
TWetStone = class(TShader)

const
  NUM_STEPS             = 32;
  AO_SAMPLES            = 4;
  AO_PARAM: vec2        = (x: 1.2; y: 3.8);
  CORNER_PARAM: vec2    = (x: 0.2; y: 20);
  INV_AO_SAMPLES: float = 1 / AO_SAMPLES;
  TRESHOLD: float       = 0.1;
  EPSILON: float        = 1E-4;
  LIGHT_INTENSITY       = 0.2;
  DISPLACEMENT: float   = 0.1;
  PI: float             = 3.1415;
  vec2_15: vec2         = (x: 127.1; y: 311.7);
  vec3_16: vec3         = (x: 1275.231; y: 4461.7; z: 7182.423);
  vec2_17: vec2         = (x: 0; y: 0);
  vec2_18: vec2         = (x: 1; y: 0);
  vec2_19: vec2         = (x: 0; y: 1);
  vec2_20: vec2         = (x: 1; y: 1);
  vec2_21: vec2         = (x: 0; y: 0);
  vec2_22: vec2         = (x: 1; y: 0);
  vec2_23: vec2         = (x: 0; y: 1);
  vec2_24: vec2         = (x: 1; y: 1);
  vec4_25: vec4         = (x: 0; y: 1; z: 0; w: 1);
  vec4_26: vec4         = (x: 0; y: 1; z: 0; w: 1);
  base: vec3            = (x: 0.42 * 0.8; y: 0.36 * 0.8; z: 0.14 * 0.8);
  sand: vec3            = (x: 0.44 * 0.8; y: 0.38 * 0.8; z: 0.2 * 0.8);
  vec3_29: vec3         = (x: 0; y: 0; z: 2.8);
  vec3_30: vec3         = (x: 0; y: 1; z: 0);

  RED: vec3             = (x: 1 * LIGHT_INTENSITY; y: 0.70 * LIGHT_INTENSITY; z: 0.70 * LIGHT_INTENSITY);
  RED_15: vec3          = (x: 1.5*1 * LIGHT_INTENSITY; y: 1.5*0.70 * LIGHT_INTENSITY; z: 1.5*0.70 * LIGHT_INTENSITY);
  // ORANGE :vec3 = (r:1    * LIGHT_INTENSITY; g:0.67 * LIGHT_INTENSITY; b:0.43 * LIGHT_INTENSITY);
  // BLUE   :vec3 = (r:0.54 * LIGHT_INTENSITY; g:0.77 * LIGHT_INTENSITY; b:1    * LIGHT_INTENSITY);
  // WHITE  :vec3 = (r:1.2  * LIGHT_INTENSITY; g:1.07 * LIGHT_INTENSITY; b:0.98 * LIGHT_INTENSITY);

  var
    ang:vec3;
    rot:mat3;

constructor Create; override;
procedure PrepareFrame;
function fromEuler(const ang: vec3): mat3;
function hash11(p: float): float;
function hash12(const p: vec2): float;
function hash31(p: float): vec3;
function noise_3(const p: vec3): float;
//function fbm3(const p: vec3; a, f: float): float;
function fbm3_high(const p: vec3; a, f: float): float;
function diffuse(const n, l: vec3; p: float): float;
function specular(const n, l, e: vec3; s: float): float;
function plane(const gp: vec3; const p: vec4): float;
function sphere(const p: vec3; r: float): float;
function capsule(p: vec3; r, h: float): float;
function cylinder(const p: vec3; r, h: float): float;
function box(p, s: vec3): float;
function rbox(p, s: vec3): float;
function quad(p: vec3; const s: vec2): float;
function boolUnion(a, b: float): float;inline;
function boolIntersect(a, b: float): float; inline;
function boolSub(a, b: float): float; inline;
function boolSmoothIntersect(a, b, k: float): float;
function boolSmoothSub(a, b, k: float): float; inline;
function rock(const p: vec3): float;
function map(const p: vec3): float;
function map_detailed(const p: vec3): float;
function getNormal(const p: vec3; dens: float): vec3;
function getOcclusion(const p, n: vec3): vec2;
function spheretracing(const ori, dir: vec3; out p: vec3): vec2;
function getStoneColor(const p: vec3; c: float; const n, e: vec3): vec3;
function main(var gl_FragCoord: vec2): TColor32;
end;

var
  WetStone: TShader;

implementation

uses SysUtils;

constructor TWetStone.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := main;
end;

procedure TWetStone.PrepareFrame;
begin
  // ray
  ang := vec3.Create(0, clamp(2 - mouse.y * 2, -PI, PI), mouse.x * 4 + time * 0.03);
  rot := fromEuler(ang);
end;

{$EXCESSPRECISION OFF}

function TWetStone.fromEuler(const ang: vec3): mat3;
var
  a1, a2, a3: vec2;
begin
  a1        := vec2.Create(sinLarge(ang.x), cosLarge(ang.x));
  a2        := vec2.Create(sinLarge(ang.y), cosLarge(ang.y));
  a3        := vec2.Create(sinLarge(ang.z), cosLarge(ang.z));

  Result.r1 := vec3.Create(a1.y * a3.y + a1.x * a2.x * a3.x, a1.y * a2.x * a3.x + a3.y * a1.x, -a2.y * a3.x);
  Result.r2 := vec3.Create(-a2.y * a1.x, a1.y * a2.y, a2.x);
  Result.r3 := vec3.Create(a3.y * a1.x * a2.x + a1.y * a3.x, a1.x * a3.x - a1.y * a3.y * a2.x, a2.y * a3.y);
end;

function TWetStone.hash11(p: float): float;
begin
  Result := fract(sinLarge(p * 727.1) * 43758.5453123);
end;

function TWetStone.hash12(const p: vec2): float;
var
  h: float;
begin
  h      := dot(p, vec2_15);
  Result := fract(sinLarge(h) * 43758.5453123);
end;

function TWetStone.hash31(p: float): vec3;
var
  h: vec3;
begin
  h      := vec3_16 * p;
  Result.x := fract(sinLarge(h.x) * 43758.543123);
  Result.y := fract(sinLarge(h.y) * 43758.543123);
  Result.z := fract(sinLarge(h.z) * 43758.543123);
end;

// 3d noise

function TWetStone.noise_3(const p: vec3): float;
var
  i, f, u           : vec3;
  ii                : vec2;
  a, b, c, d, v1, v2: float;
begin
  // p  := //p  + (123.0);
  i      := floor(p);
  f      := fract(p);
  u      := f * f * (3 - 2 * f);

  ii     := i.xy + i.z * vec2_17;
  a      := hash12(ii + vec2_17);
  b      := hash12(ii + vec2_18);
  c      := hash12(ii + vec2_19);
  d      := hash12(ii + vec2_20);
  v1     := mix(mix(a, b, u.x), mix(c, d, u.x), u.y);

  ii     := ii + (vec2_21);
  a      := hash12(ii + vec2_21);
  b      := hash12(ii + vec2_22);
  c      := hash12(ii + vec2_23);
  d      := hash12(ii + vec2_24);
  v2     := mix(mix(a, b, u.x), mix(c, d, u.x), u.y);

  Result := Math.Max(mix(v1, v2, u.z), 0);
end;

// fBm
//
//function TWetStone.fbm3(const p: vec3; a, f: float): float;
//begin
//  Exit(noise_3(p));
//end;

function TWetStone.fbm3_high(const p: vec3; a, f: float): float;
var
  ret, amp, frq: float;
  i            : int;
  n            : float;
begin
  ret   := 0;
  amp   := 1;
  frq   := 1;
  for i := 0 to 3 do
  begin
    n   := pow(noise_3(p * frq), 2);
    ret := ret + (n * amp);
    frq := frq * (f);
    amp := amp * (a * (pow(n, 0.2)));
  end;
  Exit(ret);
end;

// lighting

function TWetStone.diffuse(const n, l: vec3; p: float): float;
begin
  Result := pow(Math.Max(dot(n, l), 0), p);
end;

function TWetStone.specular(const n, l, e: vec3; s: float): float;
var
  nrm: float;
begin
  nrm    := (s + 8) * (1 / (3.1415 * 4));
  Result := pow(Math.Max(dot(reflect(e, n), l), 0), s) * nrm;
end;

// distance functions

function TWetStone.plane(const gp: vec3; const p: vec4): float;
begin
  Exit(dot(p.xyz, gp + p.xyz * p.w));
end;

function TWetStone.sphere(const p: vec3; r: float): float;
begin
  Exit(length(p) - r);
end;

function TWetStone.capsule(p: vec3; r, h: float): float;
begin
  p.y    := p.y - (clamp(p.y, -h, h));
  Result := length(p) - r;
end;

function TWetStone.cylinder(const p: vec3; r, h: float): float;
begin
  Result := Math.Max(System.abs(p.y / h), capsule(p, r, h));
end;

function TWetStone.box(p, s: vec3): float;
begin
  p      := abs(p) - s;
  Result := Math.Max(Math.Max(p.x, p.y), p.z);
end;

function TWetStone.rbox(p, s: vec3): float;
begin
  p      := abs(p) - s;
  Result := length(p - Min(p, 0));
end;

function TWetStone.quad(p: vec3; const s: vec2): float;
begin
  p      := abs(p) - vec3.Create(s.x, 0, s.y);
  Result := Math.Max(Math.Max(p.x, p.y), p.z);
end;

// boolean operations

function TWetStone.boolUnion(a, b: float): float;
begin
  Result := Math.Min(a, b);
end;

function TWetStone.boolIntersect(a, b: float): float;
begin
  Result := Math.Max(a, b);
end;

function TWetStone.boolSub(a, b: float): float;
begin
  Result := Math.Max(a, -b);
end;


// smooth operations. thanks to iq

function TWetStone.boolSmoothIntersect(a, b, k: float): float;
var
  h: float;
begin
  h := clamp(0.5 + 0.5 * (b - a) / k, 0, 1);
  Exit(mix(a, b, h) + k * h * (1 - h));
end;

function TWetStone.boolSmoothSub(a, b, k: float): float;
begin
  Exit(boolSmoothIntersect(a, -b, k));
end;

// world

function TWetStone.rock(const p: vec3): float;
var
  d    : float;
  i    : int;
  ii, r: float;
  v    : vec3;
begin
  d     := sphere(p, 1);
  for i := 0 to 8 do
  begin
    ii  := i;
    r   := 2 + hash11(ii);
    v   := normalize(hash31(ii) * 2.10 - 1);
{$IFDEF SMOOTH}
    d   := boolSmoothSub(d, sphere(p + v * r, r * 0.8), 0.03);
{$ELSE }
    d   := boolSub(d, sphere(p + v * r, r * 0.8));
{$ENDIF }
  end;
  Exit(d);
end;

function TWetStone.map(const p: vec3): float;
begin
//  Result := rock(p) + fbm3(p * 4, 0.4, 2.96) * DISPLACEMENT;
  Result := rock(p) + noise_3(p * 4) * DISPLACEMENT;
  Result := boolUnion(Result, plane(p, vec4_25));
end;

function TWetStone.map_detailed(const p: vec3): float;
begin
  Result := rock(p) + fbm3_high(p * 4, 0.4, 2.96) * DISPLACEMENT;
  Result := boolUnion(Result, plane(p, vec4_26));
end;

// tracing

function TWetStone.getNormal(const p: vec3; dens: float): vec3;
begin
  Result.x := map_detailed(vec3.Create(p.x + EPSILON, p.y, p.z));
  Result.y := map_detailed(vec3.Create(p.x, p.y + EPSILON, p.z));
  Result.z := map_detailed(vec3.Create(p.x, p.y, p.z + EPSILON));
  Result   := Result - map_detailed(p);
  Result.NormalizeSelf;
end;

function TWetStone.getOcclusion(const p, n: vec3): vec2;
var
  i                  : int;
  f, hao, hc, dao, dc: float;
begin
  Result     := vec2Black;
  for i      := 0 to AO_SAMPLES - 1 do
  begin
    f        := i * INV_AO_SAMPLES;
    hao      := 0.01 + f * AO_PARAM.x;
    hc       := 0.01 + f * CORNER_PARAM.x;
    dao      := map(p + n * hao) - TRESHOLD;
    dc       := map(p - n * hc) - TRESHOLD;
    Result.x := Result.x + (clamp(hao - dao, 0, 1) * (1 - f));
    Result.y := Result.y + (clamp(hc + dc, 0, 1) * (1 - f));
  end;
  Result.x   := pow(clamp(1 - Result.x * INV_AO_SAMPLES * AO_PARAM.y, 0, 1), 0.5);
  Result.y   := clamp(Result.y * INV_AO_SAMPLES * CORNER_PARAM.y, 0, 1);
end;

function TWetStone.spheretracing(const ori, dir: vec3; out p: vec3): vec2;
var
  td: vec2;
  i : int;
begin
  td     := vec2Black;
  for i  := 0 to NUM_STEPS - 1 do
  begin
    p    := ori + dir * td.x;
    td.y := map(p);
    if td.y < TRESHOLD then
      break;
    td.x := td.x + ((td.y - TRESHOLD) * 0.9);
  end;
  Exit(td);
end;

// stone

function TWetStone.getStoneColor(const p: vec3; c: float; const n, e: vec3): vec3;
var
  ic   : float;
  f    : float;
  nn   : vec3;
begin
  c     := Math.Min(c + pow(noise_3(vec3.Create(p.x * 20, 0, p.z * 20)), 70) * 8, 1);
  ic    := pow(1 - c, 0.5);
  Result := mix(base, sand, c);

  f       := pow(1 - Math.Max(dot(n, -e), 0), 1.5) * 0.75 * ic;
  Result  := mix(Result , Vec3White, f);
  Result  := Result  + (RED * diffuse(n, vec3Green, 0.5));
  Result  := Result  + (specular(n, vec3Green, e, 8) * RED_15 * ic);
  nn      := normalize(n - normalize(p) * 0.4);
  Result  := Result  + (specular(nn, vec3Green, e, 8) * RED_15 * ic);
end;

// main

function TWetStone.main(var gl_FragCoord: vec2): TColor32;
var
  uvy,uvx:float;
//  uv    : vec2;
  ori, dir, p: vec3;
  td         : vec2;
  n          : vec3;
  occ        : vec2;
  color      : vec3;
  vgn        : float;
begin
  uvx  := gl_FragCoord.x / resolution.x * 2 - 1;
  uvy  := gl_FragCoord.y / resolution.y * 2 - 1;
  uvx := uvx * (resolution.x / resolution.y);

  // ray
  ori := vec3_29;
  dir := normalize(vec3.Create(uvx,uvy, -2));
  ori := ori * rot;
  dir := dir * rot;

  // tracing

  td  := spheretracing(ori, dir, p);
  n   := getNormal(p, td.y);
  occ := getOcclusion(p, n);

  // color
  color   := vec3Gray;
  if (td.x < 3.5) and (p.y > -0.89) then
    color := getStoneColor(p, occ.y, n, dir);

  color   := color * occ.x;

  // background
  color := mix(vec3White, color, step(td.y, 1));

  // post
  vgn    := smoothstep(1.2, 0.7, System.abs(uvy)) *
            smoothstep(1.1, 0.8, System.abs(uvx));
  color  := color * (1 - (1 - vgn) * 0.15);
  Result := TColor32(color);
end;

initialization

WetStone := TWetStone.Create;
Shaders.Add('WetStone', WetStone);

finalization

FreeandNil(WetStone);

end.
