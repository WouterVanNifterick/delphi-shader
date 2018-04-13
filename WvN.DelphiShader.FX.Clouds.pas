unit WvN.DelphiShader.FX.Clouds;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TClouds = class(TShader)
  const
    vec2_1: vec2  = (x: 37; y: 17);
    vec3_2: vec3  = (x: 1; y: 0.1; z: 0);
    vec3_3: vec3  = (x: 0.7; y: 0.7; z: 0.7);
    vec3_4: vec3  = (x: 1; y: 0.95; z: 0.8);
    vec3_5: vec3  = (x: - 1; y: 0; z: 0);
    vec4_6: vec4  = (x: 0; y: 0; z: 0; w: 0);
    vec3_7: vec3  = (x: 0.7; y: 0.5; z: 0.3);
    vec3_8: vec3  = (x: 0.65; y: 0.68; z: 0.7);
    vec3_9: vec3  = (x: 0; y: 1; z: 0);
    vec3_10: vec3 = (x: 0; y: 1; z: 0);
    vec3_11: vec3 = (x: 1; y: 0.5; z: 1);
    vec3_12: vec3 = (x: 0.6; y: 0.71; z: 0.75);
    vec3_13: vec3 = (x: 1; y: 0.6; z: 0.1);
    vec3_14: vec3 = (x: 1; y: 0.4; z: 0.2);

  var
    sundir: vec3;
    mo    : vec2;
    ro    : vec3;
    ta    : vec3;
    ww    : vec3;
    uu    : vec3;
    vv    : vec3;

    function noise(const x: vec3): float;
    function map(const p: vec3): vec4;
    function raymarch(const ro, rd: vec3): vec4;
    function Main(var gl_FragCoord: vec2): TColor32;

    procedure PrepareFrame;
    constructor Create; override;
  end;

var
  Clouds: TShader;

implementation

uses SysUtils, Math;

constructor TClouds.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
  sundir    := vec3_5;
end;

function TClouds.noise(const x: vec3): float;
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
  rg := texture2D(tex[15], (uv + 0.5) / 256, -100).yx;
  Exit(mix(rg.x, rg.y, f.z));
end;

function TClouds.map(const p: vec3): vec4;
var
  d     : float;
  q     : vec3;
  f     : float;
begin
  d := 0.2 - p.y;

  q := p - vec3_2 * iGlobalTime;

  f := 0.5000 * noise(q);
  q := q * 2.02;
  f := f + (0.2500 * noise(q));
  q := q * 2.03;
  f := f + (0.1250 * noise(q));
  q := q * 2.01;
  f := f + (0.0625 * noise(q));

  d := d + (3 * f);
  d := clamp(d, 0, 1);

  Result     := vec4.Create(d);
  Result.xyz := mix(1.15 * vec3_4, vec3_3, Result.x);
end;

function TClouds.raymarch(const ro, rd: vec3): vec4;
var
  sum, col: vec4;
  t, dif  : float;
  i       : integer;
  pos, lin: vec3;
begin
  sum := vec4_6;

  t     := 0;
  for i := 0 to 63 do
  begin
    if sum.a > 0.99 then
      continue;

    pos := ro + t * rd;
    col := map(pos);

    dif     := clamp((col.w - map(pos + 0.3 * sundir).w) / 0.6, 0, 1);
    lin     := vec3_8 * 1.35 + 0.45 * vec3_7 * dif;
    col.xyz := col.xyz * lin;

    col.a   := col.a * 0.35;
    col.rgb := col.rgb * (col.a);

    sum := sum + col * (1 - sum.w);

    t := t + max(0.01, 0.025 * t);

  end;
  sum.xyz := sum.xyz / (0.1 + sum.w);
  Result  := clamp(sum, 0, 1);
end;

procedure TClouds.PrepareFrame;
begin
  // Created by inigo quilez - iq/2013
  // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

  // LUT based 3d value noise
  mo := Mouse.xy - 1;
  ro := 4 * normalize(vec3.Create(system.cos(2.75 - 3 * mo.x), 0.7 + (mo.y + 1), system.sin(2.75 - 3 * mo.x)));
  // camera
  ta := vec3_9;
  ww := normalize(ta - ro);
  uu := normalize(cross(vec3_10, ww));
  vv := normalize(cross(ww, uu));

end;

function TClouds.Main(var gl_FragCoord: vec2): TColor32;
var
  q  : vec2;
  p  : vec2;
  rd : vec3;
  res: vec4;
  sun: float;
  col: vec3;

begin
  q   := gl_FragCoord.xy / resolution.xy;
  p   := -1 + 2 * q;
  p.x := p.x * (resolution.x / resolution.y);
  rd  := p.x * uu + p.y * vv + 1.5 * ww;
  rd.NormalizeSelf;

  res := raymarch(ro, rd);

  sun := clamp(dot(sundir, rd), 0, 1);
  col := vec3_12 - rd.y * 0.2 * vec3_11 + 0.15 * 0.5;
  col := col + 0.2 * vec3_13 * pow(sun, 8);
  col := col * 0.95;
  col := mix(col, res.xyz, res.w);
  col := col + 0.1 * vec3_14 * pow(sun, 3);

  Result := TColor32(col);
end;

initialization

Clouds := TClouds.Create;
Shaders.Add('Clouds', Clouds);

finalization

FreeandNil(Clouds);

end.
