layout(location = 0) in vec3 pos;
layout(location = 1) in float r;
layout(location = 2) in float theta;
layout(location = 3) in float phi;

vec4 lovrmain() {
  return vec4(r, theta, phi, 1);
}
