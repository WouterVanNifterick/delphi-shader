unit WvN.DelphiShader.FX.InputMouse;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TInputMouse = class(TShader)
const
  vec3_1:vec3=(x:0;y:0;z:0);
  vec3_2:vec3=(x:1;y:1;z:0);
  vec3_3:vec3=(x:1;y:0;z:0);
  vec3_4:vec3=(x:0;y:0;z:1);

  function distanceToSegment( const a, b, p :vec2 ):float;
  function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
  InputMouse: TShader;

implementation

uses SysUtils, Math;

constructor TInputMouse.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TInputMouse.PrepareFrame;
begin
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

end;

function TInputMouse.distanceToSegment( const a, b, p :vec2 ):float;
var
  pa :vec2;
  ba :vec2;
  h :float;
  dbb:double;
begin
	pa  := p - a;
	ba  := b - a;
  dbb := dot(ba,ba);
  if IsZero(dbb) then
    h:=0
  else
  	h  := clamp( dot(pa,ba)/dbb, 0, 1 );
	Exit( length( pa - ba*h ) );
end;


function TInputMouse.Main(var gl_FragCoord: Vec2): TColor32;
var
  p :vec2;
  m :vec4;
  col :vec3;
  d :float;

begin
	p  := gl_FragCoord.xy / resolution.xx;
    m  := iMouse / resolution.x;

	col  := vec3_1;

	if  m.z>0  then
	begin
		d  := distanceToSegment( m.xy, m.zw, p );
        col  := mix( col, vec3_2, 1-smoothstep(0.005,0.006, d) );
	end;


	col  := mix( col, vec3_3, 1-smoothstep(0.03,0.04, length(p-m.xy)) );
    col  := mix( col, vec3_4, 1-smoothstep(0.03,0.04, length(p-abs(m.zw))) );

	Result := TColor32( col );
end;


initialization

InputMouse := TInputMouse.Create;
Shaders.Add('InputMouse', InputMouse);

finalization

FreeandNil(InputMouse);

end.

