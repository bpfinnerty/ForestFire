#
# FILE:         forestfire.asm
# AUTHOR:       Brian Finnerty
# SECTION:      1
#
# DESCRIPTION:
#       This program is an implementation of a varriation of Conways
#       Game of Life. This will implement Forest Fire in MIPS assembly
#       along with the rule variations added.
#
# ARGUMENTS:
#       None
#
# INPUT:
#       The Grid Size as an integer. The Number of Generations that
#       the Game will play. The direction of the wind and finally the
#       initial state of the board.
#
# OUTPUT:
#       The Specified banner of FOREST FIRE followed by a new line.
#       After that there will be an output for the current generation
#       of the board and then the actual simulation board printed below.
#       
#

#-------------------------------

#
# Numeric Constants
#
MIN_GRID = 4
MAX_GRID = 30
MIN_GEN = 0
MAX_GEN = 20
READ_CHAR = 12
PRINT_CHAR = 11
PRINT_STRING = 4
READ_STRING = 8
READ_INT = 5
PRINT_INT = 1
STRING_LENGTH= 40

#
# DATA AREAS
#
        .data
        .align  2               # word data must be on word boundaries
gridSize:
        .word 0                 # the size of the grid

genLen:
        .word 0                 # Generations that was inputed

windCheck:
        .align 2                # numerical value with NESW being 0123
        .word 1

boardOne:
        .align 2                # The data block that will represent a board
        .space 1000

boardTwo:                       # Another 1000 bytes to store upto 30 lines
       .align 2
       .space 1000

rowOne:
        .align 2                # an array to hold the starts of the strings
        .word 0,1,2,3,4,5,6,7,8,9 
        .word 0,1,2,3,4,5,6,7,8,9
        .word 0,1,2,3,4,5,6,7,8,9
rowTwo:
                                # an array that will keep track of th start
                                # of strings in boardTwo. 
        .word 0,1,2,3,4,5,6,7,8,9
        .word 0,1,2,3,4,5,6,7,8,9
        .word 0,1,2,3,4,5,6,7,8,9

junkString:
        .space 40               # this is for the unput so i can edit it

#
# Constants for the Code
#
        .align 2
char_N:
        .ascii  "N"             # for checking wind directions
char_E:
        .ascii  "E"
char_S:
        .ascii  "S"
char_W:
        .ascii  "W"
char_t:
        .ascii  "t"             # the next three are for checking input str
char_dot:
        .ascii  "."
char_B:
        .ascii  "B"
fourEqualString:
        .asciiz "===="          # print out header
spaceString:
        .asciiz " "             # print out for header
newLine:
        .asciiz "\n"            # for printing newlines
errorWindString:
        .asciiz "ERROR: invalid wind direction\n"
errorGridString:
        .asciiz "ERROR: invalid grid size\n"
errorGenString:
        .asciiz "ERROR: invalid number of generations\n"
errorGridCharString:
        .asciiz "ERROR: invalid character in grid\n"
bannerTop:
        .asciiz "+-------------+\n"
bannerMiddle:
        .asciiz " FOREST FIRE " # these few are for errors and banner
plusString:
        .asciiz "+"             # for the actual grid i must display
plusNewString:
        .asciiz "+\n"           # for the grid
dashString:
        .asciiz "-"             # for the grid top and bottom
#
# Globals
# 
        .align 2
        .text
        .globl main             # this all exists in one file. Not super
                                # pretty but it does work


#
# Name:         MAIN PROGRAM
#
# Description:  Main logic for the program.
#
#               The program reads four different values from standard
#                       input:
#               1) an integer representing the dimensions of the grid
#               2) an integer representing the number of generations 
#                       the game will display
#               3) a character representing the direction of the wind
#               4) a set of strings representing the values in the board
#               
#               After processing all input data and error checking, 
#                       the program will start the simulation of the 
#                       game forest fire
#               
#               
#

main:
        addi    $sp, $sp, -40   # allocate space on the stack
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
        sw      $s4, 16($sp)
        sw      $s5, 20($sp)
        sw      $s6, 24($sp)
        sw      $s7, 28($sp)
        sw      $ra, 32($sp)

        
        li      $v0, READ_INT   # input for dimensions of grid
        syscall
        move    $a0, $v0
        jal     processGridSize # error checking for the size

        li      $v0, READ_INT   # input for the num of Generations
        syscall
        move    $a0, $v0        # error check the generation num
        jal     processGeneration

        li      $v0, READ_CHAR  # input for the wind direction
        syscall
        move    $a0,$v0
        li      $v0, READ_CHAR
        syscall                 # removes newline from buffer
        jal     processWind     # error checking for that char

                                # the next code block will handle the
                                # grid inputed by the user
        
        la      $t6, boardOne   # get first row
        la      $t7, rowOne     # go to array of row addresses
        sw      $t6, 0($t7)     # store address of first row

        la      $t0, gridSize
        lw      $s0, 0($t0)     # load grid size for num of strings to read
        li      $s1, 0          # counter for my loop
        
stringInputLoop:
        beq     $s0, $s1, stringInputDone
        li      $v0, READ_STRING
        la      $a0, junkString
        li      $a1, STRING_LENGTH
        syscall                 # this will read in the current string
        la      $a0, junkString # get string ready for processing
        move    $a1, $s0        # how many chars i should see
        move    $a2, $s1        # what row it will go in
        jal     processGridString
        addi    $s1, $s1, 1     # enumerate the row we are on
        j       stringInputLoop

stringInputDone:
                                # handled all input, time to work
        jal     printBanner     # display banner if error isnt thrown
        la      $t6, boardTwo   # store start of board into
        la      $t7, rowTwo     # 0th row of the array
        sw      $t6, 0($t7)

        la      $a0, rowOne     # the next funtion will be so that I have
        la      $t0, gridSize   # the addrs for boardTwo to allow for easy
        lw      $a1, 0($t0)     # acces
        jal     copyIntoRow2    

        la      $a0, rowTwo     # the board that will recieve the changes
        la      $a1, rowOne     # the previous generation board
        li      $a2, 0          # the current generation
        jal     simulateForestFire
        
exit:   
                                # everything is done and time to return
        lw      $s0, 0($sp)
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw      $s5, 20($sp)
        lw      $s6, 24($sp)
        lw      $s7, 28($sp)
        lw      $ra, 32($sp)
        addi    $sp, $sp, 40
        jr      $ra
        
        
#
# Name:         processGridSize
#
# Description:  Check the requirements for the grid and ensure that
#               the input value falls within the bounds of 
#               4<= n <= 30
#
# Arguments:    a0 contains the potential size of the grid
#

processGridSize:
        li      $t0, 4          # These are the constants for the grid 
        li      $t1, 30         # constant boundary for grid
        slt     $t9, $a0, $t0   # if the size is less than 4
        bne     $t9, $zero, gridError
        slt     $t9, $t1, $a0   # if the size is greater than 30
        bne     $t9, $zero, gridError
        
        la      $t0, gridSize   # if it's a good number, then store it
        sw      $a0, 0($t0)
        jr      $ra

gridError:
        jal     printBanner     # display the banner
        li      $v0, PRINT_STRING
        la      $a0, errorGridString
        syscall                 # output error to screen
        j       exit            # terminate program

#
# Name:         processGeneration
#
# Description:  Check the requirements for the gens and ensure that
#               the input value falls within the bounds of
#               0<= n <= 20
#
# Arguments:    a0 contains the potential number of generations
#

processGeneration:
        li      $t0, 20         # These are the constants for the grid
        slt     $t9, $a0, $zero # if the input is negative, throw error
        bne     $t9, $zero, genError
        slt     $t9, $t0, $a0   # if the input > 20 throw error
        bne     $t9, $zero, genError

        la      $t0, genLen     # otherwise store it for later
        sw      $a0, 0($t0)
        jr      $ra

genError:
        jal     printBanner     # output banner
        li      $v0, PRINT_STRING
        la      $a0, errorGenString
        syscall                 # display error
        j exit                  # terminate program
#
# Name:         processWind
#
# Description: Checks to ensure a valid direction has been inputed
#               Then it will either throw an error if incorrect or
#               store that data in the appropriate block
#
# Arguments:    a0 contains the character that was read
#
processWind:
        # This first section of it will attemt to see if the user
        # inputed the north direction
        lbu     $t0, char_N     # check if the character is an  N
        bne     $a0, $t0, notNorth
        li      $t1, 1          # this is the numerical value I want for N
        la      $t2, windCheck  # stored as wind direction
        sw      $t1, 0($t2)
        jr      $ra             # now I return to move on

notNorth:
        lbu     $t0, char_E     # lets check if the user wants East
        bne     $a0, $t0, notEast
        li      $t1, 2          # numerical value for East
        la      $t2, windCheck
        sw      $t1, 0($t2)
        jr      $ra

notEast:
        lbu     $t0, char_S     # lets check if the user wanted Sout
        bne     $a0, $t0, notSouth
        li      $t1, 3          # numerical value for south
        la      $t2, windCheck
        sw      $t1, 0($t2)
        jr      $ra

notSouth:
        lbu     $t0, char_W     # the last direction that is possible is W
        bne     $a0, $t0, windError
        li      $t1, 4          # numerical value for W
        la      $t2, windCheck
        sw      $t1, 0($t2)
        jr      $ra

windError:
        jal     printBanner     # print banner
        li      $v0, PRINT_STRING
        la      $a0, errorWindString
        syscall                 # display error
        j       exit            # terminate program

#
# Name:         processGridString
#
# Description:  This method will take a string of a given len, look at each
#               character and determine if it is one of the allowed chars.
#               From there that char will be stored into block1 and this
#               will continue for every char in the string. Then the address
#               of the front of the string will be stored in the appropriate
#               rowBlock1
#
# Arguments:    a0 contains the address of the string to process
#               a1 contains the number of correct chars i should see
#               a2 contains an integer of which row i am on
#
processGridString:
        li      $t9, 0          # counter
        li      $t8, 4          # offset for the array
        la      $t0, rowOne     # the array I will store it (points to grid)
        mul     $t1, $a2, $t8   # what row i should access in bytes
        add     $t0, $t0, $t1   # now ive put on the offset for the row
        lw      $t1, 0($t0)     # address of where i store the processed str
        move    $t2, $a0
        
processStringLoop:
        beq     $t9, $a1, processStringDone
        lbu     $t3, 0($t2)     # get char from junk string
        lbu     $t4, char_B     # First check to see if this is burning
        bne     $t3, $t4, notB
        
        sb      $t3, 0($t1)     # if this is a B, store it into the row
        addi    $t1, $t1, 1     # shift all of my counters
        addi    $t2, $t2, 1
        addi    $t9, $t9, 1
        j processStringLoop     # keep going trhough loop
notB:
        lbu     $t4, char_t     # character of t
        bne     $t3, $t4, notT
        
        sb      $t3, 0($t1)
        addi    $t1, $t1, 1     # shift all of my counters
        addi    $t2, $t2, 1
        addi    $t9, $t9, 1
        j processStringLoop     # keep going trhough loop
notT:
        lbu     $t4, char_dot   # check for if this is the .
        bne     $t3, $t4, errorOnChar
        sb      $t3, 0($t1)
        addi    $t1, $t1, 1     # shift all of my counters
        addi    $t2, $t2, 1
        addi    $t9, $t9, 1
        j processStringLoop     # keep going trhough loop

errorOnChar:
        jal     printBanner     # display banner
        li      $v0, PRINT_STRING
        la      $a0, errorGridCharString
        syscall                 # error for invalid character
        j       exit            # terminate program
processStringDone:
        sb      $zero, 0($t1)   # null terminate the row
        addi    $t1, $t1, 1     # shift block pointer over by 1
        addi    $t0, $t0, 4     # shift rowOne over to next row
        sw      $t1, 0($t0)     # store adr after as the start of next row
        jr      $ra


#
# Name:         copyIntoRow2
#
# Description:  This method will simply copy the structure of the
#               grid from row 1 into row 2. This is helpful for later
#               so i can have "array" access to strings without doing
#               lots of math for the offests
#
# Arguments:    a0 is the addrs of what to copy
#               a1 is the size of the grid
#
copyIntoRow2:
        li      $t9, 0          # counter for the loop
        la      $t0, rowTwo     # address of row 2. 0th is set to 0 of b2
copyOuterLoop:
        beq     $t9, $a1, copyOuterDone
        lw      $t1, 0($a0)     # string from block 1
        lw      $t2, 0($t0)     # string from block 2
        li      $t8, 0          # inner loop counter
copyInnerLoop:
        beq     $t8, $a1, copyInnerDone
        lbu     $t3, 0($t1)     # char from string one
        sb      $t3, 0($t2)     # put that onto string twu
        addi    $t1, $t1, 1     # increment counters
        addi    $t2, $t2, 1
        addi    $t8, $t8, 1
        j       copyInnerLoop
copyInnerDone:
        sb      $zero, 0($t2)   # null terminator
        addi    $t2, $t2, 1     # shift addrs of string by 1
        move    $t4, $t0
        addi    $t4, $t4, 4     # this will shift the array to its next spot
        sw      $t2, 0($t4)     # push new address onto array. 
        addi    $t9, $t9, 1     # increment counters
        addi    $a0, $a0, 4
        addi    $t0, $t0, 4
        j       copyOuterLoop   # go back to top until we are done
copyOuterDone:
        jr      $ra             # block 2 now looks like block 1, return

#
# Name:         simulateForestFire
#
# Description:  This method start off the simulation for the game
#               it will print off the head line. After that it will
#               walk through the changing of the boards and then output
#               each new generation for each recursive call until we
#               are on the number of generations requested
#               
#               
#
# Arguments:    a0 will hold the addr of the active array (to be filled)
#               a1 will hold the addr of the previous array
#               a2 will hold the generation the simulation is on
#
simulateForestFire:
        addi    $sp, $sp, -52   # allocate space on the stack
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
        sw      $s4, 16($sp)
        sw      $s5, 20($sp)
        sw      $s6, 24($sp)
        sw      $s7, 28($sp)
        sw      $ra, 32($sp)
        sw      $a0, 36($sp)
        sw      $a1, 40($sp)
        sw      $a2, 44($sp)

        move    $s0, $a0        # the active board that will change
        move    $s1, $a1        # the previous board
        move    $s2, $a2        # the generation
        
        la      $t0, genLen     # figure out how many gens I can have
        lw      $t0, 0($t0)
        addi    $t0, $t0, 1     # add 1 for simplicity/ slt
        slt     $t9, $s2, $t0   # if s2<genLen+1, then keep goin
        beq     $t9, $zero, simulateDone
        
        move    $a0, $s1        # give it the board to print out
        move    $a1, $s2        # and the number it needs
        jal     printBoard
        
        li      $s3, 0          # counter for loop
        la      $t8, gridSize
        lw      $s5, 0($t8)     # get size of grid for loop
        
        move    $t0, $s0        # active board that needs to be changed
        move    $t1, $s1        # previous board that will be looked at

convertOuterLoop:
        beq     $s3, $s5, convertOuterLoopDone
        lw      $t2, 0($t0)     # String from active board
        lw      $t3, 0($t1)     # string from previous board
        li      $s4, 0          # counter for inner loop
convertInnerLoop:
        beq     $s4, $s5, convertInnerLoopDone
        li      $s6, 0          # 0 = no burning tree found adj
        lbu     $t4, 0($t3)     # get char from previous string
        la      $t5, char_dot
        lbu     $t5, 0($t5)     # get the value for the dot
        bne     $t4, $t5, convertNotDot
        
        addi    $t2, $t2, 1     # increment the counters
        addi    $t3, $t3, 1
        addi    $s4, $s4, 1
        j       convertInnerLoop
convertNotDot:
        lbu     $t4, 0($t3)     # get char from previous string
        la      $t5, char_B
        lbu     $t5, 0($t5)     # get the value for the B
        bne     $t4, $t5, convertNotB
        la      $t5, char_dot   # place dot where burnt tree ws
        lbu     $t5, 0($t5)
        sb      $t5, 0($t2)
 
        addi    $t2, $t2, 1     # increment counters
        addi    $t3, $t3, 1
        addi    $s4, $s4, 1
        j       convertInnerLoop
convertNotB:
        beq     $zero, $s3, lookEast
        move    $t4, $t1        # get array, i need to go backwards 1
        addi    $t4, $t4, -4    # move where i am looking up one row
        lw      $t4, 0($t4)     # get the string one level up

        add     $t4, $s4, $t4   # shift array over to the same offset
        lbu     $t5, 0($t4)     # get the character above my current
        la      $t6, char_B     # load burning character
        lbu     $t6, 0($t6)     # check if prev char is a Burning Tree
        beq     $t5, $t6, northBurn
        la      $t6, char_dot   # check if prev char is a grass space
        lbu     $t6, 0($t6)
        beq     $t5, $t6, northDot
        j       lookEast        # cant do anything to another tree
northBurn:
        li      $s6, 1          # place holder to replace yourself witha B
        j       lookEast        # now move onto next space
northDot:
        la      $t7, windCheck  # check to see if wind is North
        lw      $t7, 0($t7)
        li      $t8, 1          # now I have to check the correct wind Dic
        bne     $t7, $t8, lookEast
        
        move    $t4, $t0
        addi    $t4, $t4, -4    # now the active grid's . must turn into tree
        lw      $t4, 0($t4)     # gets row above
        add     $t4, $t4, $s4   # put offset onto string
        la      $t5, char_t
        lbu     $t5, 0($t5)     # get tree character
        sb      $t5, 0($t4)     # replace . with a t
        j       lookEast
lookEast:
        move    $t4, $t3        # we will be looking 1 to the right 
        addi    $t4, $t4, 1     # shift prev over by 1
        lbu     $t4, 0($t4)
        move    $t5, $s4        # check if i am on the boundary (no rgt edge)
        addi    $t5, $t5, 1
        beq     $t5, $s5, lookSouth
        
        la      $t5, char_B
        lbu     $t5, 0($t5)     # check if prev char is a Burning Tree
        beq     $t4, $t5, eastBurn
        
        la      $t5, char_dot   # is the character an empty space
        lbu     $t5, 0($t5)     # check if prev char is an empty spot
        beq     $t4, $t5, eastDot
        j       lookSouth
eastBurn:
        li      $s6, 1          # the current tree should change to B
        j       lookSouth
eastDot:
        la      $t7, windCheck  # eastern wind direction?
        lw      $t7, 0($t7)
        li      $t8, 2          # now I have to check the correct wind Dic
        bne     $t7, $t8, lookSouth

        move    $t4, $t2        
        addi    $t4, $t4, 1     # now the active grid's . must turn into tree
        
        la      $t5, char_t
        lbu     $t5, 0($t5)     # get tree character
        sb      $t5, 0($t4)     # put tree where the . was
        j       lookSouth
lookSouth:
        move    $t9, $t3        # cannot be on the bottom row of grid
        addi    $t9, $t9, 1
        beq     $s5, $t9, lookWest
        
        move    $t4, $t1        # get array, i need to go forwards 1
        addi    $t4, $t4, 4     # move where i am looking up one row
        lw      $t4, 0($t4)     # get the string one level lower
        add     $t4, $s4, $t4   # shift array over to the same offset
        
        lbu     $t5, 0($t4)     # get the character below my current
        la      $t6, char_B
        lbu     $t6, 0($t6)     # check if prev char is a Burning Tree
        beq     $t5, $t6, southBurn
        
        la      $t6, char_dot   # check if prev char is a grass space
        lbu     $t6, 0($t6)
        beq     $t5, $t6, southDot
        
        j       lookWest        # cant do anything to another tree
southBurn:
        li      $s6, 1          # tree should burn this gen
        j       lookWest
southDot:
        la      $t7, windCheck  # south wind direction
        lw      $t7, 0($t7)
        li      $t8, 3          # now I have to check the correct wind Dic
        bne     $t7, $t8, lookWest

        move    $t4, $t0
        addi    $t4, $t4, 4     # now the active grid's . must turn into tree
        lw      $t4, 0($t4)     # gets row above
        add     $t4, $t4, $s4   # put offset onto string
        la      $t5, char_t
        lbu     $t5, 0($t5)     # get tree character
        sb      $t5, 0($t4)     # put tree into empty grass
        j       lookWest
lookWest:
        move    $t4, $t3        # cant be on left edge
        addi    $t4, $t4, -1    # shift prev over by 1
        beq     $s4, $zero, convertTreeDone

        lbu     $t4, 0($t4)
        la      $t5, char_B
        lbu     $t5, 0($t5)     # check if prev char is a Burning Tree
        beq     $t4, $t5, westBurn

        la      $t5, char_dot
        lbu     $t5, 0($t5)     # check if prev char is an empty spot
        beq     $t4, $t5, westDot
        j       convertTreeDone
westBurn:
        li      $s6, 1
        j       convertTreeDone # the tree will burn
westDot:
        la      $t7, windCheck
        lw      $t7, 0($t7)
        li      $t8, 4          # now I have to check the correct wind Dic
        bne     $t7, $t8, convertTreeDone

        move    $t4, $t2
        addi    $t4, $t4, -1    # now the active grid's . must turn into tree

        la      $t5, char_t
        lbu     $t5, 0($t5)     # get tree character
        sb      $t5, 0($t4)     # out tree into empty grass
        j       convertTreeDone
convertTreeDone:
        li      $t9, 1          # should the tree turn into a B
        beq     $s6, $t9, burntDown
        la      $t5, char_t
        lbu     $t5, 0($t5)     # tree lives to the next generation
        sb      $t5, 0($t2)
        j       incrementConvert
burntDown:
        la      $t5, char_B
        lbu     $t5, 0($t5)     # the tree will start burning now
        sb      $t5, 0($t2)

incrementConvert:
        addi    $t2, $t2, 1     # increment everything
        addi    $t3, $t3, 1
        addi    $s4, $s4, 1
        j       convertInnerLoop
convertInnerLoopDone:
        addi    $t0, $t0, 4     # shift over to the next pair of strings
        addi    $t1, $t1, 4
        addi    $s3, $s3, 1     # increment the row
        j       convertOuterLoop

convertOuterLoopDone:
        move    $a0, $s0        # was having trouble with the boards
        la      $t9, gridSize        
        lw      $a1, 0($t9)     # my fix was to ensure they both look the same
        move    $a2, $s1        # prevents anythign missed
        jal     copyIntoRow
        
        move    $a0, $s1        # recursively call itself for next gen
        move    $a1, $s0
        move    $a2, $s2
        addi    $a2, $a2, 1
        jal     simulateForestFire

simulateDone:
        lw      $s0, 0($sp)     # simulation over
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw      $s5, 20($sp)
        lw      $s6, 24($sp)
        lw      $s7, 28($sp)
        lw      $ra, 32($sp)
        lw      $a0, 36($sp)
        lw      $a1, 40($sp)
        lw      $a2, 44($sp)
        addi    $sp, $sp, 52
        jr      $ra             # function will now terminate

#
# Name:         printBoard
#
# Description:  This method will display the generation banner and board
#               
#
#
#
# Arguments:    a0 will hold the addr of the board to be printed
#               a1 will hold the generation
#
printBoard:
        addi    $sp, $sp, -48   # allocate space on the stack
        sw      $s0, 0($sp)
        sw      $s1, 4($sp)
        sw      $s2, 8($sp)
        sw      $s3, 12($sp)
        sw      $s4, 16($sp)
        sw      $s5, 20($sp)
        sw      $s6, 24($sp)
        sw      $s7, 28($sp)
        sw      $ra, 32($sp)
        sw      $a0, 36($sp)
        sw      $a1, 40($sp)
        
        move    $s0, $a0
        move    $s1, $a1

        li      $v0, PRINT_STRING
        la      $a0, fourEqualString
        syscall                 # prints the generation header
        
        li $v0, PRINT_STRING
        la      $a0, spaceString
        syscall                 # prints new line
        
        li      $v0, PRINT_CHAR
        li      $a0, 35
        syscall                 # prints the pound symbol
        
        li      $v0, PRINT_INT
        move    $a0, $s1
        syscall                 # prints the gen number

        li      $v0, PRINT_STRING
        la      $a0, spaceString
        syscall                 # more spacing
 
        li      $v0, PRINT_STRING
        la      $a0, fourEqualString
        syscall                 # prints equals for header
        
        li      $v0, PRINT_STRING
        la      $a0, newLine
        syscall                 # newline
        
        la      $t0, gridSize
        lw      $t0, 0($t0)
        li      $t8, 0
        
        li      $v0, PRINT_STRING
        la      $a0, plusString
        syscall                 # topper for the grid
dashLoop:
        beq     $t8, $t0, dashLoopDone
        
        li      $v0, PRINT_STRING
        la      $a0, dashString # printing all the required dashes
        syscall
        addi    $t8, $t8, 1
        j       dashLoop
dashLoopDone:

        li      $v0, PRINT_STRING
        la      $a0, plusNewString
        syscall                 # prints the corner plus sign
        
        move    $t1, $s0
        move    $t8, $zero
       
boardLoop:
        beq     $t8, $t0, boardLoopDone
        
        li      $v0, PRINT_CHAR
        li      $a0, 124        # this is for the | character
        syscall 
        
        lw      $a0, 0($t1)
        li      $v0, PRINT_STRING
        syscall                 # prints string of characters for grid
        addi    $t1, $t1, 4 

        li      $v0, PRINT_CHAR
        li      $a0, 124        # ascii code for |
        syscall
        
        li      $v0, PRINT_STRING
        la      $a0, newLine    # brings it down a row
        syscall
        
        addi    $t8, $t8, 1     # increment the row I am on
        j       boardLoop

boardLoopDone:
        
        li      $v0, PRINT_STRING
        la      $a0, plusString
        syscall                 # bottom left corner
        li      $t8, 0

lastDashLoop:
        beq     $t8, $t0, lastDashLoopDone

        li      $v0, PRINT_STRING
        la      $a0, dashString
        syscall                 # dashes for the bottom of grid
        addi    $t8, $t8, 1
        j       lastDashLoop
lastDashLoopDone:
  
        li      $v0, PRINT_STRING
        la      $a0, plusNewString
        syscall                 # final plus sign

        li      $v0, PRINT_STRING
        la      $a0, newLine
        syscall                 # required spacing
        
        lw      $s0, 0($sp)     # now the function is done printing
        lw      $s1, 4($sp)
        lw      $s2, 8($sp)
        lw      $s3, 12($sp)
        lw      $s4, 16($sp)
        lw      $s5, 20($sp)
        lw      $s6, 24($sp)
        lw      $s7, 28($sp)
        lw      $ra, 32($sp)
        lw      $a0, 36($sp)
        lw      $a1, 40($sp)
        addi    $sp, $sp, 48
        jr      $ra

#
# Name:         printBanner
#
# Description:  This method will utilize the string in the data block
#               to properly print the banner to this game
#
#
#
# Arguments: NONE
#
#
#
printBanner:
        li      $v0, PRINT_STRING
        la      $a0, bannerTop  # print banner top
        syscall

        li      $v0, PRINT_CHAR
        li      $a0, 124        # this is the | char ascii code
        syscall

        li      $v0, PRINT_STRING
        la      $a0, bannerMiddle
        syscall                 # the forest fire string

        li      $v0, PRINT_CHAR
        li      $a0, 124        # ascii for  |
        syscall

        li      $v0, PRINT_STRING
        la      $a0, newLine    # brings row down
        syscall

        li      $v0, PRINT_STRING
        la      $a0, bannerTop  # print off the bottom of the banner
        syscall
        
        li      $v0, PRINT_STRING
        la      $a0, newLine
        syscall
        jr      $ra


#
# Name:         copyIntoRow
#
# Description:  This method will simply copy the values from grid 1
#               into grid 2
#
# Arguments:    a0 is the addrs of what to copy
#               a1 is the size of the grid
#               a2 is where the copy will be stored
#
copyIntoRow:
        li      $t9, 0          # counter for the loop
        move    $t0, $a0        # address of row. This is what I want to copy
        move    $t1, $a2        # this addr is where i want to copy to
copyOuterRowLoop:
        beq     $t9, $a1, copyOuterRowDone
        lw      $t2, 0($t0)     # string the copyer
        lw      $t3, 0($t1)     # string from storage
        li      $t8, 0          # inner loop counter
copyInnerRowLoop:
        beq     $t8, $a1, copyInnerRowDone
        lbu     $t4, 0($t2)     # char from string one
        sb      $t4, 0($t3)     # put that onto string two
        addi    $t2, $t2, 1     # increment counters
        addi    $t3, $t3, 1
        addi    $t8, $t8, 1
        j       copyInnerRowLoop
copyInnerRowDone:
        addi    $t9, $t9, 1     # shift arrays and incrememnt counters
        addi    $t0, $t0, 4
        addi    $t1, $t1, 4
        j       copyOuterRowLoop
copyOuterRowDone:
        jr      $ra             # nothing else to copy
