@function: replace a the character which is not a space with a space.
@parameters: r1 address
@return: no registers. A space is added to memory location of address r1
add_space:
    mov r4, #32
    strb r4, [r1]
    bx lr

@function: check if the character loaded from memory is a space.
@parameters: r3 and r1 address
@return: no registers. Comparison is delt with outside this function.
check:
    ldrb r3, [r1]
    cmp r3, #32
    bx lr

@function: print output too long message
@parameter: none
@return: nothing
print_input_too_long:
    ldr r1, =input_too_long
    mov r2, #15
    bl print
    pop {r0, r1, r2, r4, r7, lr}
    b guess_message

@function: exclude ascii range 1
@parameter: none
@return: nothing
inbetween_1:
    cmp r9, #48
    blt print_invalid_message
    bx lr

@function: exclude ascii range 2
@parameter: none
@return: nothing
inbetween_2:
    cmp r9, #65
    blt print_invalid_message
    bx lr

@function: exclude ascii range 3
@parameter: none
@return: nothing
inbetween_3:
    cmp r9, #97
    blt print_invalid_message
    bx lr

@function: exclude ascii range 4
@parameter: none
@return: nothing
inbetween_4:
    cmp r9, #127
    blt print_invalid_message
    bx lr

@function: print output invalid character
@parameter: none
@return: nothing
print_invalid_message:
    ldr r1, =invalid_input
    mov r2, #25
    bl print
    pop {r0, r1, r2, r4, r7, lr}
    b guess_message

@function: remove all previously played characters from last game
@parameters: no registers. Just load strings from memory
@return: no registers. Frame should be empty in memory
refresh_frame:
    push {r0-r9}
    ldr r1, =line03
    add r1, r1, #4
    bl check
    blne add_space
    ldr r1, =line04
    add r1, r1, #3
    bl check
    blne add_space
    ldr r1, =line04
    add r1, r1, #4
    bl check
    blne add_space
    ldr r1, =line04
    add r1, r1, #5
    bl check
    blne add_space
    ldr r1, =line05
    add r1, r1, #4
    bl check
    blne add_space
    ldr r1, =line06
    add r1, r1, #3
    bl check
    blne add_space
    ldr r1, =line06
    add r1, r1, #5
    bl check
    blne add_space
    ldr r1, =line04
    add r1, r1, #35
    mov r6, #54
    strb r6, [r1]
    ldr r1, =line05
    add r1, r1, #40
loop_space:
    bl check
    blne add_space
    add r1, r1, #2
    bne loop_space
    ldr r1, =enter_guess_message
    ldr r2, =add_hint_message
    add r1, r1, #24
    mov r5, #0
loop_refresh:
    cmp r5, #17
    beq end_refresh
    ldrb r3, [r2]
    strb r3, [r1]
    add r2, r2, #1
    add r1, r1, #1
    add r5, r5, #1
    bne loop_refresh
end_refresh:
    mov r12, #69
    pop {r0, r9}
    b start_game




@function: check if there are underscores left in the hidden word to determine if the hidden word is completely filled out
@parameters: no register parameters
@returns: no returns, jumps to win or back to keep guessing
check_underscores:
    push {r0-r7, r9}
    ldr r1, =line03
    add r1, r1, #26
loop_check_underscores:
    ldrb r4, [r1]
    cmp r4, #10
    bleq win
    cmp r4, #95
    beq return_game
    add r1, r1, #1
    bne loop_check_underscores
return_game:
    pop {r0-r7, r9}
    bx lr

@function: convert lower to upper case
@parameters: lower case letter in r3
@returns: upper case letter in r3
uppercase_conversion:
    push {r0-r2, r4-r9}
    sub r3, #32
    pop {r0-r2, r4-r9}
    bx lr

@function: show letter. Add one to the start address. If the number matches an '_' add this number to the beginning of the Word: in line 03. 
@Also load the character of the word at this number into a register. 
@parameters: r8, length of word
@return: r0, length of string for frame function. Also the hidden word should have a letter now
show_letter:
    pop {r1-r7}
    @add r11, r11, #1
    sub r10, r10, #2
    ldr r1, =line04
    add r1, r1, #35
    strb r10, [r1]
    cmp r10, #52
    bleq five_guesses_frame
    cmp r10, #51
    bleq five_guesses_frame
    bleq four_guesses_frame
    bleq remove_hint_message
    cmp r10, #50
    bleq five_guesses_frame
    bleq four_guesses_frame
    bleq three_guesses_frame
    bleq remove_hint_message
    cmp r10, #49
    bleq five_guesses_frame
    bleq four_guesses_frame
    bleq three_guesses_frame
    bleq two_guesses_frame
    bleq remove_hint_message
    cmp r10, #48
    bleq game_over
    bleq remove_hint_message
    cmp r10, #47
    bleq game_over
    bleq remove_hint_message
    ldr r1, =line03
    add r1, r1, #26
    mov r2, #0
loop_to_next:  
    ldrb r4, [r1]
    cmp r4, #95
    beq add_letter
    add r1, r1, #1
    add r2, r2, #1
    bne loop_to_next

add_letter:
    ldr r5, =word
    add r5, r5, r2
    ldrb r6, [r5]
    strb r6, [r1]
add_letters_further:
    add r5, r5, #1
    add r1, r1, #1
    ldrb r3, [r5]
    cmp r6, r3
    bleq store_byte
    cmp r3, #10
    beq done_further
    bne add_letters_further
done_further:
    add r0, r0, #25
    add r0, r0, r8
    pop {r1-r7}
    b add_man

store_byte:
    strb r6, [r1]
    bx lr

remove_hint_message:
    ldr r1, =enter_guess_message
    mov r3, #8
    add r1, r1, #32
loop_remove_hint_message:
    ldrb r5, [r1]
    strb r3, [r1]
    mov r12, #70
    cmp r5, #44
    bxeq lr
    add r1, r1, #1
    bne loop_remove_hint_message


@function: print error if file cant be opened
@parameters: -
@return: -
    push {r0-r9}
    ldr r1, =error_msg
    mov r2, #16
    bl print
    pop {r0-r9}
    bx lr

@function: print the game over frame
@parameters: length of line03 in r0
frame_game_over:
    push {r1, r2, lr}
    ldr r1, =line01
    mov r2, #7
    bl print
    ldr r1, =line02
    mov r2, #7
    bl print
    ldr r1, =line08
    mov r2, #7
    bl print
    ldr r1, =line09
    mov r2, #32
    bl print
    ldr r1, =line10
    mov r2, #7
    bl print
    ldr r1, =line11
    mov r2, #8
    bl print
    ldr r1, =line07
    mov r2, #8
    bl print
    pop {r1, r2, lr}
    bx lr

@function: print the frame
@parameters: length of line03 in r0
frame:
    push {r1, r2, lr}
    ldr r1, =line01
    mov r2, #7
    bl print
    ldr r1, =line02
    mov r2, #7
    bl print
    ldr r1, =line03
    mov r2, r0                          @length of string03
    bl print
    ldr r1, =line04
    mov r2, #37
    bl print
    ldr r1, =line05
    mov r2, #52
    bl print
    ldr r1, =line06
    mov r2, #7
    bl print
    ldr r1, =line07
    mov r2, #8
    bl print
    pop {r1, r2, lr}
    bx lr

@function: print function
print: 
    push {r0, r7}
    mov r0, #1
    mov r7, #4
    svc #0
    pop {r0, r7}
    bx lr

@function: read input
@parameters: address of input character in r1, value of input character in r3
enter_guess:
    push {r0, r1, r2, r4, r7, lr}
    ldr r1, =input
    mov r0, #0
    mov r2, #4
    mov r7, #3                          @system call to read the input
    svc #0
    ldrb r3, [r1]
    mov r4, #1
loop_guess:
    ldrb r9, [r1]
    cmp r4, #3
    beq print_input_too_long
    cmp r9, #32
    blgt inbetween_1
    cmp r9, #50
    blgt inbetween_2
    cmp r9, #90
    blgt inbetween_3
    cmp r9, #122
    blgt inbetween_4

    cmp r9, #9
    beq guess_done
    cmp r9, #32
    beq guess_done
    cmp r9, #10
    beq guess_done
    add r1, r1, #1
    add r4, r4, #1
    bne loop_guess
guess_done:
    cmp r3, #48
    beq exit
    cmp r3, #49
    beq show_letter
    cmp r3, #50
    beq refresh_frame
    cmp r3, #90
    blgt uppercase_conversion
check_already_guessed:
    push {r0-r2, r4-r9, lr}
    ldr r1, =line05
    add r1, r1, #40
    ldr r5, =line03
    add r5, r5, #26
loop_already_guessed:
    ldrb r6, [r5]
    cmp r6, #10
    beq end_loop
    cmp r3, r6
    ldreq r1, =print_already_guessed_message
    moveq r2, #48
    bleq print    
    popeq {r0-r2, r4-r9, lr}
    popeq {r0, r1, r2, r4, r7, lr}
    beq guess_message
    add r5, r5, #1
    bne loop_already_guessed
end_loop:
    ldrb r4, [r1]
    cmp r4, #10
    beq end_loop2
    cmp r4, #32
    beq end_loop2
    cmp r3, r4
    ldreq r1, =print_already_guessed_message
    moveq r2, #48
    bleq print    
    popeq {r0-r2, r4-r9, lr}
    popeq {r0, r1, r2, r4, r7, lr}
    beq guess_message
    add r1, r1, #2
    bne end_loop
end_loop2:
    pop {r0-r2, r4-r9, lr}
    pop {r0, r1, r2, r4, r7, lr}
    bx lr

@function: add O to the frame
@parameter: r10, number of guesses
@return: no return. Functions role is to store an 'o' in line03 and character position +4 characters.
five_guesses_frame:
    push {r0-r9}
    ldr r1, =line03
    add r1, r1, #4
    mov r6, #79
    strb r6, [r1]
    pop {r0-r9}
    bx lr

@function: add two | to the frame
@parameter: no register parameters
@return: no return. Functions role is to store a '|' in line04 and line05 and character position +4 characters.
four_guesses_frame:
    push {r0-r9}
    ldr r1, =line04
    add r1, r1, #4
    mov r6, #124
    strb r6, [r1]

    ldr r2, =line05
    add r2, r2, #4
    strb r6, [r2]
    pop {r0-r9}
    bx lr

@function: add an arm (\) to the frame
@parameter: no register parameters
@return: no return. Functions role is to store a '\' in line04 character position +3 characters.
three_guesses_frame:
    push {r0-r9}
    ldr r1, =line04
    add r1, r1, #3
    mov r6, #92
    strb r6, [r1]
    pop {r0-r9}
    bx lr

@function: add an arm (/) to the frame
@parameter: no register parameters
@return: no return. Functions role is to store a '/' in line04 character position +5 characters.
two_guesses_frame:
    push {r0-r9}
    ldr r1, =line04
    add r1, r1, #5
    mov r6, #47
    strb r6, [r1]
    pop {r0-r9}
    bx lr

@function: add leg (/) to the frame
@parameter: no register parameters
@return: no return. Functions role is to store a '/' in line05 character position +3 characters.
one_guess_frame:
    push {r0-r9}
    ldr r1, =line06
    add r1, r1, #3
    mov r6, #47
    strb r6, [r1]
    pop {r0-r9}
    bx lr

@function: add X and leg (\) to the frame
@parameter: r10, number of guesses
@return: no return. Functions role is to store an 'x' in line03 and character position +4 characters and '\' in line 6 at character position +5 characters
game_over:
    push {r0-r2, r4-r9}
    bl frame_game_over
    mov r4, #2
    ldr r1, =game_over_message
    ldr r1, =reserved2
    ldr r6, =word
loop_word:
    ldrb r3, [r6]
    strb r3, [r1]
    cmp r3, #10
    beq finished_word
    add r1, r1, #1
    add r6, r6, #1
    add r4, r4, #1
    bne loop_word
finished_word:
    mov r2, #20
    add r2, r2, r4
    ldr r1, =game_over_message
    bl print
    pop {r0-r2, r4-r9}

    ldr r1, = thanks_message
    mov r2, #52
    bl print
    ldr r1, = play_again_message
    mov r2, #36
    bl print
    ldr r1, =input
    push {r0, r2, r7}
    mov r0, #0
    mov r2, #2
    mov r7, #3                                  @system call to read the input
    svc #0
    pop {r0, r2, r7}
    ldrb r3, [r1]
    cmp r3, #48                                 @Decimal value for 0
    beq exit
    cmp r3, #121
    beq refresh_frame



win:
    push {r0-r9}
    bl frame
    ldr r4, =win_message
    add r4, r4, #37
    strb r10, [r4]
    ldr r1, =win_message
    mov r2, #52
    bl print
    ldr r1, = thanks_message
    mov r2, #53
    bl print
    ldr r1, = play_again_message
    mov r2, #36
    bl print
    ldr r1, =input
    push {r0, r2, r7}
    mov r0, #0
    mov r2, #2
    mov r7, #3                          @system call to read the input
    svc #0
    pop {r0, r2, r7}
    ldrb r3, [r1]
    cmp r3, #48
    beq exit
    cmp r3, #121
    beq refresh_frame
    pop {r0-r9}

.global main
main:
start_game:

@open the file containing guess words
@parameters: filename address
    push {r1-r9}
    ldr r0, =filename
    mov r1, #0
    mov r2, #0x444
    mov r7, #5
    svc #0

@check file was opened correctly - if not display error message
    cmp r0, #-1                     
    beq err

@set up memory location to store text from text file
@parameters: buffer address
    ldr r1, =buffer
    mov r2, #199
    mov r7, #3
    svc #0

@generate a number
@parameters: r0 = 0
@return: random nummber in r2
generate_number:
    mov r0, #0                  @pass 0 to r0 as argument to time call
    bl time                     @obtain current time of system
    bl srand                    @initialise the pseudo-random generator
    bl rand                     @get a random number
    and r0, r0, #0xFF
    mov r2, r0

    cmp r2, #84                 @#84 is length of string (minus last word) in memory
    bgt generate_number
    blt find_start

@find the start position of a word
@parameters: buffer address in r1, random number in r2, 10 (/n character) in r3
@return: no return, jump to store word function if conditions, (/n or 0) are met
find_start:
    mov r1, #0
    ldr r1, =buffer
    mov r3, #10
    mov r5, #0
    mov r6, #0
    add r1, r2                  @r1 = the address of beginning + random number in string of words

@add 1 to the current r1 address untill a new line, #10, is found
@parameters: random address position in string in r1, new line character r3
@return: r1, address of position of first character
loop_start:                     
    add r1, r6
    ldrb r5, [r1]
    cmp r5, r3
    beq store_word
    cmp r5, #0
    beq store_word
    mov r6, #1
    bne loop_start

@store word in reserved memory location 'word'
@parameters: address of position of first character in r1, new line character r3
@return: Length of word in r0
@free registers: r2, r6
store_word:
    mov r0, #0                  @store length of word
    ldr r5, =word
    mov r4, #0

@store each character into the address for 'word' by adding 1 to the current position in the string of words and to the word desination address
@parameters: address of word in r5, address of position of first character in r1, new line character r3
@return: no return, jump to add length function is condition is met
loop_store:
    add r1, r1, #1              @add 1 to get to the first character and 
    add r5, r5, r4              @add one during each loop to get to the next address to store the character in
    ldrb r6, [r1]
    strb r6, [r5]
    cmp r6, r3                  @compare character value with new line value
    beq add_length
    cmp r6, #0                  @compare character value with 'empty' value
    beq add_length
    mov r4, #1
    add r0, #1
    bne loop_store
    pop {r1-r9}

@add length of word represented by '_' to the end of line03
@parameters: number of characters to get to end of string03 in r2, address of line03, length of word in r0, underscore value #95 in r3, space value 32 in r4, newline value 10 in r5
@return: length of string in r6. Underscores and spaces should be added to the end of string03
add_length:
    ldr r1, =line03         @address of line location (first character - |)
    mov r2, #26
    mov r3, #95
    mov r5, #10
    mov r6, #0
    mov r4, #0
    add r1, r2              @address of line location + 27 (last character - :)


@parameters: address of line location + 27 (last character - :) in r1, underscore value in r3, space value in r4
@return: length of string in r6, address of line location at the end of the hidden word in r1
loop_length:
    add r1, r4
    strb r3, [r1]
    cmp r0, #0
    beq load_string
    sub r0, #1
    add r6, #1
    mov r4, #1
    bne loop_length

@calculate length of new line03 + hidden word
@parameters: address of end of line in r1, number of characters to get to end of string03 in r2, length of hidden word in r6, new line value in r5
@return: new length of line03 in r0
load_string:
    mov r4, #2
    mov r8, r6
    strb r5, [r1]               @store a new line character to the end of the line
    add r2, r6
    add r2, #1                  @add 3 representing the new line chracter to the r2
    mov r0, r2 


@<-- Beginning point of printing
    mov r11, #0
    mov r10, #54                      @Number of Guesses left: r4
    mov r12, #69
    ldr r1, =name_urn
    mov r2, #34
    bl print

    ldr r1, =welcome_message
    mov r2, #21
    bl print

    bl frame

guess_message:
    push {r1, r2}
    mov r1, #0
    ldr r1, =enter_guess_message
    mov r2, r12                       
    bl print
    pop {r1, r2}
    bl enter_guess


@function
@parameters: input letter r3
@return: no return. Jump to add_letter_to_hidden if condition is met and keep r3 and r5, length of word
check_letter:
    push {r0, r1, r4, r6, r7, r8, r9}
    ldr r1, =word
    ldr r9, =line03
    add r9, r9, #26
    mov r6, #0
    mov r5, #0                      @keep track of length to character in word
    loop_letters:
    add r1, r1, r6
    ldrb r4, [r1]                   @ load into r4, a letter from the word to guess
    @cmp r2, #1
    @beq finished
    cmp r4, #10                     @compare r4 to new line
    beq incorrect_letter            @if it is at the end of the word and there are no matches then go to incorrect letter function
    mov r6, #1
    cmp r3, r4
    beq add_letter_to_hidden
    add r5, #1
    bne loop_letters
    @cmp r2, #1
    @beq finished
    pop {r0, r1, r4, r6, r7, r8, r9}

@function :the guess is correct so display the character in the hidden word
@parameters: input letter in r3, length to character in r5
@return value: cant be r0 or r4 or r3. loops through the word and adds the character to the word. stores the new character line03. 
add_letter_to_hidden:
    add r9, r5
add_further_letter_to_hidden:
    strb r3, [r9]
    mov r2, #1                      @if r2 is 1 then the guess wasnt incorrect
    bl check_further_letters

check_further_letters:
    add r9, #1
    add r1, r1, r6
    ldrb r4, [r1]
    cmp r4, #10
    beq finished
    cmp r3, r4
    beq add_further_letter_to_hidden
    @add r5, #1
    bne check_further_letters


@function: the guess is incorrect so subtract 1 from r0. replace 6 in the string with this value and if guess is at 5 add an 'o' to the line aswell
@parameters: r10, number of guesses, r3 - input letter, 
@return:
incorrect_letter:
    sub r10, #1                  //subtract 1 from number of guesses left
    ldr r1, =line04
    add r1, r1, #35
    strb r10, [r1]
    ldr r1, =line05
    add r1, r1, #40
loop_incorrect_letter:
    ldrb r6, [r1]
    cmp r6, #32
    bne incorrect_letter_loop
    beq store_letter
incorrect_letter_loop:
    add r1, #2
    bl loop_incorrect_letter
store_letter:
    strb r3, [r1]
    cmp r10, #51
    bleq remove_hint_message
    bl add_man



@make the man
add_man:
    cmp r10, #53
    bleq five_guesses_frame               @put function at top and add a bx lr to bring it back

    cmp r10, #52
    bleq four_guesses_frame

    cmp r10, #51
    bleq three_guesses_frame

    cmp r10, #50
    bleq two_guesses_frame

    cmp r10, #49
    bleq one_guess_frame

    cmp r10, #48
    bleq game_over

    bl finished

finished:
@<-- Here add if there are no underscores left then the word was guessed so jump to 'win' function
    bl check_underscores
    bl frame
    bl guess_message

    

exit:
    ldr r1, = thanks_message
    mov r2, #53
    bl print
    mov r7, #1
    svc #0

.data

name_urn: .asciz "Hangman by Anna Carter (6702876)\n\n"
welcome_message: .asciz "Welcome To Hangman!\n\n"
enter_guess_message: .asciz "Enter your guess (A-Z), 1 to show letter, 2 to start new, 0 to exit: "

filename: .asciz "words.txt"

buffer: .space 200
word: .space 30


line01: .asciz "______\n"                                                                 @7
line02: .asciz "|/  | \n"                                                                 @7
line03: .asciz "|                    Word:"                                               @27
reserved: .space 99
line04: .asciz "|                    Guesses left: 6\n"                                   @35
line05: .asciz "|                    Incorrect guesses:            \n"                    @40
line06: .asciz "|     \n"                                                                 @7
line07: .asciz "|_____\n\n"                                                               @7

input: .space 4

line08: .asciz "|   x \n"
line09: .asciz "|  \\|/               GAME OVER\n"                                        @31
line10: .asciz "|   | \n"
line11: .asciz "|  / \\\n"

game_over_message: .asciz "Game over, word was "                                          @20
reserved2: .space 99


thanks_message: .asciz "\nThanks for playing hangman by Anna Carter (6702876)\n"          @53
play_again_message: .asciz "\nEnter 0 to exit or y to play again\n"                       @36

error_msg: .asciz "Cannot open file"

print_already_guessed_message: .asciz "That letter has already been entered, try again\n"
win_message: .asciz "Well done! You guessed the word with x guesses left\n"
add_hint_message: .asciz "1 to show letter,"
input_too_long: .asciz "Input too long\n"
invalid_input: .asciz "Invalid input, try again\n"     
.end
