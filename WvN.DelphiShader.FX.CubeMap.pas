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

    eps100:vec3 = (x: precis; y: 0; z: 0);
    eps010:vec3 = (x: 0; y: precis; z: 0);
    eps001:vec3 = (x: 0; y: 0; z: precis);
  var
    mo  : vec2;
    an1 : float;
    an2 : float;
    ro  : vec3;
    ww  : vec3;
    uu  : vec3;
    vv  : vec3;
    sl3:double;
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
  f  := smoothstep(0, 0.5, sl3);
  d  := 0.5 + 0.5 * sinLarge(4 * p.x + 0.13 * iGlobalTime) *
                    sinLarge(4 * p.y + 0.11 * iGlobalTime) *
                    sinLarge(4 * p.z + 0.17 * iGlobalTime);
  r  := r + (f * 0.4 * power(d, 4)){ * (0.5-0.5*p.y)};
  d1 := vec2.Create(length(p) - r, 1);

  if d2.x < d1.x then
    d1 := d2;

  p := vec3.Create(length(p.xz) - 2, p.y, &mod(iGlobalTime + 6 * atan(p.z, p.x) / pi, 1) - 0.5);
  // p  := //p  - (Vec3.Create( 1.5,0.0,0.0 ));
  d3 := vec2.Create(0.5 * (length(p) - 0.2), 3);
  if d3.x < d1.x then
    d1 := d3;

  Result := d1;
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
    if (System.abs(h) < precis) or (t > maxd) then
      break;
    t   := t + h;
    res := map(ro + rd * t);
    h   := res.x;
    sid := res.y;
  end;

  Result.x := t;

  if t > maxd then
    Result.y := -1
  else
    Result.y := sid;
end;

function TCubeMap.calcNormal(const pos: vec3): vec3;
begin
  Result.x := map(pos + eps100).x - map(pos - eps100).x;
  Result.y := map(pos + eps010).x - map(pos - eps010).x;
  Result.z := map(pos + eps001).x - map(pos - eps001).x;
  Result.NormalizeSelf;
end;


procedure TCubeMap.PrepareFrame;
begin
  // Created by inigo quilez - iq/2013
  // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

  mo  := iMouse.xy / resolution.xy;
  // camera
  an1 := 0.2 * iGlobalTime - 6.2831 * mo.x;
  an2 := clamp(0.8 + 0.6 * system.sin(2.2 + iGlobalTime * 0.11) + 1 * mo.y, 0.3, 1.35);
  ro  := 2.5 * normalize(vec3.Create(system.sin(an2) * system.cos(an1), system.cos(an2) - 0.5, system.sin(an2) * system.sin(an1)));
  ww  := normalize(vec3_1 - ro);
  uu  := normalize(cross(vec3_2, ww));
  vv  := normalize(cross(ww, uu));
  sl3 := sinLarge(3 + iGlobalTime);
end;

function TCubeMap.Main(var gl_FragCoord: vec2): TColor32;
var
  q   : vec2;
  p   : vec2;
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

  rd  := p.x * uu + p.y * vv + 1.4 * ww;
  rd.NormalizeSelf;

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

//    col := col + (2 * rim * pow(mate.w, 3));
//    col := col * (mate.w);
//    col := col * (mate.xyz);

    col.x := (col.x + (2 * rim * pow(mate.w, 3))) * mate.w * mate.x;
    col.y := (col.y + (2 * rim * pow(mate.w, 3))) * mate.w * mate.y;
    col.z := (col.z + (2 * rim * pow(mate.w, 3))) * mate.w * mate.z;

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

  col := col * (0.25 + 0.75 * power(16 * q.x * q.y * (1 - q.x) * (1 - q.y), 0.15));

  Result := TColor32(col);
end;

initialization

CubeMap := TCubeMap.Create;
Shaders.Add('CubeMap', CubeMap);

finalization

FreeandNil(CubeMap);

end.
