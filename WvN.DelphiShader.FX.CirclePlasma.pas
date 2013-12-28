unit WvN.DelphiShader.FX.CirclePlasma;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TCirclePlasma = class(TShader)
const
  vec2_1:vec2=(x:12.9898;y:100.233);
var
  aspect :float;

  function Main(var gl_FragCoord: Vec2): TColor32;
  constructor Create; override;
  procedure PrepareFrame;
end;

var
CirclePlasma: TShader;

implementation

uses SysUtils, Math;

constructor TCirclePlasma.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TCirclePlasma.PrepareFrame;
begin
	aspect  := Resolution.x / Resolution.y;
end;

function TCirclePlasma.main;

var
  pos :vec2;
  t :float;
  ht: Float;
  lp:double;
  col:vec3;
begin
	pos := gl_FragCoord.xy / Resolution;
	t  := &mod(fract(system.sin(dot(pos + time, vec2_1)) * 43758.5453), 1) * 0.1;
  lp := length(pos - (mouse.XY));
	t  := t  + (0.8 * (1 - (lp * 8)));
  t  := t  * (1.8 * (1 - (lp * (2+system.sin(time)*2)))) * 4;
  ht := system.sin(t*0.5);

  col.x := ht+system.cos(t/5.76+14.5)*0.5+0.5;
  col.y := ht+system.cos(t/4.76+14.5)*0.5+0.4;
  col.z := ht+system.cos(t/3.76+14.5)*0.5+0.3;

	Result :=TColor32( col );
end;


initialization

CirclePlasma := TCirclePlasma.Create;
Shaders.Add('CirclePlasma', CirclePlasma);

finalization

FreeandNil(CirclePlasma);

end.
