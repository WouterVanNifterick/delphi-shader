unit WvN.DelphiShader.FX._Empty;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TEmpty = class(TShader)
    constructor Create; override;
    procedure PrepareFrame;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;
  end;

var
  Empty: TShader;

implementation

uses SysUtils, Math;

constructor TEmpty.Create;
begin
  inherited;
  Image.FrameProc := PrepareFrame;
  Image.PixelProc := RenderPixel;
  SetLength(Buffers,0);
end;

procedure TEmpty.PrepareFrame;
begin
end;

function TEmpty.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
//  x:double;
  v:vec3;
  i:integer;
//  j :integer;

begin
  v:=vec3Gray;
//  j:=0;
  for I := 0 to 500 do
  begin
    v := Clamp(vec3GRay,0,1);
//    v.x := Math.min(Math.max(vec3GRay.x, 0), 1);
//    v.y := Math.min(Math.max(vec3GRay.y, 0), 1);
//    v.z := Math.min(Math.max(vec3GRay.z, 0), 1);
//    if Vec3Gray.x<0 then v.x := 0 else if Vec3Gray.x>1 then v.x := 1 else v.x := Vec3GRay.x;
//    if Vec3Gray.y<0 then v.y := 0 else if Vec3Gray.y>1 then v.y := 1 else v.y := Vec3GRay.y;
//    if Vec3Gray.z<0 then v.z := 0 else if Vec3Gray.z>1 then v.z := 1 else v.z := Vec3GRay.z;

//     v := Vec3GRay;
//     if v.x<0 then v.x := 0 else if v.x>1 then v.x := 1;
//     if v.y<0 then v.y := 0 else if v.y>1 then v.y := 1;
//     if v.z<0 then v.z := 0 else if v.z>1 then v.z := 1;
  end;

//    inc(j);
//    v := vec3GRay;
//    x := v.Length;
//  x := length(v);

  Result := TColor32(v)
end;

initialization

Empty := TEmpty.Create;
Shaders.Add('Empty', Empty);

finalization

FreeandNil(Empty);

end.
