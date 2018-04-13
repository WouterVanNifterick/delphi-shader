unit WvN.DelphiShader.FX.Atomium;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TAtomium = class(TShader)
  public const
    c: vec3       = (x: 1.05; y: 1.05; z: 1.05);
    c1: vec3      = (x: 0.7; y: 0.7; z: 0.7);
    sundir: vec3  = (x: - 1; y: 0; z: 0);
    vec3_4: vec3  = (x: 1000; y: 1000; z: 1000);
    vec3_6: vec3  = (x: 0; y: 0; z: 0);
    vec3_7: vec3  = (x: 0; y: 1; z: 0);
    vec3_8: vec3  = (x: 1; y: 0.5; z: 1);
    vec3_9: vec3  = (x: 0.6; y: 0.71; z: 0.75);
    vec3_10: vec3 = (x: 1; y: 0.6; z: 0.1);
    vec3_11: vec3 = (x: 1; y: 0.4; z: 0.2);

    MaxIter       = 12;

    function map(p: vec3): vec4;
    function raymarch(const ro, rd: vec3): vec4;
    function Main(var gl_FragCoord: Vec2): TColor32;

  var
    mo : Vec2;
    fog : float;
    g   : float;
    h   : float;
    zoom: float;
    s01 : float;
    r : float;
    ro : vec3;
    ta : vec3;
    ww : vec3;
    uu : vec3;
    vv : vec3;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Atomium: TShader;

implementation

uses SysUtils, Math;

constructor TAtomium.Create;
begin
  inherited;
  Image.FrameProc := PrepareFrame;
  Image.PixelProc := Main;
end;

function TAtomium.map(p: vec3): vec4;
var
  dr: float;
  ot: vec3;
  r2: float;
  i : integer;
  k : float;
  d : float;
begin
  dr    := 1;
  ot    := vec3_4;

  for i := 0 to MaxIter - 1 do
  begin
    r2  := dot(p, p);
    if r2 > 100 then
      continue;

    ot := min(ot, abs(p));

    // Box fold

    // Sphere fold
    k  := max(h / r2, 0.1) * g;
    p  := p * k;
    dr := dr * k;

    // Exotic squaring
    p  := abs(p * p.zxy) - c;
    dr := dr * (2 * length(p));
  end;

  d := System.sqrt(r2) * log(r2) / dr;
  Result := vec4.Create(ot, d);
end;

function TAtomium.raymarch(const ro, rd: vec3): vec4;
var
  sum: vec4;
  t  : float;
  i  : integer;
  pos: vec3;
  col: vec4;
  d  : float;

begin
  sum   := vec4Black;

  t     := 0;
  for i := 0 to 63 do
  begin
    if sum.a > 0.99 then
      continue;

    pos     := ro + t * rd;
    col     := map(pos);
    d       := col.a;
    col.a   := 0.035 * fog / d;
    col.rgb := col.rgb * (col.a);

    if dot(pos, pos) < 11 then
      sum := sum + col * (1 - sum.a);

    t     := t + min(0.1, d * 0.3);

  end;

  sum.xyz := sum.xyz / (0.001 + sum.w);

  Exit(clamp(sum, 0, 1));
end;

procedure TAtomium.PrepareFrame;
begin
  // https://www.shadertoy.com/view/XdS3D3

  // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
  // Based on Clouds by inigo quilez : https://www.shadertoy.com/view/XslGRr

  fog  := 0.65 + 0.6 * cosLarge(0.3 * iGlobalTime);
  g    := 0.8;
  h    := 1;
  zoom := 0.25;
  s01  := sinLarge(0.1 * iGlobalTime);
  r  := resolution.x / resolution.y;
  mo  := -1 + 2 * iMouse.xy / resolution.xy + s01;
  // camera
  ro     := zoom * 4 * normalize(vec3.Create(
                          System.cos(2.75 - 3 * mo.x),
                          0.7 + (mo.y + 1),
                          System.sin(2.75 - 3 * mo.x)));
  ta     := vec3_6;
  ww     := ta - ro;           ww.NormalizeSelf;
  uu     := cross(vec3_7, ww); uu.NormalizeSelf;
  vv     := cross(ww, uu);     vv.NormalizeSelf;

end;


function TAtomium.Main(var gl_FragCoord: Vec2): TColor32;
var
  q  : Vec2;
  p  : Vec2;
  rd : vec3;
  res: vec4;
  sun: float;
  col: vec3;

begin
  q   := gl_FragCoord.xy / resolution.xy;
  p   := -1 + 2 * q;
  p.x := p.x * r;

  rd     := p.x * uu + p.y * vv + 1.5 * ww;
  rd.NormalizeSelf;

  res    := raymarch(ro, rd);

  sun    := clamp(dot(sundir, rd), 0, 1);
  col    := vec3_9 - rd.y * 0.2 * vec3_8 + 0.15 * 0.5;
  col    := col + (0.2 * vec3_10 * pow(sun, 8));
  col    := col * 0.95 * 0.3;

  col    := mix(col, res.xyz, res.w);
  col    := col + (0.1 * vec3_11 * pow(sun, 3));

  Result := TColor32(col);
end;

initialization

Atomium := TAtomium.Create;
Shaders.Add('Atomium', Atomium);

finalization

FreeandNil(Atomium);

end.
