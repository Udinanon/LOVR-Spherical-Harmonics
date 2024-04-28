Constants {
  int l;
  int m;
};
layout(location = 0) out vec3 pos;
layout(location = 1) out float r;
layout(location = 2) out float theta;
layout(location = 3) out float phi;


vec4 lovrmain() {
    pos = vec3(VertexPosition.x, VertexPosition.y, VertexPosition.z);
    // compute spherical polar coordinates
    r = length(pos);
    theta = acos(VertexPosition.z / r);
    phi = atan(VertexPosition.y,  VertexPosition.x);
    
    // apply transform
    switch (l){
    case 0:
      // Y(0,0)
      r = 0.5 * sqrt(1/PI);
      break;
    case 1: {
      switch (m){
        case -1:
          // Y(1, -1)
          r = 0.5 * sqrt(1.5/PI) * sin(theta) * cos( -phi);
          break;
        case 0:
          // Y(1, 0)
          r = 0.5 * sqrt(3/PI) * cos(theta);
          break;
        case 1:
          // Y(1, 1)
          r = -0.5 * sqrt(1.5 / PI) * sin(theta) * cos(phi);
          break;
        }
      }
      break;
    case 2:{
      switch(m){
        case -2:
          // Y(2, -2)
          r = 0.25 * sqrt(7.5/PI) * pow(sin(theta), 2) * cos(-2* phi);
          break;
        case -1:
          // Y(2, -1)
          r = .5 * sqrt(7.5/PI) * sin(theta) * cos(theta) * cos(phi);
          break;
        case 0:
          // Y(2, 0)
          r = .25 * sqrt(5/PI) * (3 * pow(cos(theta), 2) - 1);
          break;
        case 1:
          // Y(2, 1)
          r = -.5 * sqrt(7.5/PI) * sin(theta) * cos(theta) * cos(phi);
          break;
        case 2:
          //Y(2, 2)
          r = 0.25 * sqrt(7.5 / PI) * cos(2 * phi) * pow(sin(theta), 2);
          break;
        }
      }
      break;
    } 

    
    
    
    // Y(4, 2)
    //r = (3/8)*sqrt(5/(2*PI)) * cos(2*phi) * sin(theta) * sin(theta) * ( (7. * cos(theta) * cos(theta)) - 1);
    // recombine in xyz 3d coords
    vec4 newVertex = vec4(r * sin(theta) * cos(phi), r * sin(theta) * sin(phi), r * cos(theta), 1);

    return Projection * View * Transform * newVertex;
}