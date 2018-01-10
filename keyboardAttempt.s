#My Constants
.equ PS2, 0xFF200100
.equ LED, 0xFF200000 #For testing purposes only
.equ BREAK_CODE1, 0x000000E0 #This is for the space bar
.equ BREAK_CODE2, 0x000000F0 #This is for the arrow keys
.equ LEFT_KEY, 0x0000006B 
.equ RIGHT_KEY, 0x00000074
.equ SPACE_KEY, 0x00000029 #Shoot the projectile!
.equ DOWN_KEY, 0x00000072#Stop
.equ ADDR_CHAR, 0x09000000
#------------------------------------------------

.section .exceptions, "ax"
movia r16, PS2
movia r23, LED

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

#Filling up the registers with values going to be used later on in the code	(This makes the keys perform any action)
PRESS_SPACE:
movi r21, 0
stwio r21, 0(r23)
br END_ISR

PRESS_DOWN:
movi r21, 1
stwio r21, 0(r23)
br END_ISR

PRESS_LEFT:
movi r21, 2
stwio r21, 0(r23)
br END_ISR

PRESS_RIGHT:
movi r21, 5
stwio r21, 0(r23)
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

movia r16, PS2

movi r11, 0x1
stwio r11, 4(r16)#Read enable interrupt

movi r11, 0x80 #keyboard interrupt (irq7)
wrctl ctl3,r11 #Set enable for irq7
movi r12, 0x01
wrctl ctl0, r12#Set PIE bit
 ##Somehow find a way to deal with external interrupts 
   movia r3, ADDR_CHAR 
  movi  r5, 0x49   /* ASCII for 'I' */
  stbio r5,3850(r3) /* x=20, y=30 */
  movi  r5, 0x4E   /* ASCII for 'N' */
  stbio r5,3852(r3) /* x=35, y=30 */
  movi  r5, 0x53   /* ASCII for 'S' */
  stbio r5,3854(r3) /* x=40, y=30 */
  movi  r5, 0x54  /* ASCII for 'T' */
  stbio r5,3856(r3) /* x=45, y=30 */
  movi  r5, 0x52   /* ASCII for 'R' */
  stbio r5,3858(r3) /* x=50, y=30 */
  movi  r5, 0x55   /* ASCII for 'U' */
  stbio r5,3860(r3) /* x=50, y=30 */
  movi  r5, 0x43   /* ASCII for 'C' */
  stbio r5,3862(r3) /* x=50, y=30 */
  movi  r5, 0x54  /* ASCII for 'T' */
  stbio r5,3864(r3) /* x=45, y=30 */
  movi  r5, 0x49   /* ASCII for 'I' */
  stbio r5,3866(r3) /* x=30, y=30 */
  movi  r5, 0x4F  /* ASCII for 'O' */
  stbio r5,3868(r3) /* x=45, y=30 */
  movi  r5, 0x4E   /* ASCII for 'N' */
  stbio r5,3870(r3) /* x=35, y=30 */
  movi  r5, 0x3A   /* ASCII for ':' */
  stbio r5,3872(r3) /* x=35, y=30 */
  movi  r5, 0x53   /* ASCII for 'S' */
  stbio r5,2595(r3) /* x=35, y=20 */
  movi  r5, 0x70   /* ASCII for 'p' */
  stbio r5,2597(r3) /* x=35, y=20 */
  movi  r5, 0x61   /* ASCII for 'a' */
  stbio r5,2599(r3) /* x=35, y=20 */
  movi  r5, 0x63   /* ASCII for 'c' */
  stbio r5,2601(r3) /* x=35, y=20 */
  movi  r5, 0x65   /* ASCII for 'e' */
  stbio r5,2603(r3) /* x=35, y=20 */
  movi  r5, 0x3A   /* ASCII for ':' */
  stbio r5,2605(r3) /* x=35, y=30 */
  movi  r5, 0x53   /* ASCII for 'S' */
  stbio r5,2607(r3) /* x=40, y=30 */
  movi  r5, 0x68   /* ASCII for 'h' */
  stbio r5,2609(r3) /* x=40, y=30 */
  movi  r5, 0x6F   /* ASCII for 'o' */
  stbio r5,2611(r3) /* x=40, y=30 */
  movi  r5, 0x6F   /* ASCII for 'o' */
  stbio r5,2613(r3) /* x=40, y=30 */
  movi  r5, 0x74   /* ASCII for 't' */
  stbio r5,2615(r3) /* x=40, y=30 */
 
  movi  r5, 0x1A   /* ASCII for '->' */
  stbio r5,3876(r3) /* x=40, y=30 */
  movi  r5, 0x3A   /* ASCII for ':' */
  stbio r5,3879(r3) /* x=35, y=30 */
  movi  r5, 0x4D   /* ASCII for 'M' */
  stbio r5,3881(r3) /* x=35, y=30 */
  movi  r5, 0x6F   /* ASCII for 'o' */
  stbio r5,3883(r3) /* x=40, y=30 */
  movi  r5, 0x76   /* ASCII for 'v' */
  stbio r5,3885(r3) /* x=40, y=30 */
  movi  r5, 0x65   /* ASCII for 'e' */
  stbio r5,3887(r3) /* x=40, y=30 */
  movi  r5, 0x52   /* ASCII for 'R' */
  stbio r5,3890(r3) /* x=40, y=30 */
  movi  r5, 0x69   /* ASCII for 'i' */
  stbio r5,3892(r3) /* x=40, y=30 */
  movi  r5, 0x67   /* ASCII for 'g' */
  stbio r5,3894(r3) /* x=40, y=30 */
  movi  r5, 0x68   /* ASCII for 'h' */
  stbio r5,3896(r3) /* x=40, y=30 */
  movi  r5, 0x74   /* ASCII for 't' */
  stbio r5,3898(r3) /* x=40, y=30 */
  movi  r5, 0x1B   /* ASCII for '>' */
  stbio r5,5156(r3) /* x=40, y=30 */
  movi  r5, 0x3A   /* ASCII for ':' */
  stbio r5,5159(r3) /* x=35, y=30 */
  movi  r5, 0x4D   /* ASCII for 'M' */
  stbio r5,5161(r3) /* x=35, y=30 */
  movi  r5, 0x6F   /* ASCII for 'o' */
  stbio r5,5163(r3) /* x=40, y=30 */
  movi  r5, 0x76   /* ASCII for 'v' */
  stbio r5,5165(r3) /* x=40, y=30 */
  movi  r5, 0x65   /* ASCII for 'e' */
  stbio r5,5167(r3) /* x=40, y=30 */
  movi  r5, 0x4C   /* ASCII for 'L' */
  stbio r5,5170(r3) /* x=40, y=30 */
  movi  r5, 0x65   /* ASCII for 'e' */
  stbio r5,5172(r3) /* x=40, y=30 */
  movi  r5, 0x66   /* ASCII for 'f' */
  stbio r5,5174(r3) /* x=40, y=30 */
  movi  r5, 0x74   /* ASCII for 't' */
  stbio r5,5176(r3) /* x=40, y=30 */
  movi  r5, 0x19   /* ASCII for DOWN ARROW */
  stbio r5,6435(r3) /* x=40, y=30 */
  movi  r5, 0x3A   /* ASCII for ':' */
  stbio r5,6437(r3) /* x=35, y=30 */
  movi  r5, 0x53   /* ASCII for 'S' */
  stbio r5,6440(r3) /* x=40, y=30 */
  movi  r5, 0x74   /* ASCII for 't' */
  stbio r5,6442(r3) /* x=40, y=30 */
  movi  r5, 0x6F   /* ASCII for 'o' */
  stbio r5,6444(r3) /* x=40, y=30 */
  movi  r5, 0x70   /* ASCII for 'p' */
  stbio r5,6446(r3) /* x=40, y=30 */
  loop:
  br loop


 
