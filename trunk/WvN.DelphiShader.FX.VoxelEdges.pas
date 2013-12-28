unit WvN.DelphiShader.FX.VoxelEdges;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TVoxelEdges = class(TShader)
const
  vec3_1:vec3=(x:1;y:113;z:257);
  vec2_2:vec2=(x:37;y:17);
  vec3_3:vec3=(x:0;y:1;z:0);
  vec3_4:vec3=(x:0;y:2;z:0);
  vec2_5:vec2=(x:0.1;y:0.9);
  vec2_6:vec2=(x:1;y:1.2);
  vec2_7:vec2=(x:1;y:4.5);
  vec2_8:vec2=(x:1.3;y:1);
  vec3_9:vec3=(x:0;y:0;z:0);
  vec3_10:vec3=(x:0;y:6;z:0);
  vec3_11:vec3=(x:0.1;y:0.3;z:0.4);
  vec3_12:vec3=(x:-1;y:0;z:-1);
  vec3_13:vec3=(x:1.00;y:0.90;z:0.70);
  vec3_14:vec3=(x:0.15;y:0.10;z:0.10);
  vec3_15:vec3=(x:0.40;y:0.30;z:0.15);
  vec3_16:vec3=(x:5;y:0.6;z:0);
  vec3_17:vec3=(x:1;y:2;z:3);

  function hash( const x :vec3 ):float;
  function noise( const x :vec3 ):float;overload;
  function noise( const x :vec2 ):float;overload;
  function texcube( const p, n :vec3 ):vec4;
  function mapTerrain( const p :vec3 ):float;
  function map( const c:vec3 ):bool;
  function castRay( const ro, rd:vec3;out oVos, oDir :vec3 ):float;
  function castVRay( const ro, rd:vec3;const maxDist :float ):float;
  function edges( const vos, nor, dir :vec3 ):vec4;
  function edgesp( const vos, nor, dir :vec3 ):vec4;
  function path(  t :float ):vec3;
  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  VoxelEdges: TShader;

implementation

uses SysUtils, Math;

constructor TVoxelEdges.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TVoxelEdges.PrepareFrame;
begin
end;

// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

function TVoxelEdges.hash( const x :vec3 ):float;
var
  n :float;

begin
	n  := dot( x, vec3_1 );
    Exit( fract(sin(n)*43758.5453) );
end;


function TVoxelEdges.noise( const x :vec3 ):float;
var
  p :vec3;
  f :vec3;
  uv :vec2;
  rg :vec2;

begin
    p  := floor(x);
    f  := fract(x);
	f  := f*f*(3-2*f);

	uv  := (p.xy+vec2_2*p.z) + f.xy;
	rg  := texture2D( tex0, (uv+ 0.5)/256 ).yx;
	Exit( mix( rg.x, rg.y, f.z ) );
end;


function TVoxelEdges.noise( const x :vec2 ):float;
var
  p :vec2;
  f :vec2;
  uv :vec2;

begin
    p  := floor(x);
    f  := fract(x);
	uv  := p.xy + f.xy*f.xy*(3-2*f.xy);
	Exit( texture2D( tex0, (uv+118.4)/256, -100 ).x );
end;



function TVoxelEdges.texcube( const p, n :vec3 ):vec4;
var
  x :vec4;
  y :vec4;
  z :vec4;
  m  :mat3;

begin
	x  := texture2D( Tex0, p.yz );
	y  := texture2D( Tex0, p.zx );
	z  := texture2D( Tex0, p.xy );
	Exit( x*abs(n.x) + y*abs(n.y) + z*abs(n.z) );
end;


//===================================
                    {
 m   := mat3( 0.00,  0.80,  0.60,
                    -0.80,  0.36, -0.48,
                    -0.60, -0.48,  0.64 );
                     }

function TVoxelEdges.mapTerrain( const p :vec3 ):float;
var
  time :float;
  ft :float;
  it :float;
  spe :float;
  f:float;

begin

	p  := p  * (0.1);
	p.xz  := p.xz  * (0.6);


	time  := 0.5 + 0.15*iGlobalTime;
	ft  := fract( time );
	it  := floor( time );
	ft  := smoothstep( 0.7, 1, ft );
	time  := it + ft;
	spe  := 1.4;


    f   := 0.5000*noise( p*1.00 + vec3_3*spe*time );
    f  := f  + (0.2500*noise( p*2.02 + vec3_4*spe*time ));
    f  := f  + (0.1250*noise( p*4.01 ));
	Exit( 25*f-10 );
end;



function TVoxelEdges.gro = vec3:vec3;;

function TVoxelEdges.map( const c:vec3 ):bool;
var
  p :vec3;
  f :float;

begin
	p  := c + 0.5;


	f  := mapTerrain( p ) + 0.25*p.y;

    f  := mix( f, 1, step( length(gro-p), 5 ) );

	Exit( f < 0.5 );
end;


function TVoxelEdges.lig = normalize( vec3:vec3;;


function TVoxelEdges.castRay( const ro, rd:vec3;out oVos, oDir :vec3 ):float;
var
  pos :vec3;
  ri :vec3;
  rs :vec3;
  dis :vec3;
  res :float;
  mm :vec3;
  i:integer; // loop variable
nor :vec3;
  vos :vec3;
  mini :vec3;
  t :float;

begin
	pos  := floor(ro);
	ri  := 1/rd;
	rs  := sign(rd);
	dis  := (pos-ro + 0.5 + rs*0.5) * ri;

	res  := -1;
	mm  := vec3(0);
	for i := 0 to 127 do
	begin
		if  map(pos)  then  begin  res=1; continue; end;

		mm  := step(dis.xyz, dis.yxy) * step(dis.xyz, dis.zzx);
		dis  := dis  + (mm * rs * ri);
        pos  := pos  + (mm * rs);
	end;


	nor  := -mm*rs;
	vos  := pos;

    // intersect the cube
	mini  := (pos-ro + 0.5 - 0.5*vec3(rs))*ri;
	t  := max ( mini.x, max ( mini.y, mini.z ) );

	oDir  := mm;
	oVos  := vos;

	Exit( t*res );

end;


function TVoxelEdges.castVRay( const ro, rd:vec3;const maxDist :float ):float;
var
  pos :vec3;
  ri :vec3;
  rs :vec3;
  dis :vec3;
  res :float;
  i:integer; // loop variable
mm :vec3;

begin

	pos  := floor(ro);
	ri  := 1/rd;
	rs  := sign(rd);
	dis  := (pos-ro + 0.5 + rs*0.5) * ri;

	res  := 1;
	for i := 0 to 49 do
	begin
		if  map(pos)  then  begin res=0; continue; end;

		mm  := step(dis.xyz, dis.yxy) * step(dis.xyz, dis.zzx);
		dis  := dis  + (mm * rs * ri);
        pos  := pos  + (mm * rs);
	end;


	Exit( res );

end;


function TVoxelEdges.edges( const vos, nor, dir :vec3 ):vec4;
var
  v1 :vec3;
  v2 :vec3;
  v3 :vec3;
  v4 :vec3;
  res :vec4;

begin
	v1  := vos + nor + dir.yzx;
	v2  := vos + nor - dir.yzx;
	v3  := vos + nor + dir.zxy;
	v4  := vos + nor - dir.zxy;

	res  := vec4(0);
	if  map(v1)  then  res.x  := 1;
	if  map(v2)  then  res.y  := 1;
	if  map(v3)  then  res.z  := 1;
	if  map(v4)  then  res.w  := 1;

	Exit( res );
end;


function TVoxelEdges.edgesp( const vos, nor, dir :vec3 ):vec4;
var
  v1 :vec3;
  v2 :vec3;
  v3 :vec3;
  v4 :vec3;
  res :vec4;

begin
	v1  := vos +  dir.yzx;
	v2  := vos -  dir.yzx;
	v3  := vos +  dir.zxy;
	v4  := vos -  dir.zxy;

	res  := vec4(0);
	if  map(v1)  then  res.x  := 1;
	if  map(v2)  then  res.y  := 1;
	if  map(v3)  then  res.z  := 1;
	if  map(v4)  then  res.w  := 1;

	Exit( res );
end;


function TVoxelEdges.path(  t :float ):vec3;
var
  p  :vec2;

begin
    p   := 100*sin( 0.02*t*vec2_6 + vec2_5 );
	     p  := p  + (50*sin( 0.04*t*vec2_8 + vec2_7 ));

	Exit( Vec3.Create( p.x,18 + 4*sin(0.05*t),p.y ) );
end;


function TVoxelEdges.Main(var gl_FragCoord: Vec2): TColor32;
var
  q :vec2;
  p :vec2;
  mo :vec2;
  time :float;
  ro :vec3;
  ta :vec3;
  cr :float;
  ww :vec3;
  uu :vec3;
  vv :vec3;
  r2 :float;
  rd :vec3;
  col :vec3;
  vos, dir:vec3;
  t :float;
  nor :vec3;
  pos :vec3;
  ed :vec4;
  ep :vec4;
  uvw :vec3;
  wir :vec3;
  www :float;
  vvv :float;
  dif :float;
  sha = 0; if( dif>0.01) sha:float;
  bac :float;
  sky :float;
  amb :float;
  occ :float;
  v1 :vec3;
  v2 :vec3;
  v3 :vec3;
  v4 :vec3;
  ff:float;
  lin :vec3;
  lineglow :float;
  linCol :vec3;

begin
    // inputs
	q  := gl_FragCoord.xy / resolution.xy;
    p  := -1 + 2*q;
    p.x  := p.x  * (resolution.x/ resolution.y);

    mo  := iMouse.xy / resolution.xy;
    if  iMouse.w<=0.00001 ) mo := vec2(0 then ;

	time  := 2*iGlobalTime + 50*mo.x;
    // camera
    ro  := 20.5*normalize(Vec3.Create(cos(time),0.5,sin(time)));
	ta  := vec3_9;
	cr  := 0.2*cos(0.1*iGlobalTime);

	ro  := path( time );
	ta  := path( time+5 ) - vec3_10;
	gro  := ro;

	// build ray
    ww  := normalize( ta - ro);
    uu  := normalize(cross( Vec3.Create(sin(cr),cos(cr),0),ww ));
    vv  := normalize(cross(ww,uu));
	r2  := p.x*p.x*0.32 + p.y*p.y;
    p  := p  * ((7-sqrt(37.5-11.5*r2))/(r2+1));
    rd  := normalize( p.x*uu + p.y*vv + 2.5*ww );

	col  := vec3(0);


	t  := castRay( ro, rd, vos, dir );
	if  t>0  then
	begin
	nor  := -dir*sign(rd);
	pos  := ro + rd*t;
	ed  := edges( vos, nor, dir );
	ep  := edgesp( vos, nor, dir );




	// wireframe
	uvw  := pos - vos;
	wir  := smoothstep( 0.4, 0.48, abs(uvw-0.5) );
    www  := 0;
	{$if 0}
	www  := (1-wir.x*wir.y)*(1-wir.x*wir.z)*(1-wir.y*wir.z);
	#else
	www  := 1;
    www  := www  * (1 -smoothstep( 0.85, 0.99,     dot(uvw,dir.yzx) )*(1-ep.x*(1-ed.x)));
    www  := www  * (1 -smoothstep( 0.85, 0.99, 1-dot(uvw,dir.yzx) )*(1-ep.y*(1-ed.y)));
    www  := www  * (1 -smoothstep( 0.85, 0.99,     dot(uvw,dir.zxy) )*(1-ep.z*(1-ed.z)));
    www  := www  * (1 -smoothstep( 0.85, 0.99, 1-dot(uvw,dir.zxy) )*(1-ep.w*(1-ed.w)));
	{$endif }

	wir  := smoothstep( 0.4, 0.5, abs(uvw-0.5) );
	vvv  := (1-wir.x*wir.y)*(1-wir.x*wir.z)*(1-wir.y*wir.z);

	col = 2*texture2D( tex1,0.01*pos.xz ).zyx;
	col  := col  + (0.8*vec3_11);
	col  := col  * (0.5 + 0.5*texcube( tex2, 0.5*pos, nor ).x);
	col  := col  * (1 - 0.75*(1-vvv)*www);

    // lighting
    dif  := clamp( dot( nor, lig ), 0, 1 );
 if  dif>0.01) sha := castVRay(pos+nor*0.01,lig,32 then ;
    bac  := clamp( dot( nor, normalize(lig*vec3_12) ), 0, 1 );
    sky  := 0.5 + 0.5*nor.y;
	amb  := clamp(0.75 + pos.y/25,0,1);
    occ  := 1;


	v1  := vos + nor + dir.yzx;
	v2  := vos + nor - dir.yzx;
	v3  := vos + nor + dir.zxy;
	v4  := vos + nor - dir.zxy;

	occ = 0;

	ff = mix( 1, pow(1-dot(uvw,dir.yzx),1), ed.x); occ  := ff = mix( 1, pow(1-dot(uvw,dir.yzx),1), ed.x); occ  + ((0.98/4)*ff);
	ff = mix( 1, pow(    dot(uvw,dir.yzx),1), ed.y); occ  := ff = mix( 1, pow(    dot(uvw,dir.yzx),1), ed.y); occ  + ((0.98/4)*ff);
	ff = mix( 1, pow(1-dot(uvw,dir.zxy),1), ed.z); occ  := ff = mix( 1, pow(1-dot(uvw,dir.zxy),1), ed.z); occ  + ((0.98/4)*ff);
	ff = mix( 1, pow(    dot(uvw,dir.zxy),1), ed.w); occ  := ff = mix( 1, pow(    dot(uvw,dir.zxy),1), ed.w); occ  + ((0.98/4)*ff);
    occ  := pow(occ,3);
	occ  := occ  * (amb);


    lin  := vec3(0);
    lin  := lin  + (6*dif*vec3_13*sha*(0.5+0.5*occ));
    lin  := lin  + (0.5*bac*vec3_14*occ);
    lin  := lin  + (2*sky*vec3_15*occ);
	//lin  := vec3(occ)*2.0;

	//lin = vec3(1.0)*occ*12.0;
	// line glow
	lineglow  := 0;
    lineglow  := lineglow  + (smoothstep( 0.4, 1,     dot(uvw,dir.yzx) )*(1-ep.x*(1-ed.x)));
    lineglow  := lineglow  + (smoothstep( 0.4, 1, 1-dot(uvw,dir.yzx) )*(1-ep.y*(1-ed.y)));
    lineglow  := lineglow  + (smoothstep( 0.4, 1,     dot(uvw,dir.zxy) )*(1-ep.z*(1-ed.z)));
    lineglow  := lineglow  + (smoothstep( 0.4, 1, 1-dot(uvw,dir.zxy) )*(1-ep.w*(1-ed.w)));

	linCol  := 2*vec3_16;
	linCol  := linCol  * ((0.5+0.5*occ)*(0.25+sha));
	lin  := lin  + (3*lineglow*linCol);

    col  := col*lin;

	col  := col  + (8*linCol*vec3_17*(1-www);
	col  := col  + (0.1*lineglow*linCol);

	col  := col  * (min(0.1,exp( -0.07*t )));


function TVoxelEdges.col2 = vec3(1.3)*(0.5+0.5*nor.y)*occ*www*(0.9+0.1*vvv)*exp:vec3;;;
function TVoxelEdges.mi = sin:float;;
mi  := smoothstep( 0.90, 0.95, mi );
col  := mix( col, col2, mi );

	end;

    // gamma
	col  := pow( col, vec3(0.45) );

    col  := clamp( col, 0, 1 );

	// vignetting
	col  := col  * (0.5 + 0.5*pow( 16*q.x*q.y*(1-q.x)*(1-q.y), 0.1 ));

	Result  := vec4( col, 1 );

initialization

VoxelEdges := TVoxelEdges.Create;
Shaders.Add('VoxelEdges', VoxelEdges);

finalization

FreeandNil(VoxelEdges);

end.

