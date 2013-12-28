unit WvN.DelphiShader.FX.SimpleRayTracer;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

// http://glsl.heroku.com/e#12608.0


type
TSimpleRayTracer = class(TShader)
  type Plane =record
    pt:vec3;
    norm:vec3;
    color:vec3;
    diffuse:float;
    specular:float;
    constructor Create(const apt,anorm,acolor:vec3; adiffuse:float; aspecular:float);
  end;


  type Sphere =record
    pt:vec4;
    color:vec3;
    diffuse:float;
    specular:float;
    constructor Create(const apt:vec4; const acolor:vec3; adiffuse:float; aspecular:float);
  end;
public
const
  vec3_1:vec3=(x:0;y:0;z:0);
  vec3_2:vec3=(x:0;y:0;z:0);
  vec3_3:vec3=(x:0;y:0;z:0);
  vec3_4:vec3=(x:0;y:0;z:0);
  vec3_5:vec3=(x:0;y:0;z:0);
  vec3_6:vec3=(x:0;y:0;z:0);
  vec3_7:vec3=(x:0;y:0;z:0);
  vec3_8:vec3=(x:0;y:0;z:0);
  vec3_9:vec3=(x:0.8;y:0;z:0);
  vec3_10:vec3=(x:-1;y:0;z:0);
  vec3_11:vec3=(x:4;y:0;z:0);
  vec3_12:vec3=(x:0;y:0.8;z:0);
  vec3_13:vec3=(x:1;y:0;z:0);
  vec3_14:vec3=(x:-4;y:0;z:0);
  vec3_15:vec3=(x:0.8;y:0.8;z:0.8);
  vec3_16:vec3=(x:0;y:-1;z:0);
  vec3_17:vec3=(x:0;y:4;z:0);
  vec3_18:vec3=(x:0.8;y:0.8;z:0.8);
  vec3_19:vec3=(x:0;y:1;z:0);
  vec3_20:vec3=(x:0;y:-4;z:0);
  vec3_21:vec3=(x:0.8;y:0.8;z:0.8);
  vec3_22:vec3=(x:0;y:0;z:-1);
  vec3_23:vec3=(x:0;y:0;z:4);
  vec3_24:vec3=(x:0.8;y:0.8;z:0.8);
  vec3_25:vec3=(x:0;y:0;z:1);
  vec3_26:vec3=(x:0;y:0;z:-4);
  vec4_27:vec4=(x:-2;y:-2;z:-3;w:1);
  vec3_28:vec3=(x:0.8;y:0.6;z:0.1);
  vec4_29:vec4=(x:-2;y:3;z:-3;w:1);
  vec3_30:vec3=(x:0.5;y:0.7;z:0.7);
  vec4_31:vec4=(x:2.5;y:2.5;z:-2.5;w:1.5);
  vec3_32:vec3=(x:0.5;y:0.5;z:0.5);
  vec4_33:vec4=(x:2;y:-2;z:-2;w:2);
  vec3_34:vec3=(x:0.5;y:0.5;z:0.5);
  vec3_35:vec3=(x:0;y:0;z:3.9);
  vec3_36:vec3=(x:0;y:0;z:0);

  numPlanes=6;
  numSpheres=3;

  var
   light :vec3;
   ambient:vec3;
   planes:array[0..numPlanes-1] of Plane;
   spheres:array[0..numSpheres-1] of Sphere ;


  function iSphere( const ro, rd:vec3;const sph:vec4 ):float;
  function nSphere( const pos:vec3;const sph:vec4 ):vec3;
  function iPlane( const ro, rd, p0, norm:vec3 ):float;
  procedure isect( const ro, rd:vec3;out tplane:float;out planeid:int;out tsphere:float;out sphereid:int );
  function shadowCast( const pos:vec3 ):float;
  function diffuseColSphere( const ro, rd:vec3;const t:float;const sid:int ):vec3;
  function diffuseColPlane( const ro, rd:vec3;const t:float;const pid:int ):vec3;
  function specularColor( const pos, dir, norm:vec3 ):vec3;
  function refractSphereColor( const pos, dir:vec3 ):vec3;
  function colSphere( const ro, rd:vec3;const t:float;const sid:int ):vec3;
  function colPlane( const ro, rd:vec3;const t:float;const pid:int ):vec3;
  function Main(var gl_FragCoord: Vec2): TColor32;

  procedure PrepareFrame;
  constructor Create; override;
end;

var
  SimpleRayTracer: TShader;

implementation

uses SysUtils, Math;

constructor TSimpleRayTracer.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;

  planes[0]  := Plane.Create(vec3_11, vec3_10, vec3_9, 1, 0);
  planes[1]  := Plane.Create(vec3_14, vec3_13, vec3_12, 1, 0);
  planes[2]  := Plane.Create(vec3_17, vec3_16, vec3_15, 1, 0);
  planes[3]  := Plane.Create(vec3_20, vec3_19, vec3_18, 0.5, 0.5);
  planes[4]  := Plane.Create(vec3_23, vec3_22, vec3_21, 1, 0);
  planes[5]  := Plane.Create(vec3_26, vec3_25, vec3_24, 1, 0);



  spheres[0] := Sphere.Create(vec4_27, vec3_28, 1, 0);
  spheres[1] := Sphere.Create(vec4_29, vec3_30, 1, 0);
  // spheres[2]  := Sphere(vec4_31, vec3_32, 0.0, 1.0);
  spheres[2] := Sphere.Create(vec4_33, vec3_34, 0, 1);

end;

function TSimpleRayTracer.iSphere(const ro, rd: vec3; const sph: vec4): float;
var
  oc     : vec3;
  b, c, d: float;
begin
  oc := ro - sph.xyz;
  b  := 2 * dot(oc, rd);
  c  := dot(oc, oc) - sph.w * sph.w;
  d  := b * b - 4 * c;
  if d < 0 then
    Exit(-1);
  Result := (-b - system.sqrt(d)) / 2;
end;

function TSimpleRayTracer.nSphere(const pos: vec3; const sph: vec4): vec3;
begin
  Result := (pos - sph.xyz) / sph.w;
end;

function TSimpleRayTracer.iPlane(const ro, rd, p0, norm: vec3): float;
var
  d: float;
begin
  d := dot(rd, norm);
  if IsZero(d) then
    Result := 0
  else
    Result := dot(p0 - ro, norm) / d;
end;

procedure TSimpleRayTracer.isect(const ro, rd: vec3; out tplane: float; out planeid: int; out tsphere: float; out sphereid: int);
var
  i : integer;
  tp: float;
  ts: float;
begin
  tplane  := 1000;
  planeid := -1;
  for i   := 0 to numPlanes - 1 do
  begin
    tp := iPlane(ro, rd, planes[i].pt, planes[i].norm);
    if (tp > 0) and (tp < tplane) then
    begin
      tplane  := tp;
      planeid := i;
    end;
  end;

  tsphere  := 1000;
  sphereid := -1;
  for i    := 0 to numSpheres - 1 do
  begin
    ts := iSphere(ro, rd, spheres[i].pt);
    if (ts > 0) and (ts < tsphere) then
    begin
      tsphere  := ts;
      sphereid := i;
    end;
  end;
end;

function TSimpleRayTracer.shadowCast(const pos: vec3): float;
var
  toLight  : vec3;
  lightDist: float;
  npos     : vec3;
  tp, ts   : float;
  pid, sid : int;

begin
  toLight   := light - pos;
  lightDist := length(toLight);
  toLight   := normalize(toLight);
  npos      := pos + 0.002 * toLight;

  isect(npos, toLight, tp, pid, ts, sid);
  if (lightDist > tp) or (lightDist > ts) then
    Exit(0)
  else
    Exit(1);
end;

function TSimpleRayTracer.diffuseColSphere(const ro, rd: vec3; const t: float; const sid: int): vec3;
var
  pos: vec3;
  i  : integer;
  nor: vec3;
  dif: float;

begin
  pos   := ro + t * rd;
  for i := 0 to numSpheres - 1 do
  begin
    if i = sid then
    begin
      nor := nSphere(pos, spheres[i].pt);
      dif := dot(nor, normalize(light - pos));
      Exit(spheres[i].color * spheres[i].diffuse * dif);
    end;
  end;
  Result := vec3_1;
end;

function TSimpleRayTracer.diffuseColPlane(const ro, rd: vec3; const t: float; const pid: int): vec3;
var
  pos    ,
  toLight: vec3;
  i      : integer;
  dif    : float;
begin
  pos     := ro + t * rd;
  toLight := normalize(light - pos);
  for i   := 0 to numPlanes - 1 do
    if i = pid then
    begin
      dif := clamp(dot(planes[i].norm, toLight), 0, 1);
      Exit(planes[i].color * planes[i].diffuse * dif);
    end;

  Result := vec3_2;
end;

function TSimpleRayTracer.specularColor(const pos, dir, norm: vec3): vec3;
var
  specCol, ref : vec3;
  rtp, rts  : float;
  rpid, rsid: int;
begin
  specCol := vec3_3;
  ref     := reflect(normalize(dir), norm);

  isect(pos + 0.002 * ref, ref, rtp, rpid, rts, rsid);
  if rpid >= 0 then
  begin
    if rsid >= 0 then
    begin
      if rtp < rts then
        specCol := diffuseColPlane(pos, ref, rtp, rpid)
      else
        specCol := diffuseColSphere(pos, ref, rts, rsid);
    end
    else
      specCol := diffuseColPlane(pos, ref, rtp, rpid);
  end
  else if rsid >= 0 then
    specCol := diffuseColSphere(pos, ref, rts, rsid);
  Exit(specCol);
end;

function TSimpleRayTracer.refractSphereColor(const pos, dir: vec3): vec3;
begin
  Result := vec3_4;
end;

function TSimpleRayTracer.colSphere(const ro, rd: vec3; const t: float; const sid: int): vec3;
var
  dif    : vec3;
  col    : vec3;
  i      : integer;
  pos    : vec3;
  nor    : vec3;
  specCol: vec3;
begin
  dif   := diffuseColSphere(ro, rd, t, sid);
  col   := vec3_5;
  for i := 0 to numSpheres - 1 do
  begin
    if i = sid then
    begin
      pos     := ro + t * rd;
      nor     := nSphere(pos, spheres[i].pt);
      specCol := vec3_6;
      if spheres[i].specular > 0 then
        specCol := specularColor(pos, rd, nor);

      col := (dif + specCol * spheres[i].specular) * shadowCast(pos) + spheres[i].color * ambient;
    end;
  end;
  Result := col;
end;

function TSimpleRayTracer.colPlane(const ro, rd: vec3; const t: float; const pid: int): vec3;
var
  dif    : vec3;
  col    : vec3;
  i      : integer;
  pos    : vec3;
  specCol: vec3;

begin
  dif   := diffuseColPlane(ro, rd, t, pid);
  col   := vec3_7;
  for i := 0 to numPlanes - 1 do
  begin
    if i = pid then
    begin
      pos     := ro + t * rd;
      specCol := vec3_8;
      if planes[i].specular > 0 then
        specCol := specularColor(pos, rd, planes[i].norm);

      col := (dif + specCol * planes[i].specular) * shadowCast(pos) + planes[i].color * ambient;
    end;

  end;

  Exit(col);
end;

procedure TSimpleRayTracer.PrepareFrame;
begin
  { Simple Ray Tracer with Specularity and Shadows
    http://cs.trinity.edu/~mhibbs
  }
  light.x := 3 * system.sin(time);
  light.y := 3 * system.cos(time);
end;

function TSimpleRayTracer.Main(var gl_FragCoord: Vec2): TColor32;
var
  uv               : Vec2;
  ro               : vec3;
  rd               : vec3;
  tplane, tsphere  : float;
  planeid, sphereid: int;
  col              : vec3;

begin
  // pixel coordinates from 0 to 1
  uv := (gl_FragCoord.xy / resolution.xy);
  // generate ray from ro in direction rd
  ro := vec3_35;
  rd := normalize(vec3.Create((-1 + 2 * uv.x) * (resolution.x / resolution.y), -1 + 2 * uv.y, -1));

  // intersect ray with scene

  isect(ro, rd, tplane, planeid, tsphere, sphereid);

  col := vec3_36;
  if planeid >= 0 then
  begin
    if sphereid >= 0 then
    begin
      if tplane < tsphere then
        col := colPlane(ro, rd, tplane, planeid)
      else
        col := colSphere(ro, rd, tsphere, sphereid);
    end
    else
      col := colPlane(ro, rd, tplane, planeid);
  end
  else if sphereid >= 0 then
    col := colSphere(ro, rd, tsphere, sphereid);

  Result := TColor32(col);
end;

{ Plane }

constructor TSimpleRayTracer.Plane.Create(const apt, anorm, acolor: vec3; adiffuse, aspecular: float);
begin
  pt       := apt;
  norm     := anorm;
  color    := acolor;
  diffuse  := adiffuse;
  specular := aspecular;
end;

{ Sphere }

constructor TSimpleRayTracer.Sphere.Create(const apt: vec4; const acolor: vec3; adiffuse, aspecular: float);
begin
  pt       := apt;
  color    := acolor;
  diffuse  := adiffuse;
  specular := aspecular;
end;

initialization

SimpleRayTracer := TSimpleRayTracer.Create;
Shaders.Add('SimpleRayTracer', SimpleRayTracer);

finalization

FreeandNil(SimpleRayTracer);

end.
