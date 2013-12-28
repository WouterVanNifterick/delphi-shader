unit WvN.DelphiShader.FX.Clod;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TClod = class(TShader)
  const
    vec3_1: vec3     = (x: 0.1; y: 0; z: 0);
    e_xyy: vec3 = (x: 0.1; y: 0; z: 0);
    e_yxy: vec3 = (x: 0; y: 0.1; z: 0.1);
    e_yyx: vec3 = (x: 0; y: 0; z: 0);
    vec3_2: vec3     = (x: 0.93; y: 0.94; z: 0.85);
    vec3_3: vec3     = (x: 0.79; y: 0.93; z: 0.4);
    vec3_4: vec3     = (x: 0.71; y: 0.85; z: 0.25);
    vec3_5: vec3     = (x: - 0.707; y: - 0.707; z: 0);
    vec3_6: vec3     = (x: 0.93; y: 0.94; z: 0.85);
    vec3_7: vec3     = (x: 1; y: 256; z: 65536);
    vec2_8: vec2     = (x: 512; y: 384);
    vec3_0_577: vec3 = (x: 0.577; y: 0.577; z: 0.577);

  var
    t: float;
    v: vec3;
    function f(const o: vec3): float;
    function s(const o, d: vec3): vec3;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  Clod: TShader;

implementation

uses SysUtils, Math;

constructor TClod.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TClod.PrepareFrame;
begin
  t := time + dot(vec3Gray, vec3_7) * 0.5;
  v := vec3.Create(system.sin(t * 1.5) * 0.5, system.cos(t) * 0.5, t);
end;

function TClod.f(const o: vec3): float;
var
  a     : float;
  v     : vec3;
  sa, ca: double;
begin
  a   := (system.sin(o.x) + o.y * 0.25) * 0.35;
  sa  := system.sin(a);
  ca  := system.cos(a);
  v.x := system.cos(ca * o.x - sa * o.y);
  v.y := system.cos(sa * o.x + ca * o.y);
  v.z := system.cos(o.z);
  Exit(dot(v * v, vec3White) - 1.2);
end;

function TClod.s(const o, d: vec3): vec3;
var
  t, a, b: float;
  i, j   : integer;
  e, p, n: vec3;
  tmp    : vec3;
begin
  t := 0;

  for i := 0 to 74 do
  begin
    if f(o + d * t) < 0 then
    begin
      a := t - 0.125;
      b := t;

      for j := 0 to 9 do
      begin
        t := (a + b) * 0.5;
        if f(o + d * t) < 0 then
          b := t
        else
          a := t;
      end;

      e := vec3_1;
      p := o + d * t;

      n.x := f(p + e);
      n.y := f(p + e_yxy);
      n.z := f(p + e_yyx);
      n := n + vec3((sin(p * 75))) * 0.01;
      n.NormalizeSelf;
      n := -n;


      if &mod(length(p.xy) * 20, 2) < 1 then
        tmp := vec3_4
      else
        tmp := vec3_3;

      Exit(mix(((max(-dot(n, vec3_0_577), 0) + 0.125 * max(-dot(n, vec3_5), 0))) * tmp, vec3_2, vec3(pow(t / 9, 5))));
    end;

    t := t + 0.125;
  end;
  Exit(vec3_6);
end;

function TClod.Main(var gl_FragCoord: vec2): TColor32;
var
  col:Vec3;
begin
  col := vec3.Create((gl_FragCoord.xy - Resolution) / Resolution, 1);
  col.NormalizeSelf;
  Result := TColor32(s(v, col));
end;

initialization

Clod := TClod.Create;
Shaders.Add('Clod', Clod);

finalization

FreeandNil(Clod);

end.
