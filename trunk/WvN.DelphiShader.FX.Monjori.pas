unit WvN.DelphiShader.FX.Monjori;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TMonjori = class(TShader)
  var
    a:Float;
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
end;

procedure TMonjori.PrepareFrame;
begin
  a := time * 40;
end;

function TMonjori.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  p                              : Vec2;
  d, e, f, h, i,  r, q: Float;
const g=1/40;
begin
  p := -1.0 + 2.0 * gl_FragCoord.xy / resolution.xy;
  e := 4*resolution.x * (p.x * 0.5 + 0.5);
  f := 4*resolution.y * (p.y * 0.5 + 0.5);
  i := 200 + System.sin(e * g + a / 150) * 20;
  d := 200 + System.cos(f * g / 2) * 18 + System.cos(e * g) * 7;
  r := System.sqrt(pow(i - e, 2) + pow(d - f, 2));
  q := f / r;
  e := (r * System.cos(q)) - a * 0.5;
  f := (r * System.sin(q)) - a * 0.5;
  d := System.sin(e * g) * 176 + System.sin(e * g) * 164 + r;
  h := ((f + d) + a / 2) * g;
  i := System.cos(h + r * p.x / 1.3) * (e + e + a) + System.cos(q * g * 6) * (r + h / 3);
  h := System.sin(f * g) * 144 - System.sin(e * g) * 212 * p.x;
  h := (h + (f - e) * q + System.sin(r - (a + h) / 7.0) * 10 + i / 4) * g;
  i := i + (System.cos(h * 2.3 * System.sin(a / 350 - q)) * 184 *
            System.sin(q - (r * 4.3 + a / 12) * g) +
            tan(r * g + h) * 184 *
            System.cos(r * g + h));
  i := &mod(i / 5.6, 256) / 64.0;

  if i < 0.0 then
    i := i + (4.0);

  if i >= 2 then
    i := 4 - i;

  d := r / 350;
  d := d + (System.sin(d * d * 8.0) * 0.52);
  f := (System.sin(a * g) + 1.0) / 2.0;

  Result := TColor32(Vec3.Create(f * i / 1.6, i / 2.0 + d / 13.0, i) * d * p.x + Vec3.Create(i / 1.3 + d / 8.0, i / 2.0 + d / 18.0, i) * d * (1.0 - p.x));
end;

initialization

Monjori := TMonjori.Create;
Shaders.Add('Monjori', Monjori);

finalization

FreeandNil(Monjori);

end.
