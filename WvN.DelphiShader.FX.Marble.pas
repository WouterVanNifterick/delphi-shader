unit WvN.DelphiShader.FX.Marble;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  // https://www.shadertoy.com/view/MtX3Ws#

  TMarble = class(TShader)
  const
    zoom         = 1;
    vec2_1: vec2 = (x: -1; y: -1);
    vec2_3: vec2 = (x: 0; y: 0);
    vec3_4: vec3 = (x: 4; y: 4; z: 4);
    ta: vec3     = (x: 0; y: 0; z: 0);
    vec3_6: vec3 = (x: 0; y: 1; z: 0);
    vec4_7: vec4 = (x: 0; y: 0; z: 0; w: 2);
  var
    m             : vec2;
    res           : Double;
    ro, ww, uu, vv: vec3;
    constructor Create; override;
    function cmul(const a, b: vec2): vec2;inline;
    function csqr(const a: vec2): vec2;inline;
    function rot(a: float): mat2;
    function iSphere(const ro, rd: vec3; const sph: vec4): vec2;
    function map(p: vec3): float;
    function raymarch(const ro, rd: vec3; const tminmax: vec2): vec3;
    procedure PrepareFrame;
    function mainImage(var fragCoord: vec2): TColor32;
  end;

var
  Marble: TShader;

implementation

uses SysUtils, Math;

constructor TMarble.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
end;

function TMarble.cmul(const a, b: vec2): vec2;
begin
  Result.x := a.x * b.x - a.y * b.y;
  Result.y := a.x * b.y + a.y * b.x;
end;

function TMarble.csqr(const a: vec2): vec2;
begin
  Result.x := a.x * a.x - a.y * a.y;
  Result.y := 2 * a.x * a.y;
end;

function TMarble.rot(a: float): mat2;
var sa,ca:double;
begin
  sa := sinLarge(a);
  ca := cosLarge(a);
  Result.r1.x := ca;
  Result.r1.y := ca;
  Result.r2.x := -sa;
  Result.r2.y := ca;
end;

function TMarble.iSphere(const ro, rd: vec3; const sph: vec4): vec2;
var
  oc     : vec3;
  b, c, h: float;
begin
  oc := ro - sph.xyz;
  b  := dot(oc, rd);
  c  := dot(oc, oc) - sph.w * sph.w;
  h  := b * b - c;
  if h < 0 then
    Exit(vec2_1);
  h := System.sqrt(h);
  Result.x := -b - h;
  Result.y := -b + h;
end;

function TMarble.map(p: vec3): float;
var
  res: float;
  c  : vec3;
  i  : int;
begin
  res   := 0;
  c     := p;
  for i := 0 to 9 do
  begin
    p    := 0.7 * abs(p) / dot(p, p) - 0.7;
    p.yz := csqr(p.yz);
    p    := p.zxy;
    res  := res + (exp(-19 * abs(dot(p, c))));
  end;
  Result := res * 0.5;
end;

function TMarble.raymarch(const ro, rd: vec3; const tminmax: vec2): vec3;
var
  t, dt: float;
  col  : vec3;
  c    : float;
  i    : int;
  pos  : vec3;
begin
  t     := tminmax.x;
  dt    := 0.02;
  col   := vec3Black;
  c     := 0;
  for i := 0 to 63 do
  begin
    t := t + (dt * exp(-2 * c));
    if t > tminmax.y then
      break;
    pos := ro + t * rd;
    c   := map(ro + t * rd);
    col := 0.99 * col + 0.08 * vec3.Create(c * c, c, c * c * c); // green
  end;
  Result := col;
end;

procedure TMarble.PrepareFrame;
begin
  m := vec2_3;
  if iMouse.z > 0 then
    m := iMouse.xy / resolution.xy * 3.14;
  m   := m - 0.5;

  // camera
  ro    := zoom * vec3_4;
  ro.yz := ro.yz * (rot(m.y));
  ro.xz := ro.xz * (rot(m.x + 0.1 * time));
  ww    := normalize(ta - ro);
  uu    := normalize(cross(ww, vec3_6));
  vv    := normalize(cross(uu, ww));
  res   := resolution.x / resolution.y;
end;

function TMarble.mainImage(var fragCoord: vec2): TColor32;
var
  q, p    : vec2;
  rd      : vec3;
  tmm     : vec2;
  col, nor: vec3;
  fre     : float;
begin
  q   := fragCoord.xy / resolution.xy;
  p   := -1 + 2 * q;
  p.x := p.x * res;

  rd  := normalize(p.x * uu + p.y * vv + 4 * ww);
  tmm := iSphere(ro, rd, vec4_7);
  // raymarch
  col := raymarch(ro, rd, tmm);
  if tmm.x < 0 then
    col := textureCube(cubes[2], rd).rgb
  else
  begin
    nor := (ro + tmm.x * rd) / 2;
    nor := reflect(rd, nor);
    fre := power(0.5 + clamp(dot(nor, rd), 0, 1), 3) * 1.3;

    col := col + textureCube( cubes[2], nor).rgb * fre;
  end;
  // shade
//  col    := 0.5 * log(1 + col);
  assert(col.x>0); assert(col.y>0); assert(col.z>0);

  col.x    := 0.5 * log2(1 + col.x);
  col.y    := 0.5 * log2(1 + col.y);
  col.z    := 0.5 * log2(1 + col.z);

  col    := clamp(col, 0, 1);
  Result := TColor32(col);
end;

initialization

Marble := TMarble.Create;
Shaders.Add('Marble', Marble);

finalization

FreeandNil(Marble);

end.

