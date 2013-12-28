unit WvN.DelphiShader.FX.Flower;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TFlower = class(TShader)
function u( const x :float ):float;
function Main(var gl_FragCoord: Vec2): TColor32;

  constructor Create; override;
  procedure PrepareFrame;
end;

var
Flower: TShader;

implementation

uses SysUtils, Math;

constructor TFlower.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TFlower.PrepareFrame;
begin
end;

//float u( float x ) begin  return 0.5+0.5*sign(x); end;

function TFlower.u( const x :float ):float;
begin
  if x>0 then
    Result := 1
  else
    Result := 0
end;

//float u( float x ) begin  return abs(x)/x; end;


function TFlower.main;
var
  p :vec2;
  a :float;
  r :float;
  w :float;
  h :float;
  d :float;
  col :float;
  n : float;
begin
    p  := (2.0*gl_FragCoord.xy-resolution)/resolution.y;

    a  := atan(p.x,p.y);
    r  := length(p)*0.75;

    w  := system.cos(3.1415927*time-r*2.0);
    h  := 0.5+0.5*system.cos(12.0*a-w*7.0+r*8.0);
    d  := 0.25+0.75*pow(h,1.0*r)*(0.7+0.3*w);

    n := 1.0-r/d;

    if n<=0 then
      col := 0
    else
      col  := u( d-r ) * system.sqrt(n)*r*2.5;
    col  := col  * (1.25+0.25*system.cos((12.0*a-w*7.0+r*8.0)/2.0));
    col  := col  * (1.0 - 0.35*(0.5+0.5*system.sin(r*30.0))*(0.5+0.5*system.cos(12.0*a-w*7.0+r*8.0)));
    Result  := TColor32(vec3.Create(        col,col-h*0.5+r*0.2 + 0.35*h*(1.0-r),col-h*r + 0.1*h*(1.0-r)));
end;


initialization

Flower := TFlower.Create;
Shaders.Add('Flower', Flower);

finalization

FreeandNil(Flower);

end.

