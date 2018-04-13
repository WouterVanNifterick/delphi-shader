unit WvN.DelphiShader.FX.ReprojectionII;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

{$DEFINE FORCE_SHADOW}
{$DEFINE ENABLE_REFLECTION}

type
  C_Ray = record
    vOrigin: vec3;
    vDir: vec3;
  end;

  TReprojectionII = class(TShader)
  var
    vMouse                   : vec2;
    vCameraPos, vCameraTarget: vec3;

  public const
    kMaxDist = 1000.0;
    kEpsilon = 0.0001;

    vec3_1: vec3 = (x: 1; y: 0; z: 0);
    vec3_2: vec3 = (x: 0; y: 1; z: 0);
    vec3_3: vec3 = (x: 0; y: 0; z: 1);

    vec3_4: vec3  = (x: 0; y: 1; z: 0);
    vec3_5: vec3  = (x: - 0.84; y: - 10; z: - 0.4);
    vec3_6: vec3  = (x: 0; y: 0; z: 8.5);
    vec3_7: vec3  = (x: - 4.1; y: 0; z: 8.5);
    vec3_8: vec3  = (x: 4; y: 0; z: 8.5);
    vec3_10: vec3 = (x: 1; y: 1; z: - 1);
    vec3_11: vec3 = (x: 0; y: 1; z: 0);
    vec3_13: vec3 = (x: 0; y: 0; z: 8);
    vec3_14: vec3 = (x: - 3; y: 0; z: - 5);
    vec3_15: vec3 = (x: 3; y: - 5; z: 5);
    vec3_16: vec3 = (x: 8; y: 0; z: 0);
    vec3_17: vec3 = (x: - 10; y: 0; z: 0);
    vec3_18: vec3 = (x: 8; y: 3; z: - 3);
    vec3_19: vec3 = (x: - 4; y: - 2; z: 0);
    vec3_20: vec3 = (x: 8; y: 5; z: 5);
    vec3_21: vec3 = (x: - 4; y: 2; z: - 5);
    vec3_22: vec3 = (x: - 10; y: 3; z: 0);
    vec3_23: vec3 = (x: 4; y: 4.5; z: - 5);
    // vec3_25: vec3 = (x: 0.9; y: 0.9; z: 0.9);
    // vec3_26: vec3 = (x: 1; y: 1; z: 1);
    // vec3_27: vec3 = (x: 0; y: 0; z: 1);

  var
    fBuildingMin: float;
    fBuildingMax: float;
    mSplineBasis: mat4;

    procedure TraceSlab(const ray: C_Ray; const vMin, vMax, vNormal: vec3; out fNear, fFar: float);
    function TraceBox(const ray: C_Ray; const vCorner1, vCorner2: vec3): float;
    function Project(const a, b: vec3): vec3;
    function TraceCylinder(const ray: C_Ray; const vPos, vDir: vec3; fRadius, fLength: float): float;
    function TraceFloor(const ray: C_Ray; const fHeight: float): float;
    function TracePillar(const ray: C_Ray; vPos: vec3): float;
    function TraceColumn(const ray: C_Ray; const vPos: vec3): float;
    function TraceBuildingSide(const ray: C_Ray): float;
    function TraceScene(const ray: C_Ray): float;
    procedure GetCameraRay(const aViewCoord: vec2; const vPos, vForwards, vWorldUp: vec3; out ray: C_Ray);
    procedure GetCameraRayLookat(const aViewCoord: vec2; const vPos, vCameraTarget: vec3; out ray: C_Ray);
    procedure GetCameraPosAndTarget(fCameraIndex: float; out vCameraPos, vCameraTarget: vec3);
    function BSpline(const a, b, c, d: vec3; const t: float): vec3;
    procedure GetCamera(out vCameraPos, vCameraTarget: vec3);
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  ReprojectionII: TShader;

implementation

uses SysUtils, Math;

constructor TReprojectionII.Create;
begin
  inherited;
  mSplineBasis := mat4.Create(-1 / 6, 3 / 6, -3 / 6, 1 / 6, 3 / 6, -6 / 6, 0 / 6, 4 / 6, -3 / 6, 3 / 6, 3 / 6, 1 / 6, 1 / 6, 0 / 6, 0 / 6, 0 / 6);

  FrameProc := PrepareFrame;
  PixelProc := Main;

  fBuildingMin := -90;
  fBuildingMax := 50;

end;


procedure TReprojectionII.TraceSlab(const ray: C_Ray; const vMin, vMax, vNormal: vec3; out fNear, fFar: float);

var
  vMinOffset    : vec3;
  vMaxOffset    : vec3;
  fMinOffset    : float;
  fMaxOffset    : float;
  fDir          : float;
  t0            : float;
  t1            : float;
  fIntersectNear: float;
  fIntersectFar : float;

begin
  vMinOffset := vMin - ray.vOrigin;
  vMaxOffset := vMax - ray.vOrigin;

  // Project offset and dir
  fMinOffset := dot(vMinOffset, vNormal);
  fMaxOffset := dot(vMaxOffset, vNormal);

  fDir := dot(ray.vDir, vNormal);

  if System.abs(fDir) < kEpsilon then
  begin
    // ray parallel to slab

    // if origin is not between slabs return false;
    if (fMinOffset > 0) or (fMaxOffset < 0) then
    begin
      fNear := kMaxDist;
      fFar  := -kMaxDist;
    end;

    // else this slab does not influence the result
  end
  else
  begin
    // ray is not parallel to slab, calculate intersections

    t0 := (fMinOffset) / fDir;
    t1 := (fMaxOffset) / fDir;

    fIntersectNear := Math.min(t0, t1);
    fIntersectFar  := Math.max(t0, t1);

    fNear := Math.max(fNear, fIntersectNear); // track largest near
    fFar  := Math.min(fFar, fIntersectFar);   // track smallest far
  end;

end;

function TReprojectionII.TraceBox(const ray: C_Ray; const vCorner1, vCorner2: vec3): float;
var
  vMin : vec3;
  vMax : vec3;
  fNear: float;
  fFar : float;

begin
  vMin := min(vCorner1, vCorner2);
  vMax := max(vCorner1, vCorner2);

  fNear := -kMaxDist;
  fFar  := kMaxDist;

  TraceSlab(ray, vMin, vMax, vec3_1, fNear, fFar);
  TraceSlab(ray, vMin, vMax, vec3_2, fNear, fFar);
  TraceSlab(ray, vMin, vMax, vec3_3, fNear, fFar);

  if fNear > fFar then
  begin
    Exit(kMaxDist);
  end;

  if fFar < 0 then
  begin
    Exit(kMaxDist);
  end;

  Exit(fNear);
end;

function TReprojectionII.Project(const a, b: vec3): vec3;
begin
  Exit(a - b * dot(a, b));
end;

function TReprojectionII.TraceCylinder(const ray: C_Ray; const vPos, vDir: vec3; fRadius, fLength: float): float;
var
  vOffset, vProjOffset, vProjDir: vec3;
  fProjScale, fTClosest         : float;
  vClosest                      : vec3;
  fDistClosest, fHalfChordLength: float;
  fTIntersectMin, fTIntersectMax: float;
begin
  vOffset := vPos - ray.vOrigin;

  vProjOffset := Project(vOffset, vDir);
  vProjDir    := Project(ray.vDir, vDir);
  fProjScale  := length(vProjDir);
  vProjDir    := vProjDir / (fProjScale);

  // intersect circle in projected space
  fTClosest := dot(vProjOffset, vProjDir);

  vClosest     := vProjDir * fTClosest;
  fDistClosest := length(vClosest - vProjOffset);
  if fDistClosest > fRadius then
  begin
    Exit(kMaxDist);
  end;

  fHalfChordLength := system.sqrt(fRadius * fRadius - fDistClosest * fDistClosest);
  fTIntersectMin   := (fTClosest - fHalfChordLength) / fProjScale;
  fTIntersectMax   := (fTClosest + fHalfChordLength) / fProjScale;

  // cap cylinder ends
  TraceSlab(ray, vPos, vPos + vDir * fLength, vDir, fTIntersectMin, fTIntersectMax);

  if fTIntersectMin > fTIntersectMax then
  begin
    Exit(kMaxDist);
  end;

  if fTIntersectMin < 0 then
  begin
    Exit(kMaxDist);
  end;

  Exit(fTIntersectMin);
end;

function TReprojectionII.TraceFloor(const ray: C_Ray; const fHeight: float): float;
var
  t: float;

begin
  if ray.vOrigin.y < fHeight then
  begin
    Exit(0);
  end;

  if ray.vDir.y > 0 then
  begin
    Exit(kMaxDist);
  end;

  t := (fHeight - ray.vOrigin.y) / ray.vDir.y;

  result := Math.max(t, 0);
end;

function TReprojectionII.TracePillar(const ray: C_Ray; vPos: vec3): float;
var
  fRadius  : float;
  fDistance: float;
  fBaseSize: float;
  vBaseMin : vec3;
  vBaseMax : vec3;
  fTopSize : float;
  vTopMin  : vec3;
  vTopMax  : vec3;

begin
  vPos.y    := -1;
  fRadius   := 0.3;
  fDistance := TraceCylinder(ray, vPos, vec3_4, fRadius, 10);
  fBaseSize := 0.4;

  vBaseMin  := vec3.Create(-fBaseSize, 0, -fBaseSize);
  vBaseMax  := vec3.Create(fBaseSize, 0.8, fBaseSize);
  fDistance := Math.min(fDistance, TraceBox(ray, vPos + vBaseMin, vPos + vBaseMax));

  fTopSize  := 0.4;
  vTopMin   := vec3.Create(-fTopSize, 5.6, -fTopSize);
  vTopMax   := vec3.Create(fTopSize, 7, fTopSize);
  fDistance := Math.min(fDistance, TraceBox(ray, vPos + vTopMin, vPos + vTopMax));

  Exit(fDistance);
end;

function TReprojectionII.TraceColumn(const ray: C_Ray; const vPos: vec3): float;
var
  vColumnMin: vec3;
  vColumnMax: vec3;
begin
  vColumnMin := vec3_5;
  vColumnMax := -vColumnMin;
  Exit(TraceBox(ray, vPos + vColumnMin, vPos + vColumnMax));
end;

function TReprojectionII.TraceBuildingSide(const ray: C_Ray): float;
var
  fDistance       : float;
  fStepHeight     : float;
  fStepDepth      : float;
  fStepStart      : float;
  x               : float;
  i               : integer;
  vBase           : vec3;
  fBackWallDist   : float;
  fBuildingHeight : float;
  fBuildingTopDist: float;
  fCeilingHeight  : float;
  fRoofDistance   : float;
  fRoofHeight     : float;

begin
  fDistance := kMaxDist;

  fStepHeight := 0.14;
  fStepDepth  := 0.2;
  fStepStart  := 7.5;
  fDistance   := Math.min(fDistance, TraceBox(ray, vec3.Create(fBuildingMin, -1.5 + fStepHeight * 0, fStepStart + fStepDepth * 0), vec3.Create(fBuildingMax, -1.5 + fStepHeight * 1, fStepStart + 20)));
  fDistance   := Math.min(fDistance, TraceBox(ray, vec3.Create(fBuildingMin, -1.5 + fStepHeight * 1, fStepStart + fStepDepth * 1), vec3.Create(fBuildingMax, -1.5 + fStepHeight * 2, fStepStart + 20)));
  fDistance   := Math.min(fDistance, TraceBox(ray, vec3.Create(fBuildingMin, -1.5 + fStepHeight * 2, fStepStart + fStepDepth * 2), vec3.Create(fBuildingMax, -1.5 + fStepHeight * 3, fStepStart + 20)));
  fDistance   := Math.min(fDistance, TraceBox(ray, vec3.Create(fBuildingMin, -1.5 + fStepHeight * 3, fStepStart + fStepDepth * 3), vec3.Create(fBuildingMax, -1.5 + fStepHeight * 4, fStepStart + 20)));

  x     := -2;
  for i := 0 to 4 do
  begin
    vBase := vec3.Create(x * 11.6, 0, 0);
    x     := x + (1);

    fDistance := Math.min(fDistance, TraceColumn(ray, vBase + vec3_6));

    fDistance := Math.min(fDistance, TracePillar(ray, vBase + vec3_7));
    fDistance := Math.min(fDistance, TracePillar(ray, vBase + vec3_8));
  end;

  fBackWallDist   := 9.5;
  fBuildingHeight := 100;
  fDistance       := Math.min(fDistance, TraceBox(ray, vec3.Create(fBuildingMin, -3, fBackWallDist), vec3.Create(fBuildingMax, fBuildingHeight, fBackWallDist + 10)));

  fBuildingTopDist := 8.1;
  fCeilingHeight   := 4.7;
  fDistance        := Math.min(fDistance, TraceBox(ray, vec3.Create(fBuildingMin, fCeilingHeight, fBuildingTopDist), vec3.Create(fBuildingMax, fBuildingHeight, fBuildingTopDist + 10)));

  fRoofDistance := 6;
  fRoofHeight   := 21;
  fDistance     := Math.min(fDistance, TraceBox(ray, vec3.Create(fBuildingMin, fRoofHeight, fRoofDistance), vec3.Create(fBuildingMax, fRoofHeight + 0.2, fRoofDistance + 10)));

  Exit(fDistance);
end;

function TReprojectionII.TraceScene(const ray: C_Ray): float;
var
  fDistance   : float;
  fFloorHeight: float;
  ray2        : C_Ray;
begin
  fDistance := kMaxDist;

  fFloorHeight := -1.5;
  fDistance    := Math.min(fDistance, TraceFloor(ray, fFloorHeight));

  // end of row
  fDistance := Math.min(fDistance, TraceBox(ray, vec3.Create(fBuildingMax, fFloorHeight, -100), vec3.Create(fBuildingMax + 1, 100, 100)));
  fDistance := Math.min(fDistance, TraceBox(ray, vec3.Create(fBuildingMin, fFloorHeight, -100), vec3.Create(fBuildingMin - 1, 100, 100)));

  fDistance := Math.min(fDistance, TraceBuildingSide(ray));

  ray2.vOrigin   := ray.vOrigin * vec3White;
  ray2.vDir      := ray.vDir * vec3_10;
  ray2.vOrigin.z := ray2.vOrigin.z - (0.3);
  fDistance      := Math.min(fDistance, TraceBuildingSide(ray2));

  Exit(fDistance);
end;

procedure TReprojectionII.GetCameraRay(const aViewCoord: vec2; const vPos, vForwards, vWorldUp: vec3; out ray: C_Ray);

var
  vRight: vec3;
  vUp   : vec3;
begin

  ray.vOrigin := vPos;

  vRight := normalize(cross(vWorldUp, vForwards));
  vUp    := cross(vRight, vForwards);

  ray.vDir := normalize(vRight * aViewCoord.x + vUp * aViewCoord.y + vForwards);
end;

procedure TReprojectionII.GetCameraRayLookat(const aViewCoord: vec2; const vPos, vCameraTarget: vec3; out ray: C_Ray);
var
  vForwards: vec3;
  vUp      : vec3;
begin
  vForwards := normalize(vCameraTarget - vPos);
  vUp       := vec3_11;

  GetCameraRay(aViewCoord, vPos, vForwards, vUp, ray);
end;

procedure TReprojectionII.GetCameraPosAndTarget(fCameraIndex: float; out vCameraPos, vCameraTarget: vec3);

var
  fCameraCount        : float;
  fCameraIndexModCount: float;

begin
  fCameraCount         := 6;
  fCameraIndexModCount := &mod(fCameraIndex, fCameraCount);

  if fCameraIndexModCount < 0.5 then
  begin
    vCameraPos    := vec3Black;
    vCameraTarget := vec3_13;
  end
  else if fCameraIndexModCount < 1.5 then
  begin
    vCameraPos    := vec3_14;
    vCameraTarget := vec3_15;
  end
  else if fCameraIndexModCount < 2.5 then
  begin
    vCameraPos    := vec3_16;
    vCameraTarget := vec3_17;
  end

  else if fCameraIndexModCount < 3.5 then
  begin
    vCameraPos    := vec3_18;
    vCameraTarget := vec3_19;
  end

  else if fCameraIndexModCount < 4.5 then
  begin
    vCameraPos    := vec3_20;
    vCameraTarget := vec3_21;
  end

  else
  begin
    vCameraPos    := vec3_22;
    vCameraTarget := vec3_23;
  end

end;

function TReprojectionII.BSpline(const a, b, c, d: vec3; const t: float): vec3;
var
  t2      : float;
  T_      : vec4;
  vCoeffsX: vec4;
  vCoeffsY: vec4;
  vCoeffsZ: vec4;
  vWeights: vec4;
begin
  t2 := t * t;
  T_ := vec4.Create(t2 * t, t2, t, 1);

  vCoeffsX := vec4.Create(a.x, b.x, c.x, d.x);
  vCoeffsY := vec4.Create(a.y, b.y, c.y, d.y);
  vCoeffsZ := vec4.Create(a.z, b.z, c.z, d.z);

  vWeights := mSplineBasis * T_;

  result.x := dot(vWeights, vCoeffsX);
  result.y := dot(vWeights, vCoeffsY);
  result.z := dot(vWeights, vCoeffsZ);
end;

procedure TReprojectionII.GetCamera(out vCameraPos, vCameraTarget: vec3);

var
  fCameraGlobalTime: float;
  fCameraTime      : float;
  fCameraIndex     : float;
  vCameraPosA      : vec3;
  vCameraTargetA   : vec3;
  vCameraPosB      : vec3;
  vCameraTargetB   : vec3;
  vCameraPosC      : vec3;
  vCameraTargetC   : vec3;
  vCameraPosD      : vec3;
  vCameraTargetD   : vec3;
begin
  fCameraGlobalTime := iGlobalTime * 0.5;
  fCameraTime       := fract(fCameraGlobalTime);
  fCameraIndex      := Math.floor(fCameraGlobalTime);

  GetCameraPosAndTarget(fCameraIndex, vCameraPosA, vCameraTargetA);
  GetCameraPosAndTarget(fCameraIndex + 1, vCameraPosB, vCameraTargetB);
  GetCameraPosAndTarget(fCameraIndex + 2, vCameraPosC, vCameraTargetC);
  GetCameraPosAndTarget(fCameraIndex + 3, vCameraPosD, vCameraTargetD);

  vCameraPos    := BSpline(vCameraPosA, vCameraPosB, vCameraPosC, vCameraPosD, fCameraTime);
  vCameraTarget := BSpline(vCameraTargetA, vCameraTargetB, vCameraTargetC, vCameraTargetD, fCameraTime);
end;

procedure TReprojectionII.PrepareFrame;
begin
  // Reprojection II - @P_Malin

  // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
  GetCamera(vCameraPos, vCameraTarget);
  vMouse := iMouse.xy / resolution.xy;


end;


function TReprojectionII.Main(var gl_FragCoord: vec2): TColor32;
var
  ray                      : C_Ray;
  vResult                  : vec3;
  fHitDist                 : float;
  vHitPos                  : vec3;
  fIntensity               : float;
  fDelta                   : float;
  vSampleDx, vSampleDy     : float;
  vNormal, vReflect        : vec3;
  fDot, r0, fSchlick       : float;
  vResult2                 : vec3;
  shade                    : float;
  vUV, vViewCoord          : vec2;
begin
  vResult := vec3Black;

  vUV          := gl_FragCoord.xy / resolution.xy;
  vViewCoord   := vUV * 2 - 1;
  vViewCoord.x := vViewCoord.x * (resolution.x / resolution.y);
  vViewCoord.y := -vViewCoord.y;
  vViewCoord   := vViewCoord * 0.5;

  GetCameraRayLookat(vViewCoord, vCameraPos, vCameraTarget, ray);

  fHitDist := TraceScene(ray);
  vHitPos  := ray.vOrigin + ray.vDir * fHitDist;

  vResult := textureCube(TShader.cubes[0], vHitPos.xyz).rgb;
  vResult := vResult * vResult;

{$IFDEF FORCE_SHADOW}
  if System.abs(vHitPos.z) > 9.48 then
  begin
    if System.abs(vHitPos.x) < 20 then
    begin
      fIntensity := length(vResult);
      fIntensity := min(fIntensity, 0.05);
      vResult := normalizeS(vResult) * fIntensity;
    end;

  end;

{$ENDIF }
{$IFDEF ENABLE_REFLECTION}
  if vHitPos.y < -1.4 then
  begin
    fDelta    := -0.1;
    vSampleDx := textureCube(TShader.cubes[0], vHitPos.xyz + vec3.Create(fDelta, 0, 0)).r;
    vSampleDx := vSampleDx * vSampleDx;

    vSampleDy := textureCube(TShader.cubes[0], vHitPos.xyz + vec3.Create(0, 0, fDelta)).r;
    vSampleDy := vSampleDy * vSampleDy;

    vNormal := vec3.Create(vResult.r - vSampleDx, 2, vResult.r - vSampleDy);
    vNormal := normalize(vNormal);

    vReflect := reflect(ray.vDir, vNormal);

    fDot := clamp(dot(-ray.vDir, vNormal), 0, 1);

    r0       := 0.1;
    fSchlick := r0 + (1 - r0) * (pow(1 - fDot, 5));

    vResult2 := textureCube(TShader.cubes[1], vReflect).rgb;
    vResult2 := vResult2 * vResult2;
    shade    := smoothstep(0.3, 0, vResult.r);
    vResult  := vResult + (shade * vResult2 * fSchlick * 5);
  end;

{$ENDIF }
  result := TColor32(sqrt(vResult));
end;

initialization

ReprojectionII := TReprojectionII.Create;
Shaders.Add('ReprojectionII', ReprojectionII);

finalization

FreeandNil(ReprojectionII);

end.
