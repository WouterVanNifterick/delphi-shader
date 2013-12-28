unit WvN.DelphiShader.FX.FlagUK;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TFlagUK = class(TShader)

  ripple  :float;
  rippleSpeed  :float;
  rippleSize  :float;

  function Main(var gl_FragCoord: Vec2): TColor32;
  constructor Create; override;
  procedure PrepareFrame;
end;

var
FlagUK: TShader;

implementation

uses SysUtils, Math;

constructor TFlagUK.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TFlagUK.PrepareFrame;
begin
 ripple   := 7.0;
 rippleSpeed   := 0.5;
 rippleSize   := 0.05;
end;


function TFlagUK.main;

var
  p :vec2;
  d :float;
  kRed :vec3;
  kBlue :vec3;

begin
	p  := ( gl_FragCoord.xy / resolution.xy ) * 2.0 - 1.0;
	p.y  := p.y  + (rippleSize * system.sin(ripple * (p.x + time * rippleSpeed)));
	d  := -p.x * Math.sign(p.y) + p.y * Math.sign(p.x);

	kRed  := vec3.Create( 204.0 / 255.0,0,0 );
	kBlue  := vec3.Create( 0.0,0.0,102.0 / 255.0 );

	if (abs(p.x) < (6.0/60.0))  or  (abs(p.y) < (6.0/30.0)) then
	begin
		Result := TColor32(kRed);
	end
	else
	if (abs(p.x) < (10.0/60.0))  or  (abs(p.y) < (10.0/30.0)) then
	begin
		Result  := clWhite32;
	end
	else
	if  (d > 0)   and  (d < 0.15) then
	begin
		Result := TColor32(kRed);
	end
	else
	if  (d > -0.15 * 3.0 / 2.0)   and  (d < 0.15 * 3.0 /2.0) then
	begin
		Result := clWhite32;
	end
	else
	begin
		Result := TColor32(kBlue);
	end;

end;


initialization

FlagUK := TFlagUK.Create;
Shaders.Add('FlagUK', FlagUK);

finalization

FreeandNil(FlagUK);

end.

