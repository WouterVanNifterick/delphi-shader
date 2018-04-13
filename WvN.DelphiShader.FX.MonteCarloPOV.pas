unit WvN.DelphiShader.FX.MonteCarloPOV;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

// Blank Slate - Work in progress @P_Malin

{$define ENABLE_MONTE_CARLO}
{$define ENABLE_REFLECTIONS}
{$define ENABLE_FOG}
{$define ENABLE_SPECULAR}
{$define ENABLE_POINT_LIGHT}
{$define ENABLE_POINT_LIGHT_FLARE}


type
C_Ray=record
  vOrigin:vec3;
  vDir:vec3;
end;

C_HitInfo=record
  vPos:vec3;
  fDistance:float;
  vObjectId:vec3;
end;

C_Material=record
  cAlbedo:vec3;
  fR0:float;
  fSmoothness:float;
  vParam:vec2;
end;

TMonteCarloPOV = class(TShader)
const
  vec4_1:vec4=(x:324.324234;y:563.324234;z:657.324234;w:764.324234);
  vec4_2:vec4=(x:567.324234;y:435.324234;z:432.324234;w:657.324234);
  vec4_3:vec4=(x:10000.0;y:-1.0;z:0.0;w:0.0);
  vec2_4:vec2=(x:3.0;y:3.0);
  vec3_5:vec3=(x:0.7;y:0.8;z:0.3);
  vec3_6:vec3=(x:0.05;y:0.35;z:0.75);
  vec3_7:vec3=(x:0.4;y:0.9;z:1.0);
  vec3_8:vec3=(x:0.0;y:1.0;z:3.0);
  vec3_9:vec3=(x:32.0;y:6.0;z:1.0);
  vec3_10:vec3=(x:0.0;y:1.0;z:0.0);
  vec3_11:vec3=(x:0.0;y:0.9;z:0.0);
  vec3_12:vec3=(x:0.0;y:0.0;z:-5.0);

  var
  vCameraPos :vec3;

function RotateX( const vPos:vec3;const fAngle :float ):vec3;
function RotateY( const vPos:vec3;const fAngle :float ):vec3;
function RotateZ( const vPos:vec3;const fAngle :float ):vec3;
function DistCombineUnion( const v1:vec4;const v2 :vec4 ):vec4;
function DistCombineIntersect( const v1:vec4;const v2 :vec4 ):vec4;
function DistCombineSubtract( const v1:vec4;const v2 :vec4 ):vec4;
function DomainRepeatXZGetTile( const vPos:vec3;const vRepeat:vec2;out vTile :vec2 ):vec3;
function DomainRepeatXZ( const vPos:vec3;const vRepeat :vec2 ):vec3;
function DomainRepeatY( const vPos:vec3;const fSize :float ):vec3;
function DomainRotateSymmetry( const vPos:vec3;const fSteps :float ):vec3;
function GetDistanceXYTorus( const p:vec3;const r1:float;const r2 :float ):float;
function GetDistanceYZTorus( const p:vec3;const r1:float;const r2 :float ):float;
function GetDistanceCylinderY( const vPos:vec3;const r:float ):float;
function GetDistanceBox( const vPos:vec3;const vSize :vec3 ):float;
function GetDistanceRoundedBox( const vPos:vec3;const vSize:vec3;const fRadius :float ):float;
function GetDistanceScene( const vPos :vec3 ):vec4;
function GetObjectMaterial( const vObjId:vec3;const vPos :vec3 ):C_Material;
function GetSkyGradient( const vDir :vec3 ):vec3;
function GetLightPos(  ):vec3;
function GetLightCol(  ):vec3;
function GetAmbientLight( const vNormal:vec3 ):vec3;
procedure ApplyAtmosphere( out col:vec3;const ray:C_Ray;const intersection:C_HitInfo );
function GetSceneNormal( const vPos :vec3 ):vec3;
procedure Raymarch( const ray:C_Ray;out result:C_HitInfo;const fMaxDist:float;const maxIter :int );
function GetShadow( const vPos:vec3;const vLightDir:vec3;const fLightDistance :float ):float;
function Schlick( const vNormal:vec3;const vView:vec3;const fR0:float;const fSmoothFactor:float ):float;
function GetDiffuseIntensity( const vLightDir:vec3;const vNormal:vec3 ):float;
function GetBlinnPhongIntensity( const ray:C_Ray;const mat:C_Material;const vLightDir:vec3;const vNormal:vec3 ):float;
function GetAmbientOcclusion( const ray:C_Ray;const intersection:C_HitInfo;const vNormal:vec3 ):float;
function GetObjectLighting( const ray:C_Ray;const intersection:C_HitInfo;const material:C_Material;const vNormal:vec3;const cReflection:vec3 ):vec3;
function GetSceneColourSimple( const ray :C_Ray ):vec3;
function GetSceneColour( const ray :C_Ray ):vec3;
function OrbitPoint( const fHeading:float;const fElevation :float ):vec3;
function Gamma( const cCol :vec3 ):vec3;
function InvGamma( const cCol :vec3 ):vec3;
function Tonemap( const cCol :vec3 ):vec3;
function InvTonemap( const cCol :vec3 ):vec3;
function Main(var gl_FragCoord: Vec2): TColor32;

var
  kPI :float;
  kHalfPi :float;
  kTwoPI :float;
  gPixelRandom:vec4;
  gRandomNormal:vec3;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
MonteCarloPOV: TShader;

implementation

uses SysUtils, Math;

constructor TMonteCarloPOV.Create;
begin
  inherited;
  {$ifdef ENABLE_MONTE_CARLO}
  UseBackBuffer := True;
  SetBufferCount(1);
  {$endif ENABLE_MONTE_CARLO}

  FrameProc := PrepareFrame;
  PixelProc := Main;

  kPI     := acos(0);
  kHalfPi := arcsin(1);
  kTwoPI  := kPI * 2;

end;

procedure TMonteCarloPOV.PrepareFrame;
begin
	vCameraPos  := OrbitPoint(-mouse.x * 7.0, (mouse.y + 0.1) * kPI * 0.25) * 7.0 - vec3_11;
	{$ifdef ENABLE_MONTE_CARLO }
	vCameraPos  := vCameraPos  + (gRandomNormal * 0.05);
	{$endif }
end;


function TMonteCarloPOV.RotateX( const vPos:vec3;const fAngle :float ):vec3;
var
  s :float;
  c :float;
begin
	s  := system.sin(fAngle);
	c  := system.cos(fAngle);
	Result := Vec3.Create( vPos.x,c * vPos.y + s * vPos.z,-s * vPos.y + c * vPos.z);
end;


function TMonteCarloPOV.RotateY( const vPos:vec3;const fAngle :float ):vec3;
var
  s :float;
  c :float;
begin
	s  := system.sin(fAngle);
	c  := system.cos(fAngle);
	Result  := Vec3.Create( c * vPos.x + s * vPos.z,vPos.y,-s * vPos.x + c * vPos.z);
end;


function TMonteCarloPOV.RotateZ( const vPos:vec3;const fAngle :float ):vec3;
var
  s :float;
  c :float;
begin
	s  := system.sin(fAngle);
	c  := system.cos(fAngle);
	Result  := Vec3.Create( c * vPos.x + s * vPos.y,-s * vPos.x + c * vPos.y,vPos.z);
end;


function TMonteCarloPOV.DistCombineUnion( const v1:vec4;const v2 :vec4 ):vec4;
begin
  // if v1.x < v2.x then  Exit(v1) else Exit(v2);
	Exit( mix(v1, v2, step(v2.x, v1.x)) );
end;


function TMonteCarloPOV.DistCombineIntersect( const v1:vec4;const v2 :vec4 ):vec4;
begin
	Exit( mix(v2, v1, step(v2.x,v1.x)) );
end;


function TMonteCarloPOV.DistCombineSubtract( const v1:vec4;const v2 :vec4 ):vec4;
begin
	Exit( DistCombineIntersect(v1, vec4.create(-v2.x, v2.yzw)) );
end;


function TMonteCarloPOV.DomainRepeatXZGetTile( const vPos:vec3;const vRepeat:vec2;out vTile :vec2 ):vec3;
var
  vTilePos :vec2;
begin
	Result  := vPos;
	vTilePos  := (vPos.xz / vRepeat) + 0.5;
	vTile  := floor(vTilePos + 1000.0);
	Result.xz  := (fract(vTilePos) - 0.5) * vRepeat;
end;


function TMonteCarloPOV.DomainRepeatXZ( const vPos:vec3;const vRepeat :vec2 ):vec3;
var
  vTilePos :vec2;
begin
	Result  := vPos;
	vTilePos  := (vPos.xz / vRepeat) + 0.5;
	Result.xz  := (fract(vTilePos) - 0.5) * vRepeat;
end;


function TMonteCarloPOV.DomainRepeatY( const vPos:vec3;const fSize :float ):vec3;
begin
	Result  := vPos;
	Result.y  := (fract(vPos.y / fSize + 0.5) - 0.5) * fSize;
end;


function TMonteCarloPOV.DomainRotateSymmetry( const vPos:vec3;const fSteps :float ):vec3;
var
  angle :float;
  fScale :float;
  steppedAngle :float;
  s :float;
  c :float;
begin
	angle  := atan( vPos.x, vPos.z );

	fScale  := fSteps / (kTwoPI);
	steppedAngle  := (floor(angle * fScale + 0.5)) / fScale;

	s  := system.sin(-steppedAngle);
	c  := system.cos(-steppedAngle);

	Result := vec3.create(
               c * vPos.x + s * vPos.z,
    			     vPos.y,
		     	    -s * vPos.x + c * vPos.z);
end;


function TMonteCarloPOV.GetDistanceXYTorus( const p:vec3;const r1:float;const r2 :float ):float;
var
  q :vec2;
begin
	q  := Vec2.Create(length(p.xy)-r1,p.z);
	Exit( length(q)-r2 );
end;

function TMonteCarloPOV.GetDistanceYZTorus( const p:vec3;const r1:float;const r2 :float ):float;
var
  q :vec2;
begin
	q  := Vec2.Create(length(p.yz)-r1,p.x);
	Exit( length(q)-r2 );
end;

function TMonteCarloPOV.GetDistanceCylinderY( const vPos:vec3;const r:float ):float;
begin
	Exit( length(vPos.xz) - r );
end;

function TMonteCarloPOV.GetDistanceBox( const vPos:vec3;const vSize :vec3 ):float;
var
  vDist :vec3;
begin
	vDist  := (abs(vPos) - vSize);
	Exit( Math.max(vDist.x, Math.max(vDist.y, vDist.z)) );
end;


function TMonteCarloPOV.GetDistanceRoundedBox( const vPos:vec3;const vSize:vec3;const fRadius :float ):float;
var
  vClosest :vec3;

begin
	vClosest  := max(min(vPos, vSize), -vSize);
	Exit( length(vClosest - vPos) - fRadius );
end;


// result is x=scene distance y=material or object id; zw are material specific parameters (maybe uv co-ordinates)
function TMonteCarloPOV.GetDistanceScene( const vPos :vec3 ):vec4;
var
  vSphereDomain :vec3;
  vDistSphere :vec4;
  vDistFloor :vec4;
begin
	Result  := vec4_3;

	vSphereDomain  := DomainRepeatXZ(vPos, vec2_4);

	vDistSphere  := vec4.Create(
                    length(vSphereDomain + Vec3.Create(0.0, system.sin(vPos.x / 4.0)*0.5 +
                                                            system.sin(vPos.z / 4.0)*0.5,0.0)) - 0.5,
                    2.0,
                    vSphereDomain.x,
                    vSphereDomain.y
                  );

	Result  := DistCombineUnion(Result, vDistSphere);

	vDistFloor  := vec4.create(vPos.y + 1, 1, vPos.x,vPos.z);
	Result  := DistCombineUnion(Result, vDistFloor);
end;


function TMonteCarloPOV.GetObjectMaterial( const vObjId:vec3;const vPos :vec3 ):C_Material;
var
  mat:C_Material;
begin
	if vObjId.x < 1.5 then
	begin
		// floor
		mat.fR0  := 0.02;
		mat.fSmoothness  := 0.0;
		mat.cAlbedo  := vec3_5;
	end
	else
	if vObjId.x < 2.5 then
	begin
		// sphere
		mat.fR0  := 0.05;
		mat.fSmoothness  := 0.9;
		mat.cAlbedo  := vec3_6;
	end;
	Exit( mat );
end;

function TMonteCarloPOV.GetSkyGradient( const vDir :vec3 ):vec3;
var
  fBlend :float;

begin
	fBlend  := vDir.y * 0.5 + 0.5;
	Exit( mix(vec3Black, vec3_7, fBlend) );
end;

function TMonteCarloPOV.GetLightPos(  ):vec3;
var
  vLightPos :vec3;

begin
	vLightPos  := vec3_8;
	{$ifdef ENABLE_MONTE_CARLO        }
	vLightPos  := vLightPos  + (gRandomNormal * 0.2);
	{$endif }
	Exit( vLightPos );
end;

function TMonteCarloPOV.GetLightCol(  ):vec3;
begin
	Exit( vec3_9 * 10.0 );
end;


function TMonteCarloPOV.GetAmbientLight( const vNormal:vec3 ):vec3;
begin
	Exit( GetSkyGradient(vNormal) );
end;


const kFogDensity = 0.0025;
procedure TMonteCarloPOV.ApplyAtmosphere( out col:vec3;const ray:C_Ray;const intersection:C_HitInfo );

var
  fFogAmount :float;
  cFog :vec3;
  vToLight :vec3;
  fDot :float;
  vClosestPoint :vec3;
  fDist :float;

begin
	{$ifdef ENABLE_FOG}
	// fog
	fFogAmount  := exp(intersection.fDistance * -kFogDensity);
	cFog  := GetSkyGradient(ray.vDir);
	col  := mix(cFog, col, fFogAmount);
	{$endif }

	// glare from light (a bit hacky - use length of closest approach from ray to light)
	{$ifdef ENABLE_POINT_LIGHT_FLARE}
	vToLight  := GetLightPos() - ray.vOrigin;
	fDot  := dot(vToLight, ray.vDir);
	fDot  := clamp(fDot, 0.0, intersection.fDistance);

	vClosestPoint  := ray.vOrigin + ray.vDir * fDot;
	fDist  := length(vClosestPoint - GetLightPos());
	col  := col  + (GetLightCol() * 0.01/ (fDist * fDist));
	{$endif }
end;

function TMonteCarloPOV.GetSceneNormal( const vPos :vec3 ):vec3;
var
  fDelta :float;
  vOffset1 :vec3;
  vOffset2 :vec3;
  vOffset3 :vec3;
  vOffset4 :vec3;
  f1 :float;
  f2 :float;
  f3 :float;
  f4 :float;
  vNormal :vec3;

begin
	// tetrahedron normal
	fDelta  := 0.025;

	vOffset1  := Vec3.Create( fDelta,-fDelta,-fDelta);
	vOffset2  := Vec3.Create(-fDelta,-fDelta,fDelta);
	vOffset3  := Vec3.Create(-fDelta,fDelta,-fDelta);
	vOffset4  := Vec3.Create( fDelta,fDelta,fDelta);

	f1  := GetDistanceScene( vPos + vOffset1 ).x;
	f2  := GetDistanceScene( vPos + vOffset2 ).x;
	f3  := GetDistanceScene( vPos + vOffset3 ).x;
	f4  := GetDistanceScene( vPos + vOffset4 ).x;

	vNormal  := vOffset1 * f1 + vOffset2 * f2 + vOffset3 * f3 + vOffset4 * f4;

	Exit( normalize( vNormal ) );
end;


const kRaymarchEpsilon = 0.01;
const kRaymarchMatIter = 256;
const kRaymarchStartDistance = 0.1;
// This is an excellent resource on ray marching -> http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
procedure TMonteCarloPOV.Raymarch( const ray:C_Ray;out result:C_HitInfo;const fMaxDist:float;const maxIter :int );

var
  i:integer; // loop variable
vSceneDist :vec4;

begin
	result.fDistance  := kRaymarchStartDistance;
	result.vObjectId.x  := 0.0;

	for i := 0 to kRaymarchMatIter do
	begin
		result.vPos  := ray.vOrigin + ray.vDir * result.fDistance;
		vSceneDist  := GetDistanceScene( result.vPos );
		result.vObjectId  := vSceneDist.yzw;

		// abs allows backward stepping - should only be necessary for non uniform distance functions
		if (System.abs(vSceneDist.x) <= kRaymarchEpsilon)  or  (result.fDistance >= fMaxDist)  or  (i > maxIter) then
		begin
			break;
		end;


		result.fDistance := result.fDistance + vSceneDist.x;
	end;



	if result.fDistance >= fMaxDist then
	begin
		result.vPos  := ray.vOrigin + ray.vDir * result.fDistance;
		result.vObjectId.x  := 0.0;
		result.fDistance  := 1000.0;
	end;

end;


function TMonteCarloPOV.GetShadow( const vPos:vec3;const vLightDir:vec3;const fLightDistance :float ):float;
var
  shadowRay:C_Ray;
  shadowIntersect:C_HitInfo;

begin

	shadowRay.vDir  := vLightDir;
	shadowRay.vOrigin  := vPos;


	Raymarch(shadowRay, shadowIntersect, fLightDistance, 32);

	Exit( step(0.0, shadowIntersect.fDistance) * step(fLightDistance, shadowIntersect.fDistance ) );
end;


// http://en.wikipedia.org/wiki/Schlick's_approximation
function TMonteCarloPOV.Schlick( const vNormal:vec3;const vView:vec3;const fR0:float;const fSmoothFactor:float ):float;
var
  fDot :float;
  fDot2 :float;
  fDot5 :float;

begin
	fDot  := dot(vNormal, -vView);
	fDot  := min(max((1.0 - fDot), 0.0), 1.0);
	fDot2  := fDot * fDot;
	fDot5  := fDot2 * fDot2 * fDot;
	Exit( fR0 + (1.0 - fR0) * fDot5 * fSmoothFactor );
end;


function TMonteCarloPOV.GetDiffuseIntensity( const vLightDir:vec3;const vNormal:vec3 ):float;
begin
	Exit( max(0.0, dot(vLightDir, vNormal)) );
end;


function TMonteCarloPOV.GetBlinnPhongIntensity( const ray:C_Ray;const mat:C_Material;const vLightDir:vec3;const vNormal:vec3 ):float;
var
  vHalf :vec3;
  fNdotH :float;
  fSpecPower :float;
  fSpecIntensity :float;

begin
	vHalf  := normalize(vLightDir - ray.vDir);
	fNdotH  := max(0.0, dot(vHalf, vNormal));

	fSpecPower  := exp2(4.0 + 6.0 * mat.fSmoothness);
	fSpecIntensity  := (fSpecPower + 2.0) * 0.125;

	Exit( pow(fNdotH, fSpecPower) * fSpecIntensity );
end;


// use distance field to evaluate ambient occlusion
function TMonteCarloPOV.GetAmbientOcclusion( const ray:C_Ray;const intersection:C_HitInfo;const vNormal:vec3 ):float;
var
  vPos :vec3;
  fAmbientOcclusion :float;
  fDist :float;
  i:integer; // loop variable
vSceneDist :vec4;

begin
	vPos  := intersection.vPos;

	fAmbientOcclusion  := 1.0;

	fDist  := 0.0;
	for i := 0 to 5 do
	begin
		fDist  := fDist  + (0.1);

		vSceneDist  := GetDistanceScene(vPos + vNormal * fDist);

		fAmbientOcclusion  := fAmbientOcclusion  * (1.0 - max(0.0, (fDist - vSceneDist.x) * 0.2 / fDist ));
	end;


	Exit( fAmbientOcclusion );
end;


function TMonteCarloPOV.GetObjectLighting( const ray:C_Ray;const intersection:C_HitInfo;const material:C_Material;const vNormal:vec3;const cReflection:vec3 ):vec3;
var
  cScene :vec3;
  vSpecularReflection :vec3;
  vDiffuseReflection :vec3;
  fAmbientOcclusion :float;
  vAmbientLight :vec3;
  vLightPos :vec3;
  vToLight :vec3;
  vLightDir :vec3;
  fLightDistance :float;
  fAttenuation :float;
  fShadowBias :float;
  fShadowFactor :float;
  vIncidentLight :vec3;
  fFresnel :float;

begin


	vSpecularReflection  := vec3(0.0);
	vDiffuseReflection  := vec3(0.0);

	fAmbientOcclusion  := GetAmbientOcclusion(ray, intersection, vNormal);
	vAmbientLight  := GetAmbientLight(vNormal) * fAmbientOcclusion;

	vDiffuseReflection  := vDiffuseReflection  + (vAmbientLight);

	vSpecularReflection  := vSpecularReflection  + (cReflection * fAmbientOcclusion);

	{$ifdef ENABLE_POINT_LIGHT}
	vLightPos  := GetLightPos();
	vToLight  := vLightPos - intersection.vPos;
	vLightDir  := normalize(vToLight);
	fLightDistance  := length(vToLight);

	fAttenuation  := 1.0 / (fLightDistance * fLightDistance);

	fShadowBias  := 0.1;
	fShadowFactor  := GetShadow( intersection.vPos + vLightDir * fShadowBias, vLightDir, fLightDistance - fShadowBias );
	vIncidentLight  := GetLightCol() * fShadowFactor * fAttenuation;

	vDiffuseReflection  := vDiffuseReflection  + (GetDiffuseIntensity( vLightDir, vNormal ) * vIncidentLight);
	vSpecularReflection  := vSpecularReflection  + (GetBlinnPhongIntensity( ray, material, vLightDir, vNormal ) * vIncidentLight);
	{$endif ENABLE_POINT_LIGHT}

	vDiffuseReflection  := vDiffuseReflection  * (material.cAlbedo);

	{$ifdef ENABLE_SPECULAR}
	fFresnel  := Schlick(vNormal, ray.vDir, material.fR0, material.fSmoothness * 0.9 + 0.1);
	cScene  := mix(vDiffuseReflection , vSpecularReflection, fFresnel);
	{$else}
	cScene  := vDiffuseReflection;
	{$endif }

	Exit( cScene );
end;


function TMonteCarloPOV.GetSceneColourSimple( const ray :C_Ray ):vec3;
var
  intersection:C_HitInfo;
  cScene:vec3;
  material :C_Material;
  vNormal :vec3;
  cReflection :vec3;

begin

	Raymarch(ray, intersection, 16.0, 32);



	if intersection.vObjectId.x < 0.5 then
	begin
		cScene  := GetSkyGradient(ray.vDir);
	end
  else
	begin
		material  := GetObjectMaterial(intersection.vObjectId, intersection.vPos);
		vNormal  := GetSceneNormal(intersection.vPos);

		// use sky gradient instead of reflection
		cReflection  := GetSkyGradient(reflect(ray.vDir, vNormal));

		// apply lighting
		cScene  := GetObjectLighting(ray, intersection, material, vNormal, cReflection );
	end;


	ApplyAtmosphere(cScene, ray, intersection);

	Exit( cScene );
end;


function TMonteCarloPOV.GetSceneColour( const ray :C_Ray ):vec3;
var
  intersection:C_HitInfo;
  cScene:vec3;
  material :C_Material;
  vNormal :vec3;
  cReflection:vec3;
  fSepration :float;
  reflectRay:C_Ray;

begin

	Raymarch(ray, intersection, 30.0, 256);



	if intersection.vObjectId.x < 0.5 then
	begin
		cScene  := GetSkyGradient(ray.vDir);
	end
	else
	begin
		material  := GetObjectMaterial(intersection.vObjectId, intersection.vPos);
		vNormal  := GetSceneNormal(intersection.vPos);

		{$ifdef ENABLE_MONTE_CARLO}
		vNormal  := normalize(vNormal + gRandomNormal / (5.0 + material.fSmoothness * 200.0));
		{$endif }


		{$ifdef ENABLE_REFLECTIONS    }
		begin
			// get colour from reflected ray
			fSepration  := 0.05;

			reflectRay.vDir  := reflect(ray.vDir, vNormal);
			reflectRay.vOrigin  := intersection.vPos + reflectRay.vDir * fSepration;

			cReflection := GetSceneColourSimple(reflectRay);
		end;
		{$else}
		cReflection := GetSkyGradient(reflect(ray.vDir, vNormal));
		{$endif }
		// apply lighting
		cScene  := GetObjectLighting(ray, intersection, material, vNormal, cReflection );
	end;


	ApplyAtmosphere(cScene, ray, intersection);

	Exit( cScene );
end;





function TMonteCarloPOV.OrbitPoint( const fHeading:float;const fElevation :float ):vec3;
var ce:double;
begin
  ce := system.cos(fElevation);
	Result.x := system.sin(fHeading) * ce;
  Result.y := system.sin(fElevation);
  Result.z := system.cos(fHeading) * ce;
end;


function TMonteCarloPOV.Gamma( const cCol :vec3 ):vec3;
begin
	Result := cCol * cCol;
end;


function TMonteCarloPOV.InvGamma( const cCol :vec3 ):vec3;
begin
	Exit( sqrt(cCol) );
end;



function TMonteCarloPOV.Tonemap( const cCol :vec3 ):vec3;
var
  vResult :vec3;

begin
	// simple Reinhard tonemapping operator
	vResult  := cCol / (1 + cCol);

	Exit( Gamma(vResult) );
end;


function TMonteCarloPOV.InvTonemap( const cCol :vec3 ):vec3;
var
  vResult :vec3;

begin
	vResult  := cCol;
	vResult  := clamp(vResult, 0.01, 0.99);
	vResult  := InvGamma(vResult);
	Exit( - (vResult / (vResult - 1.0)) );
end;


function TMonteCarloPOV.main;
var
  ray:C_Ray;
  cScene :vec3;
  fExposure :float;
	{$ifdef ENABLE_MONTE_CARLO}
  cPrev :vec3;
  fBlend :float;
  {$endif ENABLE_MONTE_CARLO}
  cFinal :vec3;

            {$ifdef ENABLE_MONTE_CARLO}
            procedure CalcPixelRandom(  );
            var
              s1 :vec4;
              s2 :vec4;
            begin
              // Nothing special here, just numbers generated by bashing keyboard
              s1            := sin(&mod( time * 9.3422 + gl_FragCoord.x * vec4_1,2*pi)) * 543.3423;
              s2            := sin(&mod( time * 1.3422 + gl_FragCoord.y * vec4_2,2*pi)) * 654.5423;
              gPixelRandom  := fract(2142.4 + s1 + s2);
              gRandomNormal := normalize(gPixelRandom.xyz - 0.1);
            end;
            {$endif }



            procedure GetCameraRay(const vPos: vec3; const vForwards: vec3; const vWorldUp: vec3; out ray: C_Ray);
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
              vPixelCoord.x := vPixelCoord.x + (gPixelRandom.z);
              vPixelCoord.y := vPixelCoord.y + (gPixelRandom.w);
{$ENDIF }
              vUV          := (vPixelCoord / resolution.xy);
              vViewCoord   := vUV * 2.0 - 1.0;
              vViewCoord   := vViewCoord * (0.75);
              fRatio       := resolution.x / resolution.y;
              vViewCoord.y := vViewCoord.y / (fRatio);
              ray.vOrigin  := vPos;
              vRight       := normalize(cross(vForwards, vWorldUp));
              vUp          := cross(vRight, vForwards);
              ray.vDir     := normalize(vRight * vViewCoord.x + vUp * vViewCoord.y + vForwards);
            end;

            procedure GetCameraRayLookat(const vPos: vec3; const vInterest: vec3; out ray: C_Ray);
            var
              vForwards: vec3;
              vUp      : vec3;
            begin
              vForwards := normalize(vInterest - vPos);
              vUp       := vec3_10;
              GetCameraRay(vPos, vForwards, vUp, ray);
            end;


begin
	{$ifdef ENABLE_MONTE_CARLO }
	CalcPixelRandom();
	{$endif }

	GetCameraRayLookat( vCameraPos, vec3Black, ray);
	//GetCameraRayLookat(vec3_12, vecBlack, ray);

	cScene  := GetSceneColour( ray );

	fExposure  := 2.5;
	cScene  := cScene * fExposure;

	{$ifdef ENABLE_MONTE_CARLO                              }
	cPrev  := texture2D(Buffers[0].Bitmap, gl_FragCoord.xy / resolution).xyz;

	/// add noise to pixel value (helps values converge)
	cPrev  := cPrev  + ((gPixelRandom.xyz - 0.5) * (1.0 / 255.0));
	cPrev  := InvTonemap(cPrev);
	// converge speed
	fBlend  := 0.3;
	cFinal  := mix(cPrev, cScene, fBlend);
	{$else}
	cFinal  := cScene;
	{$endif }

	cFinal  := Tonemap(cFinal);

	Result := TColor32( cFinal );

	//gl_FragColor = vec4(CalculateNoiseTexture()); // output noise texture
end;


initialization

MonteCarloPOV := TMonteCarloPOV.Create;
Shaders.Add('MonteCarloPOV', MonteCarloPOV);

finalization

FreeandNil(MonteCarloPOV);

end.
