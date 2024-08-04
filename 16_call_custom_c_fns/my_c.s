extern my
extern exit

section .text
global main

main:
    PUSH 1
    PUSH 2
    CALL my
    PUSH eax
    CALL exit