unit WvN.DelphiShader.FX.TwoTweets;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TTwoTweets = class(TShader)
    function f(const p: vec3): float; inline;
    function Main(var gl_FragCoord: Vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;

  const
    vec3_1: vec3 = (x: 0.2; y: 0.12; z: 0.01);
    vec3_2: vec3 = (x: 0; y: 0.1; z: 0.2);
  var
    st:double;

  end;

var
  TwoTweets: TShader;

implementation

uses SysUtils, Math;

constructor TTwoTweets.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TTwoTweets.PrepareFrame;
begin
  st := sinLarge( iGlobalTime );
end;

// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

function TTwoTweets.f(const p: vec3): float;
var
  r: vec3;
begin
  r.x := sin(p.x);
  r.y := sin(p.y);
  r.z := sinLarge(p.z+ iGlobalTime);

  Result := length(
              0.05 * system.cos(9 * p.y * p.x) +
              r - 0.10 * cosLarge(9 * (p.z + 0.3 * p.x - p.y))) - 1;
end;

function TTwoTweets.Main(var gl_FragCoord: Vec2): TColor32;
var
  t:float;
  d,o: vec3;
  i: integer;
begin
  d.x := 0.5 - gl_FragCoord.x / resolution.x;
  d.y := 0.5 - gl_FragCoord.y / resolution.y; // y?
  d.z := 0.5;
  o   := d;

  for i := 0 to 98 do
  begin
    t := f(o);
    o.x := o.x + t * d.x;
    o.y := o.y + t * d.y;
    o.z := o.z + t * d.z;
  end;

  Result := TColor32(
    abs(
      f(o - d) * vec3_2 +
      f(o - 0.6) * vec3_1
    ) *
    (10 - o.z)
  );
end;

initialization

TwoTweets := TTwoTweets.Create;
Shaders.Add('TwoTweets', TwoTweets);

finalization

FreeandNil(TwoTweets);

end.
