unit WvN.DelphiShader.FX.MetaTorus;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TMetaTorus = class(TShader)
  const
  eps=0.001;
  modder=0.1;
  vec2_1:vec2=(x:3;y:1);
  vec3_4:vec3=(x:0;y:1;z:0);
  vec3_5:vec3=(x:0;y:0;z:0);
  vec2_7:vec2=(x:0.1;y:0.0);
  vec3_8:vec3=(x:1.0;y:0.1;z:0.4);
  vec4_9:vec4=(x:0;y:0;z:0.0;w:1);
  MAX_DEPTH = 20.0;
  eps100:vec3 = (x: eps; y: 0; z: 0);
  eps010:vec3 = (x: 0; y: eps; z: 0);
  eps001:vec3 = (x: 0; y: 0; z: eps);


  var
  C,  U,  E,  A,  B,  M,  viewDir:vec3;
  time_modder,

  cos1x :float;
  sin1x :float;
  cos2x :float;
  sin2x :float;
  cos3x :float;
  sin3x :float;
  cos4x :float;
  sin4x :float;

  bv1,bv2,bv3:vec3;

  function torus( const p2:vec3;offset:Float):float;
  function inObj( const p:vec3 ):vec2;
  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;


var
  MetaTorus: TShader;

implementation

uses SysUtils, Math;

constructor TMetaTorus.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TMetaTorus.PrepareFrame;
begin
  //Camera animation
  U := vec3_4;
  viewDir := vec3_5;
  E := Vec3.Create(-sinLarge(time*0.2)*8.0,4,
                    cosLarge(time*0.2)*8.0); //Camera location;

  //Camera setup
  C := normalize(viewDir-E);
  A := cross(C, U);
  B := cross(A, C);
  M := (E+C);

    cos1x  := CosLarge(time*modder*5.0);
    sin1x  := SinLarge(time*modder*5.0);
    cos2x  := CosLarge(time*modder*4.0);
    sin2x  := SinLarge(time*modder*4.0);
    cos3x  := CosLarge(time*modder*5.5);
    sin3x  := SinLarge(time*modder*5.5);
    cos4x  := CosLarge(time*modder*4.5);
    sin4x  := SinLarge(time*modder*4.5);


  bv1 := Vec3.Create(CosLarge(time*modder*0.37)*3.33,
                     SinLarge(time*modder*0.69)*0.33,
                     CosLarge(time*modder*0.79)*0.33);

  bv2 := Vec3.Create(
                     SinLarge(time*modder*0.57)*3.33,
                     CosLarge(time*modder*0.74)*0.33,
                     CosLarge(time*modder*0.64)*0.33);
  bv3 := Vec3.Create(
                     SinLarge(time*modder*0.47)*3.33,
                     CosLarge(time*modder*0.94)*0.33,
                     CosLarge(time*modder*0.84)*0.33);

  time_modder := time * modder;
end;

// Fixed shadows and ambient occlusion bugs, and sped some shit up.
// Still needs some work
// Voltage / Defame (I just fixed some bugs, someone else did they main work on this)
// rotwang: @mod* tinted shadow
// modded by @dennishjorth. A few opts, just with the blue color, metafied blobby toruses are pretty neat.
// xpansive: removed some useless code (in the marching loop not )


//Simple raymarching sandbox with camera

//Raymarching Distance Fields
//About http://www.iquilezles.org/www/articles/raymarchingdf/raymarchingdf.htm
//Also known as Sphere Tracing
//Original seen here: http://twitter.com/# not /paulofalcao/statuses/134807547860353024

//Scene Start

//Torus
function TMetaTorus.torus( const p2:vec3;offset:Float):float;
var q,r :vec2;  p:Vec3;
begin
	p.x := (SinLarge(offset+time_modder*0.14+0.5
         +SinLarge(p2.y*p2.y*0.3 + p2.z*p2.z*0.3 +2.0+time_modder*0.14))*0.4+1.0)*p2.x;
	p.y := (SinLarge(offset+time_modder*0.15+1.0
         +SinLarge(p2.x*p2.x*0.3 + p2.z*p2.z*0.3 +1.5+time_modder*0.15))*0.4+1.0)*p2.y;
	p.z := (SinLarge(offset+time_modder*0.13+1.5
         +SinLarge(p2.x*p2.x*0.3 + p2.y*p2.y*0.3 +0.5+time_modder*0.12))*0.4+1.0)*p2.z;

  r.x := p.x;
  r.y := p.z;
	q.x  := r.Length - vec2_1.x;
  q.y  := p.y;
	Result := q.Length - vec2_1.y;
end;


//Objects union
function TMetaTorus.inObj( const p:vec3 ):vec2;
var
  p3 :vec3;
  p4 :vec3;
  p5 :vec3;
  p6 :vec3;
  b1 :float;
  b2 :float;
  b6 :float;
  b :float;
begin
  p3.x := p.x*cos1x+p.z*sin1x;
  p3.y := p.y;
  p3.z := p.x*sin1x-p.z*cos1x;

  p4.x := p.x*cos3x+p.z*sin3x;
  p4.y := p.y;
  p4.z := p.x*sin3x-p.z*cos3x;

  p5.x := p4.x;
  p5.y := p4.y*cos4x+p4.z*sin4x;
  p5.z := p4.y*sin4x-p4.z*cos4x;

  p6.x := p3.x;
  p6.y := p3.y*cos2x+p3.z*sin2x;
  p6.z := p3.y*sin2x-p3.z*cos2x;

  b1  := torus(p5+bv1, 0.5);
  b2  := torus(p3+bv2, 1.0);
  b6  := torus(p6+bv3, 1.5);

  b  := 1/(b1+1.1)+
        1/(b2+1.1)+
        1/(b6+1.1);
  Result.x := 1/b-0.7;
  Result.y := 1;

end;


//Scene End

function TMetaTorus.Main(var gl_FragCoord: Vec2): TColor32;
var
  vPos:vec2;
  scrCoord:vec3;
  scp:vec3;
  s:vec2;
  c_,p,n:vec3;
  f:float;
  i:integer; // loop variable
  b_:float;
  ep:vec3;
begin

  vPos := 2*gl_FragCoord.xy/resolution.xy - 1;
  scrCoord := M + vPos.x*A*resolution.x/resolution.y + vPos.y*B;
  scp := scrCoord-E;
  scp.NormalizeSelf;

   //Raymarching
   s := vec2_7;

  f := 1.0;
  for i := 0 to 191 do
  begin
    if (System.abs(s.x)<0.01) or (f>MAX_DEPTH) then
      break;
    f := f + s.x;
    // p := E+scp*f;
    p.x := E.x+scp.x*f;
    p.y := E.y+scp.y*f;
    p.z := E.z+scp.z*f;

    s := inObj(p);
  end;

  n.x := s.x-inObj(p-eps100).x;
  n.y := s.x-inObj(p-eps010).x;
  n.z := s.x-inObj(p-eps001).x;
  n.NormalizeSelf;

  if f<MAX_DEPTH then
  begin
    c_ := vec3_8;
	  c_.x  := c_.x * SinLarge(f+CosLarge(f+time*1.2)+time*1.1)*0.4;
	  c_.y  := 0.1;
	  c_.z  := c_.z  + CosLarge(f+SinLarge(f+time*2.1)+time*3.3)*0.2;
	  c_.x  := c_.x  + 0.2;
	  c_.z  := c_.z  + 0.4;
    // ep := E-p;
    ep.x := E.x-p.x;
    ep.y := E.y-p.y;
    ep.z := E.z-p.z;
    ep.NormalizeSelf;
    b_ := max(n.Dot(ep),0.1);
    Result:=TColor32((b_*c_+power(b_,100))*(1-f*0.001));//simple phong LightPosition=CameraPosition
  end
  else
    Result:=clBlack32; //background color
end;


initialization

MetaTorus := TMetaTorus.Create;
Shaders.Add('MetaTorus', MetaTorus);

finalization

FreeandNil(MetaTorus);

end.

