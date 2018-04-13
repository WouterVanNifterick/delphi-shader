unit WvN.DelphiShader.FX.PiersHakenRender;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

// (c) 2012 Piers Haken

type
Camera=record
  Position:vec3;
  Side:vec3;
  Up:vec3;
  View:vec3;
  Scale:vec2;
end;

Ray=record
  Position:vec3;
  Direction:vec3;
  constructor Create(
    aPosition:vec3;
    aDirection:vec3);
end;

Sphere=record
  Center:vec3;
  Radius:float;
end;


Plane=record
  Point:vec3;
  Normal:vec3;
end;

PointLight=record
  Position:vec3;
  DiffuseColor:vec3;
  DiffusePower:float;
  SpecularColor:vec3;
  SpecularPower:float;
  constructor Create(
    const aPosition:vec3;
    const aDiffuseColor:vec3;
    aDiffusePower:float;
    const aSpecularColor:vec3;
    aSpecularPower:float);
end;


Material=record
  DiffuseColor:vec3;
  SpecularColor:vec3;
  Shininess:float;
  constructor Create(
    const aDiffuseColor:vec3;
    const aSpecularColor:vec3;
    aShininess:float
  );
end;

Ball=record
  Sphere:Sphere;
  Material:Material;
  Velocity:vec3;
  constructor create(
    const aSphere:Sphere;
    const aMaterial:Material;
    const aVelocity:vec3
  );
end;

Bounce=record
  Normal:Ray;
  Material:Material;
end;

const
  INFINITY = 1/0;
  UP:vec3=(x:0;y:0;z:1);
  U3:vec3=(x:1;y:1;z:1);
  at    :vec3 = (x:0;y:0.0;z:1);///2.0;
  fov    = PI / 2.0;
  tanfov = 1.191753593; // tan(fov/1.8);

  vec3_1:vec3=(x:0;y:0;z:0);
  vec3_3:vec3=(x:1;y:1;z:1);
  vec3_4:vec3=(x:1;y:0.9;z:0.7);
  vec3_5:vec3=(x:0;y:0;z:1);
  vec3_6:vec3=(x:0;y:0;z:0);
  vec3_7:vec3=(x:1.17;y:1.9;z:3.03);
  vec3_8:vec3=(x:1;y:0;z:0);
  vec3_9:vec3=(x:1.23;y:1.8;z:1.79);
  vec3_10:vec3=(x:0;y:1;z:0);
  vec3_11:vec3=(x:1.35;y:1.7;z:2.73);
  vec3_12:vec3=(x:0;y:0;z:1);
  vec3_13:vec3=(x:1.41;y:1.6;z:2.53);
  vec3_14:vec3=(x:0;y:1;z:1);
  vec3_15:vec3=(x:1.50;y:1.5;z:2.23);
  vec3_16:vec3=(x:1;y:0;z:1);
  vec3_17:vec3=(x:1.69;y:1.4;z:1.93);
  vec3_18:vec3=(x:1;y:1;z:0);
  vec3_19:vec3=(x:1.39;y:1.19;z:1.93);
  vec3_20:vec3=(x:0;y:0;z:0);
  vec3_21:vec3=(x:1.73;y:1.01;z:1.93);
  vec3_22:vec3=(x:1;y:1;z:1);
  vec3_23:vec3=(x:0.5;y:1;z:0.5);
  vec3_24:vec3=(x:0.5;y:1;z:0.5);
  vec3_25:vec3=(x:1;y:0.5;z:0.5);
  vec3_26:vec3=(x:1;y:0.5;z:0.5);
  vec3_27:vec3=(x:-1*4;y:-0.86*4;z:2*4);
  vec3_28:vec3=(x:0.5;y:0.5;z:1);
  vec3_29:vec3=(x:0.5;y:0.5;z:1);
  vec3_30:vec3=(x:-1*4;y:0.86*4;z:2*4);
  vec3_31:vec3=(x:1*4;y:0*4;z:2*4);

  _matFloor : Material = (DiffuseColor:(x:1;y:0.9;z:0.7); SpecularColor: (x:1;y:1;z:1); Shininess: 130);
  _floor    : Plane    = (Point:(x:0;y:0;z:0); Normal: (x:0;y:0;z:1));
   s :Sphere= (Center:(x:0;y:0;z:0);radius:0.5); { Ray }

type
  TPiersHakenRender = class(TShader)
   const
    _cLights = 3;
    _cBalls  = 7;
   var
    _rgBalls: array[0.. _cBalls-1]of Ball;
    _rgLights: array[0.._cLights-1] of PointLight;

    eye :vec3;
    look :vec3;
    time2 :float;
    u :vec3;
    v :vec3;
    dx :vec3;
    dy :vec3;

    function Circle ( const time:float ):vec2;
    function IntersectSphere ( const aRay:Ray;const sphere:Sphere;out normal:Ray ):float;
    function IntersectPlane ( const aRay:Ray;const plane:Plane;out normal:Ray ):float;
    function Phong ( const light:PointLight;const material:Material;const normal:Ray;const eye:vec3 ):vec3;
    function Scene ( const aRay:Ray;out bounce:Bounce ):bool;
    function LightScene ( out aRay:Ray;out color:vec3 ):bool;
    function Main(var gl_FragCoord: Vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  PiersHakenRender: TShader;

implementation

uses SysUtils, Math;



constructor Ray.create;
begin
  self.Position := aPosition;
  self.Direction := aDirection;
end;


{ Ball }

constructor Ball.create(const aSphere: Sphere; const aMaterial: Material; const aVelocity: vec3);
begin
  Sphere   := aSphere;
  Material := aMaterial;
  Velocity := aVelocity;
end;

{ Material }

constructor Material.Create(const aDiffuseColor, aSpecularColor: vec3;  aShininess: float);
begin
  DiffuseColor  := aDiffuseColor  ;
  SpecularColor := aSpecularColor ;
  Shininess     := aShininess     ;
end;

{ PointLight }

constructor PointLight.Create(const aPosition, aDiffuseColor: vec3; aDiffusePower: float; const aSpecularColor: vec3; aSpecularPower: float);
begin
  Position     := aPosition       ;
  DiffuseColor := aDiffuseColor   ;
  DiffusePower := aDiffusePower   ;
  SpecularColor:= aSpecularColor  ;
  SpecularPower:= aSpecularPower  ;
end;


constructor TPiersHakenRender.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;


function TPiersHakenRender.Circle ( const time:float ):vec2;
begin
  result.x := system.cos(time);
  result.y := system.sin(time);
end;



function TPiersHakenRender.IntersectSphere ( const aRay:Ray;const sphere:Sphere;out normal:Ray ):float;
var
  L :vec3;
  Tca :float;
  d2 :float;
  p2 :float;
  t :float;
  intersect :vec3;
begin
	L  := sphere.Center - aRay.Position;
	Tca  := max (0.0, dot (L, aRay.Direction));
	if Tca < 0.0 then
		Exit( INFINITY );

	d2  := dot (L, L) - Tca * Tca;
	p2  := sphere.Radius * sphere.Radius - d2;
	if p2 < 0.0 then
		Exit( INFINITY );

	t  := Tca - system.sqrt(p2);
	intersect  := aRay.Position + t * aRay.Direction;
	normal.Position  := intersect;
  normal.Direction := (intersect - sphere.Center) / sphere.Radius;
	Exit( t );
end;


function TPiersHakenRender.IntersectPlane ( const aRay:Ray;const plane:Plane;out normal:Ray ):float;
var
  t :float;

begin
	t  := dot (plane.Point - aRay.Position, plane.Normal) / dot (aRay.Direction, plane.Normal);
	normal.Position := aRay.Position + t * aRay.Direction;
  normal.Direction :=  plane.Normal;
	Exit( t );
end;


function TPiersHakenRender.Phong ( const light:PointLight;const material:Material;const normal:Ray;const eye:vec3 ):vec3;
var
  viewDir :vec3;
  lightVec :vec3;
  lightDistance2 :float;
  lightDir :vec3;
  diffuse :float;
  R :vec3;
  specular :float;
  color:vec3;

begin
	viewDir  := normalize (normal.Position - eye);
	lightVec  := light.Position - normal.Position;
	lightDistance2  := dot (lightVec, lightVec);
	lightDir  := lightVec / system.sqrt(lightDistance2);
	diffuse  := dot(normal.Direction, lightDir);

	R  := lightDir - 2.0 * diffuse * normal.Direction;
	specular  := pow(math.max(0, dot(R, viewDir)), material.Shininess);

  color :=
    math.max(0, diffuse) * light.DiffuseColor * light.DiffusePower * material.DiffuseColor +
		math.max(0, specular) * light.SpecularColor * light.SpecularPower * material.SpecularColor;

	Exit( color * 110.0 / lightDistance2 );
end;


function TPiersHakenRender.Scene ( const aRay:Ray;out bounce:Bounce ):bool;
var
  tMatch :float;
  i :integer;
  t :float;
  normalPlane:Ray;
  normal:Ray;
  t2 :float;
  pt :vec3;

begin
	tMatch  := MaxDouble;

	for i  :=  0 to  _cBalls-1 do
	begin

		t  := max(0.0, IntersectSphere (aRay, _rgBalls[i].Sphere, normal));
		if (t > 0)  and  (tMatch > t) then
		begin
			tMatch  := t;
			bounce.Normal := normal;
      bounce.Material := _rgBalls[i].Material;
		end;
	end;



	t2  := IntersectPlane (aRay, _floor, normalPlane);
	if (t2 > 0)  and  (t2 < tMatch) then
	begin
		pt  := normalPlane.Position;
		if (length(pt) < 10.0)  and  ((fract(pt.x) < 0.9) = (fract(pt.y) < 0.9)) then
		begin
			tMatch  := t2;
			bounce.Normal :=normalPlane;
      bounce.Material := _matFloor;
		end;

	end;

	Result := ( tMatch < 1000)  and  (tMatch > 0 );
end;


function TPiersHakenRender.LightScene ( out aRay:Ray;out color:vec3 ):bool;
var
  lbounce:Bounce;
  bouncePos :vec3;
  bounceShadow:Bounce;
  iLight :integer; // loop variables  :Sphere;

begin
	if  not Scene (aRay, lbounce) then
		Exit( false );

	bouncePos  := lbounce.Normal.Position + lbounce.Normal.Direction * 0.0001;

	for iLight  :=  0 to  _cLights-1 do
	begin
		if  not Scene (Ray.Create(bouncePos, normalize (_rgLights[iLight].Position - bouncePos)), bounceShadow) then
			color  := color  + (Phong (_rgLights[iLight], lbounce.Material, lbounce.Normal, aRay.Position));
	end;

	aRay.Position :=bouncePos;
  aRay.Direction := reflect (aRay.Direction, lbounce.Normal.Direction);
	Exit( true );
end;


procedure TPiersHakenRender.PrepareFrame;
var i : integer;     q :float;
begin
	time2  := time / 10.0 + 100.0;

	eye := vec3.create(Circle(time / 10.0) * (7.1 - 4.5), 0.7 + 4.5);
  eye.z := 0.5 + (eye.z * mouse.y);
	look  := normalize (at - eye);

	u  := cross (look, UP);
	v  := cross (u, look);

	dx  := tanfov * u;
	dy  := tanfov * v;

  _rgBalls[0]  := Ball.create(s, Material.Create (vec3_8, U3, 100), vec3_7);
  _rgBalls[1]  := Ball.create(s, Material.Create (vec3_10, U3, 100), vec3_9);
  _rgBalls[2]  := Ball.create(s, Material.Create (vec3_12, U3, 100), vec3_11);

  _rgBalls[3]  := Ball.create(s, Material.Create (vec3_14, U3, 100), vec3_13);
  _rgBalls[4]  := Ball.create(s, Material.Create (vec3_16, U3, 100), vec3_15);
  _rgBalls[5]  := Ball.create(s, Material.Create (vec3_18, U3, 100), vec3_17);

  _rgBalls[6]  := Ball.create(s, Material.Create (vec3_20, U3, 100), vec3_19);
//  _rgBalls[7]  := Ball.create(s, Material.Create (vec3_22, U3, 100.0), vec3_21);


	for i  :=  0 to  _cBalls -1 do
	begin
		q  := fract(time2 * _rgBalls[i].Velocity.z / 3.0) - 0.5;

		_rgBalls[i].Sphere.Center := vec3.create (
			abs(&mod(time2 * _rgBalls[i].Velocity.xy, 8.0) - 4.0) - 2.0,
			_rgBalls[i].Sphere.Radius + 8.0 * (0.25-q*q));
	end;

	_rgLights[0]  := PointLight.Create(vec3_31, vec3_24, 0.3, vec3_23,1);
	_rgLights[1]  := PointLight.Create(vec3_27, vec3_26, 0.3, vec3_25,1);
	_rgLights[2]  := PointLight.Create(vec3_30, vec3_29, 0.3, vec3_28,1);
end;



function TPiersHakenRender.main;
var
  position :vec2;
  lray :Ray;
  color :vec3;
begin
	position  := (gl_FragCoord.xy - resolution/2.0) / Math.min(resolution.x, resolution.y);
	lray.Position :=eye;
  lray.Direction := normalize (look + dx * position.x + dy * position.y);

	color  := vec3Black;
//  if LightScene (lray, color) then
//    if LightScene (lray, color) then
       LightScene (lray, color);

//  color := color / 256*256*256*256;

  if color.r > 1 then color.r := 1;
  if color.g > 1 then color.g := 1;
  if color.b > 1 then color.b := 1;
  if color.r < 0 then color.r := 0;
  if color.g < 0 then color.g := 0;
  if color.b < 0 then color.b := 0;

 	Result := TColor32(color);
end;

initialization

PiersHakenRender := TPiersHakenRender.Create;
Shaders.Add('PiersHakenRender', PiersHakenRender);

finalization

FreeandNil(PiersHakenRender);

end.
