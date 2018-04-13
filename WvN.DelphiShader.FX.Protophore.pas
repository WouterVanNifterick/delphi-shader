unit WvN.DelphiShader.FX.Protophore;

interface

uses GR32,Types,WvN.DelphiShader.Shader;

type
TProtophore = class(TShader)
const
  RECURSION_LEVELS = 4;
  vec3_2:vec3 = (x:1;y:1;z:1);
  vec3_3:vec3 = (x:2;y:2;z:2);
  vec2_4:vec2 = (x:0.9;y:4);
  vec3_5:vec3 = (x:0.8;y:0.8;z:0.8);
  vec3_6:vec3 = (x:8;y:6;z:7);
  vec3_7:vec3 = (x:8;y:7;z:6);
  vec3_8:vec3 = (x:50.0;y:50.0;z:50.0);
  vec2_9:vec2 = (x:1000000;y:0);
  vec3_10:vec3 = (x:0;y:1;z:0);
  vec3_11:vec3 = (x:0;y:0;z:0);
  vec2_12:vec2 = (x:0.5;y:0);
  vec3_13:vec3 = (x:0;y:0;z:0);
  vec3_14:vec3 = (x:0;y:0;z:0);
  vec3_15:vec3 = (x:3.93;y:10.82;z:-1.5);
  vec3_16:vec3 = (x:0;y:0;z:0);
  vec3_17:vec3 = (x:0.005;y:0;z:0);
  vec3_18:vec3 = (x:1;y:1;z:1);
  vec3_19:vec3 = (x:0.91;y:0.1;z:0.41);
  vec3_20:vec3 = (x:0;y:0;z:0);
  vec3_21:vec3 = (x:0;y:0;z:0);
  vec3_22:vec3 = (x:0.1;y:0.35;z:0.95);
  vec3_23:vec3 = (x:1;y:1;z:1);
  vec3_24:vec3 = (x:1;y:0.41;z:0.41);


var
  localTime, marchCount, PI:float


  constructor  Create;override;
  procedure  PrepareFrame;
  function  saturate(const a:vec3):vec3;
  function  saturate(const a:vec2):vec2;
  function  saturate( a:float):float;
  function  RotateX(const v:vec3; rad:float):vec3;
  function  RotateY(const v:vec3; rad:float):vec3;
  function  RotateZ(const v:vec3; rad:float):vec3;
  function  GetEnvColor2(const rayDir, sunDir:vec3):vec3;
  function  camPos = vec3:vec3;
  function  camLookat=vec3:vec3;
  function  smin( a, b, k :float):float;
  function  matMin(const a, b:vec2):vec2;
  function  diagN = normalize(vec3:vec3;
  function  sphereIter(const p:vec3; radius, subA:float):vec2;
  function  DistanceToObject(const p:vec3):vec2;
  function  SphereIntersect(const pos, dirVecPLZNormalizeMeFirst, spherePos:vec3; rad:float):float;
  function  mainImage(var fragCoord:vec2):TColor32;
end;

var
    Protophore:TShader
;

implementation

uses SysUtils, Math;

constructor TProtophore.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := mainImage;
end;


procedure TProtophore.PrepareFrame;
begin
end;


function TProtophore.saturate(const a:vec3):vec3;
begin
 Exit( clamp(a, 0, 1) );
end;


function TProtophore.saturate(const a:vec2):vec2;
begin
 Exit( clamp(a, 0, 1) );
end;


function TProtophore.saturate( a:float):float;
begin
 Exit( clamp(a, 0, 1) );
end;


function TProtophore.RotateX(const v:vec3; rad:float):vec3;
var
  cos, sin:float;
begin
  cos  := cos(rad);
  sin  := sin(rad);
  Exit( Vec3.Create(v.x,cos * v.y + sin * v.z,-sin * v.y + cos * v.z) );
end;


function TProtophore.RotateY(const v:vec3; rad:float):vec3;
var
  cos, sin:float;
begin
  cos  := cos(rad);
  sin  := sin(rad);
  Exit( Vec3.Create(cos * v.x - sin * v.z,v.y,sin * v.x + cos * v.z) );
end;


function TProtophore.RotateZ(const v:vec3; rad:float):vec3;
var
  cos, sin:float;
  tex:vec3;
begin
  cos  := cos(rad);
  sin  := sin(rad);
  Exit( Vec3.Create(cos * v.x + sin * v.y,-sin * v.x + cos * v.y,v.z) );
end;
{vec3 GetEnvColor(vec3 rayDir, vec3 sunDir)
begin
	tex  := textureCube(iChannel0, rayDir).xyz;
	tex  := tex * tex;
  	// gamma correct
    Exit( tex );
end;
}
// This is a procedural environment map with a giant overhead softbox,
// 4 lights in a horizontal circle, and a bottom-to-top fade.
end;


function TProtophore.GetEnvColor2(const rayDir, sunDir:vec3):vec3;
var
  final:vec3;
  roundBox:float;
  tex, texBack, texDark:vec3;
begin
    // fade bottom to top so it looks like the softbox is casting light on a floor
    // and it's bouncing back
    final  := vec3_2 * dot(-rayDir, sunDir) * 0.5 + 0.5;
    final  := final  * (0.125);
    // overhead softbox, stretched to a rectangle
    if (rayDir.y > abs(rayDir.x)*1)  and  (rayDir.y > abs(rayDir.z*0.25)) then
     final  := vec3_3*rayDir.y;
    // fade the softbox at the edges with a rounded rectangle.
    final  := final  + (vec3_5* pow(saturate(1 - roundBox*0.5), 6));
    // purple lights from side
    final  := final  + (vec3_6 * saturate(0.001/(1 - abs(rayDir.x))));
    // yellow lights from side
    final  := final  + (vec3_7 * saturate(0.001/(1 - abs(rayDir.z))));
    Exit( vec3(final) );
end;
{vec3 GetEnvColorReflection(vec3 rayDir, vec3 sunDir, float ambient)
begin
	tex  := textureCube(iChannel0, rayDir).xyz;
	tex  := tex * tex;
    texBack  := textureCube(iChannel0, rayDir).xyz;
    texDark  := pow(texBack, vec3_8).zzz;
  	// fake hdr texture
    texBack  := texBack  + (texDark*0.5 * ambient);
    Exit( texBack*texBack*texBack );
end;
}
end;


function TProtophore.camPos = vec3:vec3;
begin
end;


function TProtophore.camLookat=vec3:vec3;
begin
// polynomial smooth min (k := 0.1);
end;


function TProtophore.smin( a, b, k :float):float;
var
  h:float;
begin
    h  := clamp( 0.5+0.5*(b-a)/k, 0, 1 );
    Exit( mix( b, a, h ) - k*h*(1-h) );
end;


function TProtophore.matMin(const a, b:vec2):vec2;
var
  spinTime:float;
begin
	if a.x < b.x then
     Exit( a );
	else return b;
end;


function TProtophore.diagN = normalize(vec3:vec3;
var
  cut, inner, outness, finWidth, teeth, globalTeeth:float;
begin
cut  := 0.77;
inner  := 0.333;
outness  := 1.414;
end;


function TProtophore.sphereIter(const p:vec3; radius, subA:float):vec2;
var
  blender:float;
  final:vec2;
  i:int;
  d:float;
  corners:vec3;
  lenCorners, subtracter:float;
  ap:vec3;
  d:float;
begin
    finWidth  := 0.1;
    teeth  := globalTeeth;
    blender  := 0.25;
    for i  := 0 to  RECURSION_LEVELS-1 do
begin
{$ifdef SPLIT_ANIM}
        // rotate top and bottom of sphere opposite directions
        p  := RotateY(p, spinTime*sign(p.y)*0.05/blender);
{$endif }
        // main sphere
        d  := length(p) - radius*outness;
{$ifdef SPLIT_ANIM}
        // subtract out disc at the place where rotation happens so we don't have artifacts
        d  := max(d, -(max(length(p) - radius*outness + 0.1, abs(p.y) - finWidth*0.25)));
{$endif }
        // calc new position at 8 vertices of cube, scaled
        corners  := abs(p) + diagN * radius;
        lenCorners  := length(corners);
        // subtract out main sphere hole, mirrored on all axises
        subtracter  := lenCorners - radius * subA;
        // make mirrored fins that go through all vertices of the cube
        ap  := abs(-p) * 0.7071;
  	// 1/sqrt(2) to keep distance field normalized
        subtracter  := max(subtracter, -(abs(ap.x-ap.y) - finWidth));
        subtracter  := max(subtracter, -(abs(ap.y-ap.z) - finWidth));
        subtracter  := max(subtracter, -(abs(ap.z-ap.x) - finWidth));
        // subtract sphere from fins so they don't intersect the inner spheres.
        // also animate them so they are like teeth
        subtracter  := min(subtracter, lenCorners - radius * subA + teeth);
        // smoothly subtract out that whole complex shape
        d  := -smin(-d, subtracter, blender);
        //vec2 sphereDist := sphereB(abs(p) + diagN * radius, radius * inner, cut);
  	// recurse
        // do a material-min with the last iteration
        final  := matMin(final, Vec2.Create(d,i));
{$if ndef SPLIT_ANIM}
        corners  := RotateY(corners, spinTime*0.25/blender);
{$endif }
        // Simple rotate 90 degrees on X axis to keep things fresh
        p  := Vec3.Create(corners.x,corners.z,-corners.y);
        // Scale things for the next iteration / recursion-like-thing
        radius  := radius  * (inner);
        teeth  := teeth  * (inner);
        finWidth  := finWidth  * (inner);
        blender  := blender  * (inner);
end;
    // Bring in the final smallest-sized sphere
    d  := length(p) - radius*outness;
    final  := matMin(final, Vec2.Create(d,6));
    Exit( final );
end;


function TProtophore.DistanceToObject(const p:vec3):vec2;
var
  distMat:vec2;
begin
    distMat  := sphereIter(p, 5.2 / outness, cut);
    Exit( distMat );
end;
// dirVec MUST BE NORMALIZED FIRST not  not  not  not
end;


function TProtophore.SphereIntersect(const pos, dirVecPLZNormalizeMeFirst, spherePos:vec3; rad:float):float;
var
  radialVec:vec3;
  b, c, h:float;
begin
    radialVec  := pos - spherePos;
    b  := dot(radialVec, dirVecPLZNormalizeMeFirst);
    c  := dot(radialVec, radialVec) - rad * rad;
    h  := b * b - c;
    if h < 0 then
     Exit( -1 );
    Exit( -b - sqrt(h) );
end;


function TProtophore.mainImage(var fragCoord:vec2):TColor32;
var
  uv:vec2;
  zoom:float;
  camUp:vec3;
  mx, my:float;
  camVec, sideNorm, upNorm, worldFacing, worldPix, rayVec:vec3;
  rampStep, step31:float;
  distAndMat:vec2;
  t, maxDepth:float;
  pos:vec3;
  hit:float;
  i:int;
  sunDir, finalColor, smallVec, normal:vec3;
  ambientS, ambient:float;
  ref:vec3;
  sunShadow, iter:float;
  nudgePos:vec3;
  i:int;
  tempDist:float;
  texColor, lightColor, refColor:vec3;
begin
    localTime  := iGlobalTime - 0;
	// ---------------- First, set up the camera rays for ray marching ----------------
	uv  := fragCoord.xy/resolution.xy * 2 - 1;
    zoom  := 1.7;
    uv  := uv  / (zoom);
	// Camera up vector.
	camUp := vec3_10;
	// Camera lookat.
	camLookat := vec3_11;
    // debugging camera
    mx := iMouse.x/resolution.x*PI*2-0.7 + localTime*3.1415 * 0.0625*0.666;
	my := -iMouse.y/resolution.y*10 - sin(localTime * 0.31)*0.5;
  /{PI/2.01;
	camPos  := camPos  + (Vec3.Create(cos(my)*cos(mx),sin(my),cos(my)*sin(mx))*(12.2));
	// Camera setup.
	camVec := normalize(camLookat - camPos);
	sideNorm := normalize(cross(camUp, camVec));
	upNorm := cross(camVec, sideNorm);
	worldFacing := (camPos + camVec);
	worldPix  := worldFacing + uv.x * sideNorm * (resolution.x/resolution.y) + uv.y * upNorm;
	rayVec  := normalize(worldPix - camPos);
	// ----------------------------------- Animate ------------------------------------
    localTime  := iGlobalTime*0.5;
    // This is a wave function like a triangle wave, but with flat tops and bottoms.
    // period is 1.0
    rampStep  := min(3,max(1, abs((fract(localTime)-0.5)*1)*8))*0.5-0.5;
    rampStep  := smoothstep(0, 1, rampStep);
    // lopsided triangle wave - goes up for 3 time units, down for 1.
    step31  := (max(0, (fract(localTime+0.125)-0.25)) - min(0,(fract(localTime+0.125)-0.25))*3)*0.333;
    spinTime  := step31 + localTime;
    //globalTeeth := 0.0 + max(0.0, sin(localTime*3.0))*0.9;
    globalTeeth  := rampStep*0.99;
    cut  := max(0.48, min(0.77, localTime));
	// --------------------------------------------------------------------------------
	t  := 0;
	//float inc := 0.02;
	maxDepth  := 24;
	pos  := vec3_13;
    marchCount  := 0;
    // intersect with sphere first as optimization so we don't ray march more than is needed.
    hit  := SphereIntersect(camPos, rayVec, vec3_14, 5.6);
    if hit >= 0 then
begin
        t  := hit;
        // ray marching time
        for i  := 0 to 289 do // This is the count of the max times the ray actually marches.
begin
            pos  := camPos + rayVec * t;
            // *******************************************************
            // This is _the_ function that defines the "distance field".
            // It's really what makes the scene geometry.
            // *******************************************************
            distAndMat  := DistanceToObject(pos);
            // adjust by constant because deformations mess up distance function.
            t  := t  + (distAndMat.x * 0.7);
            //if (t > maxDepth) break;
            if (t > maxDepth)  or  (abs(distAndMat.x) < 0.0025) then
     break;
            marchCount := marchCount + (1);
end;
end;
    else
begin
        t  := maxDepth + 1;
        distAndMat.x  := 1000000;
end;
    // --------------------------------------------------------------------------------
	// Now that we have done our ray marching, let's put some color on this geometry.
	sunDir  := normalize(vec3_15);
	finalColor  := vec3_16;
	// If a ray actually hit the object, let's light it.
	//if (abs(distAndMat.x) < 0.75)
    if t <= maxDepth then
begin
        // calculate the normal from the distance field. The distance field is a volume, so if you
        // sample the current point and neighboring points, you can use the difference to get
        // the normal.
        smallVec  := vec3_17;
        vec3 normalU := vec3(distAndMat.x - DistanceToObject(pos - smallVec.xyy).x,
                           distAndMat.x - DistanceToObject(pos - smallVec.yxy).x,
                           distAndMat.x - DistanceToObject(pos - smallVec.yyx).x);
        normal  := normalize(normalU);
        // calculate 2 ambient occlusion values. One for global stuff and one
        // for local stuff
        ambientS  := 1;
        ambientS  := ambientS  * (saturate(DistanceToObject(pos + normal * 0.1).x*10));
        ambientS  := ambientS  * (saturate(DistanceToObject(pos + normal * 0.2).x*5));
        ambientS  := ambientS  * (saturate(DistanceToObject(pos + normal * 0.4).x*2.5));
        ambientS  := ambientS  * (saturate(DistanceToObject(pos + normal * 0.8).x*1.25));
        ambient  := ambientS * saturate(DistanceToObject(pos + normal * 1.6).x*1.25*0.5);
        ambient  := ambient  * (saturate(DistanceToObject(pos + normal * 3.2).x*1.25*0.25));
        ambient  := ambient  * (saturate(DistanceToObject(pos + normal * 6.4).x*1.25*0.125));
        ambient  := max(0.035, pow(ambient, 0.3));
  	// tone down ambient with a pow and min clamp it.
        ambient  := saturate(ambient);
        // calculate the reflection vector for highlights
        ref  := reflect(rayVec, normal);
        ref  := normalize(ref);
        // Trace a ray for the reflection
        sunShadow  := 1;
        iter  := 0.1;
        nudgePos  := pos + normal*0.02;
  	// don't start tracing too close or inside the object
		for i  := 0 to 39 do
begin
            tempDist  := DistanceToObject(nudgePos + ref * iter).x;
	        sunShadow  := sunShadow  * (saturate(tempDist*50));
            if tempDist <= 0 then
     break;
            //iter *= 1.5;
  	// constant is more reliable than distance-based
            iter  := iter  + (max(0.00, tempDist)*1);
            if iter > 4.2 then
     break;
end;
        sunShadow  := saturate(sunShadow);
        // ------ Calculate texture color ------
        texColor  := vec3_18;
  // vec3(0.65, 0.5, 0.4)*0.1;
        texColor  := Vec3.Create(0.85,0.945 - distAndMat.y * 0.15,0.93 + distAndMat.y * 0.35)*0.951;
        if distAndMat.y := 6 then
     texColor  := vec3_19*10.5;
        //texColor *= mix(vec3(0.3), vec3(1.0), tex3d(pos*0.5, normal).);
        texColor  := max(texColor, vec3_20);
        texColor  := texColor  * (0.25);
        // ------ Calculate lighting color ------
        // Start with sun color, standard lighting equation, and shadow
        lightColor  := vec3_21;
  // sunCol * saturate(dot(sunDir, normal)) * sunShadow*14.0;
        // sky color, hemisphere light equation approximation, ambient occlusion
        lightColor  := lightColor  + (vec3_22 * (normal.y * 0.5 + 0.5) * ambient * 0.2);
        // ground color - another hemisphere light
        lightColor  := lightColor  + (vec3_23 * ((-normal.y) * 0.5 + 0.5) * ambient * 0.2);
        // finally, apply the light to the texture.
        finalColor  := texColor * lightColor;
        //if (distAndMat.y := ceil(mod(localTime, 4.0))) finalColor += vec3(0.0, 0.41, 0.72)*0.925;
        // reflection environment map - this is most of the light
        refColor  := GetEnvColor2(ref, sunDir)*sunShadow;
        finalColor  := finalColor  + (refColor * 0.35 * ambient);
  // * sunCol * sunShadow * 9.0 * texColor.g;
        // fog
		finalColor  := mix(vec3_24 + Vec3.Create(1),finalColor,exp(-t*0.0007));
        // visualize length of gradient of distance field to check distance field correctness
        //finalColor := vec3(0.5) * (length(normalU) / smallVec.x);
end;
    else
begin
	    finalColor  := GetEnvColor2(rayVec, sunDir);
  // + vec3(0.1, 0.1, 0.1);
end;
    //finalColor += marchCount * vec3(1.0, 0.3, 0.91) * 0.001;
    // vignette?
    //finalColor *= vec3(1.0) * saturate(1.0 - length(uv/2.5));
    //finalColor *= 1.95;
	// output the final color with sqrt for "gamma correction"
	fragColor  := vec4.Create(sqrt(clamp(finalColor,0,1)),1);
end;




initialization
  Protophore := TProtophore.Create;
  Shaders.Add('Protophore', Protophore);

finalization
  FreeandNil(Protophore);

end.
