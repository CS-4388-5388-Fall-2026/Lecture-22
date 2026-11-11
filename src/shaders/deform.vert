#version 300 es

/* Lecture 22: Advanced Shader Programming
 * CS 4388/ CS 5388, Fall 2025, Texas State University
 * Instructor: Isayas Berhe Adhanom <isayas@txstate.edu>
 * License: Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
 */ 

precision mediump float;

// material properties: coeff. of reflection for the material
uniform mat4 modelMatrix;
uniform mat4 normalMatrix;
uniform mat4 viewMatrix;
uniform mat4 projectionMatrix;

// per-vertex data
in vec3 position;
in vec3 normal;
in vec4 color;
in vec2 texCoord;

// animation data
uniform float waveAngle;
uniform float waveScale;

// data we want to send to the rasterizer and eventually the fragment shader
out vec3 vertPositionWorld;
out vec3 vertNormalWorld;
out vec4 vertColor;
out vec2 uv;

void main() 
{
    
      int mode = 1;   // 0 = original, 1 = radial ripple, 2 = fading ripple, 3 = sharp pulses, 4 = twist

    // position in homogenous coords is x, y, z, 1
    vec3 vertPositionDeformed;

    if (mode == 1)
        // Radial ripple
        vertPositionDeformed = position + (sin(length(position.xz) * 40.0 - waveAngle) * 0.5 + 0.5) * waveScale * normal;
    else if (mode == 2)
        // Ripple that fades with distance
        vertPositionDeformed = position + (sin(length(position.xz) * 40.0 - waveAngle) * 0.5 + 0.5) * exp(-3.0 * length(position.xz)) * waveScale * normal;
    else if (mode == 3)
        // Sharp pulses
        vertPositionDeformed = position + pow(cos(position.x * 20.0 + waveAngle) * 0.5 + 0.5, 8.0) * waveScale * normal;
    else if (mode == 4)
    {
        // Twist around the vertical axis
        float a = position.y * 3.0 * sin(waveAngle);
        vertPositionDeformed = vec3(position.x * cos(a) - position.z * sin(a), position.y, position.x * sin(a) + position.z * cos(a));
    }
    else
        // Original
        vertPositionDeformed = position + (cos(position.x*20.0 + waveAngle) * 0.5 + 0.5) * waveScale * normal;

    
    // position in homogenous coords is x, y, z, 1
    vertPositionWorld = (modelMatrix * vec4(vertPositionDeformed, 1)).xyz;

    // vector in homogenous coords is x, y, z, 0
    vertNormalWorld = normalize((normalMatrix * vec4(normal, 0)).xyz);

    // output the vertex color to the fragment shader
    vertColor = color;

    // output the texture coordinate to the fragment shader
    uv = texCoord.xy; 

    // compute the 2D screen coordinate position
    gl_Position = projectionMatrix * viewMatrix * vec4(vertPositionWorld, 1);
}
