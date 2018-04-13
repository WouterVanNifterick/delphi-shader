unit WvN.DelphiShader.FX.NoiseBlur;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TNoiseBlur = class(TShader)
  const
    v3_1:vec3=(x:0.6; y:0.7; z:0.7);
    v3_2:vec3=(x:1.0; y:0.95;z: 0.9);
    v2:vec2=(x:0.707;y:0.707);

  var st:double;
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

function noise(const x: Vec2): float;
var
  p: Vec2;
  f: Vec2;
  n: float;
begin
  p      := floor(x);
  f      := fract(x);
  f      := f * f * (3 - 2 * f);
  n      := p.x + p.y * 57;
  Result := mix(mix(hash(n     ),
                    hash(n +  1), f.x),
                mix(hash(n + 57),
                    hash(n + 58), f.x), f.y);
end;

procedure TNoiseBlur.PrepareFrame;
begin
  st := sinLarge(0.1 * iGlobalTime);
end;

function TNoiseBlur.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  p  : Vec2;
  uv : Vec2;
  acc: float;
  col: vec3;
  dir: Vec2;
  h  : float;
  w  : float;
  ttt: vec3;
//  gg :float;
//  nor: vec3;
  di : Vec2;
  i  : Integer;
  a: float;
  g:float;
  function map(aP: Vec2): Vec2;
  begin
    ap.x := ap.x + (0.1 * sinLarge(iGlobalTime + 2.0 * ap.y));
    ap.y := ap.y + (0.1 * sinLarge(iGlobalTime + 2.0 * ap.x));

    a   := Noise(ap * 1.5 + st) * 6.2831 - g;
    Result.x := cosLarge(a);
    Result.y := sinLarge(a);
  end;

begin
  p     := gl_FragCoord.xy / Resolution.xy;
  uv    := -1 + 2 * p;
  uv.x  := uv.x * (Resolution.x / Resolution.y);

  acc   := 0;
  col   := vec3Black;
  g     := iGlobalTime + gl_FragCoord.x / Resolution.x;
  for i := 0 to 31 do
  begin
    dir := map(uv);

    h   := i / 32;
    w   := 4 * h * (1 - h);

    ttt := w * texture2D(tex[1], uv).xyz
             * (mix(
                    v3_1,
                    v3_1,
                    0.5 - 0.5 * dot(reflect(vec3.Create(dir, 0), vec3Red ).xy, v2))
                );
    col := col + w * ttt;
    acc := acc + w;
    uv  := uv  + 0.008 * dir;
  end;

  col := col / acc;
//  gg  := dot( col, vec3(0.333) );
//  nor  := normalize( Vec3.Create( dFdx(gg),0.5,dFdy(gg) ) );
//  col    := col + (vec3(0.4) * dot(nor, vec3.Create(0.7, 0.01, 0.7)));

  di     := map(uv);
  col    := col * (0.65 + 0.35 * dot(di, v2))
                * (0.20 + 0.80 * power(4 * p.x * (1 - p.x), 0.1))
                * 1.7;

  Result := TColor32(col);
end;

initialization

NoiseBlur := TNoiseBlur.Create;
Shaders.Add('NoiseBlur', NoiseBlur);

finalization

FreeandNil(NoiseBlur);

end.
