unit WvN.DelphiShader.FX.Balls;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TPlasmaGroovy = class(TShader)
const vec3_1:(x:     s = ;y:0;z:1);

var Y :vec2;
  constructor Create; override;
  procedure PrepareFrame;
  function RenderPixel(var gl_FragCoord: Vec2): TColor32;
end;

var
PlasmaGroovy: TShader;

implementation

uses SysUtils, Math;

constructor TPlasmaGroovy.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TPlasmaGroovy.PrepareFrame;
begin
end;
precision mediump float;

uniform vec2 resolution;

Y  := resolution;

//3 coorded vectors
vec3 v = vec3(0),
     s = vec3_1,
     f = vec3(1),
     e,
     y,
     z,
     x,
     c,
     n,
     i,
     r,
     d,
     g,
     o;

//floats
float m,
      u,
      t,
      l,
      a = 1e30,  // = 1 * 10^30
      q = 0.0,
      F = 1.0,
      C = 0.5,
      Z;

//2 coorded vector

procedure X( const d:vec3 );
begin
	v  := y-d;
	t = dot(v,z),
	m  := t*t - (dot(v,v) - C*C);
	m  := -t - sqrt( m > 0.0 ? m:a );

	if m > q then
		x = y + z*m, c = x-d, Z  := m;
end;


void X()begin
	Z = a;
	X( Vec3.Create(1,0,-2.2) );
	X( Vec3.Create(-2,0,-3.5) );
	X( Vec3.Create(-0.5,0,-3) );
	m  := -(y.y + C) / z.y;

	if m > q   and   m < Z then
		x = y + z*m;
		c = s;
		Z  := m;
			end;


void main()begin

	o  := vec3(-F + 2.0*gl_FragCoord.xy / Y, 0);
	y = v,
	z  := normalize( Vec3.Create(Y.x/Y.y * o.x,o.y,-1) );
	X();
	i  := vec3(Z < 1e9 ? 1:0);
	n = r = x+(1e-5),
	g = c,
	d  := normalize( cross(f,g) );
	f  := normalize( cross(g,d) );

	for t := 0 to 36-1 do begin
		m += r.x
		   :=  + (r.y*53.0 + r.z*21.0);

		m  := sin( cos(m)*m )*C + C;
		u  := mod(m*33e3 + 626.0, 53.0) / 53.0;
		m  := 18.7e3 * u;
		l  := sqrt(F - u);
		c  := Vec3.Create( cos(m)*l,sin(m)*l,sqrt(u) );
		y  := n;

		z := Vec3.Create(c.x*d.x + c.y*f.x + c.z*g.x,c.x*d.y + c.y*f.y + c.z*g.y,c.x*d.z + c.y*f.z + c.z*g.z);

		X();

		if Z < 1e9 then
			e  := e  + (F);
				end;


	gl_FragColor := vec4( (36.0-e)/36.0 * i, 1 );
end;


initialization

PlasmaGroovy := TPlasmaGroovy.Create;
Shaders.Add('PlasmaGroovy', PlasmaGroovy);

finalization

FreeandNil(PlasmaGroovy);

end.

