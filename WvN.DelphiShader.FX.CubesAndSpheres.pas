unit WvN.DelphiShader.FX.CubesAndSpheres;

interface

// Cubes and Spheres
//
// by @paulofalcao
//

uses GR32, Types, WvN.DelphiShader.Shader;

const vec3_1:Vec3=(x:0.6;y:0.6;z:0.6);
const vec3_2:Vec3=(x:1.0;y:0.5;z:0.2);
const vec3_3:Vec3=(x:0.1);
const vec3_4:Vec3=(x:0;y:1;z:0);
const vec3_5:Vec3=(x:5;y:0;z:5);
const vec3_7:Vec3=(x:0.1;y:0.1;z:0.1);
const vec3_8:Vec3=(x:0.2;y:0.5;z:1.0);

type
  TCubesAndSpheres = class(TShader)
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  CubesAndSpheres: TShader;
  Ratio:double;

implementation

uses SysUtils, Math;

constructor TCubesAndSpheres.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TCubesAndSpheres.PrepareFrame;
begin
end;


//Util Start

function ObjUnion( const obj0:vec2;const obj1:vec2 ):vec2;
begin
  if obj0.x<obj1.x then
    Exit( obj0 )
  else
    Exit( obj1 );
end;


function sim2d( const p:vec2;const s:float ):vec2;
var ret:vec2;
begin
   ret := p;
   ret := p+s/2.0;
   ret := fract(ret/s)*s-s/2.0;
   Exit( ret );
end;


function stepspace( const p:vec3;const s:float ):vec3;
begin
  Exit( p-&mod(p-s/2.0,s) );
end;


function phong( const pt:vec3;const prp:vec3;const normal:vec3;const light:vec3;const color:vec3;const spec:float;const ambLight:vec3 ):vec3;
var lightv:vec3; diffuse:float; refl:vec3; viewv:vec3; specular:float;
begin
   lightv := normalize(light-pt);
   diffuse := dot(normal,lightv);
   refl := -reflect(lightv,normal);
   viewv := normalize(prp-pt);
   specular := pow(max(dot(refl,viewv),0.0),spec);
   Exit( (max(diffuse,0.0)+ambLight)*color+specular );
end;


//Util End

//Scene Start

function obj( p:vec3 ):vec2;
var fp:vec3; d:float; c1:float; c2:float; cf:float;
begin
  fp := stepspace(p,2.0);;
  d := System.sin(fp.x*0.3+time*4.0)+System.cos(fp.z*0.3+time*2.0);
  p.y := p.y+d;
  p.xz := sim2d(p.xz,2.0);
  c1 := length(max(abs(p)-vec3_1,0.0))-0.35;
  c2 := length(p)-1.0;
  cf := system.sin(time)*0.5+0.5;
  Exit( Vec2.Create(mix(c1,c2,cf),1.0) );
end;


function obj_c( const p:vec3 ):vec3;
var fp:vec2;
begin
  fp := sim2d(p.xz-1.0,4.0);
  if fp.y>0.0 then
    fp.x := -fp.x;

  if fp.x>0.0 then
    Result := vec3_8
  else
    Result := vec3_2;
end;


//Scene End

function raymarching( const prp:vec3;const scp:vec3;const maxite:int;const precis:float;const startf:float;const maxd:float;out objid:float ):float;
var e :vec3; s:vec2; p:vec3; f:float; i:integer;
begin
  e := vec3_3;
  s := Vec2.Create(startf,0.0);

  f := startf;
  for i := 0 to 256-1 do
  begin
    if (abs(s.x)<precis) or (f>maxd) or (i>maxite) then
      break;
    f := f + (s.x);
    p := prp+scp*f;
    s := obj(p);
    objid := s.y;
  end;

  if f>maxd then  objid := -1.0;
  Exit( f );
end;



function normal( const p:vec3 ):vec3;
var n_er :float; v1:float; v2:float; v3:float; v4:float;
begin
  //tetrahedron normal
 n_er  := 0.01;
  v1 := obj(Vec3.Create(p.x+n_er,p.y-n_er,p.z-n_er)).x;
  v2 := obj(Vec3.Create(p.x-n_er,p.y-n_er,p.z+n_er)).x;
  v3 := obj(Vec3.Create(p.x-n_er,p.y+n_er,p.z-n_er)).x;
  v4 := obj(Vec3.Create(p.x+n_er,p.y+n_er,p.z+n_er)).x;
  Exit( normalize(Vec3.Create(v4+v1-v3-v2,v3+v4-v1-v2,v2+v4-v3-v1)) );
end;


function render( const prp,scp:vec3;maxite:int;precis,startf,maxd:float;const background,light:vec3;spec:float;const ambLight:vec3;out n:vec3;out p:vec3;out f:float;out objid:float ):vec3;
var c,cf:vec3;
begin
  objid := -1.0;
  f := raymarching(prp,scp,maxite,precis,startf,maxd,objid);
  if objid>-0.5 then begin
    p := prp+scp*f;
    c := obj_c(p);
    n := normal(p);
    cf := phong(p,prp,n,light,c,spec,ambLight);
    Exit( vec3(cf) );
  end;

  f := maxd;
  Exit( vec3(background) ); //background color
end;


function TCubesAndSpheres.RenderPixel(var gl_FragCoord: Vec2): TColor32;
      function camera( const prp:vec3;const vrp:vec3;const vuv:vec3;const vpd:float ):vec3;
      var vPos:vec2; vpn:vec3; u:vec3; v:vec3; scrCoord:vec3;
      begin
        vPos := -1.0+2.0*gl_FragCoord.xy/resolution.xy;
        vpn := normalize(vrp-prp);
        u := normalize(cross(vuv,vpn));
        v := cross(vpn,u);
        scrCoord := prp+vpn*vpd+vPos.x*u*resolution.x/resolution.y+vPos.y*v;
        Exit( normalize(scrCoord-prp) );
      end;

var vuv,vrp,prp,scp,light,n,p:vec3; mx,my,vpd,o,maxe,startf,spec,f :float; backc,ambi,c1,c2:vec3;
begin

  //Camera animation
  vuv := vec3_4;
  vrp := Vec3.Create(time*4.0,0.0,0.0);
  mx := mouse.x*PI*2.0;
  my := mouse.y*PI/2.01;
  prp := vrp+
         Vec3.Create(
           system.cos(my)*system.cos(mx),
           system.sin(my),
           system.cos(my)*system.sin(mx))*12.0;
  vpd := 1.5;
  light := prp+vec3_5;

  scp := camera(prp,vrp,vuv,vpd);


 maxe  := 0.01;
 startf  := 0.1;
 backc  := vecBlack;
 spec  := 8.0;
 ambi  := vec3_7;

  c1 := render(prp,scp,256,maxe,startf,60,backc,light,spec,ambi,n,p,f,o);
  c1 := c1*max(1.0-f*0.015,0.0);
  c2 := backc;
  if o>0.5 then begin
    scp := reflect(scp,n);
    c2 := render(p+scp*0.05,scp,32,maxe,startf,10.0,backc,light,spec,ambi,n,p,f,o);
  end;

  c2 := c2*max(1.0-f*0.1,0.0);
  Result := TColor32((c1.xyz*0.75+c2.xyz*0.25));

end;


initialization

CubesAndSpheres := TCubesAndSpheres.Create;
Shaders.Add('CubesAndSpheres', CubesAndSpheres);

finalization

FreeandNil(CubesAndSpheres);

end.

