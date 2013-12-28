unit WvN.DelphiShader.FX.StarNursery;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TStarNursery = class(TShader)
  const
    m   : mat3=(r1:(x:  0.00;  y: 0.90; z: 0.60 );
                r2:(x: -0.90;  y: 0.36; z:-0.48 );
                r3:(x: -0.60;  y:-0.48; z: 0.34 ));

    CONTRAST      = 1.1;
    SATURATION    = 1.15;
    BRIGHTNESS    = 1.03;
    SunDir: vec3  = (x: 1; y: 0.4; z: 0);
    vec2_1: vec2  = (x: 37; y: 17);
    vec3_2: vec3  = (x: 0.4; y: 0.3; z: - 0.3);
    vec3_3: vec3  = (x: 0.2; y: 0; z: 0.2);
    vec3_4: vec3  = (x: 1; y: 0.4; z: 0.2);
    vec3_7: vec3  = (x: 0; y: 5.6; z: 2.4);
    vec3_8: vec3  = (x: 0; y: 1; z: 0);
    vec3_9: vec3  = (x: 0.2; y: 0.2; z: 0.3);
    vec3_10: vec3 = (x: 0.3; y: 0; z: 0.05);
    vec3_11: vec3 = (x: 0.4; y: 0.2; z: 0.67);
    vec3_12: vec3 = (x: 0.4; y: 0.4; z: 0.2);
    vec3_13: vec3 = (x: 0.2125; y: 0.7154; z: 0.0721);
   var
     mo       : vec2;
    ro       : vec3;
    ta       : vec3;
    ww       : vec3;
    uu       : vec3;
    vv       : vec3;

    function hash(n: float): float;
    function noise(const x: vec2): float; overload;
    function noise(const x: vec3): float; overload;
    function fbm(p: vec3): float;
    function map(const p: vec3): vec4;
    function raymarch(const ro, rd: vec3): vec4;
    function Main(var gl_FragCoord: vec2): TColor32;

  var
    time: float;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  StarNursery: TShader;

implementation

uses SysUtils, Math;

constructor TStarNursery.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TStarNursery.PrepareFrame;
begin
  // Built from the basics of'Clouds' Created by inigo quilez - iq/2013
  // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

  // Edited by Dave Hoskins into "Star Nursery"
  // V.1.1 Some speed up in the ray-marching loop.
  // V.1.2 Added Shadertoy's fast 3D noise for better, smaller step size.

  time := iGlobalTime + 46;

  mo  := (-1 + 2 + iMouse.xy) / resolution.xy;

  // Camera code...
  ro := 5.6 * normalize(vec3.Create(system.cos(2.75 - 3 * mo.x), 0.4 - 1.3 * (mo.y - 2.4), system.sin(2.75 - 2 * mo.x)));
  ta := vec3_7;
  ww := normalize(ta - ro);
  uu := normalize(cross(vec3_8, ww));
  vv := normalize(cross(ww, uu));

end;

function TStarNursery.hash(n: float): float;
begin
  Exit(fract(system.sin(n) * 43758.5453123));
end;

function TStarNursery.noise(const x: vec2): float;
var
  p  : vec2;
  f  : vec2;
  n  : float;
  res: float;

begin
  p := floor(x);
  f := fract(x);

  f := f * f * (3 - 2 * f);

  n := p.x + p.y * 57;

  res := mix(mix(hash(n + 0), hash(n + 1), f.x), mix(hash(n + 57), hash(n + 58), f.x), f.y);

  Exit(res);
end;

function TStarNursery.noise(const x: vec3): float;
var
  p : vec3;
  f : vec3;
  uv: vec2;
  rg: vec2;
begin
  p := floor(x);
  f := fract(x);
  f := f * f * (3 - 2 * f);

  uv := (p.xy + vec2_1 * p.z) + f.xy;
  rg := texture2D(tex[0], (uv + 0.5) / 256 { , -100 } ).yx;
  Exit(mix(rg.x, rg.y, f.z));
end;

function TStarNursery.fbm(p: vec3): float;
var
  f: float;
begin
  f := 1.600 * noise(p);        p := m * p * 2.02;
  f := f + 0.3500 * noise(p);   p := m * p * 2.33;
  f := f + 0.2250 * noise(p);   p := m * p * 2.01;
  f := f + 0.0825 * noise(p);
  Exit(f);
end;

function TStarNursery.map(const p: vec3): vec4;
var
  d  : float;
  f  : float;
  res: vec4;

begin
  d := 0.01 - p.y;

  f := fbm(p * 1 - vec3_2 * time);
  d := d + (4 * f);

  d := clamp(d);

  res   := vec4.Create(d);
  res.w := pow(res.y, 0.1);

  res.xyz := mix(0.7 * vec3_4, vec3_3, res.y * 1);
  res.xyz := res.xyz + pow(abs(0.95 - f), 26) * 1.85;
  Exit(res);
end;

function TStarNursery.raymarch(const ro, rd: vec3): vec4;
var
  sum: vec4;
  t  : float;
  pos: vec3;
  i  : integer; // loop variable
  col: vec4;

begin
  sum := vec4Black;

  t     := 0;
  pos   := vec3Black;
  for i := 0 to 99 do
  begin
    if (sum.a > 0.8) or (pos.y > 9) or (pos.y < -2) then
      break;
    pos := ro + t * rd;

    col := map(pos);

    // Accumulate the alpha with the colour...
    col.a   := col.a * (0.08);
    col.rgb := col.rgb * (col.a);

    sum := sum + col * (1 - sum.a);
    t   := t + (max(0.1, 0.04 * t));
  end;

  sum.xyz := sum.xyz / ((0.003 + sum.w));

  Exit(clamp(sum, 0, 1));
end;

function TStarNursery.Main(var gl_FragCoord: vec2): TColor32;
var
  q        : vec2;
  p        : vec2;
  rd       : vec3;
  res      : vec4;
  sun      : float;
  col      : vec3;
  v        : float;
  xy       : vec2;
  s        : float;
  backStars: vec3;

begin
  q   := gl_FragCoord.xy / resolution.xy;
  p   := -1 + 2 * q;
  p.x := p.x * (resolution.x / resolution.y);

  rd := normalize(p.x * uu + p.y * vv + 1.5 * ww);

  // Ray march into the clouds adding up colour...
  res := raymarch(ro, rd);

  sun := clamp(dot(SunDir, rd), 0, 2);
  col := mix(vec3_10, vec3_9, system.sqrt(max(rd.y, 0.001)));
  col := col + (0.4 * vec3_11 * sun);
  col := clamp(col, 0, 1);
  col := col + (0.43 * vec3_12 * pow(sun, 21));

  // Do the stars...
  v  := 1 / (2 * (1 + rd.z));
  xy.x := rd.y * v;
  xy.y := rd.x * v;
  s  := noise(rd.xz * 134);
  s  := s + (noise(rd.xz * 370));
  s  := s + (noise(rd.xz * 870));
  s  := pow(s, 19) * 0.00000001 * Math.max(rd.y, 0);
  if s > 0 then
  begin
    backStars := vec3.Create((1 - system.sin(xy.x * 20 + time * 13 * rd.x + xy.y * 30)) * 0.5 * s, s, s);
    col       := col + backStars;
  end;

  // Mix in the clouds...
  col := mix(col, res.xyz, res.w * 1.3);

  col := mix(vec3Gray, mix(vec3.Create(dot(vec3_13, col * BRIGHTNESS)), col * BRIGHTNESS, SATURATION), CONTRAST);

  Result := TColor32(col*2);
end;

initialization

StarNursery := TStarNursery.Create;
Shaders.Add('StarNursery', StarNursery);

finalization

FreeandNil(StarNursery);

end.
