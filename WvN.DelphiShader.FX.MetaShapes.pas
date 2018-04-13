unit WvN.DelphiShader.FX.MetaShapes;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TMetaShapes = class(TShader)
  const
    vec3_1: vec3  = (x: 0; y: 3; z: 0);
    vec3_2: vec3  = (x: 1; y: - 1; z: - 1);
    vec3_3: vec3  = (x: - 1; y: - 1; z: 1);
    vec3_4: vec3  = (x: - 1; y: 1; z: - 1);
    vec3_5: vec3  = (x: 1; y: 1; z: 1);
    vec3_6: vec3  = (x: 0.02; y: 0.02; z: 0.02);
    vec3_7: vec3  = (x: 1; y: 1; z: 1);
    vec3_8: vec3  = (x: 5; y: 10; z: - 20);
    vec3_9: vec3  = (x: 0.5; y: 0.4; z: 0.3);
    vec3_10: vec3 = (x: - 20; y: 10; z: 5);
    vec3_11: vec3 = (x: 0.4; y: 0.3; z: 0.2);
    vec3_12: vec3 = (x: 25; y: 5; z: - 5);
    vec3_13: vec3 = (x: 0.1; y: 0.1; z: 0.1);
    vec3_14: vec3 = (x: - 5; y: - 15; z: 10);
    CamTar: vec3 = (x: 0; y: 0; z: 0);
    vec3_16: vec3 = (x: 0; y: 0; z: 0);
    vec3_17: vec3 = (x: 0.8; y: 0.8; z: 0.8);
  var
    t:Float;
    campos : vec3;
    constructor Create; override;
    procedure PrepareFrame;
    function sphere(const pos: vec3): float;
    function box(const pos: vec3): float;
    function torus(const pos: vec3): float;
    function blob7(d1, d2, d3, d4, d5, d6, d7: float): float;
    function scene(const pos: vec3): float;
    function calcIntersection(const ro, rd: vec3): float;
    function calcNormal(const pos: vec3): vec3;
    function calcLight(const pos, lightp, lightc, camdir: vec3): vec3;
    function illuminate(const pos, camdir: vec3): vec3;
    function background(const rd: vec3): vec3;
    function calcLookAtMatrix(const ro, ta: vec3; const roll: float): mat3;
    function mainImage(var fragCoord: vec2): TColor32;
  end;

var
  MetaShapes: TShader;

implementation

uses SysUtils, Math;

constructor TMetaShapes.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
end;

{$EXCESSPRECISION OFF}
procedure TMetaShapes.PrepareFrame;
begin
  t      := iGlobalTime;
  campos := vec3.Create(10 * System.sin(t * 0.3), 2.5 * System.sin(t * 0.5), -10 * System.cos(t * 0.3));
end;

function TMetaShapes.sphere(const pos: vec3): float;
begin
  Result := length(pos) - 1;
end;

function TMetaShapes.box(const pos: vec3): float;
var
  d: vec3;
begin
  d := abs(pos) - 1;
  Result := Math.min(Math.max(d.x, Math.max(d.y, d.z)), 0) + length(max(d, 0));
end;

function TMetaShapes.torus(const pos: vec3): float;
var
  q: vec2;
begin
  q := vec2.Create(length(pos.xz) - 2, pos.y);
  Exit(length(q) - 0.5);
end;

function TMetaShapes.blob7(d1, d2, d3, d4, d5, d6, d7: float): float;
var
  k: float;
begin
  k := 2;
  Exit(-log(exp(-k * d1) + exp(-k * d2) + exp(-k * d3) + exp(-k * d4) + exp(-k * d5) + exp(-k * d6) + exp(-k * d7)) / k);
end;

function TMetaShapes.scene(const pos: vec3): float;
var
  p, b, s1, s2, s3, s4, s5: TVecType;
begin
  p  := torus(pos + vec3_1);
  b  := sphere(0.5 *(pos + vec3.Create(System.cos(t * 0.5), System.sin(t * 0.3), 0.0)));
  s1 := box(2 * (pos + 3 * vec3.Create(System.cos(t * 1.1), System.cos(t * 1.3), System.cos(t * 1.7)))) / 2;
  s2 := box(2 * (pos + 3 * vec3.Create(System.cos(t * 0.7), System.cos(t * 1.9), System.cos(t * 2.3)))) / 2;
  s3 := box(2 * (pos + 3 * vec3.Create(System.cos(t * 0.3), System.cos(t * 2.9), System.sin(t * 1.1)))) / 2;
  s4 := box(2 * (pos + 3 * vec3.Create(System.sin(t * 1.3), System.sin(t * 1.7), System.sin(t * 0.7)))) / 2;
  s5 := box(2 * (pos + 3 * vec3.Create(System.sin(t * 2.3), System.sin(t * 1.9), System.sin(t * 2.9)))) / 2;
  Exit(blob7(p, b, s1, s2, s3, s4, s5));
end;

function TMetaShapes.calcIntersection(const ro, rd: vec3): float;
var
  maxd, precis, h, t, res: float;
  i                      : int;
begin
  maxd   := 15;
  precis := 0.001;
  h      := precis * 2;
  t      := 0;
  res    := -1;
  for i  := 0 to 149 do
  begin
    if (h < precis) or (t > maxd) then
      break;
    h := scene(ro + rd * t);
    t := t + (h);
  end;
  if t < maxd then
    res := t;
  Exit(res);
end;

function TMetaShapes.calcNormal(const pos: vec3): vec3;
var
  eps           : float;
  v1, v2, v3, v4: vec3;
begin
  eps := 0.002;
  v1  := vec3_2;
  v2  := vec3_3;
  v3  := vec3_4;
  v4  := vec3_5;
  Exit(normalize(
         v1 * scene(pos + v1 * eps) +
         v2 * scene(pos + v2 * eps) +
         v3 * scene(pos + v3 * eps) +
         v4 * scene(pos + v4 * eps)));
end;

function TMetaShapes.calcLight(const pos, lightp, lightc, camdir: vec3): vec3;
var
  normal, lightdir       : vec3;
  cosa, cosr             : float;
  ambiant, diffuse, phong: vec3;
begin
  normal   := calcNormal(pos);
  lightdir := normalize(pos - lightp);
  cosa     := pow(0.5 + 0.5 * dot(normal, -lightdir), 3);
  cosr     := Math.max(dot(-camdir, reflect(lightdir, normal)), 0);
  ambiant  := vec3_6;
  diffuse  := vec3(0.7 * cosa);
  phong    := vec3(0.3 * pow(cosr, 16));
  Exit(lightc * (ambiant + diffuse + phong));
end;

function TMetaShapes.illuminate(const pos, camdir: vec3): vec3;
var
  posn,l1, l2, l3, l4: vec3;

begin
  posn := Normalize(pos);

  l1 := calcLight(pos, vec3_8, vec3_7, camdir);
  l2 := calcLight(pos, vec3_10, vec3_9, camdir);
  l3 := calcLight(pos, vec3_12, vec3_11, camdir);
  l4 := calcLight(pos, vec3_14, vec3_13, camdir);
  Exit(l1 + l2 + l3 + l4);
end;

function TMetaShapes.background(const rd: vec3): vec3;
begin
  Result := textureCube(tex[0],  rd).rgb *
            textureCube(tex[0], -rd).rgb;
end;

function TMetaShapes.calcLookAtMatrix(const ro, ta: vec3; const roll: float): mat3;
var
  ww, uu, vv: vec3;
begin
  ww := normalize(ta - ro);
  uu := normalize(cross(ww, vec3.Create(
                                   System.sin(roll),
                                   System.cos(roll), 0)));
  vv := normalize(cross(uu, ww));
  Exit(mat3.Create(uu, vv, ww));
end;

function TMetaShapes.mainImage(var fragCoord: vec2): TColor32;
var
  xy            : vec2;
  camMat        : mat3;
  camdir, col   : vec3;
  dist          : float;
  inters        : vec3;
begin
  xy     := (fragCoord.xy - resolution.xy / 2) / Math.min(resolution.xy.x, resolution.xy.y);
  camMat := calcLookAtMatrix(campos, camtar, 0);
  camdir := normalize(camMat * vec3.Create(xy, 1));
  col    := vec3_16;
  dist   := calcIntersection(campos, camdir);
  if dist = -1 then
    col := background(camdir)
  else
  begin
    inters := campos + dist * camdir;
    col    := illuminate(inters, camdir);
  end;
  col    := pow(col, vec3_17);
  Result := TColor32(col)
end;

initialization

MetaShapes := TMetaShapes.Create;
Shaders.Add('MetaShapes', MetaShapes);

finalization

FreeandNil(MetaShapes);

end.
