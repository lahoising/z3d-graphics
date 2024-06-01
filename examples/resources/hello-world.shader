// shader source vertex
#version 430 core

layout(location = 0) in vec3 a_Position;
layout(location = 1) in vec4 a_Color;

layout(location = 0) out vec4 v_Color;

void main() {
  gl_Position = vec4(a_Position, 1.0);
  v_Color = a_Color;
}

// shader source fragment
#version 430 core

layout(location = 0) in vec4 v_Color;

out vec4 f_Color;

void main() {
  f_Color = v_Color;
}
