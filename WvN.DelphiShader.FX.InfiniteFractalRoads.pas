unit WvN.DelphiShader.FX.InfiniteFractalRoads;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TInfiniteFractalRoads = class(TShader)
  const
    ang           = -37 * (pi / 180);
    vec3_1: vec3  = (x: 0; y: - 0.15; z: - 1);
    vec3_2: vec3  = (x: 0; y: - 1; z: 0);
    vec3_3: vec3  = (x: 1; y: 1; z: 0);
    vec3_4: vec3  = (x: 1; y: 1; z: 0);
    vec3_5: vec3  = (x: 0.8; y: 0.9; z: 1);
    vec3_6: vec3  = (x: 1; y: 0.9; z: 0.65);
    vec3_7: vec3  = (x: 1; y: 0.9; z: 0.7);
    vec3_8: vec3  = (x: 0.6; y: 0.8; z: 1);
    vec3_9: vec3  = (x: 1; y: 0.95; z: 0.8);
    vec3_10: vec3 = (x: 1; y: 0.95; z: 0.93);
    vec3_11: vec3 = (x: 0.05; y: 0.02; z: 0);
    vec3_12: vec3 = (x: 1.1; y: 1.03; z: 1);
    vec3_13: vec3 = (x: 1; y: 0.85; z: 0.7);
    v3_2: vec3 =  (x: 2; y: 2; z: 2);

    Iterations = 13;
    width      = 0.22;
    detail     = 0.00003;
    Scale      = 2.30;


  var
    t, h: float;
    v2:Vec2;
    from : vec3;
    FMouse:Vec2;
    function de(const pos: vec3): float;
    function normal(const p: vec3): vec3;
    function shadow(const pos, sdir: vec3): float;
    function AO(const pos, nor: vec3): float;
    function light(const p, dir: vec3): vec3;
    function raymarch(const from, dir: vec3): vec3;
    function Main(var gl_FragCoord: Vec2): TColor32;

  var
    lightdir  : vec3;
    skydir    : vec3;
    rota      : mat2;
    rota2     : mat2;
    ot        : float;
    det       : float;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  InfiniteFractalRoads: TShader;

implementation

uses SysUtils, Math;

constructor TInfiniteFractalRoads.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
  Det := 0;
end;

procedure TInfiniteFractalRoads.PrepareFrame;
var ca,sa, cam,sam:double;
begin
  lightdir   := normalize(vec3_1);
  skydir     := normalize(vec3_2);
  ca         := system.Cos(ang);
  sa         := system.Sin(ang);
  cam         := system.Cos(-ang);
  sam         := system.Sin(-ang);
  rota       := mat2.Create(ca , sa , -sa , ca);
  rota2      := mat2.Create(cam,sam, -sam, cam);

  ot  := 0;
  det := 0;

  t := radians(45 - iGlobalTime * 10);
  h := system.sin(iGlobalTime * 0.2) * 0.0031;

 	Fmouse := (iMouse.xy/resolution.xy-0.5);
  if Fmouse.x < -0.499 then
    Fmouse := vec2Black;

  v2 := Vec2.Create(iGlobalTime * 0.15);

  from   := vec3.Create(-4.975 + h, 1.256 - h, -3 + iGlobalTime * 0.005);

end;

// "Infinite Fractal Roads" by Kali

function TInfiniteFractalRoads.de(const pos: vec3): float;
var
  DEfactor: float;
  p       : vec3;
  i       : integer;
  r2      : float;

begin
  DEfactor := Scale;
  p        := pos;
  ot       := 1000;
  for i    := 0 to Iterations - 1 do
  begin
    p        := v3_2 - abs(abs(p.xyz + vec3_4) - v3_2) - vec3_3;
    r2       := dot(p.xyz, p.xyz);
    ot       := clamp(ot, 0, r2);
    p        := p * (Scale / clamp(r2));
    DEfactor := DEfactor * (Scale / clamp(r2, 0, 1));
    p        := p + pos.yxz;
  end;

  Exit(length(p.xyz) / DEfactor);
end;

function TInfiniteFractalRoads.normal(const p: vec3): vec3;
var
  e: vec3;

begin
  e := Default(vec3);
  e.y := det;
  Result := normalize(vec3.Create(
          de(p + e.yxx) - de(p - e.yxx),
          de(p + e.xyx) - de(p - e.xyx),
          de(p + e.xxy) - de(p - e.xxy)));
end;

function TInfiniteFractalRoads.shadow(const pos, sdir: vec3): float;
var
  totalDist: float;
  sh       : float;
  steps    : integer;
  p        : vec3;
  dist     : float;

begin
  totalDist := 5 * detail;
  sh        := 1;
  for steps := 0 to 19 do
  begin
    if totalDist < 0.3 then
    begin
      p    := pos - totalDist * sdir;
      dist := de(p);
      if dist < det then
        sh      := 0.2;
      totalDist := totalDist + (dist);
    end;

  end;

  Exit(sh);
end;

function TInfiniteFractalRoads.AO(const pos, nor: vec3): float;
var
  i,
  aoi  : integer;
  totao: float;
  sca  : float;
  hr   : float;
  aopos: vec3;
  dd   : float;

begin
  // by iq...
  aoi   := 0;
  totao := 0;
  sca   := 20;

  for I := 0 to 4 do
  begin
    hr    := 0.015 + 0.01 * aoi * aoi;
    aopos := nor * hr + pos;
    dd    := de(aopos);
    totao := totao + (-(dd - hr) * sca);
    sca   := sca * (0.4);
    Inc(aoi);
  end;

  Exit(1 - clamp(totao, 0, 1));
end;

function TInfiniteFractalRoads.light(const p, dir: vec3): vec3;
var
  n   : vec3;
  sh  : float;
  _ao : float;
  diff: float;
  amb : float;
  r   : vec3;
  spec: float;

begin
  n    := normal(p);
  sh   := shadow(p, lightdir);
  _ao  := AO(p, n);
  diff := Math.max(0, dot(lightdir, -n));
  amb  := (0.2 + 0.6 * Math.max(0, dot(normalize(skydir), -n))) * _ao;
  r    := reflect(lightdir, n);
  spec := Math.max(0, dot(dir, -r));
  Exit((diff * 1.5 + pow(spec, 20) * 0.4) * sh * vec3_6 + amb * vec3_5);
end;

function TInfiniteFractalRoads.raymarch(const from, dir: vec3): vec3;
var
  st     : float;
  d      : float;
  totdist: float;
  p      : vec3;
  col    : vec3;
  i      : integer;
  l      : float;
  backg  : vec3;
begin
  st      := 0;
  d       := 1;
  totdist := 0;

  for i := 0 to 139 do
  begin
    if (d > det) and (totdist < 0.5) then
    begin
      p       := from + totdist * dir;
      d       := de(p) * 0.8;
      det     := detail * (1 + totdist * 50);
      totdist := totdist + (d);
      st      := st + (max(0, 0.032 - d));
    end;

  end;

  l     := pow(Math.max(0, dot(normalize(-dir), normalize(lightdir))), 4);
  backg := vec3_8 * 0.4 * (0.4 + clamp(l, 0, 0.6)) + vec3_7 * l * 0.5;
  if d < det then
  begin
    ot  := clamp(pow(ot, 2) * 4);
    col := 0.5 + vec3.Create(ot * ot, ot, ot * ot * ot * 1.1) * 0.5;
    col := col * (light(p - det * dir, dir));
    col := mix(col, backg, 1 - exp(-9 * totdist * totdist));
  end
  else
  begin
    col := backg * (1 + texture2D(tex[0], dir.xy * rota2 * 0.5 - Vec2.Create(0, iGlobalTime * 0.004)).z * 0.25);
  end;

  Exit(col + st * vec3_9 * 0.15);
end;

function TInfiniteFractalRoads.Main(var gl_FragCoord: Vec2): TColor32;
var
  uv   : Vec2;
  uv2  : Vec2;
  dir  : vec3;
  col  : vec3;
  flare: vec3;
begin
  uv     := gl_FragCoord.xy / resolution.xy * 2 - 1;
  uv.y   := uv.y * (resolution.y / resolution.x);
  uv2    := uv;
  uv     := uv + (Fmouse * 1.5);
  uv.y   := uv.y - (0.1);
  uv     := uv * (rota);
  uv     := uv + ((texture2D(tex[14], v2).xy - 0.5) * Math.max(0, h) * 7);
  dir    := normalize(vec3.Create(uv * 1.3, 1));
  col    := raymarch(from, dir);
  flare  := vec3_10 * pow(max(0, 0.8 - length(uv2 - Fmouse * 1.5)) / 0.8, 1.5) * 0.3;
  col    := col + (flare * dot(uv2, uv2));
  col    := col * (length(clamp((0.6 - pow(abs(uv2), vec2_3_3)), Vec2Black, Vec2White)));
  col    := col * vec3_12 + vec3_11;
  col    := col + (vec3_13 * power(max(0, 0.3 - length(uv)) / 0.3, 2) * 0.5);
  Result := TColor32(col);
end;

initialization

InfiniteFractalRoads := TInfiniteFractalRoads.Create;
Shaders.Add('InfiniteFractalRoads', InfiniteFractalRoads);

finalization

FreeandNil(InfiniteFractalRoads);

end.
