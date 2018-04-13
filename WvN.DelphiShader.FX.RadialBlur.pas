unit WvN.DelphiShader.FX.RadialBlur;

interface

uses GR32, Types, WvN.DelphiShader.Shader, jpeg;

type
  TRadialBlur=class(TShader)
    constructor Create;override;
    function deform( const p:vec2 ):Vec3;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord:Vec2): TColor32;
  end;

var
  RadialBlur:TShader;

implementation

uses SysUtils, Math;

function TRadialBlur.deform( const p:vec2 ):Vec3;
var uv,q:vec2; r:TVecType;
begin
    q := vec2.create( System.sin(1.1*iGlobalTime+p.x),System.sin(1.2*iGlobalTime+p.y) );

//    a := atan(q.y,q.x);
    r := System.sqrt(dot(q,q));

    uv.x := System.sin(0.0+1.0*iGlobalTime)+p.x*System.sqrt(r*r+1.0);
    uv.y := System.sin(0.6+1.1*iGlobalTime)+p.y*System.sqrt(r*r+1.0);

    Result := texture2D(tex[0],uv*0.5).xyz;
    Result.b := Result.b / 2;
end;

constructor TRadialBlur.Create;
begin
  inherited;
  FrameProc := prepareFrame;
  PixelProc := RenderPixel;
end;

procedure TRadialBlur.PrepareFrame;
begin
end;

const vec2_black:vec2=(x:0;y:0);

function TRadialBlur.RenderPixel(var gl_FragCoord:Vec2): TColor32;
var
  p, s, d   : vec2;
  total, res: Vec3;
  w, r      : Double;
  I         : Integer;
begin
  p := -1 + 2 * gl_FragCoord / Resolution;
  s := p;

  total := vec3Black;
  d     := (vec2_black - p) / 20.0;
  w     := 1.0;
  for I := 0 to 19 do
  begin
    res   := deform(s);
    // res   := smoothstep(0.1, 1.0, res * res);
    total := total + w * res;
    w     := w * 0.99;
    s     := s + d;
  end;
  total  := total / 20.0;
  r      := 1.5 / (1.0 + dot(p, p));
  r   := r * 4;
  Result := TColor32(total * r - 1);
end;


initialization
  RadialBlur := TRadialBlur.Create;
  Shaders.Add('RadialBlur',RadialBlur);

finalization
  FreeandNil(RadialBlur);
end.
