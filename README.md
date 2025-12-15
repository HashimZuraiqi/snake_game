🐍 Snake Game — Intel 8086 Assembly

A classic Snake game implemented in Intel 8086 assembly, running in 80×25 text mode using BIOS and DOS interrupts.
This project was created for an academic assignment focused on low-level programming, system interrupts, memory management, and structured program design on the 8086 architecture.

📌 Project Overview

This project is a full implementation of the Snake Game using pure 8086 assembly language without external libraries.
The game runs in text mode, draws its own borders, handles real-time input, moves the snake, detects collisions, generates random food, displays score, and handles game over & restart events.

🎯 Features
✔ Text-Mode Graphics

Uses BIOS interrupt INT 10h

80×25 screen mode

ASCII borders (┌ ┐ └ ┘ │ ─)

Snake head (@) and body (O)

Food represented as *

✔ Snake Mechanics

Snake moves automatically

Player turns left/right using keyboard

Snake grows when eating food

Real-time movement loop

✔ Input Handling

Non-blocking keyboard input (INT 16h, AH=01h)

Fast direction changes

Game restarts when pressing R after game over

✔ Food System

Randomized position using simple pseudo-RNG

Food never spawns on snake or walls

Only one food item active at a time

✔ Collision Detection

Wall collision

Self collision

Food collision

Game over message and final score

✔ Score System

Score displayed at top of screen

Updates immediately on food pickup
