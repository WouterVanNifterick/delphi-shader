unit WvN.DelphiShader.FX.Flying;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TFlying = class(TShader)
  public
  const
    k: vec3 = (x:0.4; y: - 0.2; z:0.9);
    constructor Create; override;
    procedure PrepareFrame;
    function m(p:vec3): vec3;
    function RenderPixel(var p:Vec2):TColor32;
  end;

var
  Flying: TShader;

implementation

uses SysUtils, Math;

constructor TFlying.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
end;

procedure TFlying.PrepareFrame;
begin
end;

function TFlying.m(p:vec3): vec3;
var
  i: int;
begin
  p     := p - (iGlobalTime);
  for i := 0 to 15 do
    p   := reflect(abs(p) - 9, k);
  Result := p * 0.5;
end;

function TFlying.RenderPixel(var p:Vec2):TColor32;
var
  d, o: vec3;
  i      : int;
begin
  exit(clRed32);
  d     := vec3.Create(p,1) / Resolution.xyy^;
  o     := d;
  for i := 0 to 98 do
    o := o + (d * m(o).x);

  Result := TColor32(texture2D(tex[0], m(o).yz) * (0.5 + 99 * m(o - k * 0.02).x) * exp(o.y * o.z * o.z * o.z * 0.04));
end;

initialization

  Flying := TFlying.Create;
  Shaders.Add('Flying', Flying);

finalization

  FreeandNil(Flying);

end.
