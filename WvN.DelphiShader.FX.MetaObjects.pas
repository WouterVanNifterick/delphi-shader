unit WvN.DelphiShader.FX.MetaObjects;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TMetaObjects = class(TShader)
  M,A,B,E:vec3;
  ratio:double;
  st07,st77,st,ct:double;

  t1,sp1,sp2,sp3,sp4:vec3;


  const  MAX_DEPTH = 20;
  function ObjUnion( const obj_floor:vec2;const obj_roundBox:vec2 ):vec2;
  function torus( const p:vec3;const t:vec2 ):float;inline;
  function sphere( p:vec3;radius:float ):float;inline;
  function obj_floor( const p:vec3 ):vec2;inline;
  function obj_floor_c( const p:vec3 ):vec3;inline;
  function obj_roundBox( const p:vec3 ):vec2;inline;
  function obj_sphere( const p:vec3 ):vec2;inline;
  function obj_roundBox_c( const p:vec3 ):vec3;inline;
  function inObj( const p:vec3 ):vec2;inline;
  function ao( const p,n:vec3; d:float ):float;
  function shadow( const ro:vec3;const rd:vec3 ):float;
  function softshadow( const ro,rd:vec3; k :float ):float;
  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

const
  vec3_1:vec3=(x:0;y:0;z:0);
  vec3_2:vec3=(x:1;y:1;z:1);
  vec3_3:vec3=(x:1;y:1;z:1);
  vec3_4:vec3=(x:0;y:0;z:0);
  vec3_5:vec3=(x:1;y:1;z:1);
  RoundBoxCol:vec3=(x:0.1;y:0.1;z:1.0);
  vec2_7:vec2=(x:2.0;y:1.0);
  vec3_8:vec3=(x:0;y:1;z:0);
  vec3_9:vec3=(x:0;y:0;z:0);
  vec3_10:vec3=(x:0.1;y:0;z:0);
  vec2_11:vec2=(x:0.1;y:0.0);
  vec2_12:vec2=(x:0.1;y:0.0);
  vec2_13:vec2=(x:0.1;y:0.0);

  vx:vec3=(x:0.1;y:0.0;z:0.0);
  vy:vec3=(x:0.0;y:0.1;z:0.0);
  vz:vec3=(x:0.0;y:0.0;z:0.1);


var
MetaObjects: TShader;

implementation

uses SysUtils, Math;

constructor TMetaObjects.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

// Playing around with metaobjects.

// Edit: trying to do some water like object, reflections still need fixing...


//Simple raymarching sandbox with camera

//Raymarching Distance Fields
//About http://www.iquilezles.org/www/articles/raymarchingdf/raymarchingdf.htm
//Also known as Sphere Tracing
//Original seen here: http://twitter.com/# not /paulofalcao/statuses/134807547860353024

//Util Start
function TMetaObjects.ObjUnion( const obj_floor:vec2;const obj_roundBox:vec2 ):vec2;
begin
  if obj_floor.x<obj_roundBox.x then
  	Result := obj_floor
  else
  	Result := obj_roundBox;
end;

//Util End

//Scene Start

//Torus
function TMetaObjects.torus( const p:vec3;const t:vec2 ):float;
var
  q :vec2;
begin
	q.x := length(p.xz)-t.x;
  q.y := p.y;
	Result := length(q) - t.y;
end;


//Sphere
function TMetaObjects.sphere( p:vec3;radius:float ):float;
var
  length :float;
begin
	p.y  := p.y  - 1;
	length  := system.sqrt(p.x*p.x + p.y*p.y + p.z*p.z);
	Result := length-radius;
end;


//Floor
function TMetaObjects.obj_floor( const p:vec3 ):vec2;
begin
  Result.x := p.y+3;
  Result.y := 0;
end;

//Floor Color (checkerboard)
function TMetaObjects.obj_floor_c( const p:vec3 ):vec3;
begin
 if fract(p.x*0.5)>0.5 then
   if fract(p.z*0.5)>0.5 then
     Exit( vec3_1 )
   else
     Exit( vec3_2 )
 else
   if fract(p.z*0.5)>0.5 then
     Exit( vec3_3 )
   else
     	Exit( vec3_4 )
end;


//IQs RoundBox (try other objects http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm)
function TMetaObjects.obj_roundBox( const p:vec3 ):vec2;
begin
  Result.x := length(max(abs(p)-vec3_5,0))-0.25;
  Result.y := 1;
end;


function TMetaObjects.obj_sphere( const p:vec3 ):vec2;
begin
  Result := vec2(length(p)-2)
end;


//RoundBox with simple solid color
function TMetaObjects.obj_roundBox_c( const p:vec3 ):vec3;
begin
	Exit( RoundBoxCol );
end;



//Objects union
function TMetaObjects.inObj( const p:vec3 ):vec2;
var
  floor :vec2;
  b1 :float;
  b2 :float;
  b3 :float;
  b4 :float;
  b5 :float;
  b :float;
  d:vec2;
const
  e = 0.1;
  r = 2;
  re=e+r;
begin
    floor  := obj_floor(p);
    b1  := torus(p+t1,vec2_7);
    b2  := sphere(p+sp1,2);
    b3  := sphere(p+sp2,2);
    b4  := sphere(p+sp1,2);
    b5  := sphere(p+sp4,2);
    b   := 1/(b1+1.5+e)
          +1/(b2+re)
          +1/(b3+re)
          +1/(b4+re)
          +1/(b5+re);

    d.x := 1/b-0.7;
    d.y := 1;

    Result  := ObjUnion(d,floor);
end;



function TMetaObjects.ao( const p,n:vec3;d:float ):float;
var
  s,o:float;i:Integer;
begin
	s := Math.sign(d);
	o := s * 0.5 + 0.5;
  for i := 5 downto 1 do
  begin
		o := o - ((i*d-inObj(p+n*i*d*s).x)/exp2(i));
	end;

	Exit( o );
end;


function TMetaObjects.shadow( const ro:vec3;const rd:vec3 ):float;
var
  t,h:float;
  i:integer;
begin
    t := 0;
    for i := 1 to 59 do
    begin
        h  := inObj(ro + rd*t).x;
        if  h<0.001  then
            Exit( 0.0 );
        t  := t  + (h);
    end;

    Exit( 1.0 );
end;


function TMetaObjects.softshadow( const ro,rd:vec3;k :float ):float;
var
  res :float;
  t:float;
  i:integer; // loop variable
  h :float;
begin
    res  := 1.0;
    t := 0.00001;
    for i := 0 to 49 do
    begin
        h  := inObj(ro + rd*t).x;
        if  h<0.0001  then
            Exit( 0.0 );
        res  := min( res, k*h/t );
        t  := t  + h;
    end;

    Exit( res );
end;

//Scene End

procedure TMetaObjects.PrepareFrame;
var
  U:vec3;
  viewDir:vec3;
  C :vec3;
begin
  Ratio := resolution.x/resolution.y;

  //Camera animation
  U := vec3_8;
  viewDir := vec3_9;

  st := sinlarge(time);
  ct := cosLarge(time);
  st77 := sinLarge(time*0.77);
  st07 := sinLarge(time*0.7);

  E := Vec3.Create(-system.sin(time*0.2)*8.0,4,system.cos(time*0.2)*8.0); //Camera location;
//  E := Vec3.Create(mouse.x*4.0,4,mouse.y*4.0); //Camera location;

  //Camera setup
  C := normalize(viewDir-E);
  A := cross(C, U);
  B := cross(A, C);
  M := (E+C);

  t1   := Vec3.Create(st77*1.4,st*2.0,ct*5);
  sp1  := Vec3.Create(ct*4.4,ct*2.,cosLarge(time*1.2)*3.5);
  sp2  := Vec3.Create(st*3.6,st07*2.,st*2.6);
  sp3  := Vec3.Create(cosLarge(time*0.7)*4.4,sinLarge(time*1.1)*2.,ct*3.5);
  sp4  := Vec3.Create(sinLarge(time*1.3)*3.6,cosLarge(time*1.33)*2.,sinLarge(time*0.94)*2.6);
end;

function TMetaObjects.main;
var
  vPos:vec2;
  scrCoord,
  scp:vec3;
  s:vec2;
  c_,p,n,m_:vec3;
  vt:vec3;
  l:vec2;
  gt:float;
  f:float;
  g:float;
  i,Z:integer; // loop variables
  t:float;
  u_:vec3;
  y :vec2;
  b_:float;
  gl_FragColor:Vec3;
begin
  vPos := 2*gl_FragCoord.xy/resolution.xy - 1;
  scrCoord := M + vPos.x*A*ratio + vPos.y*B;
  scp := normalize(scrCoord-E);

  //Raymarching
  s := vec2_11;
  l := vec2_12;

  f := 1;  g := 1;
  for i := 0 to 499 do begin
    if (System.abs(s.x)<0.007) or (f>MAX_DEPTH) then
	     break;
    f := f + s.x;
    g := g + l.x;
    p := E+scp*f;
    m_ := E+scp*g;
    s := inObj(p);
    l := obj_floor(m_);
  end;

  n := normalize( Vec3.Create(s.x-inObj(p-vx).x,s.x-inObj(p-vy).x,s.x-inObj(p-vz).x));
  scp  := normalize(reflect(scp,n));
  t := 1.0;

  y  := vec2_13;
  for Z := 0 to 299 do
  begin
    if (System.abs(y.x)<0.007) or (t > MAX_DEPTH) then
      break;
    t := t + y.x;
    u_ := E+scp*t;
    y := inObj(u_);
  end;


  if f<MAX_DEPTH then
  begin
    if s.y=0.0 then
      c_ := obj_floor_c(p)
    else
    begin
      if g>MAX_DEPTH then
        gt := 0
      else
        gt := 1;
      if t>MAX_DEPTH then
        t := 0
      else
        t := 1;
      if y.y=0 then
        vt :=  obj_floor_c(u_)
      else
        vt := obj_roundBox_c(u_);

      c_ := RoundBoxCol {obj_roundBox_c(p)}
            + (obj_floor_c(m_+n) * (1-g*0.03)*gt) * 0.5
            + (vt*(1-t*0.03)*gt);
    end;

    b_ := dot(n,normalize(E-p));

    gl_FragColor:=vec3((b_*c_+power(b_,300)) * (1-f*0.03));//simple phong LightPosition=CameraPosition

    if s.y=1 then
      gl_FragColor  := gl_FragColor  - (1 - ao(p, n, 0.1))
    else
      if s.y=0 then
        gl_FragColor  := gl_FragColor  * softshadow(p, n, 16);

    Result := TColor32(gl_FragColor);
  end
  else
    Exit(clBlack32); //background color
end;


initialization

MetaObjects := TMetaObjects.Create;
Shaders.Add('MetaObjects', MetaObjects);

finalization

FreeandNil(MetaObjects);

end.

