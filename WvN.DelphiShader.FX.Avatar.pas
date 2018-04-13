unit WvN.DelphiShader.FX.Avatar;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type

  // http://www.fractalforums.com/movies-showcase-%28rate-my-movie%29/very-rare-deep-sea-fractal-creature/
  // https://www.shadertoy.com/view/MdS3zm

  TAvatar = class(TShader)
  private const
    detail = 0.075;

    vec3_1: vec3 = (x: - 2; y: - 1.5; z: - 0.5);
    vec3_2: vec3 = (x: 0.5; y: - 0.05; z: - 0.5);
    vec3_3: vec3 = (x: 0.5; y: 1; z: 0.5);
    vec3_4: vec3 = (x: 1; y: 1; z: 1);
    vec4_5: vec4 = (x: 0; y: 0; z: 0; w: 0);
    vec3_6: vec3 = (x: 0; y: -0.7; z: -20);

    yxx:vec3 = (x: detail; y: 0; z: 0);
    xyx:vec3 = (x: 0; y: detail; z: 0);
    xxy:vec3 = (x: 0; y: 0; z: detail);


    function de(p: vec3): float;
    function normal(const p: vec3): vec3;
    function softshadow(const ro, rd: vec3; mint, k: float): float;
    function light(const p, dir: vec3; d: float): vec4;
    function raymarch(const from, dir: vec3): vec4;
    function rotationMatrix3(const v: vec3; angle: float): mat3;
    function Main(var gl_FragCoord: Vec2): TColor32;

  var
    Iterations: int;
    Scale     : float;
    Julia     : vec3;
    RotVector : vec3;
    RotAngle  : float;
    Speed     : float;
    Amplitude : float;
    lightdir  : vec3;
    rot       : mat2;
    from      : vec3;
    time:Float;
    rot2 : mat3;
    t6:double;

    ani : vec3;
    SinA,cosA:Double;
    st:double;
    m:mat2;
    a   : float;

    procedure PrepareFrame;
  public
    constructor Create; override;
  end;

var
  Avatar: TShader;

implementation

uses SysUtils, Math;

constructor TAvatar.Create;
begin
  inherited;
  Image.FrameProc := PrepareFrame;
  Image.PixelProc := Main;
end;

procedure TAvatar.PrepareFrame;
begin
  Iterations := 16;
  Scale      := 1.27;
  Julia      := vec3_1;
  RotVector  := vec3_2;
  RotAngle   := 145;
  Speed      := 1.3;
  Amplitude  := 0.25;
  lightdir   := -vec3_3;
  rot     := mat2.Create(System.cos(-0.5), System.sin(-0.5), -System.sin(-0.5), System.cos(-0.5));
  from    := vec3_6;
  from.yz := from.yz * rot;

  t6 := time * 6;


  a    := 1.5 + sinLarge(iGlobalTime * 0.5) * 0.5;
  SinA := system.Sin(a);
  CosA := System.Cos(a);
  m := mat2.Create(cosA, sinA, -sinA, cosA);
  time := iGlobalTime * Speed;

  st := sinLarge(time);

  ani := vec3.Create(st, st, cosLarge(time)) * Amplitude;
  rot2 := rotationMatrix3(normalize(RotVector + ani), RotAngle + st * 10);

end;

function TAvatar.normal(const p: vec3): vec3;
begin
  Result.x := de(p + yxx) - de(p - yxx);
  Result.y := de(p + xyx) - de(p - xyx);
  Result.z := de(p + xxy) - de(p - xxy);
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
    res := min(res, k * h / t);
    t   := t + clamp(h, 0.01, 0.5);
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
  Exit(3 * lightCol * diff * sh + pow(spec, 30) * 0.5 * sh + 0.15 * Math.max(0, dot(normalize(dir), -n)));
end;

function TAvatar.raymarch(const from, dir: vec3): vec4;
var
  d  : float;
  totdist: float;
  p      : vec3;
  col    : vec4;
  i      : integer;
  backg  : vec4;

begin
  d       := 1;
  totdist := 0;

  for i := 0 to 29 do
  begin
    if (d > detail) and (totdist < 150) then
    begin
      p       := from + totdist * dir;
      d       := de(p);
      totdist := totdist + d;
    end;

  end;

  backg := vec4_5;
  if d < detail then
  begin
    col := light(p, dir, d);
  end
  else
  begin
    col := backg;
  end;

  // col := mix(col, backg, 1.0-exp(-0.000025*pow(totdist,3.5)));
  Result := col;
end;

function TAvatar.rotationMatrix3(const v: vec3; angle: float): mat3;
var
  c: float;
  s: float;
begin
  c := System.cos(radians(angle));
  s := System.sin(radians(angle));

  Result := mat3.Create(
              c + (1 - c) * v.x * v.x,
              (1 - c) * v.x * v.y - s * v.z,
              (1 - c) * v.x * v.z + s * v.y,
              (1 - c) * v.x * v.y + s * v.z,
              c + (1 - c) * v.y * v.y,
              (1 - c) * v.y * v.z - s * v.x,
              (1 - c) * v.x * v.z - s * v.y,
              (1 - c) * v.y * v.z + s * v.x,
              c + (1 - c) * v.z * v.z);
end;

function TAvatar.de(p: vec3): float;
var
  pp  : vec3;
  i   : integer;
begin
  p    := p.zxy;

  p.xy := p.xy * m;
  p.x  := p.x * 0.75;

  // p   := p + (sin(p * 3 + time * 6) * 0.04);
  p.x   := p.x + (sinLarge(p.x * 3 + t6) * 0.04);
  p.y   := p.y + (sinLarge(p.y * 3 + t6) * 0.04);
  p.z   := p.z + (sinLarge(p.z * 3 + t6) * 0.04);

  pp  := p;

  for i := 0 to Iterations - 1 do
  begin
    p.x := abs(p.x);
    p.y := abs(p.y);
    p    := p * Scale + Julia;
    p    := p * rot2;
  end;

  Exit(p.Length * pow(Scale, -Iterations) * 0.9);
end;

function TAvatar.Main(var gl_FragCoord: Vec2): TColor32;
var
  uv  : Vec2;
  dir : vec3;
  col : vec4;
begin
  uv      := gl_FragCoord.xy / resolution.xy * 2 - 1;
  uv.y    := uv.y * (resolution.y / resolution.x);
  dir     := normalize(vec3.create(uv * 0.7, 1));
  dir.yz  := dir.yz * rot;

  col    := raymarch(from, dir);
  Result := TColor32(col);
end;

initialization

Avatar := TAvatar.Create;
Shaders.Add('Avatar', Avatar);

finalization

FreeandNil(Avatar);

end.
