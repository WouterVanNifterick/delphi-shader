unit WvN.DelphiShader.FX.CubeMap;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TCubeMap = class(TShader)
  const
    precis       = 0.001;
    vec3_1: vec3 = (x: 0; y: 0; z: 0);
    vec3_2: vec3 = (x: 0; y: 1; z: 0);
    vec4_3: vec4 = (x: 0; y: 0; z: 0; w: 0);
    vec3_4: vec3 = (x: 4; y: 4; z: 4);

    function map(p: vec3): vec2;
    function sphereColor(const pos, nor: vec3): vec4;
    function satelitesColor(const pos, nor: vec3): vec4;
    function floorColor(const pos, nor: vec3): vec4;
    function intersect(const ro, rd: vec3): vec2;
    function calcNormal(const pos: vec3): vec3;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  CubeMap: TShader;

implementation

uses SysUtils, Math;

constructor TCubeMap.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TCubeMap.PrepareFrame;
begin
  // Created by inigo quilez - iq/2013
  // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

end;

function TCubeMap.map(p: vec3): vec2;
var
  d2: vec2;
  r : float;
  f : float;
  d : float;
  d1: vec2;
  d3: vec2;

begin
  d2 := vec2.Create(p.y + 1, 2);

  r  := 1;
  f  := smoothstep(0, 0.5, system.sin(3 + iGlobalTime));
  d  := 0.5 + 0.5 * system.sin(4 * p.x + 0.13 * iGlobalTime) * system.sin(4 * p.y + 0.11 * iGlobalTime) * system.sin(4 * p.z + 0.17 * iGlobalTime);
  r  := r + (f * 0.4 * pow(d, 4)){ * (0.5-0.5*p.y)};
  d1 := vec2.Create(length(p) - r, 1);

  if d2.x < d1.x then
    d1 := d2;

  p := vec3.Create(length(p.xz) - 2, p.y, &mod(iGlobalTime + 6 * atan(p.z, p.x) / pi, 1) - 0.5);
  // p  := //p  - (Vec3.Create( 1.5,0.0,0.0 ));
  d3 := vec2.Create(0.5 * (length(p) - 0.2), 3);
  if d3.x < d1.x then
    d1 := d3;

  Exit(d1);
end;

function TCubeMap.sphereColor(const pos, nor: vec3): vec4;
var
  uv : vec2;
  col: vec3;
  ao : float;

begin
  uv  := vec2.Create(atan(nor.x, nor.z), acos(nor.y));
  col := (texture2D(tex[5], uv).xyz);
  ao  := clamp(0.75 + 0.25 * nor.y, 0, 1);
  Exit(vec4.Create(col, ao));
end;

function TCubeMap.satelitesColor(const pos, nor: vec3): vec4;
var
  uv : vec2;
  col: vec3;
  ao : float;

begin
  uv  := vec2.Create(atan(nor.x, nor.z), acos(nor.y));
  col := (texture2D(tex[5], uv).xyz);
  ao  := 1;
  Exit(vec4.Create(col, ao));
end;

function TCubeMap.floorColor(const pos, nor: vec3): vec4;
var
  col   : vec3;
  f     : float;
begin
  col := texture2D(tex[9], 0.5 * pos.xz).xyz;

  // fake ao
  f := smoothstep(0.1, 1.75, length(pos.xz));

  Exit(vec4.Create(col, 0.5 * f + 0.5 * f * f));
end;

function TCubeMap.intersect(const ro, rd: vec3): vec2;
var
  h   : float;
  t   : float;
  maxd: float;
  sid : float;
  i   : integer;
  res : vec2;

begin
  h := precis * 2;

  t     := 0;
  maxd  := 9;
  sid   := -1;
  for i := 0 to 99 do
  begin
    if (abs(h) < precis) or (t > maxd) then
      break;
    t   := t + (h);
    res := map(ro + rd * t);
    h   := res.x;
    sid := res.y;
  end;

  if t > maxd then
    sid := -1;
  Exit(vec2.Create(t, sid));
end;

function TCubeMap.calcNormal(const pos: vec3): vec3;
var
  eps: vec3;
  nor: vec3;

begin
  eps := vec3.Create(precis, 0, 0);

  nor.x := map(pos + eps.xyy).x - map(pos - eps.xyy).x;
  nor.y := map(pos + eps.yxy).x - map(pos - eps.yxy).x;
  nor.z := map(pos + eps.yyx).x - map(pos - eps.yyx).x;
  Exit(normalize(nor));
end;

function TCubeMap.Main(var gl_FragCoord: vec2): TColor32;
var
  q   : vec2;
  p   : vec2;
  mo  : vec2;
  an1 : float;
  an2 : float;
  ro  : vec3;
  ww  : vec3;
  uu  : vec3;
  vv  : vec3;
  rd  : vec3;
  col : vec3;
  tmat: vec2;
  pos : vec3;
  nor : vec3;
  ref : vec3;
  rim : float;
  mate: vec4;
  tref: vec2;
  fre : float;
  sss : vec3;

begin
  q   := gl_FragCoord.xy / resolution.xy;
  p   := -1 + 2 * q;
  p.x := p.x * (resolution.x / resolution.y);
  mo  := iMouse.xy / resolution.xy;

  // camera
  an1 := 0.2 * iGlobalTime - 6.2831 * mo.x;
  an2 := clamp(0.8 + 0.6 * system.sin(2.2 + iGlobalTime * 0.11) + 1 * mo.y, 0.3, 1.35);
  ro  := 2.5 * normalize(vec3.Create(system.sin(an2) * system.cos(an1), system.cos(an2) - 0.5, system.sin(an2) * system.sin(an1)));
  ww  := normalize(vec3_1 - ro);
  uu  := normalize(cross(vec3_2, ww));
  vv  := normalize(cross(ww, uu));
  rd  := normalize(p.x * uu + p.y * vv + 1.4 * ww);

  // raymarch
  col := textureCube(CubeMap.cubes[0], rd).xyz;

  tmat := intersect(ro, rd);
  if tmat.y > 0.5 then
  begin
    // geometry
    pos := ro + tmat.x * rd;
    nor := calcNormal(pos);
    ref := reflect(rd, nor);

    rim := pow(clamp(1 + dot(nor, rd), 0, 1), 4);

    col := textureCube(CubeMap.cubes[1], nor).xyz;

    // color
    mate := vec4_3;
    if tmat.y < 1.5 then
      mate := sphereColor(pos, nor)
    else if tmat.y < 2.5 then
      mate := floorColor(pos, nor)
    else
      mate := satelitesColor(pos, nor);

    col := col + (2 * rim * pow(mate.w, 3));
    col := col * (mate.w);
    col := col * (mate.xyz);

    // reflection occlusion
    tref := intersect(pos + nor * 0.001, ref);
    if tref.y < 0.5 then
    begin
      fre := 0.3 + 0.7 * pow(clamp(1 + dot(rd, nor), 0, 1), 5);
      sss := textureCube(tex[0], ref).xyz;
      col := col + (2 * mate.w * pow(sss, vec3_4) * fre);
    end;

    col := sqrt(col);
  end;

  col := col * (0.25 + 0.75 * pow(16 * q.x * q.y * (1 - q.x) * (1 - q.y), 0.15));

  Result := TColor32(col);
end;

initialization

CubeMap := TCubeMap.Create;
Shaders.Add('CubeMap', CubeMap);

finalization

FreeandNil(CubeMap);

end.
