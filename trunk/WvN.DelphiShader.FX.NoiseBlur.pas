unit WvN.DelphiShader.FX.NoiseBlur;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TNoiseBlur = class(TShader)
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  NoiseBlur: TShader;

implementation

uses SysUtils, Math;

constructor TNoiseBlur.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;



function noise( const x :vec2 ):float;
var p :vec2; f :vec2; n :float;
begin
    p  := floor(x);
    f  := fract(x);
    f  := f*f*(3.0-2.0*f);
    n  := p.x + p.y*57.0;
    Result := mix(mix( hash(n+  0.0), hash(n+  1.0),f.x), mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);
end;


procedure TNoiseBlur.PrepareFrame;
begin
end;

function TNoiseBlur.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var p :vec2; uv :vec2; acc :float; col :vec3; dir :vec2; h :float; w :float; ttt :vec3; gg :float; nor :vec3; di :vec2;
    i:Integer;
  function map( var p :vec2 ):vec2;
  var a :float;
  begin
    p.x  := p.x  + (0.1*system.sin( iGlobalTime + 2.0*p.y ) );
    p.y  := p.y  + (0.1*system.sin( iGlobalTime + 2.0*p.x ) );

    a  := noise(p*1.5 + system.sin(0.1*iGlobalTime))*6.2831;
    a  := a  - (iGlobalTime + gl_FragCoord.x / Resolution.x);
    Exit( Vec2.Create( system.cos(a),system.sin(a) ) );
  end;



begin
    p  := gl_FragCoord.xy / Resolution.xy;
	uv  := -1.0 + 2.0*p;
	uv.x  := uv.x  * (Resolution.x / Resolution.y);

	acc  := 0.0;
	col  := vec3(0.0);
    for i:=0 to 31 do
   	begin
		dir  := map( uv );

		h  := i/32.0;
		w  := 4.0*h*(1.0-h);

		ttt  := w*texture2D( tex[1], uv ).xyz;
		ttt  := ttt  * (mix(
                      vec3.create(0.6,0.7,0.7),
                      vec3.create(1.0,0.95,0.9), 0.5 - 0.5 * dot( reflect(vec3.create(dir,0.0), Vec3.Create(1.0,0.0,0.0)).xy,vec2.create(0.707) ) ));
		col  := col  + (w*ttt);
		acc  := acc  + (w);

		uv  := uv  + (0.008*dir);
	end;

	col  := col  / (acc);

	gg  := dot( col, vec3(0.333) );
//	nor  := normalize( Vec3.Create( dFdx(gg),0.5,dFdy(gg) ) );
  col  := col  + (vec3(0.4)*dot( nor, Vec3.Create(0.7,0.01,0.7) ));


	di  := map( uv );
	col  := col  * (0.65 + 0.35*dot( di, vec2(0.707) ));
	col  := col  * (0.20 + 0.80*pow( 4.0*p.x*(1.0-p.x), 0.1 ));
	col  := col  * (1.7);

	Result := TColor32(col);
end;

initialization

NoiseBlur := TNoiseBlur.Create;
Shaders.Add('NoiseBlur', NoiseBlur);

finalization

FreeandNil(NoiseBlur);

end.
