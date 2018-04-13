unit WvN.DelphiShader.FX.MultiFX;

interface

uses GR32, Types, WvN.DelphiShader.Shader;

type
  // http://glsl.heroku.com/e#13104.0

  TMultiFX = class(TShader)
  public const
    vec2_1: vec2 = (x: 12.9898; y: 78.233);
    vec2_2: vec2 = (x: 0.5; y: 0.5);
    vec3_3: vec3 = (x: 0; y: 0; z: 0);
    vec2_4: vec2 = (x: 0.5; y: 0.5);
    vec2_5: vec2 = (x: 0.5; y: 0.5);
    vec2_6: vec2 = (x: 0; y: 0);
    vec2_7: vec2 = (x: 0; y: 0);
    vec2_8: vec2 = (x: 0.5; y: 0.5);
    vec4_9: vec4 = (x: 0; y: 0; z: 0; w: 0);

    function rand(const vector: vec2): float;
    function get_bump_height(const position: vec2): float;
    function get_light(const position: vec2): float;
    function calc_all_effects(const gl_FragCoord: vec2; const dis: vec2): vec4;
    function Main(var gl_FragCoord: vec2): TColor32;

  var
    rsteps      : integer;
    light_x     : float;
    light_y     : float;
    light_power : float;
    light_length: float;

    constructor Create; override;
    procedure PrepareFrame;
  end;

var
  MultiFX: TShader;

implementation

uses SysUtils, Math;

constructor TMultiFX.Create;
begin
  inherited;
  UseBackBuffer := True;
  FrameProc     := PrepareFrame;
  PixelProc     := Main;
  SetBufferCount(1);
end;

procedure TMultiFX.PrepareFrame;
begin
  // Multiple effects by Optimus
  // Guest code by AkumaX (rand function)

  // Version Bump and Radial Blur
  rsteps       := 64;
  light_x      := 0;
  light_y      := 0;
  light_power  := 1;
  light_length := 0.5;

end;

function TMultiFX.rand(const vector: vec2): float;
begin
  Exit(fract(43758.5453 * system.sin(dot(vector, vec2_1))));
end;

function TMultiFX.get_bump_height(const position: vec2): float;
begin
  Exit(system.sin((system.sin(position.x * 32) + system.sin(position.y * 24) + system.sin(position.x * 4 + system.sin(position.y * 8 + time))) * 4) * 0.5 + 0.5);
end;

function TMultiFX.get_light(const position: vec2): float;
var
  tex: vec2;

begin
  tex    := &mod(position * 4, 1) - vec2_2;
  Result := pow(length(tex), 4);

  if IsZero(Result) then
    Exit;

  Exit(0.0005 / Result);
end;

function TMultiFX.calc_all_effects(const gl_FragCoord: vec2; const dis: vec2): vec4;
var
  scale             : float;
  position          : vec2;
  coord             : vec2;
  effect            : vec2;
  effect_number     : float;
  effect_group      : vec2;
  gradient          : float;
  color             : vec3;
  angle             : float;
  radius            : float;
  fade              : float;
  u, v              : float;
  z                 : float;
  centered_coord    : vec2;
  dist_from_center  : float;
  angle_from_center : float;
  dist_from_center_y: float;
  i                 : integer;
  blob_coord        : vec2;
  disp              : float;
  p00               : float;
  p10               : float;
  p01               : float;
  dx                : float;
  dy                : float;
  light_coord       : vec2;
  disp_coord        : vec2;
  rotated_coord     : vec2;
  zoom              : float;
  pix               : vec2;
  raster1           : float;
  raster2           : float;
  raster3           : float;
  rcolor            : vec3;
  star_pos          : vec2;
  tex               : vec2;
  discolamp         : vec2;
  steps             : integer;
  sum               : float;
  displacement      : vec2;
  xpos              : float;
  ypos              : float;
  z_fractal         : float;
  iter              : integer;
  iter2             : float;
  z0_r              : float;
  z0_i              : float;
  z1_r              : float;
  z1_i              : float;
  p_r               : float;
  p_i               : float;
  d                 : float;
  nn                : float;
  n                 : integer;
  zom               : float;
  x0                : float;
  y0                : float;
  x1, y1, mj2       : float;
  posx              : float;
  posy              : float;
  q: Float;
begin
  scale := 2; // sin(0.3 * time) * 8.0 + 8.25;

  position.x := ((gl_FragCoord.x / resolution.x) - 0.5) * scale - mouse.x * 16 + dis.x;
  position.y := ((gl_FragCoord.y / resolution.y) - 0.5) * scale - mouse.y * 16 + dis.y;

  // vec2 rotated_position;
  // rotated_position.x  := ((position.x - 0.5) * cos(sin(0.25 * time) * 2.5) - (position.y - 0.5) * sin(sin(0.25 * time) * 2.5)) * scale;
  // rotated_position.y  := ((position.y - 0.5) * cos(sin(0.25 * time) * 2.5) + (position.x - 0.5) * sin(sin(0.25 * time) * 2.5)) * scale;
  // position  := rotated_position;

  coord         := &mod(position, 1);
  effect        := floor(&mod(position, 4));
  effect_number := effect.y * 4 + effect.x;
  effect_group  := floor(position) * 7;

  gradient := 0;
  color    := vec3_3;

  centered_coord := coord - vec2_4;

  dist_from_center  := length(centered_coord);
  angle_from_center := atan(centered_coord.y, centered_coord.x);

  if effect_number = 0 then
  begin
    // gradient  := mod(sin(coord.x*400.0) * sin(coord.y * 400.0) * 16.0 * time, 1.0);
    gradient := (rand(vec2(sin(coord * 400)) * time));
    color    := vec3(gradient);
  end;

  if effect_number = 1 then
  begin
    color.r  := system.sin(coord.x * 32) + system.sin(coord.y * 24) + system.sin(coord.x * 4 + system.sin(coord.y *  8 + time));
    color.g  := system.sin(coord.x * 16) + system.sin(coord.y * 12) + system.sin(coord.x * 8 + system.sin(coord.y * 16 + 2 * time));
    color.b  := system.sin(coord.x *  8) + system.sin(coord.y * 48) + system.sin(coord.x * 2 + system.sin(coord.y *  4 + 3 * time));
    gradient := (color.r + color.g + color.b) / 3;
  end;

  if effect_number = 2 then
  begin
    radius := dist_from_center + system.sin(time * 8) * 0.1 + 0.1;
    angle  := angle_from_center + time;

    gradient := 0.5 / radius + system.sin(angle * 5) * 0.3;
    color    := vec3.Create(gradient, gradient / 2, gradient / 3);
  end;

  if effect_number = 3 then
  begin
    radius := dist_from_center;
    angle  := angle_from_center + time;

    gradient := system.sin(&mod(angle + system.sin(-radius + time) * 2, 2 * pi) * 4) + 1;
    color    := vec3.Create(gradient / 3, gradient / 2, gradient);
  end;

  if effect_number = 4 then
  begin
    dist_from_center_y := length(centered_coord.y);

    if IsZero(dist_from_center_y) then
    begin
      u := 16 * time;
      v := system.sin(time) * 8;
    end
    else
    begin
      u := 8 / dist_from_center_y + 16 * time;
      v := (16 / dist_from_center_y) * centered_coord.x + system.sin(time) * 8;
    end;


    fade     := dist_from_center_y * 2;
    gradient := ((1 - pow(system.sin(u) + 1, 0.1)) + (1 - pow(system.sin(v) + 1, 0.1))) * fade;
    color    := vec3.Create(gradient / 2, gradient, gradient / 2);
  end;

  if effect_number = 5 then
  begin
    if IsZero(dist_from_center) then
      dist_from_center := 0.0001;

    u := 8 / dist_from_center + 16 * time;
    v := angle_from_center * 16;

    fade     := dist_from_center * 2;
    gradient := ((1 - pow(system.sin(u) + 1, 0.1)) + (1 - pow(system.sin(v) + 1, 0.1))) * fade;
    color    := vec3.Create(gradient * 4, gradient, gradient / 2);
  end;

  if effect_number = 6 then
  begin
    for i := 0 to 32 do
    begin
      blob_coord := vec2.Create(system.sin(2 * i + 2 * time) * 0.4, system.cos(3 * i + 3 * time) * 0.4);
      gradient   := gradient + (((0.0001 + system.sin(i * i + 4 * time) * 0.000095)) / pow(length(centered_coord - blob_coord), 2.75));
    end;

    color := vec3.Create(gradient, gradient * 2, gradient / 2);
  end;

  if effect_number = 7 then
  begin
    gradient := 1;
    for i    := 0 to 16 do
    begin
      blob_coord := vec2.Create(system.sin(32 * i + 0.5 * time) * 0.5, system.cos(256 * i + 1 * time) * 0.5);
      gradient   := Math.min(gradient, length(centered_coord - blob_coord));
    end;

    gradient := pow(system.sin(gradient), 2) * 16;
    color    := vec3.Create(gradient / 1.5, gradient / 2, gradient * 1.5);
  end;

  if effect_number = 8 then
  begin
    disp := 0.005;
    p00  := get_bump_height(centered_coord);
    p10  := get_bump_height(centered_coord + vec2.Create(disp, 0));
    p01  := get_bump_height(centered_coord + vec2.Create(0, disp));

    dx := p10 - p00;
    dy := p01 - p00;

    light_coord := vec2.Create(system.sin(time) * 0.3, system.sin(2 * time) * 0.3);
    disp_coord  := centered_coord - vec2.Create(dx, dy);
    gradient    := 0.1 / length(disp_coord - light_coord);
    color       := vec3.Create(gradient, gradient, gradient * 1.25);
  end;

  if effect_number = 9 then
  begin

    zoom            := system.sin(time) + 1.25;
    rotated_coord.x := zoom * (centered_coord.x * system.cos(time) - centered_coord.y * system.sin(time));
    rotated_coord.y := zoom * (centered_coord.y * system.cos(time) + centered_coord.x * system.sin(time));

    pix := floor(rotated_coord * 8);

    gradient := &mod(&mod(pix.x, 2) + &mod(pix.y, 2), 2);
    color    := vec3(gradient);

    raster1 := 0.01 / length(centered_coord.y - sin(1.5 * time) * 0.5);
    raster2 := 0.01 / length(centered_coord.y - sin(1.5 * time + 0.3) * 0.5);
    raster3 := 0.01 / length(centered_coord.y - sin(1.5 * time + 0.6) * 0.5);

    if (raster1 > 0.25) or (raster2 > 0.25) or (raster3 > 0.25) then
    begin
      rcolor := vec3.Create(raster1, 0, 0);
      rcolor := rcolor + (vec3.Create(0, raster2, 0));
      rcolor := rcolor + (vec3.Create(0, 0, raster3));
      color  := rcolor;
    end;

  end;

  if effect_number = 10 then
  begin
    for i := 1 to 128 do
    begin
      star_pos   := vec2.Create(system.sin(i) * 64, system.sin(i * i * i) * 64);
      z          := &mod(i * i - 128 * time, 256);
      fade       := (256 - z) / 256;
      if not IsZero(z) then
        blob_coord := star_pos / z
      else
        blob_coord := vec2Black;

      d := pow(length(centered_coord - blob_coord), 1.5);
      if not IsZero(d) then
        gradient   := gradient + (((fade / 384) / d) * (fade * fade))
      else
        gradient := 0;
    end;

    color := vec3.Create(gradient * 2, gradient, gradient / 2);
  end;

  if effect_number = 11 then
  begin
    q   := 0.25 - centered_coord.x * centered_coord.x - centered_coord.y * centered_coord.y;
    if q>0 then
    begin
      z := system.sqrt(q);
      tex := (centered_coord * 32) / z;
    end
    else
    begin
      z := 0;
      tex := Vec2Black;
    end;


    fade      := pow(z, 2);
    discolamp := vec2.Create(pow(system.sin(tex.x + system.sin(0.5 * time) * 64) + 1, 2), pow(system.sin(tex.y + system.sin(0.4 * time) * 128) + 1, 2));
    gradient  := (4 - discolamp.x - discolamp.y) * fade;
    color     := vec3.Create(gradient * 4, gradient, gradient / 2);
  end;

  if effect_number = 12 then
  begin
    steps := 64;
    sum   := 0;
    for i := 0 to steps do
    begin
      light_coord    := centered_coord + vec2.Create(system.sin(time), system.sin(time * 1.24));
      displacement.x := mix(centered_coord.x, 0.25 * light_coord.x, (steps - i) / steps);
      displacement.y := mix(centered_coord.y, 0.25 * light_coord.y, (steps - i) / steps);
      sum            := mix(get_light(centered_coord + displacement), sum, 0.9);
    end;

    gradient := sum;
    if gradient <= 0.1 then
      gradient := length(centered_coord) * 0.25;
    color      := vec3.Create(gradient * 4, gradient, gradient / 2);
  end;

  if effect_number = 13 then
  begin
    xpos      := -0.5 + system.sin(centered_coord.y * 16 + time) * 0.06;
    ypos      := 0 + system.sin(centered_coord.x * 24 + 1.5 * time) * 0.04;
    z_fractal := 0.4;

    iter  := 64;
    iter2 := iter / 4;

    z0_r := 0;
    z0_i := 0;
    p_r  := (centered_coord.x + xpos * z_fractal) / z_fractal;
    p_i  := (centered_coord.y + ypos * z_fractal) / z_fractal;

    nn := 0;

    for n := 0 to iter - 1 do
    begin
      z1_r := z0_r * z0_r - z0_i * z0_i + p_r;
      z1_i := 2 * z0_r * z0_i + p_i;
      d    := system.sqrt(z1_i * z1_i + z1_r * z1_r);
      z0_r := z1_r;
      z0_i := z1_i;
      if d > iter2 then
        break;
      nn := n;
    end;

    gradient := (nn / iter) * 4;

    color := vec3.Create(gradient * 2, gradient, gradient * 16);
  end;

  nn := 0;

  if effect_number = 14 then
  begin
    zom := 3.5;
    x0  := centered_coord.x * zom;
    y0  := centered_coord.y * zom;

    iter := 32;

    posx := system.sin(time * 2) * 0.75;
    posy := system.sin(time * 1.5) * 0.75;

    for n := 0 to iter do
    begin
      x1  := x0 * x0 - y0 * y0 + posx;
      y1  := 2 * x0 * y0 + posy;
      mj2 := x1 * x1 + y1 * y1;
      x0  := x1;
      y0  := y1;
      nn  := n;
      if mj2 > iter then
        break;
    end;

    gradient := (nn / iter) * 2;

    color := vec3.Create(1 - gradient, 1 - gradient * 2, gradient * 2);
  end;

  if effect_number = 15 then
  begin
    gradient := system.sin(coord.x * 32 + 2 * time) + system.sin(coord.x * 16 + coord.y * 24) + system.sin(coord.x * 4 + system.sin(coord.y * 18 + 4 * time)) + system.sin(system.sin((coord.x + coord.y) * 33) + system.sin(coord.y * 24 + time));
    color    := vec3.Create(system.sin(gradient * 2) * 0.5 + 0.5, system.sin(gradient * 1.5) * 0.75 + 0.25, system.sin(gradient * 1.2) * 0.5 + 0.5);
  end;

  color.r := color.r * ((system.sin(effect_group.x) * 0.5 + 0.5));
  color.g := color.g * ((system.sin(effect_group.y) * 0.5 + 0.5));
  color.b := color.b * ((system.sin(effect_group.x * effect_group.y) * 0.5 + 0.5));

  Exit(vec4.Create(color, gradient));
end;

function TMultiFX.Main(var gl_FragCoord: vec2): TColor32;
var
  screen_position              : vec2;
  dis                          : float;
  col00, col10, col01          : vec4;
  p00, p10, p01                : float;
  dx, dy                       : float;
  light_coord, disp_coord      : vec2;
  gradient                     : float;
  tex_coord,
  centered_tex_coord,
  sample_tex_coord             : vec2;
  lighta_coord                 : vec2;
  rgb0                         : vec4;
  sum                          : vec4;
  i                            : integer;
  displacement                 : vec2;
  d                            : vec2;
  t: Double;
begin
  screen_position := vec2.Create(gl_FragCoord.x / resolution.x, gl_FragCoord.y / resolution.y) - vec2_5;

  dis := 0.005;

  col00 := calc_all_effects(gl_FragCoord, vec2_6);
  col10 := calc_all_effects(gl_FragCoord, vec2.Create(dis, 0));
  col01 := calc_all_effects(gl_FragCoord, vec2.Create(0, dis));

  p00 := col00.a;
  p10 := col10.a;
  p01 := col01.a;

  dx := p10 - p00;
  dy := p01 - p00;

  light_coord := vec2_7;
  disp_coord  := screen_position - vec2.Create(dx, dy);

  d        := disp_coord - light_coord;
  t := pow(length(d), 2);
  if not IsZero(t) then
    gradient := 0.02 / t
  else
    gradient := 0;


  // =================

  tex_coord          := vec2.Create(gl_FragCoord.x / resolution.x, gl_FragCoord.y / resolution.y);
  centered_tex_coord := tex_coord - vec2_8;
  lighta_coord       := vec2.Create(light_x * light_length, light_y * light_length);

  rgb0 := col00 * gradient;

  sum   := vec4_9;
  for i := 0 to rsteps - 1 do
  begin
    sample_tex_coord := mix(centered_tex_coord, (centered_tex_coord - lighta_coord) * (1 - light_length), i / rsteps);
    displacement     := sample_tex_coord - centered_tex_coord;
    sum              := sum + texture2D(Buffers[0].Bitmap, tex_coord + displacement) * light_power;
  end;

  Result := TColor32(mix(sum / rsteps, rgb0, 0.5));
end;

initialization

MultiFX := TMultiFX.Create;
Shaders.Add('MultiFX', MultiFX);

finalization

FreeandNil(MultiFX);

end.
