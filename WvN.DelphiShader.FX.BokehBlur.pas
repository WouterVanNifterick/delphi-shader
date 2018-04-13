unit WvN.DelphiShader.FX.BokehBlur;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TBokehBlur = class(TShader)
var
  ar,ar2:array[-1..1,-1..1] of vec3;
  scale_ar:array[-1..1] of double;
  rot,matx :mat3;
  rx :float;
const
  vec3_1 :vec3=(x: 0;y: 0.2;z:0.7);

  vec3_2 :vec3=(x:-1;y: 1;z:-1);
  vec3_3 :vec3=(x: 1;y: 1;z:-1);
  vec3_4 :vec3=(x:-1;y: 1;z: 1);
  vec3_5 :vec3=(x: 1;y: 1;z: 1);
  vec3_6 :vec3=(x:-1;y:-1;z:-1);
  vec3_7 :vec3=(x: 1;y:-1;z:-1);
  vec3_8 :vec3=(x:-1;y:-1;z: 1);
  vec3_9 :vec3=(x: 1;y:-1;z: 1);
  vec3_10:vec3=(x: 0;y: 0;z:14);

  function cap( const a, b:vec2 ):float;
  function cap1(  p:float ):float;
  function ebok( const p, a, b:vec2 ):float;
  function handleCorner( const p, a, b, c:vec2 ):float;
  function bokehtria( const p, a, b, c:vec2 ):float;
  function bokehsquare( p,a,b,c,d:vec2; scale:float ):float;
  function project( const v:vec3 ):vec2;
  function shade( const v:vec3; f:float ):vec4;
  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  BokehBlur: TShader;

implementation

uses SysUtils, Math;

constructor TBokehBlur.Create;
begin
  inherited;
  Image.FrameProc := PrepareFrame;
  Image.PixelProc := Main;

	rot  := mat3.Create(1,0,0,0,0.8,0.6,0,-0.6,0.8)*mat3.Create(0.96,0.28,0,-0.28,0.96,0,0,0,1);

end;


function TBokehBlur.cap( const a, b:vec2 ):float;
var
  abd :vec2;
  y_x :float;

begin
	abd  := Vec2.Create(a.x*b.x+a.y*b.y,a.y*b.x-a.x*b.y);
  if abd.x<>1 then
  	y_x := abd.y/(abd.x-1)
  else
    y_x := 0;


	Exit( arctan(-y_x)-y_x/(1+y_x*y_x)+PI/2 );
end;


function TBokehBlur.cap1(  p:float ):float;
begin
	p  := EnsureRange(p,-1,1);
	Exit( arcsin(p)+p * system.sqrt(1-p*p)+PI/2 );
end;


function TBokehBlur.ebok( const p, a, b:vec2 ):float;
var
  an :vec2;
  bn :vec2;
  surface:float;
  pa :float;
  ra :float;
  pac :vec2;
  pb :float;
  rb :float;
  pbc :vec2;
  d1 :float;
  d2 :float;
  sda :float;
  sdb :float;

begin
	an  := Vec2.Create(a.y,-a.x);
	bn  := Vec2.Create(b.y,-b.x);


	if dot(normalize(an),normalize(bn))>0.9999 then
  begin
		// This is neccessary to remove dot crawl around corners
		surface  := 0;
  end
  else
    if dot(p,p) < 0.99 then
    begin
      pa  := dot(p,a);
      ra  := -pa + system.sqrt(pa*pa-dot(p,p)+1);
      pac  := ra*a;

      pb  := dot(p,b);
      rb  := -pb + system.sqrt(pb*pb-dot(p,p)+1);
      pbc  := rb*b;

      surface  := cap(p+pac,p+pbc)+(pac.x*pbc.y-pac.y*pbc.x)*0.5;
    end
    else
    begin
      d1  := dot(an,p);
      d2  := -dot(bn,p);
      sda  := step(dot(p,a),0);
      sdb  := step(dot(p,b),0);
      surface  := PI*(sda+sdb-sda*sdb) - cap1(-d1)*sda - cap1(-d2)*sdb;
  	end;
	Exit( surface );
end;

function TBokehBlur.handleCorner( const p, a, b, c:vec2 ):float;
var
  ba :vec2;
  bc :vec2;
  h :float;

begin
	ba  := normalize(a-b);
	bc  := normalize(c-b);
	h  := dot(a-p,Vec2.Create(ba.y,-ba.x));
	Exit( ebok(p-b, bc, ba) - cap1(h) );
end;


function TBokehBlur.bokehtria( const p, a, b, c:vec2 ):float;
var
  mi :vec2;
  ma :vec2;

begin
	mi  := min(min(a,b),c)-1;
	ma  := max(max(a,b),c)+1;
	Exit( ifthen(((a.x-b.x)*(a.y-c.y)<(a.y-b.y)*(a.x-c.x)) or (p.x<mi.x) or (p.y<mi.y) or (p.x>ma.x) or (p.y>ma.y) , 0 ,  handleCorner(p,a,b,c) + handleCorner(p,b,c,a) + handleCorner(p,c,a,b) + PI ));
end;


function TBokehBlur.bokehsquare( p,a,b,c,d:vec2; scale:float ):float;
var
  mi :vec2;
  ma :vec2;

begin
	p  := p  * (scale);
  a  := a  * (scale);
  b  := b  * (scale);
  c  := c  * (scale);
  d  := d  * (scale);
	mi  := min(min(a,b),min(c,d))-1;
	ma  := max(max(a,b),max(c,d))+1;
  if ((a.x-b.x)*(a.y-c.y)<(a.y-b.y)*(a.x-c.x)) or (p.x<mi.x) or (p.y<mi.y) or (p.x>ma.x) or (p.y>ma.y) then
    Result := 0
  else
    Result := handleCorner(p,a,b,c) + handleCorner(p,b,c,d) + handleCorner(p,c,d,a) + handleCorner(p,d,a,b) + PI;
end;


function TBokehBlur.project( const v:vec3 ):vec2;
begin
	Result := v.xy/(v.z+14)
end;


function TBokehBlur.shade( const v:vec3; f:float ):vec4;
var
  highlight :float;
begin
	highlight  := pow(f*0.5+0.5,100);
	Result := vec4.create(pow(f*0.5+0.5,10)*v*1.5*(1-highlight)+highlight,1)/PI;
end;

procedure TBokehBlur.PrepareFrame;
var x,z:integer;
begin
  matx := mat3.Create(system.cos(rx),0,system.sin(rx),0,1,0,-system.sin(rx),0,system.cos(rx));
	rx  := time;
	for z  := -1 to 1 do
  begin
		for x  :=  -1 to 1 do
    begin
  		ar[z,x] := Vec3.Create(x*3.5+z,system.sin(x*2+z*2+time),z*-3.5+x);
      ar2[z,x] := ar[z,x] + vec3_10;
    end;

    scale_ar[z] := 1/(1/(ar[z,0].z +14) - 1/(mouse.y*9-4.5+14.1));
  end;
end;

function TBokehBlur.Main(var gl_FragCoord: Vec2): TColor32;
var
  mat :mat3;
  p :vec2;
  color :vec3;
  z,
  x :integer;
  q :vec3;
  scale :float;
  a,  b,  c,  d,  e,  f,  g,  h :vec2;
  s0,  s1,  s2 :float;
  t0,  t1,  t2 :float;
  color1:vec4;
begin
	mat  := matx;
	p  := ( gl_FragCoord.xy - resolution*0.5 ) / resolution.x ;

	color  := vec3_1;

	for z  := -1 to 1 do
  begin
		for x  :=  -1 to 1 do
    begin
			q  := ar[z,x];

			scale  := scale_ar[z];

			a  := project(vec3_2*mat+q);
			b  := project(vec3_3*mat+q);
			c  := project(vec3_4*mat+q);
			d  := project(vec3_5*mat+q);
			e  := project(vec3_6*mat+q);
			f  := project(vec3_7*mat+q);
			g  := project(vec3_8*mat+q);
			h  := project(vec3_9*mat+q);

			s0  := step(  dot(Vec3.Create(mat.r1.y,mat.r2.y,mat.r3.y),ar2[z,x]),0);
			s1  := step(0,dot(Vec3.Create(mat.r1.z,mat.r2.z,mat.r3.z),ar2[z,x])  );
			s2  := step(0,dot(Vec3.Create(mat.r1.x,mat.r2.x,mat.r3.x),ar2[z,x])  );
			t0  := 1-s0;
			t1  := 1-s1;
			t2  := 1-s2;

      color1 := bokehsquare(p, a * s0 + g * t0, b * s0 + h * t0, d * s0 + f * t0, c * s0 + e * t0, scale) * shade(vec3.Create(0.7 * s0 + 0.3 * t0, 0.5, 0.5), mat.r3.y * (t0 - s0)) +
                bokehsquare(p, b * s1 + h * t1, a * s1 + g * t1, e * s1 + c * t1, f * s1 + d * t1, scale) * shade(vec3.Create(0.5, 0.7 * s1 + 0.3 * t1, 0.5), mat.r3.z * (s1 - t1)) +
                bokehsquare(p, a * s2 + f * t2, c * s2 + h * t2, g * s2 + d * t2, e * s2 + b * t2, scale) * shade(vec3.Create(0.5, 0.5, 0.7 * s2 + 0.3 * t2), mat.r3.x * (s2 - t2));
      color  := color1.xyz + color*(1-color1.w);
			mat  := mat  * rot;
		end;

	end;


  Color := clamp(color,0,1);
	Result  := TColor32( sqrt((color)));
end;



initialization

BokehBlur := TBokehBlur.Create;
Shaders.Add('BokehBlur', BokehBlur);

finalization

FreeandNil(BokehBlur);

end.
