unit WvN.DelphiShader.FX.RayMarching1;

interface

uses GR32, Types, WvN.DelphiShader.Shader, Vcl.Imaging.GIFImg;

type
  TRayMarching1=class(TShader)
    mx, my,
    c1, s1,
    c2, s2,
    c3, s3  :TVecType;
    rotmat:TMatrix3d;


    constructor Create;override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;

    function Dist(v:Vec3):Float;

  end;

var
  RayMarching1:TShader;

implementation

uses SysUtils, Math;


const
  n=10;
  PI2=pi*2;

constructor TRayMarching1.Create;
begin
  inherited;
  FrameProc := prepareFrame;
  PixelProc := RenderPixel;
end;

procedure TRayMarching1.PrepareFrame;
var m1,m2,m3:TMatrix3d;
begin
  mx := system.sin(1.32 + time * 0.00037312) * 1.45 + 0.5;
  my := system.cos(1.01 + time * 0.00023312) * 1.45 + 0.5;

  c1 := system.cos(my * PI2);
  s1 := system.sin(my * PI2);
  c2 := system.cos(mx * PI2);
  s2 := system.sin(mx * PI2);
  c3 := system.cos(imouse.x * PI2);
  s3 := system.sin(imouse.x * PI2);

  m1.m11 := c1 ;  m1.m12 := -s1;  m1.m13 := 0;  m1.m14 := 0;
  m1.m21 := s1 ;  m1.m22 :=  c1;  m1.m23 := 0;  m1.m24 := 0;
  m1.m31 := 0  ;  m1.m32 :=   0;  m1.m33 := 1;  m1.m34 := 0;
  m1.m41 := 0  ;  m1.m42 :=   0;  m1.m43 := 0;  m1.m34 := 0;


  m2.m11 := 1  ;  m2.m12 :=   0;  m2.m13 := 0;  m2.m14 := 0;
  m2.m21 := 0  ;  m2.m22 :=  c2;  m2.m23 :=-s2; m2.m24 := 0;
  m2.m31 := 0  ;  m2.m32 :=  s2;  m2.m33 :=c2;  m2.m34 := 0;
  m2.m41 := 0  ;  m2.m42 :=   0;  m2.m43 := 0;  m2.m34 := 0;

  m3.m11 := c3 ;  m3.m12 :=   0;  m3.m13 := -s3;m3.m14 := 0;
  m3.m21 := 0  ;  m3.m22 :=   1;  m3.m23 := 0;  m3.m24 := 0;
  m3.m31 := s3 ;  m3.m32 :=   0;  m3.m33 := c3; m3.m34 := 0;
  m3.m41 := 0  ;  m3.m42 :=   0;  m3.m43 := 0;  m3.m34 := 0;

  RotMat := m1*m2*m3;
end;

function tri( x:TVectype ):TVectype;overload;
begin
  if IsNan(x) then exit(0);
  if IsInfinite(x) then exit(0);  
  if x < -1000 then Exit (0);
  if x>1000000 then exit(0);

 	Result := abs(fract(x)-0.5)-0.25;
end;

function tri( const p:Vec3 ):Vec3;overload;
begin
	Result.x := tri(p.x);
  Result.x := tri(p.y);
  Result.x := tri(p.z);
end;

function TRayMarching1.Dist(v:Vec3):Float;
var f,mul,zoomed:Float;vsum:Vec3;i:Integer;
begin
	vsum := vec3(0.0);
	zoomed := 1.0;

  for i:=0 to N-1 do
  begin
		f := i / N;
		mul :=  1.0 + 0.1/(f*f+0.45);
		v := v * mul;
		zoomed := zoomed * mul;
    v := v + ((imouse.y - 0.5)*1.0);
//		v := v * rotmat;

    v.x := v.x * rotmat.M[0].V[0] + v.x * rotmat.M[0].V[1] + v.x * rotmat.M[0].V[2];
    v.y := v.y * rotmat.M[1].V[0] + v.y * rotmat.M[1].V[1] + v.y * rotmat.M[1].V[2];
    v.z := v.z * rotmat.M[2].V[0] + v.z * rotmat.M[2].V[1] + v.z * rotmat.M[2].V[2];

		v := tri( v ); // fold // -0.25 <= tri() <= +0.25
  end;
	Result := (v.x+0.1) / zoomed;

end;

function TRayMarching1.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  dir,pos:Vec3;c,t,d:Float;i:integer;
const M=60;
begin
	dir := normalize(vec3.create( (gl_FragCoord.xy - resolution/2.0) / Math.min(resolution.y,resolution.x) * 2.0, 1.0));
	pos := vec3(0.0);
	t := 0.0;

  for i := 0 to M-1 do
  begin
		d := dist( pos + dir*t );
		if ( i = 0) and (d < 0.0 ) then
			dir := -dir;

		if ( abs(d) < 0.0001 ) and (not IsZero(d)) and (not IsZero(t)) then
    begin
			c := (M-i) / M;
			Exit( TColor32(vec3.create( c*c*1.2, c*1.0, c*c*0.5+abs(0.2/t) )) );
    end;
		t := t + (d * 1.00);
  end;

	Result := TColor32(vec3.create( 0.0, 0.0, abs(0.2/t) ) );

end;


initialization
  RayMarching1 := TRayMarching1.Create;
  Shaders.Add('RayMarching1',RayMarching1);
finalization
  FreeandNil(RayMarching1);
end.
