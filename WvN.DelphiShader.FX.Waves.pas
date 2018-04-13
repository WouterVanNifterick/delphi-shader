unit WvN.DelphiShader.FX.Waves;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TWaves = class(TShader)
  const
    tscale = 1.0; // How fast it animates
    function wave( const position:vec2;freq:float;height:float;speed:float ):float;
    function combo( const position:vec2;center:float;size:float ):vec3;
    function Main(var gl_FragCoord: Vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Waves: TShader;

implementation

uses SysUtils, Math;

constructor TWaves.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TWaves.PrepareFrame;
begin
end;

// http://glsl.heroku.com/e#1220.2


function TWaves.wave( const position:vec2;freq:float;height:float;speed:float ):float;
begin
	result  := sinLarge(position.x*freq - time*tscale*speed);
	result  := result * 0.8 * 5.0 - 1.0;
	result  := result  * (height);
end;


function TWaves.combo( const position:vec2; center:float; size:float ):vec3;
var
  offset :float;
  lum   :float;
begin
	offset  := pi * (center * 8.9);
	lum     := System.abs(tan(position.y * pi + offset)) - pi / 100.9;
	lum     := lum  * (size);

  Result.r := lum + wave(position, 10.0, 0.9*size,  1.008);
	Result.g := lum + wave(position, 10.5, 0.5*size, -0.023);
	Result.b := lum + wave(position, 10.5, 0.2*size,  1.042);
end;


function TWaves.main;
var
  position :vec2;
  c :vec3;
begin
	// normalize position
	position  := gl_FragCoord.xy / resolution.xy;

	c  := vec3Black;
	c  := c  + combo(position, 0.10+0.05*sinLarge(0.60*time + 4.0*position.x), 0.05);
	c  := c  + combo(position, 0.50+0.05*sinLarge(0.90*time + 2.0*position.x), 0.25);
	c  := c  + combo(position, 0.85+0.05*sinLarge(0.42*time + 1.3*position.x), 0.05);
 // c  := c  + combo(position, 0.02+0.05*sin(0.012*time + 6.3*position.y), -0.5);

	Result := TColor32(c);

end;


initialization

Waves := TWaves.Create;
Shaders.Add('Waves', Waves);

finalization

FreeandNil(Waves);

end.

