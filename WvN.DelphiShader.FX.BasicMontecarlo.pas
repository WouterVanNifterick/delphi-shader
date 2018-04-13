unit WvN.DelphiShader.FX.BasicMontecarlo;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  // https://www.shadertoy.com/view/MsdGzl
  TBasicMontecarlo = class(TShader)
  const
    vec3_1: vec3  = (x: 1; y: 1; z: 1);
    vec3_2: vec3  = (x: 0; y: 3; z: 1);
    vec3_3: vec3  = (x: 0.22; y: 0.35; z: 0.4);
    eps: vec3     = (x: 0.0001; y: 0; z: 0);
    vec3_5: vec3  = (x: - 0.3; y: 1.3; z: 0.1);
    vec3_6: vec3  = (x: 1; y: 0.8; z: 0.6);
    vec3_7: vec3  = (x: 0.2; y: 0.35; z: 0.5);
    vec3_8: vec3  = (x: 1; y: 1; z: 1);
    vec3_9: vec3  = (x: 0; y: 0; z: 0);
    vec3_10: vec3 = (x: 0.9; y: 1; z: 1);
    vec3_11: vec3 = (x: 1.2; y: 1.1; z: 1);
    vec3_12: vec3 = (x: 0.4; y: 0.4; z: 0.4);
    vec3_13: vec3 = (x: 0; y: 0; z: 0);
    vec3_14: vec3 = (x: 0.9; y: 1; z: 1);
    vec2_15: vec2 = (x: 12.9898; y: 78.233);
    vec3_16: vec3 = (x: 0; y: 0; z: 0);
    vec3_17: vec3 = (x: 1.5; y: 0.7; z: 1.5);
    vec3_18: vec3 = (x: 0; y: 0; z: 0);
    v2: vec2      = (x: 12.9898; y: 78.233);

  var
    sunDir, sunCol, skyCol: vec3;

    constructor Create; override;
    procedure PrepareFrame;
    function hash(seed: float): float;
    function cosineDirection(const seed: float; const nor: vec3): vec3;
    function maxcomp(const p: vec3): float;
    function sdBox(const p, b: vec3): float;
    function map(p: vec3): float;
    function calcNormal(const pos: vec3): vec3;
    function intersect(const ro, rd: vec3): float;
    function shadow(const ro, rd: vec3): float;
    function calculateColor(ro, rd: vec3; sa: float): vec3;
    function setCamera(const ro, rt: vec3; const cr: float): mat3;
    function Buffer1(var gl_FragCoord: vec2): TColor32;
    function mainImage(var gl_FragCoord: vec2): TColor32;
  end;

var
  BasicMontecarlo: TShader;

implementation

uses SysUtils, Math;

constructor TBasicMontecarlo.Create;
begin
  inherited;
  SetBufferCount(1);

  Buffers[0].PixelProc := Buffer1;

  FrameProc := PrepareFrame;
  PixelProc := Buffer1;

  sunDir := normalize(vec3_5);
  sunCol := 6 * vec3_6;
  skyCol := 4 * vec3_7;

end;

procedure TBasicMontecarlo.PrepareFrame;
begin
end;

function TBasicMontecarlo.hash(seed: float): float;
begin
  Exit(fract(sin(seed) * 43758.5453));
end;

function TBasicMontecarlo.cosineDirection(const seed: float; const nor: vec3): vec3;
var
  tc, uu, vv: vec3;
  u, v, a   : float;
begin
  // compute basis from normal
  // see http://orbit.dtu.dk/fedora/objects/orbit:113874/datastreams/file_75b66578-222e-4c7d-abdf-f7e255100209/content
  // (link provided by nimitz)
  tc     := vec3.Create(1 + nor.z - nor.xy * nor.xy, -nor.x * nor.y) / (1 + nor.z);
  uu     := vec3.Create(tc.x, tc.z, -nor.x);
  vv     := vec3.Create(tc.z, tc.y, -nor.y);
  u      := hash(78.233 + seed);
  v      := hash(10.873 + seed);
  a      := 6.283185 * v;
  Result := System.sqrt(u) * (cos(a) * uu + sin(a) * vv) + System.sqrt(1 - u) * nor;
end;

function TBasicMontecarlo.maxcomp(const p: vec3): float;
begin
  Result := Math.max(p.x, Math.max(p.y, p.z));
end;

function TBasicMontecarlo.sdBox(const p, b: vec3): float;
var
  di: vec3;
  mc: float;
begin
  di     := abs(p) - b;
  mc     := maxcomp(di);
  Result := Math.min(mc, length(max(di, 0)))
end;

function TBasicMontecarlo.map(p: vec3): float;
var
  w, q                 : vec3;
  d, s                 : float;
  m                    : int;
  a, r                 : vec3;
  da, db, dc, c, d1, d2: float;
begin
  w     := p;
  q     := p;
  q.xz  := &mod(q.xz + 1, 2) - 1;
  d     := sdBox(q, vec3_1);
  s     := 1;
  for m := 0 to 5 do
  begin
    p  := q - 0.5 * sin(abs(p.y) + m) * 3 + vec3_2;
    a  := &mod(p * s, 2) - 1;
    s  := s * (3);
    r  := abs(1 - 3 * abs(a));
    da := Math.max(r.x, r.y);
    db := Math.max(r.y, r.z);
    dc := Math.max(r.z, r.x);
    c  := (Math.min(da, Math.min(db, dc)) - 1) / s;
    d  := Math.max(c, d);
  end;
  d1 := length(w - vec3_3) - 0.09;
  d  := Math.min(d, d1);
  d2 := w.y + 0.22;
  d  := Math.min(d, d2);
  Exit(d);
end;

function TBasicMontecarlo.calcNormal(const pos: vec3): vec3;
begin
  Result := vec3.Create(map(pos + eps.xyy) - map(pos - eps.xyy), map(pos + eps.yxy) - map(pos - eps.yxy), map(pos + eps.yyx) - map(pos - eps.yyx));
  Result.NormalizeSelf;
end;

function TBasicMontecarlo.intersect(const ro, rd: vec3): float;
var
  res, tmax, t: float;
  i           : int;
  h           : float;
begin
  res   := -1;
  tmax  := 16;
  t     := 0.01;
  for i := 0 to 127 do
  begin
    h := map(ro + rd * t);
    if (h < 0.0001) or (t > tmax) then
      break;
    t := t + (h);
  end;
  if t < tmax then
    res := t;
  Exit(res);
end;

function TBasicMontecarlo.shadow(const ro, rd: vec3): float;
var
  res, tmax, t: float;
  i           : int;
  h           : float;
begin
  res   := 0;
  tmax  := 12;
  t     := 0.001;
  for i := 0 to 79 do
  begin
    h := map(ro + rd * t);
    if (h < 0.0001) or (t > tmax) then
      break;
    t := t + (h);
  end;
  if t > tmax then
    res := 1;
  Exit(res);
end;

function TBasicMontecarlo.calculateColor(ro, rd: vec3; sa: float): vec3;
var
  epsilon                       : float;
  colorMask, accumulatedColor   : vec3;
  fdis                          : float;
  bounce                        : int;
  t                             : float;
  pos, nor, surfaceColor, iColor: vec3;
  sunDif, sunSha                : float;
  skyPoint                      : vec3;
  skySha, ff                    : float;
begin
  epsilon          := 0.0001;
  colorMask        := vec3_8;
  accumulatedColor := vec3_9;
  fdis             := 0;
  for bounce       := 0 to 2 do // bounces of GI
  begin
    rd := normalize(rd);
    // -----------------------         // trace
    t := intersect(ro, rd);
    if t < 0 then
    begin
      if bounce = 0 then
        Exit(mix(0.05 * vec3_10, skyCol, smoothstep(0.1, 0.25, rd.y)));
      break;
    end;
    if bounce = 0 then
      fdis       := t;
    pos          := ro + rd * t;
    nor          := calcNormal(pos);
    surfaceColor := vec3_12 * vec3_11;
    // -----------------------         // add direct lighitng
    // -----------------------         colorMask  := //-----------------------         colorMask  * (surfaceColor);
    iColor := vec3_13;
    // light 1
    sunDif := Math.max(0, dot(sunDir, nor));
    sunSha := 1;
    if sunDif > 0.00001 then
      sunSha := shadow(pos + nor * epsilon, sunDir);
    iColor   := iColor + (sunCol * sunDif * sunSha);
    // todo - add back direct specular
    // light 2

    skyPoint         := cosineDirection(sa + 7.1 * Frame + 5681.123 + bounce * 92.13, nor);
    skySha           := shadow(pos + nor * epsilon, skyPoint);
    iColor           := iColor + (skyCol * skySha);
    accumulatedColor := accumulatedColor + (colorMask * iColor);
    rd               := cosineDirection(76.2 + 73.1 * bounce + sa + 17.7 * Frame, nor);
    ro               := pos;
  end;
  ff               := exp(-0.01 * fdis * fdis);
  accumulatedColor := accumulatedColor * (ff);
  accumulatedColor := accumulatedColor + ((1 - ff) * 0.05 * vec3_14);
  Exit(accumulatedColor);
end;

function TBasicMontecarlo.setCamera(const ro, rt: vec3; const cr: float): mat3;
var
  cw, cp, cu, cv: vec3;
begin
  cw     := normalize(rt - ro);
  cp     := vec3.Create(sin(cr), cos(cr), 0);
  cu     := normalize(cross(cw, cp));
  cv     := normalize(cross(cu, cw));
  Result := mat3.Create(cu, cv, -cw);
end;

function TBasicMontecarlo.Buffer1(var gl_FragCoord: vec2): TColor32;
var
  sa     : float;
  &of, p : vec2;
  ro, ta : vec3;
  ca     : mat3;
  rd, col: vec3;
begin
  sa  := hash(dot(gl_FragCoord, v2) + 1113.1 * Frame);
  &of := -0.5 + vec2.Create(hash(sa + 13.271), hash(sa + 63.216));
  p   := (-resolution.xy + 2 * (gl_FragCoord + &of)) / resolution.y;
  ro  := vec3_16;
  ta  := vec3_17;
  ca  := setCamera(ro, ta, 0);
  rd  := normalize(ca * vec3.Create(p, -1.3));
  col := texture2D(Buffers[0].Bitmap, gl_FragCoord / resolution.xy).xyz;
  if Frame = 0 then
    col  := vec3_18;
  col    := col + (calculateColor(ro, rd, sa));
  Result := TColor32(col);
end;

function TBasicMontecarlo.mainImage(var gl_FragCoord: vec2): TColor32;
var
  uv : vec2;
  col: vec3;
begin
  uv  := gl_FragCoord.xy / resolution.xy;
  col := vec3_1;
  if Frame > 0 then
  begin
    col := texture2D(Buffers[0].Bitmap, uv).xyz;
    col := col / Frame;
    col := pow(col, vec3_2);
  end;
  // color grading and vigneting
  col    := pow(col, vec3_3);
  col    := col * (0.5 + 0.5 * power(16 * uv.x * uv.y * (1 - uv.x) * (1 - uv.y), 0.1));
  Result := TColor32(col);
end;

initialization

BasicMontecarlo := TBasicMontecarlo.Create;
Shaders.Add('BasicMontecarlo', BasicMontecarlo);

finalization

FreeandNil(BasicMontecarlo);

end.
