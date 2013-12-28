unit WvN.DelphiShader.FX.Flare;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TFlare = class(TShader)
const
  vec3_1:vec3=(x:0.5;y:0.8;z:1.5);
var
  v:Vec2;
  omega :float;
  divisor :float;

function flare( const spos:vec2;const fpos:vec2;const clr:vec3 ):vec3;
function noise( const pos:vec2 ):float;
function RenderPixel(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
Flare: TShader;

implementation

uses SysUtils, Math;

constructor TFlare.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TFlare.PrepareFrame;
var n:double;
begin
	omega  := time*2.;//-(sin(time)/1.5);
	divisor  := 1.0-0.5*system.cos(omega);
  n := (2/divisor);
  v.x := system.sin(omega)/n;
  v.y := system.cos(omega)/n*0.5;
end;

//MrOMGWTF

function TFlare.flare( const spos:vec2;const fpos:vec2;const clr:vec3 ):vec3;
var
  color:vec3;
  dd:vec2;

begin
	dd.x  := spos.x - fpos.x;
	dd.y  := spos.y - fpos.y;
	dd  := abs(dd);

	color  := clr * max(0.0, 0.025 / dd.y) * max(0.0, 1.1 -  dd.x);

	color  := color  + (clr * max(0.0, 0.05 / distance(spos, fpos       ))        )
                   + (clr * max(0.0, 0.1  / distance(spos, -fpos      )) * 0.15 )
                   + (clr * max(0.0, 0.13 - distance(spos, -fpos * 1.5)) * 1.50 )
                   + (clr * max(0.0, 0.07 - distance(spos, -fpos * 0.4)) * 2.00 );

	Exit( color );
end;

const
  vec2_222:Vec2=(x:2222;y:22);
function TFlare.noise( const pos:vec2 ):float;
begin
	Exit( fract(1111 * system.sin(111 * dot(pos, vec2_222))) );
end;


function TFlare.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  position :vec2;
  color :vec3;
begin
	position := ( gl_FragCoord.xy / resolution.xy * 2.0 ) - 1.0;
	position.x  := position.x  * (resolution.x / resolution.y);
	color  := flare(position, v ,vec3_1);

	Result  := TColor32( vec3( color * (0.95 + noise(position*0.001 + 0.0001) * 0.05) ) );
end;


initialization

Flare := TFlare.Create;
Shaders.Add('Flare', Flare);

finalization

FreeandNil(Flare);

end.

