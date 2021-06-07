# TODO: Haochen Liu 260917834
# TODO: Please see comments below for detailed explaination.
# TODO: SEE LABELS FOR PROCEDURES YOU MUST IMPLEMENT AT THE BOTTOM OF THIS FILE

.data
TestNumber:	.word 2		# TODO: Which test to run!
				# 0 compare matrices stored in files Afname and Bfname
				# 1 test Proc using files A through D named below
				# 2 compare MADD1 and MADD2 with random matrices of size Size
				
Proc:		MADD1		# Procedure used by test 2, set to MADD1 or MADD2		
				
Size:		.word 64		# matrix size (MUST match size of matrix loaded for test 0 and 1)

Afname:		.asciiz "A64.bin"
Bfname:		.asciiz "B64.bin"
Cfname:		.asciiz "C64.bin"
Dfname:	 	.asciiz "D64.bin"

#################################################################
# Main function for testing assignment objectives.
# Modify this function as needed to complete your assignment.
# Note that the TA will ultimately use a different testing program.
.text
main:		la $t0 TestNumber
		lw $t0 ($t0)
		beq $t0 0 compareMatrix
		beq $t0 1 testFromFile
		beq $t0 2 compareMADD
		li $v0 10 # exit if the test number is out of range
        		syscall	

compareMatrix:	la $s7 Size	
		lw $s7 ($s7)		# Let $s7 be the matrix size n

		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix A
		move $s0 $v0		# $s0 is a pointer to matrix A
		la $a0 Afname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s0
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix B
		move $s1 $v0		# $s1 is a pointer to matrix B
		la $a0 Bfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s1
		jal loadMatrix
	
		move $a0 $s0
		move $a1 $s1
		move $a2 $s7
		jal check
		
		li $v0 10      	# load exit call code 10 into $v0
        		syscall         	# call operating system to exit	

testFromFile:	la $s7 Size	
		lw $s7 ($s7)		# Let $s7 be the matrix size n

		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix A
		move $s0 $v0		# $s0 is a pointer to matrix A
		la $a0 Afname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s0
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix B
		move $s1 $v0		# $s1 is a pointer to matrix B
		la $a0 Bfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s1
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix C
		move $s2 $v0		# $s2 is a pointer to matrix C
		la $a0 Cfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s2
		jal loadMatrix
	
		move $a0 $s7
		jal mallocMatrix		# allocate heap memory and load matrix A
		move $s3 $v0		# $s3 is a pointer to matrix D
		la $a0 Dfname
		move $a1 $s7
		move $a2 $s7
		move $a3 $s3
		jal loadMatrix		# D is the answer, i.e., D = AB+C 
	
		# TODO: add your testing code here
		move $a0, $s0	# A
		move $a1, $s1	# B
		move $a2, $s2	# C
		move $a3, $s7	# n
		
		la $ra ReturnHere
		la $t0 Proc	# function pointer
		lw $t0 ($t0)	
		jr $t0		# like a jal to MADD1 or MADD2 depending on Proc definition

ReturnHere:	move $a0 $s2	# C
		move $a1 $s3	# D
		move $a2 $s7	# n
		jal check	# check the answer

		li $v0, 10      	# load exit call code 10 into $v0
	        	syscall         	# call operating system to exit	

compareMADD:	la $s7 Size
		lw $s7 ($s7)	# n is loaded from Size
		mul $s4 $s7 $s7	# n^2
		sll $s5 $s4 2	# n^2 * 4

		move $a0 $s5
		li   $v0 9	# malloc A
		syscall	
		move $s0 $v0
		move $a0 $s5	# malloc B
		li   $v0 9
		syscall
		move $s1 $v0
		move $a0 $s5	# malloc C1
		li   $v0 9
		syscall
		move $s2 $v0
		move $a0 $s5	# malloc C2
		li   $v0 9
		syscall
		move $s3 $v0	
	
		move $a0 $s0	# A
		move $a1 $s4	# n^2
		jal  fillRandom	# fill A with random floats
		move $a0 $s1	# B
		move $a1 $s4	# n^2
		jal  fillRandom	# fill A with random floats
		move $a0 $s2	# C1
		move $a1 $s4	# n^2
		jal  fillZero	# fill A with random floats
		move $a0 $s3	# C2
		move $a1 $s4	# n^2
		jal  fillZero	# fill A with random floats

		move $a0 $s0	# A
		move $a1 $s1	# B
		move $a2 $s2	# C1	# note that we assume C1 to contain zeros !
		move $a3 $s7	# n
		jal MADD1

		move $a0 $s0	# A
		move $a1 $s1	# B
		move $a2 $s3	# C2	# note that we assume C2 to contain zeros !
		move $a3 $s7	# n
		jal MADD2

		move $a0 $s2	# C1
		move $a1 $s3	# C2
		move $a2 $s7	# n
		jal check	# check that they match
	
		li $v0 10      	# load exit call code 10 into $v0
        		syscall         	# call operating system to exit	

###############################################################
# mallocMatrix( int N )
# Allocates memory for an N by N matrix of floats
# The pointer to the memory is returned in $v0	
mallocMatrix: 	mul  $a0, $a0, $a0	# Let $s5 be n squared
		sll  $a0, $a0, 2		# Let $s4 be 4 n^2 bytes
		li   $v0, 9		
		syscall			# malloc A
		jr $ra
	
###############################################################
# loadMatrix( char* filename, int width, int height, float* buffer )
.data
errorMessage: .asciiz "FILE NOT FOUND" 
.text
loadMatrix:	mul $t0 $a1 $a2 	# words to read (width x height) in a2
		sll $t0 $t0  2	  	# multiply by 4 to get bytes to read
		li $a1  0     		# flags (0: read, 1: write)
		li $a2  0     		# mode (unused)
		li $v0  13    		# open file, $a0 is null-terminated string of file name
		syscall
		slti $t1 $v0 0
		beq $t1 $0 fileFound
		la $a0 errorMessage
		li $v0 4
		syscall		  	# print error message
		li $v0 10         	# and then exit
		syscall		
fileFound:	move $a0 $v0     	# file descriptor (negative if error) as argument for read
  		move $a1 $a3     	# address of buffer in which to write
		move $a2 $t0	  	# number of bytes to read
		li  $v0 14       	# system call for read from file
		syscall           	# read from file
		# $v0 contains number of characters read (0 if end-of-file, negative if error).
                	# We'll assume that we do not need to be checking for errors!
		# Note, the bitmap display doesn't update properly on load, 
		# so let's go touch each memory address to refresh it!
		move $t0 $a3	# start address
		add $t1 $a3 $a2  	# end address
loadloop:	lw $t2 ($t0)
		sw $t2 ($t0)
		addi $t0 $t0 4
		bne $t0 $t1 loadloop		
		li $v0 16	# close file ($a0 should still be the file descriptor)
		syscall
		jr $ra	

##########################################################
# Fills the matrix $a0, which has $a1 entries, with random numbers
fillRandom:	li $v0 43
		syscall		# random float, and assume $a0 unmodified!!
		swc1 $f0 0($a0)
		addi $a0 $a0 4
		addi $a1 $a1 -1
		bne  $a1 $zero fillRandom
		jr $ra

##########################################################
# Fills the matrix $a0 , which has $a1 entries, with zero
fillZero:	sw $zero 0($a0)	# $zero is zero single precision float
		addi $a0 $a0 4
		addi $a1 $a1 -1
		bne  $a1 $zero fillZero
		jr $ra



######################################################
# TODO: void subtract( float* A, float* B, float* C, int N )  C = A - B 
subtract: 	mul $a3 $a3 $a3 # get n^2
		li $t0 0 # counter

subtractLoop:	beq $t0 $a3 subtractDone # if counter =n^2, then done
		lwc1 $f4 ($a0) # load matrix A
		lwc1 $f6 ($a1) # loac matrix B
		sub.s $f4 $f4 $f6 # subtract
		addi $a0 $a0 4 # next entry of A
		addi $a1 $a1 4 # next entry of B
		swc1 $f4 ($a2) # store result in C
		addi $a2 $a2 4 # next entry of C
		addi $t0 $t0 1 # increment counter
		j subtractLoop # back to loop

subtractDone:	li $t0 0 # reset counter
		jr $ra

#################################################
# TODO: float frobeneousNorm( float* A, int N )
frobeneousNorm:	mul $a1 $a1 $a1 # get n^2
		li $t0 0 
		mtc1 $t0 $f6 # set sum f6 to 0
		li $t1 0 # counter
		
FNLoop:		beq $t1 $a1 FNDone # if counter = n^2, then done
		lwc1 $f4 ($a0) # load matrix A
		addi $a0 $a0 4 # next entry of A
		mul.s $f4 $f4 $f4 # square of this entry
		add.s $f6 $f6 $f4 # add to the sum
		addi $t1 $t1 1 # increment counter
		j FNLoop # back to loop

FNDone:		sqrt.s $f0 $f6 # square root of the sum
		li $t1 0 # reset counter
		jr $ra

#################################################
# TODO: void check ( float* C, float* D, int N )
#                      a0         a1       a2
# Print the forbeneous norm of the difference of C and D
check: 		move $s0 $a0 # stores matrix C in s0
		move $s1 $a1 # stores matrix D in s1
		move $s2 $a2 # stores n in $a2
		sw $ra -4($sp)
		move $a2 $s0 # C as a2 for subtract
		move $a3 $s2 # n as a3 for subtract
		jal subtract #a0=C a1=D a2=C a3=n
		move $a0 $s0 # load matrix C to a0
		move $a1 $s2 # load n to a1. Now the arugments of fNorm are set.
		jal frobeneousNorm # a0=C a1=n
		li $t0 0
		mtc1 $t0 $f12 # set arugment register to 0
		add.s $f12 $f12 $f0 # get result from return register
		li $v0 2
		syscall # print
		lw $ra -4($sp)
		jr $ra

##############################################################
# TODO: void MADD1( float*A, float* B, float* C, N )
MADD1: 		move $t0 $zero #i
		move $t1 $zero #j
		move $t2 $zero #k
		j MA1MainLoop

MA1k:		addi $t2 $t2 1 #increment k
		beq $t2 $a3 MA1j # if at the end of this loop
		j MA1MainLoop

MA1j:		move $t2 $zero # reset k
		addi $t1 $t1 1 # increment j 
		beq $t1 $a3 MA1i # if at the end of this loop	
		j MA1MainLoop

MA1i:		move $t1 $zero # reset j
		addi $t0 $t0 1 # increment i
		beq $t0 $a3 MA1Done # if at the end of this loop	 

MA1MainLoop:	#get Aik, actual position is 4(ni+k)
		la $t3 ($a0)
		mul $t6 $t0 $a3 # n*i
		add $t6 $t6 $t2 # ni+k
		mul $t6 $t6 4 # offset of A=4(ni+k)
		add $t3 $t3 $t6 #get Aik
		lwc1 $f4 ($t3)
		#get Bkj, actual position is 4(nk+j)
		la $t4 ($a1)
		mul $t6 $t2 $a3 # n*k
		add $t6 $t6 $t1 # nk+j
		mul $t6 $t6 4 # offset of B=4(nk+j)
		add $t4 $t4 $t6 # get Bkj
		lwc1 $f6 ($t4)
		#get Cij, actual position is 4(ni+j)
		la $t5 ($a2)
		mul $t6 $t0 $a3 # n*i
		add $t6 $t6 $t1 # ni+j
		mul $t6 $t6 4 # offset of C=4(ni+j)
		add $t5 $t5 $t6	# get Cij
		lwc1 $f8 ($t5)
		# calculation
		mul.s $f4 $f4 $f6 # Aik*Bkj
		add.s $f8 $f8 $f4 # value to Cij
		swc1 $f8 ($t5) # store to C
		j MA1k

MA1Done:		jr $ra
#########################################################
# TODO: void MADD2( float*A, float* B, float* C, N )
MADD2: 		move $t0 $zero # jj
		move $t1 $zero # kk
		move $t2 $zero # i
		move $t3 $zero # j
		move $t4 $zero # k
		mtc1 $zero $f4 #sum
		j MA2MainLoop # go to mainloop
		
# updating loop conditions, checking conditions, and doing resets
MA2k0:		addi $t4 $t4 1 # increment k by 1
		addi $t8 $t1 4 # kk+bsize
		blt $t8 $a3 MA2k1 # getting mininum of kk+size and n
		blt $t4 $a3 MA2MainLoop # n is min, back to mainloop if k is still less than it
		j MA2j0 # otherwise go update j loop
MA2k1:		blt $t4 $t8 MA2MainLoop # kk+size is min, back to mainloop if k is still less than it
MA2j0:		#get Cij, actual position is 4(ni+j)
		la $t7 ($a2)
		mul $t8 $t2 $a3 # n*i
		add $t8 $t8 $t3 # ni+j
		mul $t8 $t8 4 # offset of C=4(ni+j)
		add $t7 $t7 $t8 # get Cij
		lwc1 $f6 ($t7) # load          
		add.s $f6 $f6 $f4 
		swc1 $f6 ($t7) # store
		addi $t3 $t3 1 # increment j by 1
		addi $t8 $t0 4 # jj + bsize
		blt $t8 $a3 MA2j1 # getting minimum of jj+size and n
		blt $t3 $a3 MA2NewkLoop # N is min, start a new k loop if j is still less than it
		j MA2i # otherwise go to i loop
MA2j1:		blt $t3 $t8 MA2NewkLoop # jj+bsize is min, start a new k loop if j is still less than it
		j MA2i # otherwise go update i loop
		
MA2NewkLoop:	move $t4 $t1 #initialize k
		mtc1 $zero $f4 #initialize the sum	
		j MA2MainLoop # go to mainloop

MA2i:		addi $t2 $t2 1 # increment i by 1
		blt $t2 $a3 MA2NewjLoop # if i<N, then start a new j loop
		j MA2kk # otherwise go update the kk loop
		
MA2NewjLoop:	move $t3 $t0 # reset j
		j MA2NewkLoop # start a new j loop, also go start a new k loop

MA2kk:		addi $t1 $t1 4 # increment kk by bsize
		blt $t1 $a3 MA2NewiLoop #if kk<N, then start a new i loop
		j MA2jj # otherwise go update jj loop
		
MA2NewiLoop:	move $t2 $zero # reset i
		j MA2NewjLoop # start a new i loop, also go start a new j loop
		
MA2jj:		addi $t0 $t0 4 # increment jj by bsize
		blt $t0 $a3 MA2NewkkLoop # if jj<N, then start a new kk loop
		j MA2Done # otherwise the entire process is completed, go return

		
MA2NewkkLoop: 	move $t1 $zero #initialize kk
		j MA2NewiLoop

MA2MainLoop:	#get Aik, actually position is 4(ni+k)
		la $t5 ($a0)
		mul $t8 $t2 $a3 # n*i
		add $t8 $t8 $t4 # ni+k
		mul $t8 $t8 4 # offset of A=4(ni+k)
		add $t5 $t5 $t8
		lwc1 $f6 ($t5)
		#get Bkj, actual position is 4(nk+j)
        		la $t6 ($a1)
        		mul $t8 $t4 $a3 # n*k
        		add $t8 $t8 $t3 # nk+j
        		mul $t8 $t8 4 # offset of B=4(nk+j)
        		add $t6 $t6 $t8
        		lwc1 $f8 ($t6) # load 
		mul.s $f6 $f6 $f8 # get product
		add.s $f4 $f4 $f6 # add to the sum
		j MA2k0 # go check the loop conditions

MA2Done: 	jr $ra	# done
