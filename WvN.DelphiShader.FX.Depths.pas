unit WvN.DelphiShader.FX.Depths;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TDepths = class(TShader)
  const
    v3_123:vec3 = (x:1; y:2; z:3);
    v3_321:vec3 = (x:1; y:2; z:3);
    v4_1:vec4 = (x:0; y:57; z:113; w:170);
    v4_2:vec4 = (x:1; y:58; z:114; w:171);
  var
    sa,ca:array[0..1]of double;
    Pos:Vec3;
    v3_123_norm:vec3;
    Res:Double;
    Res2:Vec2;
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
    function tex(const x:vec3):float;
    function map(const p:Vec3):Float;
    function rot(const p:vec2;i:integer):vec2;
  end;

var
  Depths: TShader;

implementation

uses SysUtils, Math;

function TDepths.rot(const p:vec2;i:integer):vec2;
begin
	Result.x := p.x * ca[i] - p.y * sa[i];
  Result.y := p.x * sa[i] + p.y * ca[i];
end;

function TDepths.map(const p:Vec3):Float;
begin
	Result := system.cos(p.x) + system.cos(p.y);
	Result := max(Result, -(length(abs( &mod(p.yz, 6) ) - 3) - 1.0));
	Result := max(Result, -(length(abs( &mod(p.xz, 6) ) - 3) - 1.5));
end;

constructor TDepths.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
  v3_123_norm := v3_123;
  v3_123_norm.NormalizeSelf;

end;


function TDepths.tex(const x:vec3):float;
var p,f:Vec3;n,res:float;a,b:vec4;
begin
    p := floor(x);
    f := fract(x);
    f := f*f*(3-2*f);

    n := p.x + p.y*57 + 113*p.z;
    a := hash(n + v4_1);
    b := hash(n + v4_2);

    res := mix(mix(mix(a.x, b.x, f.x), mix(a.y, b.y, f.x), f.y),
               mix(mix(a.z, b.z, f.x), mix(a.w, b.w, f.x), f.y), f.z);
    Result := res*2-1;

end;

procedure TDepths.PrepareFrame;
begin
  Res := resolution.x / resolution.y;
  Res2 := vec2.create(res, 1.0);
	pos    := vec3.create(0, 0, time * 5.0);

  sa[0] := system.Sin(time * 0.1);
  ca[0] := system.Cos(time * 0.1);
  sa[1] := system.Sin(time * 0.2);
  ca[1] := system.Cos(time * 0.2);
end;


function TDepths.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var dir:vec3;t:float;
  I: Integer;
  inter, col:vec3;
begin
	dir    := normalize(vec3.create( (-1 + 2 * ( gl_FragCoord / resolution.xy )) * res2, 1.0));
	t      := 0.0;
	dir.xy := rot(dir.xy, 1);
	dir.zx := rot(dir.zx, 0);

  for I := 0 to 74 do
		t := t+map(pos + dir * t) * 0.98;

	inter := vec3(pos + dir * t);
	col   := mix(v3_123, v3_321, t * 0.1) * clamp(tex(inter*2)*20, -1,2);
  col   := clamp(col,0,1);
	col   := sqrt(col * 0.01) * (map(inter + v3_123_norm) * 3);
	result := Tcolor32((col + t * 0.02)*2);

end;

initialization
  Depths := TDepths.Create;
  Shaders.Add('Depths', Depths);
finalization
  FreeandNil(Depths);
end.




