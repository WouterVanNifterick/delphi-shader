unit WvN.DelphiShader.FX.ColorSpiral;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TColorSpiral = class(TShader)
  const
    PI           = 3.1415927;
    PI2          = (PI * 2.0);
    IBALLRAD     = (1.0 / 0.5);
    vec3_4: vec3 = (x: 0; y: 0; z: 0);
    vec3_5: vec3 = (x: - 0; y: - 1; z: 1);
    vec3_6: vec3 = (x: 10; y: 1000; z: 100000);
    vec3_7: vec3 = (x: 0; y: 0; z: 1);
    vec3_8: vec3 = (x: 1; y: 1; z: 1);
  var
    fix :float;
    constructor Create; override;
    procedure PrepareFrame;
    function main(var gl_FragCoord: vec2): TColor32;
  end;

var
  ColorSpiral: TShader;

implementation

uses SysUtils, Math;

constructor TColorSpiral.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := main;
end;

procedure TColorSpiral.PrepareFrame;
begin
  fix      := -time * 1.3;
end;

function TColorSpiral.main(var gl_FragCoord: vec2): TColor32;
var
  position                      : vec2;
  adjust1, r,  a, d: float;
  n                             : int;
  dd, da                        : float;
  norm                          : vec3;
  pos, len                      : float;
  color, lightdir               : vec3;
  rand                          : float;
  halfv                         : vec3;
  spec                          : float;
begin
  position := (2 * gl_FragCoord.xy - resolution) / resolution.xx;
//  adjust1  := mouse.x * 100;
  adjust1  := 50;
  position := position * adjust1;
  r        := length(position);
  a        := atan(position.y, position.x) + PI;
  d        := r - a + PI2;
  n        := trunc(d / PI2);
  d        := d - n * PI2;
  da       := a + n * PI2;
  pos      := da * da * 0.07 + fix;
  norm.x   := (fract(pos) * 0.5) * IBALLRAD;
  norm.y   := (d / PI2 - 0.5) * IBALLRAD;

  len      := length(norm.xy);
  color    := vec3_4;
  if len <= 1 then
  begin
    norm.z    := System.sqrt(1 - len * len);
    lightdir  := normalize(vec3_5);
    dd        := dot(lightdir, norm);
    dd        := max(dd, 0.1);
    rand      := sinLarge(floor(pos));
    color.rgb := dd * fract(rand * vec3_6);
    halfv     := normalize(lightdir + vec3_7);
    spec      := dot(halfv, norm);
    spec      := Math.max(spec, 0);
    spec      := power(spec, 40);
    color     := color + (spec * vec3_8);
  end;
  Result := TColor32(color);
end;

initialization

ColorSpiral := TColorSpiral.Create;
Shaders.Add('ColorSpiral', ColorSpiral);

finalization

FreeandNil(ColorSpiral);

end.
