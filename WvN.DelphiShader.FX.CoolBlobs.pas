unit WvN.DelphiShader.FX.CoolBlobs;

interface

uses GR32, Types, WvN.DelphiShader.Shader;


// {$define ENABLE_MONTE_CARLO}
{$DEFINE ENABLE_REFLECTIONS}
// {$DEFINE ENABLE_FOG}
{$DEFINE ENABLE_SPECULAR}
{$DEFINE ENABLE_POINT_LIGHT}
{$DEFINE ENABLE_POINT_LIGHT_FLARE}

type
  C_Ray = record
    vOrigin: vec3;
    vDir: vec3;
  end;

  C_HitInfo = record
    vPos: vec3;
    fDistance: float;
    vObjectId: vec3;
  end;

  C_Material = record
    cAlbedo: vec3;
    fR0: float;
    fSmoothness: float;
    vParam: vec2;
  end;

  TCoolBlobs = class(TShader)
  public const
    vec4_1: vec4  = (x: 324.324234; y: 563.324234; z: 657.324234; w: 764.324234);
    vec4_2: vec4  = (x: 567.324234; y: 435.324234; z: 432.324234; w: 657.324234);
    vec4_3: vec4  = (x: 10000; y: - 1; z: 0; w: 0);
    vec3_4: vec3  = (x: 0; y: 0; z: 0);
    vec3_5: vec3  = (x: 1; y: 1; z: 1);
    vec3_6: vec3  = (x: 1; y: 1; z: 1);
    vec3_7: vec3  = (x: 0; y: 0; z: 0);
    vec3_8: vec3  = (x: 0.5; y: 0.6; z: 0.7);
    vec3_9: vec3  = (x: 0; y: 0; z: 0);
    vec3_10: vec3 = (x: 2; y: 9; z: 2);
    vec3_11: vec3 = (x: 32; y: 6; z: 1);
    vec3_12: vec3 = (x: 0; y: 0; z: 0);
    vec3_13: vec3 = (x: 0; y: 0; z: 0);
    vec3_14: vec3 = (x: 0; y: 1; z: 0);
    vec3_15: vec3 = (x: 0; y: 0; z: 0);
    vec3_16: vec3 = (x: 0.0; y: 0.0; z: - 5.0);

  var
    kPI, kHalfPi, kTwoPI: float;
    gPixelRandom        : vec4;
    gRandomNormal       : vec3;

    function RotateX(const vPos: vec3; const fAngle: float): vec3;
    function RotateY(const vPos: vec3; const fAngle: float): vec3;
    function RotateZ(const vPos: vec3; const fAngle: float): vec3;
    function DistCombineUnion(const v1, v2: vec4): vec4;
    function DistCombineIntersect(const v1, v2: vec4): vec4;
    function DistCombineSubtract(const v1, v2: vec4): vec4;
    function DomainRepeatXZGetTile(const vPos: vec3; const vRepeat: vec2; out vTile: vec2): vec3;
    function DomainRepeatXZ(const vPos: vec3; const vRepeat: vec2): vec3;
    function DomainRepeatY(const vPos: vec3; const fSize: float): vec3;
    function DomainRotateSymmetry(const vPos: vec3; const fSteps: float): vec3;
    function GetDistanceXYTorus(const p: vec3; const r1, r2: float): float;
    function GetDistanceYZTorus(const p: vec3; const r1, r2: float): float;
    function GetDistanceCylinderY(const vPos: vec3; const r: float): float;
    function GetDistanceBox(const vPos, vSize: vec3): float;
    function GetDistanceRoundedBox(const vPos, vSize: vec3; fRadius: float): float;
    function GetDistanceScene(const vPos: vec3): vec4;
    function GetObjectMaterial(const vObjId, vPos: vec3): C_Material;
    function GetSkyGradient(const vDir: vec3): vec3;
    function GetLightPos: vec3;
    function GetLightCol: vec3;
    function GetAmbientLight(const vNormal: vec3): vec3;
    procedure ApplyAtmosphere(out col: vec3; const ray: C_Ray; const intersection: C_HitInfo);
    function GetSceneNormal(const vPos: vec3): vec3;
    procedure Raymarch(const ray: C_Ray; out result: C_HitInfo; fMaxDist: float; maxIter: int);
    function GetShadow(const vPos, vLightDir: vec3; const fLightDistance: float): float;
    function Schlick(const vNormal, vView: vec3; const fR0, fSmoothFactor: float): float;
    function GetDiffuseIntensity(const vLightDir, vNormal: vec3): float;
    function GetBlinnPhongIntensity(const ray: C_Ray; const mat: C_Material; const vLightDir, vNormal: vec3): float;
    function GetAmbientOcclusion(const ray: C_Ray; const intersection: C_HitInfo; const vNormal: vec3): float;
    function GetObjectLighting(const ray: C_Ray; const intersection: C_HitInfo; const material: C_Material; const vNormal, cReflection: vec3): vec3;
    function GetSceneColourSimple(const ray: C_Ray): vec3;
    function GetSceneColour(const ray: C_Ray): vec3;
    function OrbitPoint(const fHeading, fElevation: float): vec3;
    function Gamma(const cCol: vec3): vec3;
    function InvGamma(const cCol: vec3): vec3;
    function Tonemap(const cCol: vec3): vec3;
    function InvTonemap(const cCol: vec3): vec3;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  CoolBlobs: TShader;

implementation

uses SysUtils, Math;

constructor TCoolBlobs.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
{$IFDEF ENABLE_MONTE_CARLO        }
  UseBackBuffer := True;
  gPixelRandom  := default (vec4);
{$ENDIF}
  kPI     := acos(0.0);
  kHalfPi := arcsin(1.0);
  kTwoPI  := kPI * 2.0;

end;

procedure TCoolBlobs.PrepareFrame;
begin
  // 704 Remake - @PauloFalcao
  // based on Blank Slate - @P_Malin (http://glsl.heroku.com/e#2540.09)
  //
  // Tonight was very tired from work, and decided to do some graphics fun to clear the mind not  :)
  // I opened the http://glsl.heroku.com/ and saw a copy of @P_Malin framework
  // I Remembered my old 704 (http://www.backtothepixel.com/demos/js/webgl/704_webgl.html)
  // and thought... how it would look like if i used the 704 object...
  // I loved the results not  not  not  @P_Malin framework is awesome not  not  not
  // Very complete, with nice variable names, really nice not  :)
  // Colors, and the object are the same as the original 704,
  // but time is slower to give to the stuff time to cook... ;)
  //

  // somehow these enable pan/zoom controls (using magic)
  // uniform vec2 surfaceSize;
  // varying vec2 surfacePosition;

end;

function TCoolBlobs.RotateX(const vPos: vec3; const fAngle: float): vec3;
var
  s      : float;
  c      : float;
  vResult: vec3;

begin
  s := system.sin(fAngle);
  c := system.cos(fAngle);

  vResult := vec3.Create(vPos.x, c * vPos.y + s * vPos.z, -s * vPos.y + c * vPos.z);

  Exit(vResult);
end;

function TCoolBlobs.RotateY(const vPos: vec3; const fAngle: float): vec3;
var
  s      : float;
  c      : float;
  vResult: vec3;

begin
  s := system.sin(fAngle);
  c := system.cos(fAngle);

  vResult := vec3.Create(c * vPos.x + s * vPos.z, vPos.y, -s * vPos.x + c * vPos.z);

  Exit(vResult);
end;

function TCoolBlobs.RotateZ(const vPos: vec3; const fAngle: float): vec3;
var
  s      : float;
  c      : float;
  vResult: vec3;

begin
  s := system.sin(fAngle);
  c := system.cos(fAngle);

  vResult := vec3.Create(c * vPos.x + s * vPos.y, -s * vPos.x + c * vPos.y, vPos.z);

  Exit(vResult);
end;

function TCoolBlobs.DistCombineUnion(const v1, v2: vec4): vec4;
begin

  Exit(mix(v1, v2, step(v2.x, v1.x)));
end;

function TCoolBlobs.DistCombineIntersect(const v1, v2: vec4): vec4;
begin
  Exit(mix(v2, v1, step(v2.x, v1.x)));
end;

function TCoolBlobs.DistCombineSubtract(const v1, v2: vec4): vec4;
begin
  result := DistCombineIntersect(v1, vec4.Create(-v2.x, v2.yzw));
end;

function TCoolBlobs.DomainRepeatXZGetTile(const vPos: vec3; const vRepeat: vec2; out vTile: vec2): vec3;
var
  vResult : vec3;
  vTilePos: vec2;

begin
  vResult    := vPos;
  vTilePos   := (vPos.xz / vRepeat) + 0.5;
  vTile      := floor(vTilePos + 1000);
  vResult.xz := (fract(vTilePos) - 0.5) * vRepeat;
  Exit(vResult);
end;

function TCoolBlobs.DomainRepeatXZ(const vPos: vec3; const vRepeat: vec2): vec3;
var
  vResult : vec3;
  vTilePos: vec2;

begin
  vResult    := vPos;
  vTilePos   := (vPos.xz / vRepeat) + 0.5;
  vResult.xz := (fract(vTilePos) - 0.5) * vRepeat;
  Exit(vResult);
end;

function TCoolBlobs.DomainRepeatY(const vPos: vec3; const fSize: float): vec3;
var
  vResult: vec3;

begin
  vResult   := vPos;
  vResult.y := (fract(vPos.y / fSize + 0.5) - 0.5) * fSize;
  Exit(vResult);
end;

function TCoolBlobs.DomainRotateSymmetry(const vPos: vec3; const fSteps: float): vec3;
var
  angle       : float;
  fScale      : float;
  steppedAngle: float;
  s           : float;
  c           : float;
  vResult     : vec3;

begin
  angle := atan(vPos.x, vPos.z);

  fScale       := fSteps / (kTwoPI);
  steppedAngle := (floor(angle * fScale + 0.5)) / fScale;

  s := system.sin(-steppedAngle);
  c := system.cos(-steppedAngle);

  vResult := vec3.Create(c * vPos.x + s * vPos.z, vPos.y, -s * vPos.x + c * vPos.z);

  Exit(vResult);
end;

function TCoolBlobs.GetDistanceXYTorus(const p: vec3; const r1, r2: float): float;
var
  q: vec2;

begin
  q := vec2.Create(length(p.xy) - r1, p.z);
  Exit(length(q) - r2);
end;

function TCoolBlobs.GetDistanceYZTorus(const p: vec3; const r1, r2: float): float;
var
  q: vec2;

begin
  q := vec2.Create(length(p.yz) - r1, p.x);
  Exit(length(q) - r2);
end;

function TCoolBlobs.GetDistanceCylinderY(const vPos: vec3; const r: float): float;
begin
  Exit(length(vPos.xz) - r);
end;

function TCoolBlobs.GetDistanceBox(const vPos, vSize: vec3): float;
var
  vDist: vec3;

begin
  vDist := (abs(vPos) - vSize);
  Exit(Math.max(vDist.x, Math.max(vDist.y, vDist.z)));
end;

function TCoolBlobs.GetDistanceRoundedBox(const vPos, vSize: vec3; fRadius: float): float;
var
  vClosest: vec3;

begin
  vClosest := max(min(vPos, vSize), -vSize);
  Exit(length(vClosest - vPos) - fRadius);
end;

// result is x=scene distance y=material or object id; zw are material specific parameters (maybe uv co-ordinates)
function TCoolBlobs.GetDistanceScene(const vPos: vec3): vec4;
var
  oP           : float;
  vSphereDomain: vec3;
  tt           : float;
  vDistSphere  : vec4;
  vDistFloor   : vec4;

begin
  result := vec4_3;

  oP              := length(vPos);
  tt              := time * 0.05 + 10;
  vSphereDomain   := vPos;
  vSphereDomain.x := system.sin(vSphereDomain.x) + system.sin(tt);
  vSphereDomain.z := system.sin(vSphereDomain.z) + system.cos(tt);

  vDistSphere.x := length(length(vSphereDomain)) - 1.5 - system.sin(oP - tt * 4);
  vDistSphere.y := 2;
  vDistSphere.z := vSphereDomain.x;
  vDistSphere.w := vSphereDomain.y;
  result        := DistCombineUnion(result, vDistSphere);

  vDistFloor.x := vPos.y + 1;
  vDistFloor.y := 1;
  vDistFloor.z := vPos.x;
  vDistFloor.w := vPos.y;
  result       := DistCombineUnion(result, vDistFloor);
end;

function TCoolBlobs.GetObjectMaterial(const vObjId, vPos: vec3): C_Material;
var
  mat: C_Material;
  tt : float;
  d  : float;

begin

  if vObjId.x < 1.5 then
  begin
    // floor
    mat.fR0         := 0.01;
    mat.fSmoothness := 0;
    if fract(vPos.x * 0.5) > 0.5 then
      if fract(vPos.z * 0.5) > 0.5 then
        mat.cAlbedo := vec3_4
      else
        mat.cAlbedo := vec3_5
    else if fract(vPos.z * 0.5) > 0.5 then
      mat.cAlbedo := vec3_6
    else
      mat.cAlbedo := vec3_7;
  end
  else if vObjId.x < 2.5 then
  begin
    // sphere
    mat.fR0         := 0.5;
    mat.fSmoothness := 0.9;
    tt              := time * 0.05 + 10;
    d               := length(vPos);
    mat.cAlbedo     := vec3.Create((system.sin(d * 0.25 - tt * 4) + 1) / 2, (system.sin(tt) + 1) / 2, (system.sin(d - tt * 4) + 1) / 2);
  end;

  Exit(mat);
end;

function TCoolBlobs.GetSkyGradient(const vDir: vec3): vec3;
var
  fBlend: float;

begin
  fBlend := vDir.y * 0.5 + 0.5;
  Exit(mix(vec3_9, vec3_8, fBlend));
end;

function TCoolBlobs.GetLightPos: vec3;
var
  vLightPos: vec3;

begin
  vLightPos := vec3_10;
{$IFDEF ENABLE_MONTE_CARLO        }
  vLightPos := vLightPos + (gRandomNormal * 0.2);
{$ENDIF }
  Exit(vLightPos);
end;

function TCoolBlobs.GetLightCol: vec3;
begin
  Exit(vec3_11 * 10);
end;

function TCoolBlobs.GetAmbientLight(const vNormal: vec3): vec3;
begin
  Exit(GetSkyGradient(vNormal));
end;

const
  kFogDensity = 0.035;

procedure TCoolBlobs.ApplyAtmosphere(out col: vec3; const ray: C_Ray; const intersection: C_HitInfo);

var
{$IFDEF ENABLE_FOG}
  fFogAmount: float;
  cFog      : vec3;
{$ENDIF}
{$IFDEF ENABLE_POINT_LIGHT_FLARE}
  vToLight     : vec3;
  fDot         : float;
  vClosestPoint: vec3;
  fDist        : float;
{$ENDIF}
begin
{$IFDEF ENABLE_FOG}
  // fog
  fFogAmount := exp(intersection.fDistance * -kFogDensity);
  cFog       := GetSkyGradient(ray.vDir);
  col        := mix(cFog, col, fFogAmount);
{$ENDIF }

  // glare from light (a bit hacky - use length of closest approach from ray to light)
{$IFDEF ENABLE_POINT_LIGHT_FLARE}
  vToLight := GetLightPos() - ray.vOrigin;
  fDot     := dot(vToLight, ray.vDir);
  fDot     := clamp(fDot, 0, intersection.fDistance);

  vClosestPoint := ray.vOrigin + ray.vDir * fDot;
  fDist         := length(vClosestPoint - GetLightPos());
  col           := col + (GetLightCol() * 0.01 / (fDist * fDist));
{$ENDIF }
end;

function TCoolBlobs.GetSceneNormal(const vPos: vec3): vec3;
var
  fDelta  : float;
  vOffset1: vec3;
  vOffset2: vec3;
  vOffset3: vec3;
  vOffset4: vec3;
  f1      : float;
  f2      : float;
  f3      : float;
  f4      : float;
begin
  // tetrahedron normal
  fDelta := 0.025;

  vOffset1 := vec3.Create(fDelta, -fDelta, -fDelta);
  vOffset2 := vec3.Create(-fDelta, -fDelta, fDelta);
  vOffset3 := vec3.Create(-fDelta, fDelta, -fDelta);
  vOffset4 := vec3.Create(fDelta, fDelta, fDelta);

  f1 := GetDistanceScene(vPos + vOffset1).x;
  f2 := GetDistanceScene(vPos + vOffset2).x;
  f3 := GetDistanceScene(vPos + vOffset3).x;
  f4 := GetDistanceScene(vPos + vOffset4).x;

  result := vOffset1 * f1 + vOffset2 * f2 + vOffset3 * f3 + vOffset4 * f4;
  result.NormalizeSelf;
end;

const
  kRaymarchEpsilon = 0.01;

const
  kRaymarchMatIter = 256;

const
  kRaymarchStartDistance = 0.1;

  // This is an excellent resource on ray marching -> http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
procedure TCoolBlobs.Raymarch(const ray: C_Ray; out result: C_HitInfo; fMaxDist: float; maxIter: int);

var
  i         : integer;
  vSceneDist: vec4;

begin
  result.fDistance   := kRaymarchStartDistance;
  result.vObjectId.x := 0;

  for i := 0 to kRaymarchMatIter - 1 do
  begin
    result.vPos      := ray.vOrigin + ray.vDir * result.fDistance;
    vSceneDist       := GetDistanceScene(result.vPos);
    result.vObjectId := vSceneDist.yzw;

    // abs allows backward stepping - should only be necessary for non uniform distance functions
    if vSceneDist.x < -1000 then
      Break;

    if (System.Abs(vSceneDist.x) <= kRaymarchEpsilon) or (result.fDistance >= fMaxDist) or (i > maxIter) then
    begin
      break;
    end;
    result.fDistance := result.fDistance + vSceneDist.x;
  end;

  if result.fDistance >= fMaxDist then
  begin
    result.vPos        := ray.vOrigin + ray.vDir * result.fDistance;
    result.vObjectId.x := 0;
    result.fDistance   := 1000;
  end;

end;

function TCoolBlobs.GetShadow(const vPos, vLightDir: vec3; const fLightDistance: float): float;
var
  shadowRay      : C_Ray;
  shadowIntersect: C_HitInfo;

begin

  shadowRay.vDir    := vLightDir;
  shadowRay.vOrigin := vPos;

  Raymarch(shadowRay, shadowIntersect, fLightDistance, 32);

  Exit(step(0, shadowIntersect.fDistance) * step(fLightDistance, shadowIntersect.fDistance));
end;

// http://en.wikipedia.org/wiki/Schlick's_approximation
function TCoolBlobs.Schlick(const vNormal, vView: vec3; const fR0, fSmoothFactor: float): float;
var
  fDot : float;
  fDot2: float;
  fDot5: float;

begin
  fDot  := dot(vNormal, -vView);
  fDot  := min(max((1 - fDot), 0), 1);
  fDot2 := fDot * fDot;
  fDot5 := fDot2 * fDot2 * fDot;
  Exit(fR0 + (1 - fR0) * fDot5 * fSmoothFactor);
end;

function TCoolBlobs.GetDiffuseIntensity(const vLightDir, vNormal: vec3): float;
begin
  Exit(Math.max(0, dot(vLightDir, vNormal)));
end;

function TCoolBlobs.GetBlinnPhongIntensity(const ray: C_Ray; const mat: C_Material; const vLightDir, vNormal: vec3): float;
var
  vHalf         : vec3;
  fNdotH        : float;
  fSpecPower    : float;
  fSpecIntensity: float;

begin
  vHalf  := normalize(vLightDir - ray.vDir);
  fNdotH := Math.max(0, dot(vHalf, vNormal));

  fSpecPower     := exp2(4 + 6 * mat.fSmoothness);
  fSpecIntensity := (fSpecPower + 2) * 0.125;

  Exit(pow(fNdotH, fSpecPower) * fSpecIntensity);
end;

// use distance field to evaluate ambient occlusion
function TCoolBlobs.GetAmbientOcclusion(const ray: C_Ray; const intersection: C_HitInfo; const vNormal: vec3): float;
var
  vPos             : vec3;
  fAmbientOcclusion: float;
  fDist            : float;
  i                : integer;
  vSceneDist       : vec4;

begin
  vPos := intersection.vPos;
  fAmbientOcclusion := 1;
  fDist := 0;
  for i := 0 to 6 do
  begin
    fDist := fDist + 0.1;

    vSceneDist := GetDistanceScene(vPos + vNormal * fDist);

    if System.Abs(vSceneDist.x) > 1000 then
      break;
    if System.Abs(vSceneDist.x) < -1000 then
      break;

    fAmbientOcclusion := fAmbientOcclusion * (1 - max(0, (fDist - vSceneDist.x) * 0.2 / fDist));
  end;

  Exit(fAmbientOcclusion);
end;

function TCoolBlobs.GetObjectLighting(const ray: C_Ray; const intersection: C_HitInfo; const material: C_Material; const vNormal, cReflection: vec3): vec3;
var
  cScene             : vec3;
  vSpecularReflection: vec3;
  vDiffuseReflection : vec3;
  fAmbientOcclusion  : float;
  vAmbientLight      : vec3;
  vLightPos          : vec3;
  vToLight           : vec3;
  vLightDir          : vec3;
  fLightDistance     : float;
  fAttenuation       : float;
  fShadowBias        : float;
  fShadowFactor      : float;
  vIncidentLight     : vec3;
  fFresnel           : float;

begin

  vSpecularReflection := vec3_12;
  vDiffuseReflection  := vec3_13;

  fAmbientOcclusion := GetAmbientOcclusion(ray, intersection, vNormal);
  vAmbientLight     := GetAmbientLight(vNormal) * fAmbientOcclusion;

  vDiffuseReflection := vDiffuseReflection + (vAmbientLight);

  vSpecularReflection := vSpecularReflection + (cReflection * fAmbientOcclusion);

{$IFDEF ENABLE_POINT_LIGHT}
  vLightPos      := GetLightPos();
  vToLight       := vLightPos - intersection.vPos;
  vLightDir      := normalize(vToLight);
  fLightDistance := length(vToLight);

  fAttenuation := 1 / (fLightDistance * fLightDistance);

  fShadowBias    := 0.1;
  fShadowFactor  := GetShadow(intersection.vPos + vLightDir * fShadowBias, vLightDir, fLightDistance - fShadowBias);
  vIncidentLight := GetLightCol() * fShadowFactor * fAttenuation;

  vDiffuseReflection  := vDiffuseReflection + (GetDiffuseIntensity(vLightDir, vNormal) * vIncidentLight);
  vSpecularReflection := vSpecularReflection + (GetBlinnPhongIntensity(ray, material, vLightDir, vNormal) * vIncidentLight);
{$ENDIF ENABLE_POINT_LIGHT}
  vDiffuseReflection := vDiffuseReflection * (material.cAlbedo);

{$IFDEF ENABLE_SPECULAR}
  fFresnel := Schlick(vNormal, ray.vDir, material.fR0, material.fSmoothness * 0.9 + 0.1);
  cScene   := mix(vDiffuseReflection, vSpecularReflection, fFresnel);
{$ELSE }
  cScene := vDiffuseReflection;
{$ENDIF }
  Exit(cScene);
end;

function TCoolBlobs.GetSceneColourSimple(const ray: C_Ray): vec3;
var
  intersection: C_HitInfo;
  cScene      : vec3;
  material    : C_Material;
  vNormal     : vec3;
  cReflection : vec3;

begin

  Raymarch(ray, intersection, 16, 32);

  if intersection.vObjectId.x < 0.5 then
  begin
    cScene := GetSkyGradient(ray.vDir);
  end
  else
  begin
    material := GetObjectMaterial(intersection.vObjectId, intersection.vPos);
    vNormal  := GetSceneNormal(intersection.vPos);

    // use sky gradient instead of reflection
    cReflection := GetSkyGradient(reflect(ray.vDir, vNormal));

    // apply lighting
    cScene := GetObjectLighting(ray, intersection, material, vNormal, cReflection);
  end;

  ApplyAtmosphere(cScene, ray, intersection);

  Exit(cScene);
end;

function TCoolBlobs.GetSceneColour(const ray: C_Ray): vec3;
var
  intersection: C_HitInfo;
  cScene      : vec3;
  material    : C_Material;
  vNormal     : vec3;
  cReflection : vec3;
  fSepration  : float;
  reflectRay  : C_Ray;

begin

  Raymarch(ray, intersection, 60, 256);

  if System.Abs(intersection.vPos.x) > 1E10 then
    Exit;
  if System.Abs(intersection.vPos.y) > 1E10 then
    Exit;
  if System.Abs(intersection.vPos.z) > 1E10 then
    Exit;

  if intersection.vObjectId.x < 0.5 then
  begin
    cScene := GetSkyGradient(ray.vDir);
  end
  else
  begin
    material := GetObjectMaterial(intersection.vObjectId, intersection.vPos);
    vNormal  := GetSceneNormal(intersection.vPos);

{$IFDEF ENABLE_MONTE_CARLO}
    vNormal := normalize(vNormal + gRandomNormal / (5 + material.fSmoothness * 200));
{$ENDIF }
{$IFDEF ENABLE_REFLECTIONS    }
    begin
      // get colour from reflected ray
      fSepration := 0.05;

      reflectRay.vDir    := reflect(ray.vDir, vNormal);
      reflectRay.vOrigin := intersection.vPos + reflectRay.vDir * fSepration;

      cReflection := GetSceneColourSimple(reflectRay);
    end;

{$ELSE }
    cReflection = GetSkyGradient(reflect(ray.vDir, vNormal));
{$ENDIF }
    // apply lighting
    cScene := GetObjectLighting(ray, intersection, material, vNormal, cReflection);
  end;

  ApplyAtmosphere(cScene, ray, intersection);

  Exit(cScene);
end;

function TCoolBlobs.OrbitPoint(const fHeading, fElevation: float): vec3;
begin
  result := vec3.Create(system.sin(fHeading) * system.cos(fElevation), system.sin(fElevation), system.cos(fHeading) * system.cos(fElevation));
end;

function TCoolBlobs.Gamma(const cCol: vec3): vec3;
begin
  result := cCol * cCol;
end;

function TCoolBlobs.InvGamma(const cCol: vec3): vec3;
begin
  result := sqrt(cCol);
end;

function TCoolBlobs.Tonemap(const cCol: vec3): vec3;
var
  vResult: vec3;
begin
  // simple Reinhard tonemapping operator
  vResult := cCol / (1 + cCol);
  result  := Gamma(vResult);
end;

function TCoolBlobs.InvTonemap(const cCol: vec3): vec3;
var
  vResult: vec3;
begin
  vResult := cCol;
  vResult := clamp(vResult, 0.01, 0.99);
  vResult := InvGamma(vResult);
  result  := -(vResult / (vResult - 1));
end;

function TCoolBlobs.Main(var gl_FragCoord: vec2): TColor32;
var
  ray                    : C_Ray;
  fCamreaInitialHeading  : float;
  fCamreaInitialElevation: float;
  fCamreaInitialDist     : float;
  fCameraHeight          : float;
  fOrbitSpeed            : float;
  fZoom                  : float;
  vCenterPosition        : vec2;
  fHeading               : float;
  fElevation             : float;
  vCameraPos             : vec3;
{$IFDEF ENABLE_MONTE_CARLO}
  fDepthOfField: float;
  cPrev        : vec3;
  fBlend       : float;
{$ENDIF}
  cScene   : vec3;
  fExposure: float;
  cFinal   : vec3;
{$IFDEF ENABLE_MONTE_CARLO}
  procedure CalcPixelRandom;
  var
    s1, s2: vec4;
  begin
    // Nothing special here, just numbers generated by bashing keyboard
    s1            := sin(time * 3.3422 + vec4.Create(gl_FragCoord.x) * vec4_1) * 543.3423;
    s2            := sin(time * 1.3422 + vec4.Create(gl_FragCoord.y) * vec4_2) * 654.5423;
    gPixelRandom  := fract(2142.4 + s1 + s2);
    gRandomNormal := normalize(gPixelRandom.xyz - 0.5);
  end;
{$ENDIF }
  procedure GetCameraRay(const vPos, vForwards, vWorldUp: vec3; out ray: C_Ray);
  var
    vPixelCoord: vec2;
    vUV        : vec2;
    vViewCoord : vec2;
    fRatio     : float;
    vRight     : vec3;
    vUp        : vec3;
  begin
    vPixelCoord := gl_FragCoord.xy;
{$IFDEF ENABLE_MONTE_CARLO}
    vPixelCoord := vPixelCoord + gPixelRandom.zw;
{$ENDIF }
    vUV          := (vPixelCoord / resolution);
    vViewCoord   := vUV * 2 - 1;
    vViewCoord   := vViewCoord * (0.75);
    fRatio       := resolution.x / resolution.y;
    vViewCoord.y := vViewCoord.y / (fRatio);
    ray.vOrigin  := vPos;
    vRight       := normalize(cross(vForwards, vWorldUp));
    vUp          := cross(vRight, vForwards);
    ray.vDir     := normalize(vRight * vViewCoord.x + vUp * vViewCoord.y + vForwards);
  end;

  procedure GetCameraRayLookat(const vPos, vInterest: vec3; out ray: C_Ray);
  var
    vForwards: vec3;
    vUp      : vec3;
  begin
    vForwards := normalize(vInterest - vPos);
    vUp       := vec3_14;
    GetCameraRay(vPos, vForwards, vUp, ray);
  end;

begin
{$IFDEF ENABLE_MONTE_CARLO             }
  CalcPixelRandom();
{$ENDIF }
  fCamreaInitialHeading   := 0.5;
  fCamreaInitialElevation := 0.5;
  fCamreaInitialDist      := 20;
  fCameraHeight           := 0.01;
  fOrbitSpeed             := 1;

  // This magic stolen from other 3d pan/zoom examples
  // surfaceSize := self.Resolution;
  // surfacePosition := gl_FragCoord;
  // fZoom  := surfaceSize.y * 0.5 + 0.4;
  fZoom := 1;

  vCenterPosition := (0.5 - (gl_FragCoord.xy / resolution));
  fHeading        := vCenterPosition.x * fOrbitSpeed + fCamreaInitialHeading;
  fElevation      := (vCenterPosition.y * fOrbitSpeed + fCamreaInitialElevation);

  vCameraPos := OrbitPoint(fHeading, fElevation) * fCamreaInitialDist * fZoom;

  vCameraPos := vCameraPos + (vec3.Create(0, -fCameraHeight, 0));
{$IFDEF ENABLE_MONTE_CARLO             }
  fDepthOfField := 0.1;
  vCameraPos    := vCameraPos + (gRandomNormal * fDepthOfField);
{$ENDIF }
  GetCameraRayLookat(vCameraPos, vec3_15, ray);
  // GetCameraRayLookat(vec3_16, vecBlack, ray);

  cScene := GetSceneColour(ray);

  fExposure := 3.5;
  cScene    := cScene * fExposure;

{$IFDEF ENABLE_MONTE_CARLO                              }
  cPrev := texture2D(backbuffer, gl_FragCoord.xy / resolution).xyz;
  // add noise to pixel value (helps values converge)
  cPrev := cPrev + ((gPixelRandom.xyz - 0.5) * (1 / 255));
  cPrev := InvTonemap(cPrev);
  // converge speep
  fBlend := 0.1;
  cFinal := mix(cPrev, cScene, fBlend);
{$ELSE }
  cFinal := cScene;
{$ENDIF }
  cFinal := Tonemap(cFinal);

  result := TColor32(cFinal);
end;

initialization

CoolBlobs := TCoolBlobs.Create;
Shaders.Add('CoolBlobs', CoolBlobs);

finalization

FreeandNil(CoolBlobs);

end.
