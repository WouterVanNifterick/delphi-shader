unit WvN.DelphiShader.FX.Avatar;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TAvatar = class(TShader)
  private const
    Iterations   = 16;
    detail       = 0.075;
    e_yxx : vec3 = (x:detail; y:0;z:0);
    e_xyx : vec3 = (x:  0  ; y:detail;z:0);
    e_xxy : vec3 = (x:  0  ; y:0;z:detail);
    vec3_1: vec3 = (x: -2  ; y: -1.5; z: -0.5);
    vec3_2: vec3 = (x:  0.5; y: -0.05; z: -0.5);
    vec3_3: vec3 = (x: -0.5; y: -1; z: -0.5);
    vec3_4: vec3 = (x: 1; y: 1; z: 1);
    vec3_6: vec3 = (x: 0; y: -0.7; z: -20);

    function normal(const p: vec3): vec3;
    function softshadow(const ro, rd: vec3; mint, k: float): float;
    function light(const p, dir: vec3; d: float): vec4;
    function raymarch(const from, dir: vec3): vec4;
    function Main(var gl_FragCoord: Vec2): TColor32;
    function rotationMatrix3(const v: vec3; angle: float): mat3;
    function de(const aP: vec3): float;

  var
    t   : float;
    time: float;
    a   : float;
    rot3 : mat3;
    Ci,
    Scale     : float;
    Julia     : vec3;
    RotVector : vec3;
    RotAngle  : float;
    Speed     : float;
    Amplitude : float;
    lightdir  : vec3;
    rot,Mat2Rot : mat2;
    v3Rot:Vec3;
  public
    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Avatar: TShader;

implementation

uses SysUtils, Math;

constructor TAvatar.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TAvatar.PrepareFrame;
begin
  Scale      := 1.27;
  Julia      := vec3_1;
  RotVector  := vec3_2;
  RotAngle   := 145;
  Speed      := 1.3;
  Amplitude  := 0.25;
  lightdir   := vec3_3;

  time := iGlobalTime * Speed;
  t    := iGlobalTime * 0.3;

  ci := pow(Scale, -Iterations) * 0.9;
  a    := 1.5 + system.sin(iGlobalTime * 0.5) * 0.5;
  Mat2Rot := mat2.Create(system.cos(a), system.sin(a), -system.sin(a), system.cos(a));
  v3Rot := vec3.Create(system.sin(time), system.sin(time), system.cos(time))  * Amplitude;
  rot3 := rotationMatrix3(normalize(RotVector + v3Rot), RotAngle + system.sin(time) * 10);
  rot     := mat2.Create(system.cos(-0.5), system.sin(-0.5), -system.sin(-0.5), system.cos(-0.5));
end;

function TAvatar.normal(const p: vec3): vec3;
begin
  Result.x := de(p + e_yxx) - de(p - e_yxx);
  Result.y := de(p + e_xyx) - de(p - e_xyx);
  Result.z := de(p + e_xxy) - de(p - e_xxy);
  Result.NormalizeSelf;
end;

function TAvatar.softshadow(const ro, rd: vec3; mint, k: float): float;
var
  res: float;
  t  : float;
  i  : integer;
  h  : float;
begin
  res   := 1;
  t     := mint;
  for i := 0 to 47 do
  begin
    h   := de(ro + rd * t);
    h   := Math.max(h, 0);
    res := Math.min(res, k * h / t);
    t   := t + (clamp(h, 0.01, 0.5));
  end;

  Exit(clamp(res, 0, 1));
end;

function TAvatar.light(const p, dir: vec3; d: float): vec4;
var
  lightCol: vec4;
  ldir    : vec3;
  n       : vec3;
  sh      : float;
  diff    : float;
  r       : vec3;
  spec    : float;
  ray     : vec3;
begin
  ldir     := normalize(lightdir);
  n        := normal(p);
  sh       := softshadow(p, -ldir, 1, 20);
  diff     := Math.max(0, dot(ldir, -n));
  r        := reflect(ldir, n);
  spec     := Math.max(0, dot(dir, -r));
  ray      := 0.8 * d * ((0.4 * p - 3 * r) + d * vec3_4);
  lightCol := texture2D(tex[0], ray.xz + ray.xy);
  Exit(3 * lightCol * diff * sh + power(spec, 30) * 0.5 * sh + 0.15 * Math.max(0, dot(normalize(dir), -n)));
end;

function TAvatar.raymarch(const from, dir: vec3): vec4;
var
  st     : float;
  d      : float;
  totdist: float;
  p      : vec3;
  i      : integer;
begin

  d       := 1;
  totdist := 0;
  st      := 0;

  for i := 0 to 29 do
  begin
    if (d > detail) and (totdist < 150) then
    begin
      p       := from + totdist * dir;
      d       := de(p);
      totdist := totdist + d;
    end;

  end;

  if d < detail then
    Result := light(p, dir, d)
  else
    Result := vec4Black;

  // Result  := mix(Result , backg, 1.0-exp(-.000025*pow(totdist,3.5)));
end;

function TAvatar.Main(var gl_FragCoord: Vec2): TColor32;
var
  uv  : Vec2;
  from: vec3;
  dir : vec3;
  col : vec4;
begin
  uv   := gl_FragCoord.xy / resolution.xy * 2 - 1;
  uv.y := uv.y * (resolution.y / resolution.x);
  from := vec3_6;
  dir  := vec3.Create(uv * 0.7, 1);
  dir.NormalizeSelf;
  dir.yz  := dir.yz * rot;
  from.yz := from.yz * rot;
  col     := raymarch(from, dir);
  Result  := TColor32(col);
end;

function TAvatar.rotationMatrix3(const v: vec3; angle: float): mat3;
var
  c,s,d: float;
begin
  c := system.cos(radians(angle));
  s := system.sin(radians(angle));

  d := 1-c;
  Result := mat3.Create(
    c + d * v.x * v.x,
        d * v.x * v.y - s * v.z,
        d * v.x * v.z + s * v.y,
        d * v.x * v.y + s * v.z,
    c + d * v.y * v.y,
        d * v.y * v.z - s * v.x,
        d * v.x * v.z - s * v.y,
        d * v.y * v.z + s * v.x,
    c + d * v.z * v.z);
end;

function TAvatar.de(const aP: vec3): float;
var
  p  : vec3;
  l   : float;
  i   : integer;
begin
  p    := aP;
  p    := p.zxy;
  p.xy := p.xy * mat2Rot;
  p.x  := p.x * 0.75;

  p   := p + (sin(p * 3 + time * 6) * 0.04);

  for i := 0 to Iterations - 1 do
  begin
    p.xy := abs(p.xy);
    p    := p * Scale + Julia;
    p    := p * rot3;
    l    := length(p);
  end;
  Exit(l * ci);
end;

initialization

Avatar := TAvatar.Create;
Shaders.Add('Avatar', Avatar);

finalization

FreeandNil(Avatar);

end.
