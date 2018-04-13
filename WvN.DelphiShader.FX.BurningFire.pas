unit WvN.DelphiShader.FX.BurningFire;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  // http://glslsandbox.com/e#21919.27

  // Procedural Burning Fire
  // By Brandon Fogerty
  // bfogerty at gmail dot com
  // Special Thanks Inigo Quilez

  TBurningFire = class(TShader)
  const
    FlameSpeed   = 0.9;
    ColorScale   = 0.45;
    vec3_5: vec3 = (x: 1; y: 57; z: 113);

  var
    Ratio:double;
    v, Color0, Color1, Color2, Color3, Color4, Color5: vec3;
    TheTime                                          : Double;
    constructor Create; override;
    procedure PrepareFrame;
    function noise(const uv: vec2): float;
    function perlinNoise(const uv: vec2): float;
    function fBm(uv: vec2): float;
    function blendColor(const uv: vec2; const Color0, Color1: vec3; scalar, minLimit, maxLimit, aRange: float): vec3;
    function main(var gl_FragCoord: vec2): TColor32;
  end;

var
  BurningFire: TShader;

implementation

uses SysUtils, Math;

constructor TBurningFire.Create;
begin
  inherited;
  UseBackBuffer := True;
  SetBufferCount(1);
  Image.FrameProc := PrepareFrame;
  Image.PixelProc := main;

  Color0  := vec3.Create(0.1, 0.1, 0.3) * ColorScale;
  Color1  := vec3.Create(0.7, 0.4, 0.2) * ColorScale;
  Color2  := vec3.Create(0.4, 0.15, 0.15) * ColorScale;
  Color3  := vec3.Create(0.2, 0.15, 0.15) * ColorScale;
  Color4  := vec3.Create(0.15, 0.15, 0.15) * ColorScale;
  Color5  := vec3.Create(0.10, 0.10, 0.10) * ColorScale;
end;

procedure TBurningFire.PrepareFrame;
begin
  TheTime := time * FlameSpeed;
  Ratio :=Resolution.x / Resolution.y;
end;

function hash(x: float): float;{inline;}
begin
//  {$EXCESSPRECISION OFF}
  Result := Fract(system.sin(x) * 43758.5453);
end;

function TBurningFire.noise(const uv: vec2): float;
var
  x, p, f: vec3;
  n : double;
begin
  // x := vec3.Create(uv.xy, 0);
  x.x := uv.x;
  x.y := uv.y;
  x.z := 0;

  // p := floor(x);
  p.x := floor(x.x);
  p.y := floor(x.y);
  p.z := floor(x.z);

  //f := fract(x);
  f.x := fract(x.x);
  f.y := fract(x.y);
  f.z := fract(x.z);

//  f := f * f * (3 - 2 * f);
  f.x := f.x * f.x * (3 - 2 * f.x);
  f.y := f.y * f.y * (3 - 2 * f.y);
  f.z := f.z * f.z * (3 - 2 * f.z);

  n := dot(p, vec3_5);

  // wtf...the code below calls hash, which calls sin() with huge values.
  // in x64, the larger X is for sin(X), the slow it is.
  // this resulted in an extreme slowdown.

  // for smaller sin values you can do {$EXCESSPRECISION OFF}, but in this case
  // that would result in a wrong image.

  // so, let's just cut off n like this:
  n := math.fmod(n,1000);

  Exit(mix(mix(mix(
                hash(n + 0),
                hash(n + 1), f.x),
            mix(hash(n + 57),
                hash(n + 58), f.x), f.y), mix(mix(
                hash(n + 113),
                hash(n + 114), f.x), mix(
                hash(n + 170),
                hash(n + 171), f.x), f.y), f.z));
end;

function TBurningFire.perlinNoise(const uv: vec2): float;
var
  uv1, uv2, uv3, uv4: vec2;
  n                 : float;
begin
  uv1 := uv + vec2.Create(0, -TheTime * 0.1);
  uv2 := uv + vec2.Create(system.cos(-TheTime) * 7, -TheTime * 0.3);
  uv3 := uv + vec2.Create(0, -TheTime * 0.4);
  uv4 := uv + vec2.Create(system.sin(-TheTime * 2), -TheTime * 0.2);

  n   := noise(uv1 * 1) * 128 +
         noise(uv1 * 2) * 64 +
         noise(uv1 * 4) * 32 +
         noise(uv  * 8) * 16 +
         noise(uv  * 16) * 8 +
         noise(uv4 * 32) * 4 +
         noise(uv4 * 64) * 2 +
         noise(uv  * 128) * 1;

  Exit(n / (1 + 2 + 4 + 8 + 16 + 32 + 64 + 128));
end;

function TBurningFire.fBm(uv: vec2): float;
var
  mag, freq: float;
  i        : int;
begin
  mag    := 0;
  freq   := 1;

  for i  := 0 to 5 do
  begin
    uv   := uv + vec2.Create(0, -TheTime * 2);
    mag  := mag + (System.abs(perlinNoise(uv * freq) - 0.5) * 2 / freq);
    freq := freq * 0.80;
  end;
  Result := mag;
end;

function TBurningFire.blendColor(
  const uv: vec2;
  const Color0, Color1: vec3;
        scalar, minLimit, maxLimit, aRange: float): vec3;
var
  t: float;
begin
  if (uv.y < minLimit) or (uv.y >= maxLimit) then
    Exit(Vec3Black);

  t := (uv.y - minLimit) * aRange;
  Exit(mix(Color0 * scalar, Color1 * scalar, t));
end;

function TBurningFire.main(var gl_FragCoord: vec2): TColor32;
var
  uv        : vec2;
  c         : float;
  finalColor: vec3;
begin
  uv         := gl_FragCoord.xy / Resolution.xy;
  uv.x       := uv.x * Ratio;

  c          := fBm(uv * 5);

  finalColor :=    (
                   blendColor(uv, Color0, Color1, c, 0.00, 0.30,1/(0.30-0.00))
                 + blendColor(uv, Color1, Color2, c, 0.30, 0.70,1/(0.70-0.30))
                 + blendColor(uv, Color2, Color3, c, 0.70, 0.80,1/(0.80-0.70))
                 + blendColor(uv, Color3, Color4, c, 0.80, 0.95,1/(0.95-0.80))
                 + blendColor(uv, Color4, Color5, c, 0.95, 1.00,1/(1.00-0.95))
                    )
                 *  pow(c, 1.3);

  Result     := TColor32(finalColor);
end;

initialization

BurningFire := TBurningFire.Create;
Shaders.Add('BurningFire', BurningFire);

finalization

FreeandNil(BurningFire);

end.
