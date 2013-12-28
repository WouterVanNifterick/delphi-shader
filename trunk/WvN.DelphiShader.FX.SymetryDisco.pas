unit WvN.DelphiShader.FX.SymetryDisco;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TSymetryDisco = class(TShader)
    ax: array [0 .. 26] of double;
    ay: array [0 .. 26] of double;
    n, t: float;
    function makeSymmetry(const p: vec2): vec2;
    function makePoint(x, y: float; i: Integer): float;
    function sim(const p: vec3; s: float): vec3;
    function rot(const p: vec2; r: float): vec2;
    function rotsim(const p: vec2; s: float): vec2;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  SymetryDisco: TShader;

implementation

uses SysUtils, Math;

constructor TSymetryDisco.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

procedure TSymetryDisco.PrepareFrame;
begin
  t := time * 0.5;
  n := system.sin(time * 0.3) * 2.0 + 3.0 + tan(time / 12.2);

  ax[0]  := tan(t * 3.3) * 0.3;
  ay[0]  := tan(t * 2.9) * 0.3;
  ax[1]  := tan(t * 1.9) * 0.4;
  ay[1]  := tan(t * 2.0) * 0.4;
  ax[2]  := tan(t * 0.8) * 0.4;
  ay[2]  := tan(t * 0.7) * 0.5;
  ax[3]  := tan(t * 2.3) * 0.6;
  ay[3]  := tan(t * 0.1) * 0.3;
  ax[4]  := tan(t * 0.8) * 0.5;
  ay[4]  := tan(t * 1.7) * 0.4;
  ax[5]  := tan(t * 0.3) * 0.4;
  ay[5]  := tan(t * 1.0) * 0.4;
  ax[6]  := tan(t * 1.4) * 0.4;
  ay[6]  := tan(t * 1.7) * 0.5;
  ax[7]  := tan(t * 1.3) * 0.6;
  ay[7]  := tan(t * 2.1) * 0.3;
  ax[8]  := tan(t * 1.8) * 0.5;
  ay[8]  := tan(t * 1.7) * 0.4;
  ax[9]  := tan(t * 1.2) * 0.3;
  ay[9]  := tan(t * 1.9) * 0.3;
  ax[10] := tan(t * 0.7) * 0.4;
  ay[10] := tan(t * 2.7) * 0.4;
  ax[11] := tan(t * 1.4) * 0.4;
  ay[11] := tan(t * 0.6) * 0.5;
  ax[12] := tan(t * 2.6) * 0.6;
  ay[12] := tan(t * 0.4) * 0.3;
  ax[13] := tan(t * 0.7) * 0.5;
  ay[13] := tan(t * 1.4) * 0.4;
  ax[14] := tan(t * 0.7) * 0.4;
  ay[14] := tan(t * 1.7) * 0.4;
  ax[15] := tan(t * 0.8) * 0.4;
  ay[15] := tan(t * 0.5) * 0.5;
  ax[16] := tan(t * 1.4) * 0.6;
  ay[16] := tan(t * 0.9) * 0.3;
  ax[17] := tan(t * 0.7) * 0.5;
  ay[17] := tan(t * 1.3) * 0.4;
  ax[18] := tan(t * 3.7) * 0.3;
  ay[18] := tan(t * 0.3) * 0.3;
  ax[19] := tan(t * 1.9) * 0.4;
  ay[19] := tan(t * 1.3) * 0.4;
  ax[20] := tan(t * 0.8) * 0.4;
  ay[20] := tan(t * 0.9) * 0.5;
  ax[21] := tan(t * 1.2) * 0.6;
  ay[21] := tan(t * 1.7) * 0.3;
  ax[22] := tan(t * 0.3) * 0.5;
  ay[22] := tan(t * 0.6) * 0.4;
  ax[23] := tan(t * 0.3) * 0.4;
  ay[23] := tan(t * 0.3) * 0.4;
  ax[24] := tan(t * 1.4) * 0.4;
  ay[24] := tan(t * 0.8) * 0.5;
  ax[25] := tan(t * 0.2) * 0.6;
  ay[25] := tan(t * 0.6) * 0.3;
  ax[26] := tan(t * 1.3) * 0.5;
  ay[26] := tan(t * 0.5) * 0.4;
end;

// By @paulofalcao
//
// Some blobs modifications with symmetries

// nice stuff :)
function TSymetryDisco.makeSymmetry(const p: vec2): vec2;
begin
  Result   := p;
  Result   := rotsim(Result, n);
  Result.x := abs(Result.x);
end;

function TSymetryDisco.makePoint(x, y: float; i: Integer): float;
var
  xx, yy: float;
begin
  xx     := x + ax[i]; // tan(t*fx)*sx
  yy     := y - ay[i]; // tan(t*fy)*sy
  Result := 0.8 / system.sqrt(abs(x * xx + yy * yy));
end;

function TSymetryDisco.sim(const p: vec3; s: float): vec3;
begin
  Result := p;
  Result := p + s * 0.5;
  Result := fract(Result / s) * s - s * 0.5;
end;

function TSymetryDisco.rot(const p: vec2; r: float): vec2;
var sr,cr:Double;
begin
  sr := system.sin(r);
  cr := system.cos(r);
  Result.x := p.x * cr - p.y * sr;
  Result.y := p.x * sr + p.y * cr;
end;

function TSymetryDisco.rotsim(const p: vec2; s: float): vec2;
begin
  Result := p;
  Result := rot(p, -PI / (s * 2));
  Result := rot(p, floor(atan(Result.x, Result.y) / PI * s) * (PI / s));
end;

// Util stuff end

function TSymetryDisco.Main;
var
  p: vec2;
  x: float;
  y: float;
  a: float;
  b: float;
  c: float;
  d: vec3;

begin
  p := (gl_FragCoord.xy / resolution.x) * 2.0 - vec2.Create(1.0, resolution.y / resolution.x);

  // p := p*2.0;
  p := makeSymmetry(p);
  x := p.x;
  y := p.y;

  a :=     makePoint(x, y, 0);
  a := a + makePoint(x, y, 1);
  a := a + makePoint(x, y, 2);
  a := a + makePoint(x, y, 3);
  a := a + makePoint(x, y, 4);
  a := a + makePoint(x, y, 5);
  a := a + makePoint(x, y, 6);
  a := a + makePoint(x, y, 7);
  a := a + makePoint(x, y, 8);

  b := {-a +} makePoint(x, y, 9);
  b := b + makePoint(x, y, 10);
  b := b + makePoint(x, y, 11);
  b := b + makePoint(x, y, 12);
  b := b + makePoint(x, y, 13);
  b := b + makePoint(x, y, 14);
  b := b + makePoint(x, y, 15);
  b := b + makePoint(x, y, 16);
  b := b + makePoint(x, y, 17);

  c := {-b +} makePoint(x, y, 18);
  c := c + makePoint(x, y, 19);
  c := c + makePoint(x, y, 20);
  c := c + makePoint(x, y, 21);
  c := c + makePoint(x, y, 22);
  c := c + makePoint(x, y, 23);
  c := c + makePoint(x, y, 24);
  c := c + makePoint(x, y, 25);
  c := c + makePoint(x, y, 26);

  d := vec3.Create(a, b, c)/64;

  Result := TColor32(d);
end;

initialization

SymetryDisco := TSymetryDisco.Create;
Shaders.Add('SymetryDisco', SymetryDisco);

finalization

FreeandNil(SymetryDisco);

end.
