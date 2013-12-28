unit WvN.DelphiShader.FX.SphereTracer;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type

  // a simple sphere raytracer for educational purposes
  // hellfire/haujobb

  TSphereTracer = class(TShader)
    function reflection(dir: vec3; const normal: vec3): vec3;
    function intersectSphere(const o: vec3; const d: vec3; const sphere: vec4; const color: vec3; const thres: float): float;
    function intersectScene(const p: vec3; const d: vec3): float;
    function rayBlocked(const src: vec3; const dst: vec3): bool;
    function calcLight(const lpos: vec3; const lcol: vec3; const pos: vec3; const normal: vec3; const col: vec3): vec3;
    function calcLights(const pos: vec3; const normal: vec3; const col: vec3): vec3;
    function traceRay(p: vec3; d: vec3): vec3;
    function RenderPixel(var gl_FragCoord: Vec2): TColor32;

  var
    sphere     : array [0 .. 2] of vec4;
    colors     : array [0 .. 2] of vec3; // colors of the 3 spheres
    lightpos   : array [0 .. 1] of vec3; // position and color of the light sources
    lightcol   : array [0 .. 1] of vec3;
    thres      : float; // absolute threshold. anything beyond this distance will be discarded
    hitposition: vec3;  // if a sphere is hit remember the position, normal and sphere
    hitnormal  : vec3;
    hitcolor   : vec3;

    constructor Create; override;
    procedure PrepareFrame;
  end;

  const
    vec3_dkGray: vec3 = (x: 0.2; y: 0.2; z: 0.2);
    vec3_2: vec3 = (x: 0.9; y: 0.6; z: 0.2);
    vec3_3: vec3 = (x: 0.0; y: 0.7; z: 0.6);
    vec3_4: vec3 = (x: 0.3; y: 0.1; z: 1.0);
    vec3_5: vec3 = (x: -10.0; y: -5.0; z: -10.0);
    vec3_6: vec3 = (x: 1.1; y: 0.8; z: 0.4);
    vec3_7: vec3 = (x: 0.6; y: 0.3; z: 1.1);
    vec3_9: vec3 = (x: 5; y: - 3; z: - 5);


var
  SphereTracer: TShader;

implementation

uses SysUtils, Math;

constructor TSphereTracer.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := RenderPixel;
  thres     := 100.0;

  colors[0] := vec3_2;
  colors[1] := vec3_3;
  colors[2] := vec3_4;

  lightpos[0] := vec3_5;
  lightcol[0] := vec3_6;

  lightpos[1] := vec3_9;
  lightcol[1] := vec3_7;

end;

procedure TSphereTracer.PrepareFrame;
begin
  sphere[0] := vec4.Create(system.sin(time * 1.1), system.cos(time * 0.9), -3.0 + system.sin(time * 0.8), 0.7);
  sphere[1] := vec4.Create(system.cos(time * 0.8), -system.sin(time * 1.2), -3.0 + system.cos(time * 0.9), 0.8);
  sphere[2] := vec4.Create(-system.cos(time * 1.3), system.sin(time * 0.7), -3.0 - system.cos(time * 1.0), 0.9);
end;

// reflect direction vector "dir" at "normal"
// position and radius of the 3 spheres
function TSphereTracer.reflection(dir: vec3; const normal: vec3): vec3;
begin
  dir := normalize(dir);
  Exit(dir - normal * 2.0 * dot(normal, dir));
end;

// intersect sphere with ray o+t*d
// discard hits with t>thres (a closer hit already exists)
function TSphereTracer.intersectSphere(const o: vec3; const d: vec3; const sphere: vec4; const color: vec3; const thres: float): float;
var
  l  : vec3;
  tca: float;
  d2 : float;
  thc: float;
  t0 : float;
begin
  l   := sphere.xyz - o;
  tca := dot(l, d);
  // sphere is behind the ray: intersection is impossible
  if tca < 0.0 then
    Exit(thres);

  // project center onto ray
  d2 := dot(l, l) - tca * tca;

  // distance is longer than radius: no intersection
  if d2 > sphere.w * sphere.w then
    Exit(thres);
  thc := system.sqrt(sphere.w * sphere.w - d2);
  t0  := tca - thc;

  // intersection is further away than current threshold: skip
  if t0 > thres then
    Exit(thres);

  // get intersection position, surface normal and sphere color
  hitposition := o + t0 * d;
  hitnormal   := normalize(hitposition - sphere.xyz); // / sphere.w
  hitcolor    := color;

  Exit(t0);
end;

// find the nearest intersection point of the ray with the scene
function TSphereTracer.intersectScene(const p: vec3; const d: vec3): float;
var
  t: float;
  i: integer; // loop variable
begin
  t := thres;

  for i := 0 to 3 - 1 do
    t   := intersectSphere(p, d, sphere[i], colors[i], t);

  Exit(t);
end;

// is anything between the points "src" (point on surface) and "dst" (light source) ?
function TSphereTracer.rayBlocked(const src: vec3; const dst: vec3): bool;
var
  dir   : vec3;
  length: float;
  t     : float;
begin
  dir    := dst - src;
  length := system.sqrt(dot(dir, dir));
  dir    := dir / length;
  t      := intersectScene(src + dir * 0.001, -dir);
  if (t > 0.0) and (t < length) then
    Exit(true)
  else
    Exit(false);
end;

function TSphereTracer.calcLight(const lpos: vec3; const lcol: vec3; const pos: vec3; const normal: vec3; const col: vec3): vec3;
var
  color   : vec3;
  dir     : vec3;
  invDist : float;
  diffuse : float;
  refl    : vec3;
  specular: float;
  s       : float;
begin
  color := vecBlack;

  // no lighting if point is shadowed
  if not rayBlocked(pos, lpos) then
  begin
    // get light direction and distance
    dir     := (pos - lpos);
    invDist := 1.0 / system.sqrt(dot(dir, dir));
    dir     := dir * invDist; // normalize

    // diffuse: light -> surface
    diffuse := dot(dir, normal);
    if diffuse > 0.0 then
    begin
      color := color + (col * diffuse * lcol * invDist * 15.0);
    end;

    // specular: reflection -> light
    refl     := reflection(pos, normal);
    specular := dot(refl, dir);
    if specular > 0.0 then
    begin
      s     := pow(specular, 30.0);
      color := color + (s * lcol);
    end;

  end;

  Exit(color);
end;

// calculate lighting for point "pos" with "normal" and color
function TSphereTracer.calcLights(const pos: vec3; const normal: vec3; const col: vec3): vec3;
var
  color: vec3;
begin
  color := vecBlack;

  // iterate through all lights
  color := color + (calcLight(lightpos[0], lightcol[0], pos, normal, col));
  color := color + (calcLight(lightpos[1], lightcol[1], pos, normal, col));

  Exit(color);
end;

//
function TSphereTracer.traceRay(p: vec3; d: vec3): vec3;
var
  it    : int;
  color : vec3;
  origin: vec3;
  scale : float;
  t     : float;
  nrm   : vec3;
  i     : integer;
begin
  it     := 0;
  color  := vecBlack;
  origin := vecBlack;

  scale := 1.0;

  // two iterations of reflection
  for i := 0 to 1 do
  begin
    t := intersectScene(p, d);
    if t < thres then
    begin
      // ray intersects something
      // remember current hit information as calcLight will overwrite
      p   := hitposition;
      nrm := hitnormal;

      // calculate lighting for this point
      color := color + (calcLights(p, nrm, hitcolor) * scale);
      Inc(it);

      // each iteration of reflection gets darker
      scale := scale * (0.4);

      // start new ray from intersection point along reflection vector
      d      := reflection(p - origin, nrm);
      p      := p + (d * 0.01);
      origin := p;

      // reflection
      t := intersectScene(p, d);
      if t < thres then
      begin
        // ray intersects something
        // remember current hit information as calcLight will overwrite
        p   := hitposition;
        nrm := hitnormal;

        // calculate lighting for this point
        color := color + (calcLights(p, nrm, hitcolor) * scale);

        // each iteration of reflection gets darker
        scale := scale * (0.4);

        // start new ray from intersection point along reflection vector
        d      := reflection(p - origin, nrm);
        p      := p + (d * 0.001);
        origin := p;

        Inc(it);

        // interreflection
        t := intersectScene(p, d);
        if t < thres then
        begin
          // ray intersects something
          // remember current hit information as calcLight will overwrite
          p   := hitposition;
          nrm := hitnormal;

          // calculate lighting for this point
          color := color + (calcLights(p, nrm, hitcolor) * scale);

          // each iteration of reflection gets darker
          scale := scale * (0.4);

          // start new ray from intersection point along reflection vector
          d      := reflection(p - origin, nrm);
          p      := p + (d * 0.001);
          origin := p;

          Inc(it);
        end;
      end;
    end;
  end;

  if it = 0 then // nothing hit: background gradient
    color := vec3_dkGray * (p.y + 1.5);

  Exit(color);
end;

function TSphereTracer.RenderPixel(var gl_FragCoord: Vec2): TColor32;
var
  aspect: float;
  d     : vec3;
  color : vec3;
  p     : vec3;
begin
  aspect := resolution.x / resolution.y;
  p      := vec3.Create((gl_FragCoord.x * 2.0 / resolution.x - 1.0) * aspect, (gl_FragCoord.y * 2.0 / resolution.y - 1.0), -1.0);
  d      := normalize(p);

  // trace the ray and get rgb color
  color := traceRay(p, d);

  Result := TColor32(color); // background color
end;

initialization

SphereTracer := TSphereTracer.Create;
Shaders.Add('SphereTracer', SphereTracer);

finalization

FreeandNil(SphereTracer);

end.
