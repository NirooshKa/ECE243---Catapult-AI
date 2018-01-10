.equ ADDR_SLIDESWITCHES, 0xFF200040
.equ ADDR_REDLEDS, 0xFF200000
.equ ADDR_JP1, 0xFF200060   # Address GPIO JP1 
.equ TIMER, 0xFF202000
.equ HEX0TO3, 0xFF200020
.equ numCycles, 26 

.section .text
.global _start

##IF THE PERSON SCORES 5 POINTS, THEY WIN!!

_start:
#INITIALIZATION ----------------------------------------------------------

  movia r2,ADDR_SLIDESWITCHES
  movia r5,ADDR_REDLEDS
  movia  r8, ADDR_JP1  
  movia r25, HEX0TO3

  movia  r9, 0x07f557ff       # set direction for motors to all output 
  stwio  r9, 4(r8)
  movia r16, TIMER  
  movi r13, 9 #Value to compare the sensors against
  movia r24, 0x00000006 #This is where the score will be stored
  
  stwio r24, 0(r25)
  
  
  
  
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
  #Checking if the shot somehow makes it in/on to the target
  ble r11,r13, SCORE
  ble r12,r13, SCORE

  
  #This stage is impossible to reach (Defensive Programming)
  br _start

## ALL POSSIBLE CAR COMBINATIONS START HERE~!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!  
  
TRICK_SHOT:
#LED DEBUGGING
movi r3,0xFF
stwio r3, 0(r5)  
#Moves the motor 
movia r9,  0xffffffcf          # motor2 enabled (bit0=0), direction set to forward (bit1=0) 
stwio r9, 0(r8)

ble r11,r13, SCORE
ble r12,r13, SCORE

#CHECK SENSOR TO SEE IF SHOT IS VALID
br _start
  
SHOOT: 
#LED DEBUGGING
  movi r3, 2
  stwio r3, 0(r5)
#THIS MOVES THE MOTOR
  movia r9,0xffffffef         # motor2 enabled (bit0=0), direction set to forward (bit1=0) 
  stwio r9, 0(r8)
  
  ble r11,r13, SCORE
  ble r12,r13, SCORE
  
##CHECKS SENSORS TO SEE IF VALUE IS VALID  
br _start

GORIGHT:
#LED DEBUGGING
  movi r3, 1
  stwio r3, 0(r5)
#THIS MOVES THE MOTOR

  movia r9, 0xfffffffb         # motor0 enabled (bit0=0), direction set to forward (bit1=0) 
  stwio r9, 0(r8)
  
  br _start
  
GOLEFT:
#LED DEBUGGING
  movi  r3,0xFF
  stwio r3,0(r5)        	  # Write to LEDs 
#THIS MOVES THE MOTOR
  movia	 r9, 0xfffffff3       # motor0 enabled (bit0=0), direction set to reverse (bit1=1) 
  stwio	 r9, 0(r8)	

  
  br _start
  
STOP:
#LED DEBUGGING  
  movi  r3,0x00
  stwio r3,0(r5)        # Write to LEDs
#THIS MOVES THE MOTOR  
  movia	 r9, 0xffffffff       #EVERYTHING IS TURNED OFF
  stwio	 r9, 0(r8)	

  
  br _start
 
 
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
 br _start

 SCORE:
 #LED FOR DEBUGGING
  movi  r3,0x5
  stwio r3,0(r5)        # Write to LEDs
  br _start
 


