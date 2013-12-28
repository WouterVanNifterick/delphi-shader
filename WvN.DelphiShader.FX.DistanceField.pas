unit WvN.DelphiShader.FX.DistanceField;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  C_Ray = record
    vOrigin:vec3;
    vDir:vec3;
  end;

  C_HitInfo = record
    fDistance:float;
    fObjectId:float;
    vPos:vec3;
  end;

  TDistanceField = class(TShader)
    fRatio :float;
    LightPos:Vec3;

    function DistCombineUnion( const v1, v2 :vec2 ):vec2;
    function GetDistanceSphere( const vPos,vSphereOrigin:vec3;const fSphereRadius :float ):float;
    function GetDistancePlane( const vPos,vPlaneNormal:vec3;const fPlaneDist :float ):float;
    function GetDistanceBumpyFloor( const vPos:vec3;const fHeight :float ):float;
    function GetDistanceScene( const vPos :vec3 ):vec2;
    function GetSceneNormal( const vPos :vec3 ):vec3;
    procedure Raymarch( const ray:C_Ray; out result:C_HitInfo );
    function GetObjectDiffuse( const fObjId:float;const vPos :vec3 ):vec3;
    function GetSkyGradient( const vDir :vec3 ):vec3;
    function GetShadow( const ray:C_Ray; const intersection:C_HitInfo; const vLightDir:vec3;const fLightDistance :float ):float;
    function Schlick4( const vNormal:vec3;const vView:vec3;const fR0:float ):float;
    function GetDiffuseLight( const vLightDir:vec3;const vNormal:vec3 ):vec3;
    function GetPhong( const ray:C_Ray; const vLightDir:vec3;const vNormal:vec3 ):vec3;
    function GetAmbientLight( const vNormal:vec3 ):vec3;
    function GetAmbientOcclusion(const intersection:C_HitInfo;  const vNormal:vec3 ):float;
    procedure ApplyAtmosphere(out col:vec3;const ray:C_Ray; const intersection:C_HitInfo );
    function GetSceneColourSimple( const ray:C_Ray):vec3;
    function GetSceneColour( const ray:C_Ray ):vec3;
    function Main(var gl_FragCoord: Vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

const
  vec3_1:vec3=(x:0.3;y:0.8;z:0.9);
  vec3_2:vec3=(x:0;y:0;z:1);
  vec3_3:vec3=(x:1;y:0;z:0);
  vec3_4:vec3=(x:0.4;y:1;z:1);
  vec3_5:vec3=(x:0;y:0;z:1);
  LightCol:vec3=(x:3;y:3;z:1);
  vec3_7:vec3=(x:0.1;y:0.3;z:0.5);
  vec3_8:vec3=(x:0.5;y:0.8;z:1);


var
DistanceField: TShader;

implementation

uses SysUtils, Math;

constructor TDistanceField.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

// playing around with ray marching distance fields and lighting - @P_Malin


function TDistanceField.DistCombineUnion( const v1:vec2;const v2 :vec2 ):vec2;
begin
	if v1.x < v2.x then
		Result := v1
	else
		Result := v2;
end;


function TDistanceField.GetDistanceSphere( const vPos:vec3;const vSphereOrigin:vec3;const fSphereRadius :float ):float;
begin
	Result := length(vPos - vSphereOrigin) - fSphereRadius;
end;


function TDistanceField.GetDistancePlane( const vPos:vec3;const vPlaneNormal:vec3;const fPlaneDist :float ):float;
begin
	Result := dot(vPos, vPlaneNormal) + fPlaneDist;
end;


function TDistanceField.GetDistanceBumpyFloor( const vPos:vec3;const fHeight :float ):float;
begin
	Result := vPos.y - fHeight + (system.sin((vPos.x + time) * 10) * 0.01 + 0.01) + (system.sin((vPos.z) * 10) * 0.01 + 0.01);
end;



function TDistanceField.GetDistanceScene( const vPos :vec3 ):vec2;
var
  vDistPlane1 :vec2;
  vDistSphere1 :vec2;
  vDistSphere2 :vec2;
  vResult :vec2;

begin
	vDistPlane1  := Vec2.Create(GetDistanceBumpyFloor( vPos, -1 ),1);
	vDistSphere1  := Vec2.Create(GetDistanceSphere( vPos, Vec3.Create( 1.75 + system.sin(time), -0.25, 5 + system.cos(time)),0.75 ),2);
	vDistSphere2  := Vec2.Create(GetDistanceSphere( vPos, Vec3.Create(-1.75 - system.sin(time), -0.25, 5 - system.cos(time)),0.75 ),3);

	vResult  := DistCombineUnion(vDistSphere1, vDistSphere2);
	vResult  := DistCombineUnion(vResult, vDistPlane1);
	Exit( vResult );
end;


function TDistanceField.GetSceneNormal( const vPos :vec3 ):vec3;
var
  fDelta :float;
  fDx :float;
  fDy :float;
  fDz :float;
  vNormal :vec3;
begin
	fDelta  := 0.001;

	fDx  := GetDistanceScene( vPos + Vec3.Create(fDelta, 0, 0) ).x - GetDistanceScene( vPos + Vec3.Create(-fDelta,0,0) ).x;
	fDy  := GetDistanceScene( vPos + Vec3.Create(0, fDelta, 0) ).x - GetDistanceScene( vPos + Vec3.Create(0,-fDelta,0) ).x;
	fDz  := GetDistanceScene( vPos + Vec3.Create(0, 0, fDelta) ).x - GetDistanceScene( vPos + Vec3.Create(0,0,-fDelta) ).x;

	vNormal  := Vec3.Create( fDx,fDy,fDz );

	Exit( normalize( vNormal ) );
end;

procedure TDistanceField.Raymarch( const ray:C_Ray; out result:C_HitInfo );

var
  fMaxDist  :float;
  fEpsilon  :float;
  i:integer; // loop variable
  vSceneDist :vec2;
begin
  fMaxDist   := 30;
  fEpsilon   := 0.01;

	result.fDistance  := 0;
	result.fObjectId  := 0;

 	for i := 0 to 127 do
	begin
		result.vPos  := ray.vOrigin + ray.vDir * result.fDistance;
		vSceneDist   := GetDistanceScene( result.vPos );
		if vSceneDist.x <= fEpsilon then
		begin
			result.fObjectId  := vSceneDist.y;
			break;
		end;


		result.fDistance  := result.fDistance  + vSceneDist.x;

		if result.fDistance > fMaxDist then
		begin
			result.vPos  := ray.vOrigin + ray.vDir * result.fDistance;
			result.fDistance  := fMaxDist;
			result.fObjectId  := 0;
			break;
		end;

	end;


end;


function TDistanceField.GetObjectDiffuse( const fObjId:float;const vPos :vec3 ):vec3;
var
  fBlend :float;

begin
	if fObjId < 0.5 then
	begin
		Exit( vec3_1 );
	end;


	if fObjId < 1.5 then
	begin
		fBlend  := &mod(floor(fract(vPos.x + time) *2) + floor(fract(vPos.z) * 2), 2);
		Exit( vec3_3 * fBlend + vec3_2 * (1 - fBlend) );
	end;


	Exit( Vec3.Create( &mod(fObjId, 2), &mod(fObjId / 2, 2),&mod(fObjId/4,2)) );
end;


function TDistanceField.GetSkyGradient( const vDir :vec3 ):vec3;
var
  fBlend :float;

begin
	fBlend  := vDir.y * 0.5 + 0.5;
	Exit( vec3_5 * fBlend + vec3_4 * (1 - fBlend) );

end;




function TDistanceField.GetShadow( const ray:C_Ray; const intersection:C_HitInfo; const vLightDir:vec3;const fLightDistance :float ):float;
var
  fSepration :float;
  shadowRay : C_Ray;
  shadowIntersect : C_HitInfo;
begin
	fSepration  := 0.1;
	shadowRay.vDir  := vLightDir;
	shadowRay.vOrigin  := intersection.vPos + shadowRay.vDir * fSepration;

	Raymarch(shadowRay, shadowIntersect);

	if (shadowIntersect.fDistance >= 0)  and  (shadowIntersect.fDistance <= fLightDistance) then
		Exit( 0 );

	Exit( 1 );

end;


function TDistanceField.Schlick4( const vNormal:vec3;const vView:vec3;const fR0:float ):float;
var
  fDot :float;
  fDot2 :float;
  fDot4 :float;

begin
	fDot  := dot(vNormal, -vView);
	fDot  := max((1 - fDot), 0);
	fDot2  := fDot * fDot;
	fDot4  := fDot2 * fDot2;
	Exit( fR0 + (1 - fR0) * fDot4 );
end;




function TDistanceField.GetDiffuseLight( const vLightDir:vec3;const vNormal:vec3 ):vec3;
var
  fDiffuseIntensity :float;
begin

	fDiffuseIntensity  := math.max(0, dot(vLightDir, vNormal));

	Exit( LightCol * fDiffuseIntensity );
end;


function TDistanceField.GetPhong( const ray:C_Ray; const vLightDir:vec3;const vNormal:vec3 ):vec3;
var
  vHalf :vec3;
  fNdotH :float;

begin
	vHalf  := normalize(vLightDir - ray.vDir);
	fNdotH  := math.max(0, dot(vHalf, vNormal));

	Exit( LightCol * pow(fNdotH, 100) * 5 );
end;


function TDistanceField.GetAmbientLight( const vNormal:vec3 ):vec3;
begin
	Exit( GetSkyGradient(vNormal) );
	//return vec3_7;
end;


function TDistanceField.GetAmbientOcclusion(const intersection:C_HitInfo; const vNormal:vec3 ):float;
var
  vPos :vec3;
  fDist :float;
  i:integer; // loop variable
  vSceneDist :vec2;
begin
	vPos  := intersection.vPos;
	Result := 1;
	fDist  := 0;
	for i := 0 to 4 do
	begin
		fDist  := fDist  + (0.1);
		vSceneDist  := GetDistanceScene(vPos + vNormal * fDist);
		Result := Result   * (1 - max(0, (fDist - vSceneDist.x) * 0.2 / fDist ));
	end;
end;


procedure TDistanceField.ApplyAtmosphere(out col:vec3;const ray:C_Ray; const intersection:C_HitInfo );

var
  vToLight :vec3;
  fDot :float;
  vClosestPoint :vec3;
  fDist :float;
  fFogDensity :float;
  fFogAmount :float;
  cFog :vec3;

begin
	// glare from light
	vToLight  := LightPos - ray.vOrigin;
	fDot  := dot(vToLight, ray.vDir);
	fDot  := clamp(fDot, 0, intersection.fDistance);

	vClosestPoint  := ray.vOrigin + ray.vDir * fDot;
	fDist  := length(vClosestPoint - LightPos);
	col  := col  + (LightCol * 0.1 / (fDist * fDist));

	// fog
	fFogDensity  := 0.015;
	fFogAmount  := exp(intersection.fDistance * -fFogDensity);
	cFog  := vec3_8;
	col  := col * fFogAmount + cFog * (1 - fFogAmount);


end;


function TDistanceField.GetSceneColourSimple( const ray:C_Ray):vec3;
var
  cScene:vec3;
  vNormal :vec3;
  vLightPos :vec3;
  vToLight :vec3;
  vLightDir :vec3;
  fLightDistance :float;
  fShadowFactor :float;
  vDiffuseLight :vec3;
  fAmbientOcclusion :float;
  vAmbientLight :vec3;
  cMatDiffuse :vec3;
  vDiffuseReflection :vec3;
  vSpecularReflection :vec3;
  fR0 :float;
  fFresnel :float;
  intersection :C_HitInfo;
begin
	Raymarch(ray, intersection);



	if intersection.fObjectId < 0.5 then
	begin
		cScene  := GetSkyGradient(ray.vDir);
	end
	else
	begin

		vNormal  := GetSceneNormal(intersection.vPos);

		vLightPos  := LightPos;
		vToLight  := vLightPos - intersection.vPos;
		vLightDir  := normalize(vToLight);
		fLightDistance  := length(vToLight);

		fShadowFactor  := GetShadow( ray, intersection, vLightDir, fLightDistance );
		vDiffuseLight  := GetDiffuseLight( vLightDir, vNormal ) * fShadowFactor;
		fAmbientOcclusion  := GetAmbientOcclusion(intersection, vNormal);
		vAmbientLight  := GetAmbientLight(vNormal) * fAmbientOcclusion;

		cMatDiffuse  := GetObjectDiffuse(intersection.fObjectId, intersection.vPos);
		vDiffuseReflection  := cMatDiffuse * (vDiffuseLight + vAmbientLight);

		vSpecularReflection  := (GetSkyGradient(reflect(ray.vDir, vNormal)))
                           +(GetPhong( ray, vLightDir, vNormal ) * fShadowFactor);
		fR0  := 0.25;
		fFresnel  := Schlick4(vNormal, ray.vDir, fR0);
		cScene  := vDiffuseReflection * (1 - fFresnel) + vSpecularReflection * fFresnel;


	end;
	ApplyAtmosphere(cScene, ray, intersection);

	Result := cScene;
end;




function TDistanceField.GetSceneColour( const ray:C_Ray ):vec3;
var
  cScene:vec3;
  vNormal :vec3;
  vLightPos :vec3;
  vToLight :vec3;
  vLightDir :vec3;
  fLightDistance :float;
  fShadowFactor :float;
  vDiffuseLight :vec3;
  fAmbientOcclusion :float;
  vAmbientLight :vec3;
  cMatDiffuse :vec3;
  vDiffuseReflection :vec3;
  vSpecularReflection :vec3;
  fSepration :float;
  fR0 :float;
  fFresnel :float;
  intersection : C_HitInfo;
  reflectRay:C_Ray ;
begin
	Raymarch(ray, intersection);

	if intersection.fObjectId < 0.5 then
	begin
		cScene  := GetSkyGradient(ray.vDir);
	end
	else
	begin
		vNormal  := GetSceneNormal(intersection.vPos);

		vLightPos  := LightPos;
		vToLight  := vLightPos - intersection.vPos;
		vLightDir  := normalize(vToLight);
		fLightDistance  := length(vToLight);

		fShadowFactor  := GetShadow( ray, intersection, vLightDir, fLightDistance );
		vDiffuseLight  := GetDiffuseLight( vLightDir, vNormal ) * fShadowFactor;
		fAmbientOcclusion  := GetAmbientOcclusion(intersection, vNormal);
		vAmbientLight  := GetAmbientLight(vNormal) * fAmbientOcclusion;


		cMatDiffuse  := GetObjectDiffuse(intersection.fObjectId, intersection.vPos);
		vDiffuseReflection  := cMatDiffuse * (vDiffuseLight + vAmbientLight);
		vSpecularReflection  := vec3Black;
		begin
			fSepration  := 0.1;

			reflectRay.vDir  := reflect(ray.vDir, vNormal);
			reflectRay.vOrigin  := intersection.vPos + reflectRay.vDir * fSepration;

			vSpecularReflection  := vSpecularReflection  + (GetSceneColourSimple(reflectRay));

		end;


		vSpecularReflection  := vSpecularReflection  + (GetPhong( ray, vLightDir, vNormal ) * fShadowFactor);

		fR0  := 0.25;
		fFresnel  := Schlick4(vNormal, ray.vDir, fR0);
		cScene  := vDiffuseReflection * (1 - fFresnel) + vSpecularReflection * fFresnel;
	end;


	ApplyAtmosphere(cScene, ray, intersection);

	Exit( cScene );
end;

procedure TDistanceField.PrepareFrame;
begin
  fRatio  := resolution.x / resolution.y;
	LightPos := Vec3.Create(system.sin(time),1 + system.cos(time * 1.231),5);
end;


function TDistanceField.main;
var
  cScene :vec3;
  fExposure :float;
  cFinal :vec3;


  procedure GetCameraRay(out ray:C_Ray);
  var
    vUV :vec2;
    vViewCoord :vec2;
  begin
    vUV  := ( gl_FragCoord.xy / resolution.xy );
    vViewCoord  := vUV * 2 - 1;
    vViewCoord.y  := vViewCoord.y  / fRatio;

    ray.vOrigin  := vecBlack;
    ray.vDir.x := vViewCoord.x;
    ray.vDir.y := vViewCoord.y;
    ray.vDir.z := 1;
    ray.vDir.NormalizeSelf;
  end;

var
	ray:C_Ray;
begin
	GetCameraRay(ray);

	cScene  := GetSceneColour( ray );

	fExposure  := 1.5;
	cFinal  := cScene * fExposure;
	cFinal  := cFinal / (1 + cFinal);

	Result := TColor32( cFinal );
end;


initialization

DistanceField := TDistanceField.Create;
Shaders.Add('DistanceField', DistanceField);

finalization

FreeandNil(DistanceField);

end.

