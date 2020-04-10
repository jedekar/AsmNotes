  %define u(x) __utf16__(x)

  section .data
  Caption dw u("Я програма на асемблері"), 0
  Text dw u("Здоровеньки були!"), 0

  section .text
  extern _MessageBoxW@16
  extern _ExitProcess@4
  
  global _main
_main:
  push 0
  push Caption
  push Text
  push 0
  call _MessageBoxW@16
  push 0
  call _ExitProcess@4

