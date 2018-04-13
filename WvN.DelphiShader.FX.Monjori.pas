unit WvN.DelphiShader.FX.Monjori;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TMonjori = class(TShader)
  const
    g = 1 / 40;
    eg = (1 / 40)*(1 / 40);
    fg = (1 / 40)*(1 / 40);
  var
    ry6i,zz,a,i1,c1,d1,ry1,rx1,seg,ceg,sfg,rx7,ry7: Float;
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  Monjori: TShader;

implementation

uses SysUtils, Math;

constructor TMonjori.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
  seg := sin(eg);
  ceg := cos(eg);
  sfg := sin(fg);
  c1 := cos(fg / 2) * 18 + ceg * 7;
end;

procedure TMonjori.PrepareFrame;
begin
  a := time * 40;
  i1 := resolution.y + sinLarge(eg + a / (resolution.x * 0.3)) * 20;
  d1 := seg * (resolution.x * 0.4) + seg * (resolution.y * 0.4);
  rx1 := resolution.x * 0.5;
  ry1 := resolution.y * 0.5;
  rx7 := resolution.x * 0.7;
  ry7 := resolution.y * 0.7;
  ry6i := 1/(resolution.y * 0.6);
  zz := (sinLarge(a * g) + 1) / 2;
end;

function TMonjori.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  p                     : Vec2;
  d, e, f, h, i, r, q: Float;
begin
  p := 0.5+ 1 * (gl_FragCoord.xy / resolution.xy);
  e := resolution.x * (p.x * 0.5 + 0.5);
  f := resolution.x * (p.y * 0.5 + 0.5);
  i := i1;
  d := resolution.y + c1;
  r := system.sqrt(pow(i - e, 2) + pow(d - f, 2));
  q := f / r;
  e := (r * cos(q)) - a * 0.5;
  f := (r * sin(q)) - a * 0.5;
  d := d1 + r;
  h := ((f + d) + a / 2) * g;
  i := cos(h + r * p.x / 1.3) * (e + e + a) + cos(q * g * 6) * (r + h / 3);
  h := sfg * ry1 - seg * rx1 * p.x;
  h := (h + (f - e) * q + sin(r - (a + h) / 7) * 10 + i / 4) * g;
  i := i + (cos(h * 2.3 * sin(a / rx7 - q)) * (resolution.y * 0.7) * sin(q - (r * 4.3 + a / 12) * g) + tan(r * g + h) * ry7 * cos(r * g + h));
  i := fmod(i / 5.6, 256) / 64;

  if i < 0 then
    i := i + 4;
  if i >= 2 then
    i := 4 - i;

  d := r * ry6i ;
  d := d + (sin(d * d * 8) * 0.52);
  f := zz;

  Result := TColor32(
    Vec3.Create(
        f * i / 1.6,
        i / 2 + d / 13,
        i)
    * d
    * p.x
    + Vec3.Create(
        i / 1.3 + d / 8,
        i / 2 + d / 18,
        i) * d * (1 - p.x));
end;

initialization

Monjori := TMonjori.Create;
Shaders.Add('Monjori', Monjori);

finalization

FreeandNil(Monjori);

end.
