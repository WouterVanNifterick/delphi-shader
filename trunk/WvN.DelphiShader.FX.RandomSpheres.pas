unit WvN.DelphiShader.FX.RandomSpheres;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  TRandomSpheres = class(TShader)
  var
    res     : double;
    light, o: vec3;
    mat     : Mat3;

  const
    tan_fov = 1.1917;
    fov     = 0.8726646;

    vec2_5: vec2  = (x: 12.9898; y: 78.233);
    vec3_6: vec3  = (x: 1; y: 1; z: 1);
    vec4_7: vec4  = (x: 0; y: 0; z: 0; w: 1);
    vec3_8: vec3  = (x: 1; y: 1; z: 1);
    vec3_9: vec3  = (x: 1; y: 1; z: 1);
    vec3_10: vec3 = (x: 0; y: 0; z: 0);
    vec3_11: vec3 = (x: 1; y: 1; z: 1);
    vec3_12: vec3 = (x: 1; y: 1; z: 1);
    vec3_13: vec3 = (x: 0; y: 0; z: 0);

    Q1: vec3 = (x: 0; y: 0; z: 0);
    Q2: vec3 = (x: 1; y: 0; z: 0);
    Q3: vec3 = (x: 0; y: 1; z: 0);
    Q4: vec3 = (x: 1; y: 1; z: 0);

    function rand(const co: vec2): float;
    function calc_light(const ray_origin, ray_dir, light_pos: vec3; out q: float): bool;
    function calc_sphere(const pt, ray_origin, ray_dir, offset: vec3; out norm: vec3; out q: float): bool;
    function Main(var gl_FragCoord: vec2): TColor32;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  RandomSpheres: TShader;

implementation

uses SysUtils, Math;

constructor TRandomSpheres.Create;
begin
  inherited;
  FrameProc := PrepareFrame;
  PixelProc := Main;
end;

function TRandomSpheres.rand(const co: vec2): float;
begin
  Exit(fract(system.sin(dot(co.xy, vec2_5)) * 43758.5453));
end;

function TRandomSpheres.calc_light(const ray_origin, ray_dir, light_pos: vec3; out q: float): bool;
var
  found       : bool;
  d           : vec3;
  r           : float;
  A           : float;
  B           : float;
  C           : float;
  discriminant: float;
begin
  found := false;

  d := -light_pos + ray_origin;
  r := 0.15;

  A := dot(ray_dir, ray_dir);
  B := 2 * dot(ray_dir, d);
  C := dot(d, d) - r * r;

  discriminant := B * B - 4 * A * C;
  if discriminant > 0 then
  begin
    q     := -(B + system.sqrt(discriminant)) / (2 * A);
    found := (q > 0);
  end;

  Exit(found);
end;

function TRandomSpheres.calc_sphere(const pt, ray_origin, ray_dir, offset: vec3; out norm: vec3; out q: float): bool;
var
  ixyz, centre, d:vec3;
  found: bool;
  t, r, A, B, C        : float;
  discriminant         : float;
  p                    : vec3;
begin
  ixyz     := floor(pt) - offset;
  centre   := ixyz + 0.5;
  centre.x := centre.x + rand(ixyz.xy);
  centre.y := centre.y + rand(ixyz.xz);
  // centre.z  := //centre.z  + (random3(ixyz.yz));

  d     := pt - centre;
  found := false;

  r := 0.05 + 0.35 * rand(ixyz.xy + 150 * ixyz.z);

  A := dot(ray_dir, ray_dir);
  B := 2 * dot(ray_dir, d);
  C := dot(d, d) - r * r;

  discriminant := B * B - 4 * A * C;

  if discriminant > 0 then
  begin
    t := -(B + system.sqrt(discriminant)) / (2 * A);
    p := d + t * ray_dir;
    q := dot(pt + t * ray_dir - ray_origin, ray_dir);
    if q > 0 then
    begin
      norm  := normalize(p);
      found := true;
    end;
  end;

  Exit(found);
end;

procedure TRandomSpheres.PrepareFrame;
begin
  res   := resolution.x / resolution.y;
  mat   := Mat3.Create(
             system.cos(0.1 * iGlobalTime),
             system.sin(0.1 * iGlobalTime), 0,
            -system.sin(0.1 * iGlobalTime),
             system.cos(0.1 * iGlobalTime), 0, 0, 0, 1);

  o.x   := 0.6 * system.sin(0.5 * iGlobalTime);
  o.y   := 0.6 * system.cos(0.5 * iGlobalTime);
  o.z   := iGlobalTime;
  light := o + vec3.Create(
                 system.sin(iGlobalTime) + 0.3 * system.sin(3 * iGlobalTime),
                 system.cos(iGlobalTime),
                 system.cos(iGlobalTime) + 3);
end;

function TRandomSpheres.Main(var gl_FragCoord: vec2): TColor32;
var
  ixyz                  : vec3;
  ray, origin, light_ray: vec3;
  sphere_colour         : vec3;
  pixel                 : vec4;
  pt, fpt, exact_pt     : vec3;
  norm, final_normal    : vec3;
  t, direct, refl       : float;
  found                 : bool;
  found_count           : int;
  to_camera             : float;
  q                     : float;
  n                     : integer;

begin
  ray.x := (2 * gl_FragCoord.x / resolution.y - res);
  ray.y := (2 * gl_FragCoord.y / resolution.y - 1);
  ray.z := (0.5 / tan_fov) + 0.5 * length(ray.xy) / (0.001 + tan(fov * length(ray.xy)));
  ray.NormalizeSelf; // 20.0;

  ray           := mat * ray;
  origin        := o;
  sphere_colour := vec3_6;
  pixel         := vec4_7;

  t           := 0; // 3.0;//15.0;
  direct      := 0;
  found_count := 0;
  to_camera   := 100000;

  refl := 0;

  if calc_light(origin, ray, light, q) then
  begin
    direct        := 1;
    to_camera     := q;
    refl          := 0;
    sphere_colour := vec3_8;
    final_normal  := vec3_9;
    exact_pt      := vec3_10;
  end;

  for n := 0 to 20 - 1 do
  begin
    pt := origin + t * ray;
    fpt := floor(pt);
    if pixel.w > 0.01 then
    begin
      if found_count < 3 then
      begin
        found := false;
        if calc_sphere(pt, origin, ray, Q1, norm, q) then
        begin
          if q < to_camera then
          begin
            exact_pt        := origin + q * ray;
            light_ray       := light - exact_pt;
            direct          := dot(norm, light_ray) / dot(light_ray, light_ray);
            to_camera       := q;
            ixyz            := fpt - Q1;
            sphere_colour.g := 0.2 + 0.5 * rand(ixyz.xy + 200);
            sphere_colour.B := 0.2 + 0.5 * rand(ixyz.xz + 200);
            final_normal    := norm;
            refl            := 0.05;
          end;
          found := true;
        end;

        if calc_sphere(pt, origin, ray, Q2, norm, q) then
        begin
          if q < to_camera then
          begin
            exact_pt        := origin + q * ray;
            light_ray       := light - exact_pt;
            direct          := dot(norm, light_ray) / dot(light_ray, light_ray);
            to_camera       := q;
            ixyz            := fpt - Q2;
            sphere_colour.g := 0.2 + 0.5 * rand(ixyz.xy + 200);
            sphere_colour.B := 0.2 + 0.5 * rand(ixyz.xz + 200);
            final_normal    := norm;
            refl            := 0.05;
          end;
          found := true;
        end;

        if calc_sphere(pt, origin, ray, Q3, norm, q) then
        begin
          if q < to_camera then
          begin
            exact_pt        := origin + q * ray;
            light_ray       := light - exact_pt;
            direct          := dot(norm, light_ray) / dot(light_ray, light_ray);
            to_camera       := q;
            ixyz            := fpt - Q3;
            sphere_colour.g := 0.2 + 0.5 * rand(ixyz.xy + 200);
            sphere_colour.B := 0.2 + 0.5 * rand(ixyz.xz + 200);
            final_normal    := norm;
            refl            := 0.05;
          end;
          found := true;
        end;

        if calc_sphere(pt, origin, ray, Q4, norm, q) then
        begin
          if q < to_camera then
          begin
            exact_pt        := origin + q * ray;
            light_ray       := light - exact_pt;
            direct          := dot(norm, light_ray) / dot(light_ray, light_ray);
            to_camera       := q;
            ixyz            := fpt - Q4;
            sphere_colour.g := 0.2 + 0.5 * rand(ixyz.xy + 200);
            sphere_colour.B := 0.2 + 0.5 * rand(ixyz.xz + 200);
            final_normal    := norm;
            refl            := 0.05;
          end;
          found := true;
        end;

        if (found) or (found_count <> 0) then
          Inc(found_count);

      end
      else
      begin
        found_count := 0;

        direct := direct * (1 - to_camera / 16);
        if direct < 0 then
          direct := 0;

        pixel.xyz := pixel.xyz + (pixel.w * (1 - refl) * sphere_colour * direct);
        pixel.w   := pixel.w * refl;

        t         := -0.5; // 5;
        to_camera := 10000;
        ray       := reflect(ray, final_normal);
        origin    := exact_pt; // + 1.01*ray;

        if calc_light(origin, ray, light, q) then
        begin
          direct        := 5;
          to_camera     := q;
          refl          := 0;
          sphere_colour := vec3_11;
          final_normal  := vec3_12;
          exact_pt      := vec3_13;
        end;
      end;
    end;
    t := t + 0.8;
  end;

  direct := direct * (1 - to_camera / 16);
  if direct < 0 then
    direct := 0;

  pixel.xyz := pixel.xyz + (pixel.w * (1 - refl) * sphere_colour * direct);
//  pixel.w   := pixel.w * refl;
  pixel.r := pow(pixel.r, 0.6);
  pixel.g := pow(pixel.g, 0.6);
  pixel.B := pow(pixel.B, 0.6);
//  pixel.w := 1;

  Result  := TColor32(pixel);
end;

initialization

RandomSpheres := TRandomSpheres.Create;
Shaders.Add('RandomSpheres', RandomSpheres);

finalization

FreeandNil(RandomSpheres);

end.
