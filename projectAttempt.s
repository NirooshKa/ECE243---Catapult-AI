#My Constants
.equ PS2, 0xFF200100
.equ BREAK_CODE1, 0x000000E0 #This is for the space bar
.equ BREAK_CODE2, 0x000000F0 #This is for the arrow keys
.equ LEFT_KEY, 0x0000006B 
.equ RIGHT_KEY, 0x00000074
.equ SPACE_KEY, 0x00000029 #Shoot the projectile!
.equ DOWN_KEY, 0x00000072#Stop
.equ ADDR_CHAR, 0x09000000
.equ ADDR_VGA, 0x08000000
start_screen: .incbin "startimage.bmp", 138 #138 for skip the header
aim_image: .incbin "aim_image.bmp",138
aim_image_1: .incbin "aim_image_1.bmp",138
gotcha: .incbin "gotcha.bmp",138
win_image: .incbin "score.bmp",138
INS:  .incbin "in.bmp",138
final: .incbin "play_again.bmp",138
.equ ADDR_SLIDESWITCHES, 0xFF200040
.equ ADDR_REDLEDS, 0xFF200000
.equ ADDR_JP1, 0xFF200060   # Address GPIO JP1 
.equ TIMER, 0xFF202000
.equ HEX0TO3, 0xFF200020
.equ HEX4TO5, 0xFF200030
.equ time, 100000000 

#HEXDIGITS
.equ zero, 0x3f
.equ one, 0x06
.equ two, 0x5b
.equ three, 0x4f
.equ four, 0x66
.equ five, 0x6d

#------------------------------------------------
#INTERRUPTS
.section .exceptions, "ax"
movia r16, PS2

CHECK_ISR:
	rdctl et, ctl4 #Check for IRQ7
	srli et,et,7 #Move 7 bits to make it easier to see if something is valid (10000000 -> 0000001)
	andi et,et,0x1
	bne et, r0, START_KEYS #If IRQ7 is enabled, check to see if valid
	br END_ISR #Just end it if it's not present
	
START_KEYS:
	ldwio et, 0(r16)
	andi r20, et, 0x8000 #Masking for validity
	beq r20, r0, START_KEYS #This is the polling part
		
	andi et,et, 0x00FF #Mask data if valid
	movia r19, BREAK_CODE1 #Get space bar break code
	movia r21, BREAK_CODE2 #Get arrow keys break code
	beq et,r19, READ_KEYS  #SPACE BAR ACTIVATED
	beq et,r21, READ_KEYS #Arrow Keys activated!
	br END_ISR #If nothing, just end it too
	
READ_KEYS:
ldwio et, 0(r16) #checks for data
andi r20, et, 0x8000 #data masking
beq r20,r0, READ_KEYS #poll to ensure right data is received
andi et,et, 0xFF #Get data and mask if valid

#Operation #1
movia r19, SPACE_KEY
beq et, r19, PRESS_SPACE

#Operation #2
movia r19, DOWN_KEY
beq et, r19, PRESS_DOWN

#Operation #3
movia r19, LEFT_KEY
beq et, r19, PRESS_LEFT

#Operation #4
movia r19, RIGHT_KEY
beq et, r19, PRESS_RIGHT

#If none of the options get satisfied, then we exit :D
br END_ISR

#PRESS SPACE FOR START IMAGE
PRESS_SPACE:
call CLEAR_SCREEN
call DRAW_START_SCREEN
br END_ISR

#press down arrow for continue the game 
PRESS_DOWN:
#call CLEAR_CHAR
call CLEAR_SCREEN
call DRAW_AIM
br END_ISR

#press left arrow to go back to INSTRUCTION IMAGE 
PRESS_LEFT:
call CLEAR_SCREEN
call DRAW_INS
br END_ISR

#press right arrow for surprise IMAGE
PRESS_RIGHT:
call CLEAR_SCREEN
call DRAW_GOTCHA
br END_ISR

END_ISR:	
ldwio et, 0(r16) #Cleaning out the register
srli et,et,16
bne et,r0, END_ISR #Keep polling until clean

subi ea,ea,4
eret #Returns to the main function
## ACTUAL CODE -----------------------------------------------------------------------------------------

.section .text
.global _start

_start:
#This starts the counter for the 7 segment hex display
INITIALIZE_COUNTER:
movi r26,0

start1:
movia r16, PS2

movi r11, 0x1
stwio r11, 4(r16)#Read enable interrupt

movi r11, 0x80 #keyboard interrupt (irq7)
wrctl ctl3,r11 #Set enable for irq7
movi r12, 0x01
wrctl ctl0, r12#Set PIE bit

 ##Somehow find a way to deal with external interrupts 

call DRAW_INS
#done draw the INSTRUCTION IMAGE

 movia r2,ADDR_SLIDESWITCHES
 movia r5,ADDR_REDLEDS
 movia  r8, ADDR_JP1  
 movia r10, TIMER
 movia r14, HEX0TO3
  
 movia  r9, 0x07f557ff       # set direction for motors to all output 
 stwio  r9, 4(r8)
  
 movi r13, 9 #Value to compare the sensors against
  

##DEALING WITH MOVEMENTS~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 ldwio r3,0(r2) #Read switches 
 movi r4, 1 #Left
 movi r6, 2 #Right
 movi r7,4 #Shoot
 movi r21, 8 #Moves the motor back to normal
 movi r22, 16 #This is to check whether if your shot went in (Turns on sensors, turns off motors)
  
  
#THIS IS WHERE THE CONDITIONALS START
 beq r3, r22, CHECK_SENSORS
 beq r3, r4, GOLEFT
 beq r3, r6, GORIGHT
 beq r3, r7, SHOOT
 beq r3, r21, TRICK_SHOT
 beq r3, r0, STOP #No LED's are turned on at this point


  
  #This stage is impossible to reach (Defensive Programming)
 br start1

## ALL POSSIBLE CAR COMBINATIONS START HERE~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  
  
TRICK_SHOT:
#LED DEBUGGING
movi r3,3
stwio r3, 0(r5)  
#Moves the motor 
movia r9,  0xffffffcf          # motor2 enabled (bit0=0), direction set to forward (bit1=0) 
stwio r9, 0(r8)

#CHECK SENSOR TO SEE IF SHOT IS VALID
br start1
  
SHOOT: 
#LED DEBUGGING
  movi r3, 2
  stwio r3, 0(r5)
#THIS MOVES THE MOTOR
  movia r9,0xffffffef         # motor2 enabled (bit0=0), direction set to forward (bit1=0) 
  stwio r9, 0(r8)
  
  
##CHECKS SENSORS TO SEE IF VALUE IS VALID  
br start1

GORIGHT:
#LED DEBUGGING
  movi r3, 1
  stwio r3, 0(r5)
#THIS MOVES THE MOTOR

  movia r9, 0xfffffffb         # motor0 enabled (bit0=0), direction set to forward (bit1=0) 
  stwio r9, 0(r8)
  
  br start1
  
GOLEFT:
#LED DEBUGGING
  movi  r3,0xFF
  stwio r3,0(r5)        	  # Write to LEDs 
#THIS MOVES THE MOTOR
  movia	 r9, 0xfffffff3       # motor0 enabled (bit0=0), direction set to reverse (bit1=1) 
  stwio	 r9, 0(r8)	

  
  br start1
  
STOP:
#LED DEBUGGING  
  movi  r3,0x00
  stwio r3,0(r5)        # Write to LEDs
#THIS MOVES THE MOTOR  
  movia	 r9, 0xffffffff       #EVERYTHING IS TURNED OFF
  stwio	 r9, 0(r8)	

  
  br start1
 
 
#This checks the sensor whenever someone shoots
CHECK_SENSORS:	
sensor0:
movia  r10, 0xfffff3ff #enable sensor 0,disable all motors (Except for motors 1 and 2)
and r10, r10, r9
stwio r10, 0(r8)  
ldwio r11, 0(r8)  #check for valid data      
srli  r11, r11, 27  #shift right 27 bits makes sersor has the lower 4 bits as value
andi  r11, r11, 0x0f 

sensor5:
movia  r10, 0xfff3ffff #enable sensor 5,disable all motors (Except for motors 1 and 2)
and r10, r10, r9
stwio r10, 0(r8)  
ldwio r12, 0(r8)  #check for valid data      
srli  r12, r12, 27  #shift right 27 bits makes sersor has the lower 4 bits as value
andi  r12, r12, 0x0f 
 
ble r11,r13, SCORE
ble r12,r13, SCORE
br start1

SCORE:
#LED FOR DEBUGGING (I am going to use a counter, and that counter will determine which hex I want to display)
 
#SCORE COMPARISONS
 
#WHERE BRANCHING HAPPENS

#LED FOR DEBUGGING (I am going to use a counter, and that counter will determine which hex I want to display)
 
#SCORE COMPARISONS

 movi r11, 1
 movi r12, 2
 movi r3, 3
 movi r4,4 
 movi r5,5
 movi r6, 6
 
 #WHERE BRANCHING HAPPENS
 beq r26, r0, SCORE0
 beq r26, r11, SCORE1
 beq r26, r12, SCORE2
 beq r26, r3, SCORE3
 beq r26, r4, SCORE4
 beq r26, r6, YOUWIN
  
 SCORE0:
 addi r26,r26,1
 movia r3, one
 stwio r3,0(r14)
 call DRAW_WIN_IMAGE
   br TIMERTIME
 
 
 
 SCORE1: 
 addi r26,r26,1
 movia r3, two
 stwio r3,0(r14)
 call CLEAR_SCREEN
   call DRAW_WIN_IMAGE
   br TIMERTIME
 
 
 SCORE2:
  addi r26,r26,1
 movia r3, three
 stwio r3,0(r14)
  call CLEAR_SCREEN
   call DRAW_WIN_IMAGE
   br TIMERTIME
 
 SCORE3:
  addi r26,r26,1
  movia r3, four
 stwio r3,0(r14)
 call CLEAR_SCREEN
  call DRAW_WIN_IMAGE
br TIMERTIME
 
 
 SCORE4:
  addi r26,r26,1
  movia r3, five
 stwio r3,0(r14)
  call CLEAR_SCREEN


 YOUWIN:
  movi  r3,0x5
  stwio r3,0(r5)        # Write to LEDs

  call DRAW_FINAL




##THIS IS THE TIMER
	
TIMERTIME:

Initial: #This is how the program is going to be organized (R9 = TIMEOUT BIT ; if 0, SWITCH SCREEN)
call LEDon
call delayed #Call 10 times to make a 20 second timer
call LEDoff
br start1

LEDon: #This will turn on the LED
movi r9, 1 #Turning on LED#1, you can change the number from 1-9
movia r8, ADDR_REDLEDS #Moving the address of the LED into the register
stwio r9, 0(r8) #Giving the LED on the board a certain instruction
ret

delayed:
#First, I store, then I reset it, and I run it afterwards.

movia r10, TIMER
movui r11, %lo(time)
stwio r11, 8(r10) #Initialize the board's low time value 
movui r11, %hi(time)

stwio r11, 12(r10) #Initialize the board's high time value
stwio r0, 0(r10) #Resets the timer

movui r11, 0b100 #Enables Timer
stwio r11, 4(r10) #Starts the timer

poll: #This is to check if the 1 second time has been elapsed
ldwio r11, (r10) #Read first register in Timer
andi r11,r11,0b1 #Check is TO is 1
beq r11,r0, poll

ret



LEDoff:
movi r9, 0
movia r8, ADDR_REDLEDS #Moving the address of the LED into the register
stwio r9, 0(r8)
stwio r0, (r8)
ret

	
	
	
	

#-------------------------THE CALLEE FUNCTIONS START HERE--------------------------------------------------

DRAW_START_SCREEN:
	subi sp, sp, 16
	stw r16,0(sp)
	stw r17,4(sp)
	stw r18,8(sp)
	stw r19,10(sp)
	
	movia r8, ADDR_VGA 	
	
	movia r19, start_screen 		
	mov r14, r19				#r14 is the pixel pointer points to the image
	mov r10, r0  				#r10 is initial x=0 
	movui r11, 239 				#r11 is initial y=239
	movui r12, 320 				#r12 max limit for x
#draw the pixel
draw_pixel:
	ldh r13,0(r14) 				#r13 stores pixel information
	muli r16,r10,2 				#r16 = x*2
	muli r17,r11,1024			#r17 = y*1024
	add r16,r16,r17				#r16= x*2 + y*1024
	add r18,r16,r8				#add offset to address
	sthio r13,0(r18) 			#draw the pixel

	addi r14,r14,2   			#increase pixel pointer
	addi r10,r10,1   			#increase x
	blt r10,r12,draw_pixel 	#if x < 320, keep drawing 

	mov r10,r0   				#reset x
	subi r11, r11, 1	 			#decrease y
	bge r11,r0,draw_pixel 	#if y > 0, keep drawing
	
	ldw r16,0(sp)
	ldw r17,4(sp)
	ldw r18,8(sp)
	ldw r19,10(sp)
	addi sp,sp,16
	ret

#done draw start screen image

DRAW_GOTCHA:
	subi sp, sp, 16
	stw r16,0(sp)
	stw r17,4(sp)
	stw r18,8(sp)
	stw r19,10(sp)
	
	movia r8, ADDR_VGA 	
	
	movia r19, gotcha 		#r14 is the pixel pointer points to the image
	mov r14, r19
	mov r10, r0  				#r10 is initial x=0 
	movui r11, 239 				#r11 is initial y=239
	movui r12, 320 				#r12 max limit for x
#draw the pixel
draw_gotcha_image:
	ldh r13,0(r14) 				#r13 stores pixel information
	muli r16,r10,2 				#r16 = x*2
	muli r17,r11,1024			#r17 = y*1024
	add r16,r16,r17				#r16= x*2 + y*1024
	add r18,r16,r8				#add offset to address
	sthio r13,0(r18) 			#draw the pixel

	addi r14,r14,2   			#increase pixel pointer
	addi r10,r10,1   			#increase x
	blt r10,r12,draw_gotcha_image 	#if x < 320, keep drawing 

	mov r10,r0   				#reset x
	subi r11, r11, 1	 			#decrease y
	bge r11,r0,draw_gotcha_image 	#if y > 0, keep drawing
	
	ldw r16,0(sp)
	ldw r17,4(sp)
	ldw r18,8(sp)
	ldw r19,10(sp)
	addi sp,sp,16
	ret
#done draw the gotcha image

DRAW_INS:

	subi sp, sp, 16
	stw r16,0(sp)
	stw r17,4(sp)
	stw r18,8(sp)
	stw r19,10(sp)
	
	movia r8, ADDR_VGA 	
	
	movia r19, INS		#r14 is the pixel pointer points to the image
	mov r14, r19
	mov r10, r0  				#r10 is initial x=0 
	movui r11, 239 				#r11 is initial y=239
	movui r12, 320 				#r12 max limit for x
#draw the pixel
draw_IN:
	ldh r13,0(r14) 				#r13 stores pixel information
	muli r16,r10,2 				#r16 = x*2
	muli r17,r11,1024			#r17 = y*1024
	add r16,r16,r17				#r16= x*2 + y*1024
	add r18,r16,r8				#add offset to address
	sthio r13,0(r18) 			#draw the pixel

	addi r14,r14,2   			#increase pixel pointer
	addi r10,r10,1   			#increase x
	blt r10,r12,draw_IN 	#if x < 320, keep drawing 

	mov r10,r0   				#reset x
	subi r11, r11, 1	 			#decrease y
	bge r11,r0,draw_IN 	#if y > 0, keep drawing
	
	ldw r16,0(sp)
	ldw r17,4(sp)
	ldw r18,8(sp)
	ldw r19,10(sp)
	addi sp,sp,16
	ret

#DONE DARW THE INSTRUCTION IMAGE
CLEAR_SCREEN:
	subi sp,sp, 12
	stw r16,0(sp)
	stw r17,4(sp)
	stw r18,8(sp)

	movia r8, ADDR_VGA 			
	mov r10, r0  				
	movui r11, 239 				
	movui r12, 320 				

Draw_black:
	muli r16,r10,2 
	muli r17,r11,1024
	add r16,r16,r17
	add r18,r16,r8
	sthio r0,0(r18) 	#draw black		

	
	addi r10,r10,1   			
	blt r10,r12,Draw_black 			

	mov r10,r0   				
	subi r11, r11, 1			
	bge r11,r0,Draw_black 		

#done drawing
	ldw r16,0(sp)
	ldw r17,4(sp)
	ldw r18,8(sp)
	addi sp,sp,12
	ret
#done clear screen
			

DRAW_AIM:
	subi sp, sp, 16
	stw r16,0(sp)
	stw r17,4(sp)
	stw r18,8(sp)
	stw r19,10(sp)
	
	movia r8, ADDR_VGA 	
	
	movia r19, aim_image 		#r14 is the pixel pointer points to the image
	mov r14, r19
	mov r10, r0  				#r10 is initial x=0 
	movui r11, 239 				#r11 is initial y=239
	movui r12, 320 				#r12 max limit for x
#draw the pixel
draw_aim_image:
	ldh r13,0(r14) 				#r13 stores pixel information
	muli r16,r10,2 				#r16 = x*2
	muli r17,r11,1024			#r17 = y*1024
	add r16,r16,r17				#r16= x*2 + y*1024
	add r18,r16,r8				#add offset to address
	sthio r13,0(r18) 			#draw the pixel

	addi r14,r14,2   			#increase pixel pointer
	addi r10,r10,1   			#increase x
	blt r10,r12,draw_aim_image 	#if x < 320, keep drawing 

	mov r10,r0   				#reset x
	subi r11, r11, 1	  			#decrease y
	bge r11,r0,draw_aim_image 	#if y > 0, keep drawing
	
	ldw r16,0(sp)
	ldw r17,4(sp)
	ldw r18,8(sp)
	ldw r19,10(sp)
	addi sp,sp,16
	ret
#done draw aim image
DRAW_CHANGE_AIM:
	subi sp, sp, 16
	stw r16,0(sp)
	stw r17,4(sp)
	stw r18,8(sp)
	stw r19,10(sp)
	
	movia r8, ADDR_VGA 	
	
	movia r19, aim_image_1 		#r14 is the pixel pointer points to the image
	mov r14, r19
	mov r10, r0  				#r10 is initial x=0 
	movui r11, 239 				#r11 is initial y=239
	movui r12, 320 				#r12 max limit for x
#draw the pixel
draw_aim_image_1:
	ldh r13,0(r14) 				#r13 stores pixel information
	muli r16,r10,2 				#r16 = x*2
	muli r17,r11,1024			#r17 = y*1024
	add r16,r16,r17				#r16= x*2 + y*1024
	add r18,r16,r8				#add offset to address
	sthio r13,0(r18) 			#draw the pixel

	addi r14,r14,2   			#increase pixel pointer
	addi r10,r10,1   			#increase x
	blt r10,r12,draw_aim_image_1 	#if x < 320, keep drawing 

	mov r10,r0   				#reset x
	subi r11, r11, 1	 			#decrease y
	bge r11,r0,draw_aim_image_1 	#if y > 0, keep drawing
	
	ldw r16,0(sp)
	ldw r17,4(sp)
	ldw r18,8(sp)
	ldw r19,10(sp)
	addi sp,sp,16
	ret
#done draw another aim image


DRAW_WIN_IMAGE:
	subi sp, sp, 16
	stw r16,0(sp)
	stw r17,4(sp)
	stw r18,8(sp)
	stw r19,10(sp)
	
	movia r8, ADDR_VGA 	
	
	movia r19, win_image 		#r14 is the pixel pointer points to the image
	mov r14, r19
	mov r10, r0  				#r10 is initial x=0 
	movui r11, 239 				#r11 is initial y=239
	movui r12, 320 				#r12 max limit for x
#draw the pixel
draw_win:
	ldh r13,0(r14) 				#r13 stores pixel information
	muli r16,r10,2 				#r16 = x*2
	muli r17,r11,1024			#r17 = y*1024
	add r16,r16,r17				#r16= x*2 + y*1024
	add r18,r16,r8				#add offset to address
	sthio r13,0(r18) 			#draw the pixel

	addi r14,r14,2   			#increase pixel pointer
	addi r10,r10,1   			#increase x
	blt r10,r12,draw_win 	#if x < 320, keep drawing 

	mov r10,r0   				#reset x
	subi r11, r11, 1	 			#decrease y
	bge r11,r0,draw_win 	#if y > 0, keep drawing
	
	ldw r16,0(sp)
	ldw r17,4(sp)
	ldw r18,8(sp)
	ldw r19,10(sp)
	addi sp,sp,16
	ret
	
	
DRAW_FINAL:
	subi sp, sp, 16
	stw r16,0(sp)
	stw r17,4(sp)
	stw r18,8(sp)
	stw r19,10(sp)
	
	movia r8, ADDR_VGA 	
	
	movia r19, final 		#r14 is the pixel pointer points to the image
	mov r14, r19
	mov r10, r0  				#r10 is initial x=0 
	movui r11, 239 				#r11 is initial y=239
	movui r12, 320 				#r12 max limit for x
#draw the pixel
draw_final_1:
	ldh r13,0(r14) 				#r13 stores pixel information
	muli r16,r10,2 				#r16 = x*2
	muli r17,r11,1024			#r17 = y*1024
	add r16,r16,r17				#r16= x*2 + y*1024
	add r18,r16,r8				#add offset to address
	sthio r13,0(r18) 			#draw the pixel

	addi r14,r14,2   			#increase pixel pointer
	addi r10,r10,1   			#increase x
	blt r10,r12,draw_final_1 	#if x < 320, keep drawing 

	mov r10,r0   				#reset x
	subi r11, r11, 1	 			#decrease y
	bge r11,r0,draw_final_1 	#if y > 0, keep drawing
	
	ldw r16,0(sp)
	ldw r17,4(sp)
	ldw r18,8(sp)
	ldw r19,10(sp)
	addi sp,sp,16
	ret