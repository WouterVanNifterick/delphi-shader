unit WvN.DelphiShader.FX.GearMachine;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TGearMachine = class(TShader)

  constructor Create; override;
  procedure PrepareFrame;
  function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  function fan( p:vec2;const at:vec2;const ang:float ):float;
  function layerA( const p:vec2;const seed:float ):float;
  function layerB( const p:vec2;const seed:float ):float;

end;

var
GearMachine: TShader;

implementation

uses SysUtils, Math;

constructor TGearMachine.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TGearMachine.PrepareFrame;
begin
end;

// by srtuss, 2013
// a little expAession of my love for complex machines and stuff
// was going for some cartoonish 2d look
// still could need some optimisation

// * improved gears
// * improved camera movement



// simulates a resonant lowpass filter
function mechstep( const x:float;const f:float;const r:float ):float;
var fr :float; fl :float;
begin
	fr  := fract(x);
	fl  := Math.floor(x);
	Exit( fl + pow(fr, 0.5) + system.sin(fr * f) * exp(-fr * 3.5) * r );
end;


// voronoi cell id noise
function voronoi( const x:vec2 ):vec3;
var n,f, mg, mr:vec2; md :float; g :vec2; o :vec2; r :vec2; d :float;
i,j:Integer;
begin
	n  := floor(x);
	f  := fract(x);



	md  := 8.0;
	for j  :=  -1 to 1 do
	begin
		for i  :=  -1 to 1 do
		begin
			g  := Vec2.Create(i,j);
			o  := hash(n + g);
			r  := g + o - f;
			d  := math.max(System.abs(r.x), System.abs(r.y));

			if d < md then
			begin
				md  := d;
				mr  := r;
				mg  := g;
			end;

		end;

	end;


	Exit( vec3.create(n + mg, mr.x) );
end;


function rotate( const p:vec2;const a:float ):vec2;
begin
	Exit( Vec2.Create(p.x * system.cos(a) - p.y * system.sin(a),
                    p.x * system.sin(a) + p.y * system.cos(a)) );
end;


function stepfunc( const a:float ):float;
begin
	Exit( step(a, 0.0) );
end;


function TGearMachine.fan( p:vec2;const at:vec2;const ang:float ):float;
var v,le,a,w :float;
begin
	p  := p  - (at);
	p  := p  * (3.0);

	le  := length(p);

	v  := le - 1.0;

	if v > 0.0 then
		Exit( 0.0 );

	a  := system.sin(atan(p.y, p.x) * 3.0 + ang);

	w  := le - 0.05;
	v  := max(v, -(w + a * 0.8));

	w  := le - 0.15;
	v  := max(v, -w);

	Exit( stepfunc(v) );
end;


function gear( p:vec2;const at:vec2;const teeth:float;const size:float;const ang:float ):float;
var v,w,le :float;
begin
	p  := p  - (at);
	le  := length(p);

	w  := le - 0.3 * size;
	v  := w;

	w  := system.sin(atan(p.y, p.x) * teeth + ang);
	w  := smoothstep(-0.7, 0.7, w) * 0.1;
	v  := min(v, v - w);

	w  := le - 0.05;
	v  := max(v, -w);

	Exit( stepfunc(v) );
end;


function car( p:vec2;const at:vec2 ):float;
var v,w :float; box :vec2;
begin
	p  := p  - (at);
	w  := length(p + Vec2.Create(-0.05,-0.32)) - 0.03;
	v  := w;
	w  := length(p + Vec2.Create(0.05,-0.32)) - 0.03;
	v  := Math.min(v, w);

	box  := abs(p + Vec2.Create(0.0,-0.3 - 0.08));
	w  := max(box.x - 0.1, box.y - 0.05);
	v  := Math.min(v, w);
	Exit( stepfunc(v) );
end;


function TGearMachine.layerA( const p:vec2;const seed:float ):float;
var v,w,a :float; si :float; sr :float; sp :vec2;
//strut :float;
st :float;
begin
	si  := Math.floor(p.y);
	sr  := hash(si + seed * 149.91);
	sp  := Vec2.Create(p.x, &mod(p.y,4.0));

	st  := time + sr;

	v  := step(2.0, System.Abs(voronoi(p + Vec2.Create(0.35,seed * 194.9)).x));

	w  := length(sp - Vec2.Create(-2.0,0.0)) - 0.8;
	v  := min(v, 1.0 - step(w, 0.0));


	a  := st;
	w  := fan(sp, Vec2.Create(2.5, 0.65),a * 40.0);
	v  := min(v, 1.0 - w);


	Exit( v );
end;


function TGearMachine.layerB( const p:vec2;const seed:float ):float;
var v,w,a :float; si :float; sp :vec2; sr :float; strut :float; st :float; cs :float; ct :float;
begin
	si  := floor(p.y / 3.0) * 3.0;
	sp  := Vec2.Create(p.x, &mod(p.y,3.0));
	sr  := hash(si + seed * 149.91);
	sp.y  := sp.y  - (sr * 2.0);

	strut  := 0.0;
	strut  := strut  + (step(System.Abs(sp.y), 0.3));
	strut  := strut  + (step(System.Abs(sp.y - 0.2), 0.1));

	st  := time + sr;

	cs  := 2.0;
	if hash(sr) > 0.5 then
		cs  := cs  * (-1.0);
	ct  := &mod(st * cs, 5.0 + sr) - 2.5;


	v  := step(2.0, System.Abs(voronoi(p + Vec2.Create(0.35,seed * 194.9)).x) + strut);

	w  := length(sp - Vec2.Create(-2.3,0.6)) - 0.15;
	v  := min(v, 1.0 - step(w, 0.0));
	w  := length(sp - Vec2.Create(2.3,0.6)) - 0.15;
	v  := min(v, 1.0 - step(w, 0.0));

	if v > 0.0 then
		Exit( 1.0 );


	w  := car(sp, Vec2.Create(ct,0.0));
	v  := w;

	if hash(si + 81.0) > 0.5 then
		a  := mechstep(st * 2.0, 20.0, 0.4) * 3.0
	else
		a  := st * (sr - 0.5) * 30.0;
	w  := gear(sp, Vec2.Create(-2.0 + 4.0 * sr, 0.5), 8.0, 1.0,a);
	v  := Math.max(v, w);

	w  := gear(sp, Vec2.Create(-2.0 + 0.65 + 4.0 * sr, 0.35), 7.0, 0.8,-a);
	v  := Math.max(v, w);
	if hash(si - 105.13) > 0.8 then
	begin
		w  := gear(sp, Vec2.Create(-2.0 + 0.65 + 4.0 * sr, 0.35), 7.0, 0.8,-a);
		v  := Math.max(v, w);
	end;

	if hash(si + 77.29) > 0.8 then
	begin
		w  := gear(sp, Vec2.Create(-2.0 - 0.55 + 4.0 * sr, 0.30), 5.0, 0.5,-a + 0.7);
		v  := Math.max(v, w);
	end;


	Exit( v );
end;


function TGearMachine.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var uv,p:vec2; t,w :float; cam,o :vec2; v,z,f,zz :float;
i:integer;
begin
	uv  := gl_FragCoord.xy / resolution.xy;
	uv  := uv * 2.0 - 1.0;
	p  := uv;
	p.x  := p.x  * (resolution.x / resolution.y);

	t  := time;

	cam  := Vec2.Create(system.sin(t) * 0.2,t);

	p  := rotate(p, system.sin(t) * 0.1);

	o  := Vec2.Create(0.0,t);
	v  := 0.0;


	z  := 3.0 - system.sin(t * 0.7) * 0.1;
	for i  :=  0 to  5-1 do
	begin
		zz  := 0.3 + z;

		f  := zz * 2.0 * 0.9;


		if (i = 3)  or  (i = 1) then
			w  := layerA(Vec2.Create(p.x, p.y) * f + cam,i)
		else
			w  := layerB(Vec2.Create(p.x, p.y) * f + cam,i);
		v  := mix(v, exp(-System.Abs(zz) * 0.3 + 0.1), w);


		z  := z  - (0.6);
	end;





	v  := 1.0 - v;// * pow(1.0 - System.Abs(uv.x), 0.1);

	Result := Tcolor32(vec3.Create(v));
end;


initialization

GearMachine := TGearMachine.Create;
Shaders.Add('GearMachine', GearMachine);

finalization

FreeandNil(GearMachine);

end.

