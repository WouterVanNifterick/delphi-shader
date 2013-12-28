unit WvN.DelphiShader.FX.MetaTorus;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TMetaTorus = class(TShader)
  C,  U,  E,  A,  B,  M,  viewDir:vec3;
  function torus( const p2:vec3;const t:vec2; offset, modder:float ):float;
  function inObj( const p:vec3 ):vec2;
  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

const
  vec2_1:vec2=(x:3.0;y:1.0);
  vec2_2:vec2=(x:3.0;y:1.0);
  vec2_3:vec2=(x:3.0;y:1.0);
  vec3_4:vec3=(x:0;y:1;z:0);
  vec3_5:vec3=(x:0;y:0;z:0);
  vec3_6:vec3=(x:0.001;y:0;z:0);
  vec2_7:vec2=(x:0.1;y:0.0);
  vec3_8:vec3=(x:1.0;y:0.1;z:0.4);
  vec4_9:vec4=(x:0;y:0;z:0.0;w:1);

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
  E := Vec3.Create(-system.sin(time*0.2)*8.0,4,system.cos(time*0.2)*8.0); //Camera location;

  //Camera setup
  C := normalize(viewDir-E);
  A := cross(C, U);
  B := cross(A, C);
  M := (E+C);
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
function TMetaTorus.torus( const p2:vec3;const t:vec2; offset, modder:float ):float;
var q :vec2;  p:Vec3;
begin
	p := Vec3.Create(
		(system.sin(offset+time*modder*0.14+0.5+system.sin(p2.y*p2.y*0.3+p2.z*p2.z*0.3+2.0+time*modder*0.14))*0.4+1.0)*p2.x,
		(system.sin(offset+time*modder*0.15+1.0+system.sin(p2.x*p2.x*0.3+p2.z*p2.z*0.3+1.5+time*modder*0.15))*0.4+1.0)*p2.y,
		(system.sin(offset+time*modder*0.13+1.5+system.sin(p2.x*p2.x*0.3+p2.y*p2.y*0.3+0.5+time*modder*0.12))*0.4+1.0)*p2.z
		);
	q  := Vec2.Create(length(Vec2.Create(p.x,p.z))-t.x,p.y);
	Exit( length(q) - t.y );
end;


//Objects union
function TMetaTorus.inObj( const p:vec3 ):vec2;
var
  modder  :float;
  cos1x :float;
  sin1x :float;
  cos2x :float;
  sin2x :float;
  cos3x :float;
  sin3x :float;
  cos4x :float;
  sin4x :float;
  p3 :vec3;
  p4 :vec3;
  p5 :vec3;
  p6 :vec3;
  b1 :float;
  b2 :float;
  b6 :float;
  e  :float;
  b :float;
  dist :vec2;

begin
 modder   := 0.1;
    cos1x  := system.cos(time*modder*5.0);
    sin1x  := system.sin(time*modder*5.0);
    cos2x  := system.cos(time*modder*4.0);
    sin2x  := system.sin(time*modder*4.0);
    cos3x  := system.cos(time*modder*5.5);
    sin3x  := system.sin(time*modder*5.5);
    cos4x  := system.cos(time*modder*4.5);
    sin4x  := system.sin(time*modder*4.5);

    p3  := Vec3.Create(p.x*cos1x+p.z*sin1x,
	    p.y,
	    p.x*sin1x-p.z*cos1x);

    p4  := Vec3.Create(p.x*cos3x+p.z*sin3x,
	    p.y,
	    p.x*sin3x-p.z*cos3x);

   p5  := Vec3.Create(p4.x,
	    p4.y*cos4x+p4.z*sin4x,
	    p4.y*sin4x-p4.z*cos4x);

   p6  := Vec3.Create(p3.x,
	    p3.y*cos2x+p3.z*sin2x,
	    p3.y*sin2x-p3.z*cos2x);

    b1  := torus(p5+Vec3.Create(system.cos(time*modder*0.37)*3.33,system.sin(time*modder*0.69)*0.33,system.cos(time*modder*0.79)*0.33),vec2_1,0.5,modder);
    b2  := torus(p3+Vec3.Create(system.sin(time*modder*0.57)*3.33,system.cos(time*modder*0.74)*0.33,system.cos(time*modder*0.64)*0.33),vec2_2,1.0,modder);
    b6  := torus(p6+Vec3.Create(system.sin(time*modder*0.47)*3.33,system.cos(time*modder*0.94)*0.33,system.cos(time*modder*0.84)*0.33),vec2_3,1.5,modder);
   e   := 0.1;
    b  := 1.0/(b1+1.0+e)+1.0/(b2+1.0+e)+1.0/(b6+1.0+e);
    dist  := Vec2.Create(1.0/b-0.7,1);
    Exit( dist );
end;


//Scene End

function TMetaTorus.Main(var gl_FragCoord: Vec2): TColor32;
var
  vPos:vec2;
  scrCoord:vec3;
  scp:vec3;
  e_ :vec3;
  MAX_DEPTH:float;
  s:vec2;
  c_,p,n:vec3;
  f:float;
  i:integer; // loop variable
  b_:float;

begin

  vPos := 2.0*gl_FragCoord.xy/resolution.xy - 1.0;
  scrCoord := M + vPos.x*A*resolution.x/resolution.y + vPos.y*B;
  scp := normalize(scrCoord-E);

   //Raymarching
   e_  := vec3_6;
   MAX_DEPTH := 20.0;

   s := vec2_7;


  f := 1.0;
  for i := 0 to 191 do
  begin
    if (abs(s.x)<0.01) or (f>MAX_DEPTH) then
      break;
    f := f + (s.x);
    p := E+scp*f;
    s := inObj(p);
  end;

  n := normalize(
      Vec3.Create(
           s.x-inObj(p-e_.xyy).x,
           s.x-inObj(p-e_.yxy).x,
           s.x-inObj(p-e_.yyx).x));

  if f<MAX_DEPTH then
  begin
    c_ := vec3_8;
	  c_.x  := c_.x*system.sin(f+system.cos(f+time*1.2)+time*1.1)*0.4;
	  c_.y  := 0.1;
	  c_.z  := c_.z  + (system.cos(f+system.sin(f+time*2.1)+time*3.3)*0.2);
	  c_.x  := c_.x  + (0.2);
	  c_.z  := c_.z  + (0.4);
    b_ := max(dot(n,normalize(E-p)),0.1);
    Result:=TColor32(vec3((b_*c_+pow(b_,100.0))*(1.0-f*0.001)));//simple phong LightPosition=CameraPosition
  end
    else Result:=clBlack32; //background color
end;


initialization

MetaTorus := TMetaTorus.Create;
Shaders.Add('MetaTorus', MetaTorus);

finalization

FreeandNil(MetaTorus);

end.

