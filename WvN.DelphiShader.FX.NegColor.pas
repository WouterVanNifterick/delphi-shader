unit WvN.DelphiShader.FX.NegColor;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
TNegColor = class(TShader)
  a,b,res :Double;

  pos :vec3;
  constructor Create; override;
  procedure PrepareFrame;
  function RenderPixel(var gl_FragCoord: Vec2): TColor32;
end;

var
NegColor: TShader;

implementation

uses SysUtils, Math;

constructor TNegColor.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

function bf( const p:vec2;const r:float ):float;
begin
  Result := length(abs(&mod(p, 10.0)) - 5.0) - r;
end;

function rot( const p:vec2;const a:float ):vec2;
var sa,ca:double;
begin
  sa := system.sin(a);
  ca := system.cos(a);
  Result.x := p.x * ca - p.y * sa;
  Result.y := p.x * sa + p.y * ca;
end;

const
  vec3_3:Vec3=(x:3;y:3;z:3);
  vec3_123:Vec3=(x:1;y:2;z:3);
  vec3_010:Vec3=(x:0;y:1;z:0);
  vec3_8_11_9:Vec3=(x:8;y:11;z:9);


function map( const p:vec3 ):float;
var k :float;
begin
	k  := 5 - dot(abs(p), vec3_010) + (cosLarge(p.z) + cosLarge(p.x)) * 0.4;
	Result := max(max(k, -bf(p.xz, 4.0)), -bf(p.zy, 3.5));
end;

procedure TNegColor.PrepareFrame;
begin
	a  := -iGlobalTime * 0.1;
  b := sinLarge(a * 4.0);
	pos  := Vec3.Create(
            iGlobalTime * 4.0,
            0,
            iGlobalTime * 7.0);
  res := Resolution.x / Resolution.y;

end;

function TNegColor.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var dir :vec3; npos :vec3; t  :float; col :vec3; i:integer;
begin
	dir  := Vec3.Create(
             Vec2.Create(res,1) * (-1 + 2 * (gl_FragCoord.xy / Resolution.xy )),
             1.0);
  dir.NormalizeSelf;

	dir.xz  := rot(dir.xz, b);
	dir.xy  := rot(dir.xy, -a);
	npos  := pos;
	t   := 0.0;
	for i  :=  0  to  75-1 do
  begin
		npos  := pos + dir * t;
		t  := t  + map(npos);
	end;

	col  := 0.1 * mix(vec3_123, vec3_123.yzx, t * 0.7) * map(npos * vec3_8_11_9) * 2.0;
	//col  := clamp(col,0,1);
	Result := TColor32( (1.5-abs(sqrts(vec3_3 - col) + t * 0.05 )) );
end;


initialization

NegColor := TNegColor.Create;
Shaders.Add('NegColor', NegColor);

finalization

FreeandNil(NegColor);

end.

