
#THIS IS WHERE THE AUDIO GETS STORED
.section .data
name: .incbin "Scary_Shooting_Noise.wav"
.equ FIFO, 0xFF203040
.equ TIMER, 0xFF202000


.section .text
.global _start

_start:

movia r8, name
movia r15, TIMER
movia r6, FIFO

ldh r9, 0(r8)
beq r9,r0, INCREMENT_MUSIC #This skips all of the white noise

#ldwio r7, 0(r15)
#andi r7,r7, 1
#bne r7,r0, RESET

ldwio r7, 4(r6) # read fifospace register
srli r7,r7,16 #Check if right write FIFO is empty
andi r11, r7, 0xff 

beq r11,r0, _start #If so, loop again
andi r11, r7, 0xff #Check if left write FIFO is empty
beq r11,r0, _start #If empty, loop again

ldh r10, 2(r8)

slli r9,r9,16 #Amplify music
stwio r9, 8(r6)
slli r10,r10, 16
stwio r10, 12(r6)

addi r8,r8,4

br _start

INCREMENT_MUSIC:
addi r9,r9,1
ret

RESET:
ret