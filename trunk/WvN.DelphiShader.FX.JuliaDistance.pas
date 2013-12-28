unit WvN.DelphiShader.FX.JuliaDistance;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

const
  NumSamples   = 1;
  iSamples     = 1 / NumSamples;
  vec2_1: vec2 = (x: 0.2655; y: 0.301);
  vec2_2: vec2 = (x: - 0.745; y: 0.186);
  vec2_3: vec2 = (x: 1.0; y: 0.0);
  vec3_4: vec3 = (x: 1.0; y: 1.1; z: 1.4);
  vec3_5: vec3 = (x: 1.0; y: 0.98; z: 0.95);

type
  TJuliaDistance = class(TShader)
    ff:array[0..pred(NumSamples)] of vec2;
    function calc(p: vec2; time: float): float;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  JuliaDistance: TShader;

implementation

uses SysUtils, Math;

constructor TJuliaDistance.Create;
var i : integer;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;

  for i := 0 to NumSamples-1 do
  begin
    ff[i] := vec2.Create(system.cos(6.3 * (i/NumSamples)),
                         system.sin(15 * (i/NumSamples)));
    ff[i] := ff[i] * 0.5;
    ff[i] := ff[i] + 0.5;
  end;
end;

procedure TJuliaDistance.PrepareFrame;
begin
end;

function TJuliaDistance.calc(p: vec2; time: float): float;
var
  ltime     : float;
  zoom      : float;
  an        : float;
  ce        : vec2;
  c         : vec2;
  z         : vec2;
  dz        : vec2;
  t         : float;
  i         : integer; // loop variable
  d         : float;
begin
  p   := -1.0 + 2.0 * p;
  p.x := p.x * (resolution.x / resolution.y);

  ltime := 0.5 - 0.5 * system.cos(time * 0.12);
  zoom  := pow(0.9, 100.0 * ltime);
  an    := 2.0 * ltime;
  p     := mat2.Create(system.cos(an), system.sin(an), -system.sin(an), system.cos(an)) * p;
  ce    := vec2_1;
  ce    := ce + (zoom * 0.8 * system.cos(4.0 + 4.0 * ltime));
  p     := ce + (p - ce) * zoom;
  c     := vec2_2 - 0.045 * zoom * (1.0 - ltime);

  z  := p;
  dz := vec2_3;
  t  := 0.0;

  for i := 0 to 99 do
    if dot(z, z) < 50.0 then
    begin
      dz := 2.0 * vec2.Create(z.x * dz.x - z.y * dz.y, z.x * dz.y + z.y * dz.x);
      z  := vec2.Create(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
      t  := t + (1.0);
    end;

  d := system.sqrt(dot(z, z) / dot(dz, dz)) * log(dot(z, z));

  Exit(pow(clamp((200.0 / zoom) * d, 0.0, 1.0), 0.5));
end;

function TJuliaDistance.Main(var gl_FragCoord: vec2): TColor32;
var
  scol    : float;
  h       : float;
  i       : integer;
  vcol    : vec3;
  uv      : vec2;
  _of     : vec2;
begin
  // Created by inigo quilez - iq/2013
  // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


  // learn more here: // http://www.iquilezles.org/www/articles/distancefractals/distancefractals.htm

  // scol  := calc( gl_FragCoord.xy/resolution.xy, iGlobalTime );
  scol     := 0.0;
  h        := 0.0;

  for i := 0 to NumSamples-1 do
  begin
    h    := i * iSamples;
    _of  := ff[i];
    scol := scol + (calc((gl_FragCoord.xy + ff[i]) / resolution.xy, iGlobalTime - h * 0.4 / 24.0));
  end;

  scol := scol * iSamples;
  vcol := pow(vec3(scol), vec3_4);
  vcol := vcol * (vec3_5);
  uv   := gl_FragCoord.xy / resolution.xy;
  //vcol := vcol * (0.7 + 0.3 * pow(16.0 * uv.x * uv.y * (1.0 - uv.x) * (1.0 - uv.y), 0.25));

  Result := TColor32(vcol);
end;

initialization

JuliaDistance := TJuliaDistance.Create;
Shaders.Add('JuliaDistance', JuliaDistance);

finalization

FreeandNil(JuliaDistance);

end.
