TITLE Project 6 - String Primatives and Macros     (Proj6_hossanf.asm)

; Author: Farris Hossan
; Last Modified: 12/10/2023
; OSU email address: hossanf@oregonstate.edu
; Course number/section:  CS271 Section 400
; Project Number: 6 - String Primatives and Macros     Due Date: 12/10/2023
; Description:  This program uses two macros for string processing that use Irvine's
;				ReadString and WriteString. ReadString is used to read a string of digits
;				in its raw format, then the input is converted into ASCII code. The
;				input is a series of ten signed integers, which is converted from 
;				the string input into its corresponding ASCII numeric form. The input
;				is validated and can handle + and - signs. From there the program
;				calculates the sum and the truncated average, however, whenever the
;				array is printed it is converted back into its original string format
;				before being printed to screen. 



INCLUDE Irvine32.inc


; -----------------------------------------------------------------------------
; Name : mGetString
;
; Macro  uses Irvine32's ReadString to read input from user, and stores
; to an array memory location. After ReadString is called the length
; is stored in ECX, and the output array is stored in EDX. The String
; output is null terminated automatically. 
;
; Preconditions :	All parameters are initialized in the data section,
;					and passed in the specific order required of the macro. 
;
; Postconditions :  None
;
; Recieves : 
;	userPrompt			: Address offset of string prompt asking for user input
;	memoryLocation		: Address offset of array where the user input is to 
;						  be saved.
;	userInputLimit		: The maximum amount of bytes to be stored in given array 
;						  location
;	userInputLength		: Location to store length of recorder input from user.
;
; Returns  :	 The user input stored in memoryLocation, and the length of the 
;				 user in put stored in inputLength. 
;------------------------------------------------------------------------------

mGetString  MACRO  userPrompt, memoryLocation, userInputLimit, userInputLength  

	PUSH		EDX
	PUSH		ECX
	PUSH		EAX

	; Prompt user for input
	MOV			EDX, userPrompt
	CALL		WriteString

	; Get input from user, save to array
	; EDX - Address of user string, ECX - Buffer size
	MOV			EDX, memoryLocation
	MOV			ECX, userInputLimit
	CALL		ReadString

	; Saves length of user input string
	MOV			userInputLength, EAX			

	POP			EAX
	POP			ECX
	POP			EDX
ENDM


; -----------------------------------------------------------------------------
; Name : mDisplayString
;
; Macro  uses Irvine32's WriteString to write string requested. 
;
; Preconditions :	All parameters are initialized in the data section. 
; Postconditions :  None
;
; Recieves : 
;	stringToPrint : Address of the string to print to screen. 
;
; Returns  :		Prints the passed string to the terminal. 
;------------------------------------------------------------------------------

mDisplayString	MACRO  stringToPrint

	PUSH		EDX

	; String offset passed to EDX
	MOV			EDX, stringToPrint
	CALL		WriteString

	POP			EDX

ENDM


NUMBER_LIMIT EQU 10
MAX_INPUT_LENGTH EQU 15 


.data

titleMessage		BYTE	"Project 6 - Low Level I/O: String Primatives and Macros", 0  
dispAuthor			BYTE	"               By  Farris Hossan", 0  
instruction1		BYTE	"Please provide 10 signed decimal integers.", 0  
instruction2		BYTE	"Each number needs to be small enough to fit inside a 32 bit register.", 0  
instruction3		BYTE	"After you have finished inputting the numbers I will display a list of", 13,10
					BYTE	"the integers, their sum, and their average value.", 0  

requestInteger		BYTE	"Please enter a signed integer :  ", 0  
errorMessage		BYTE	"ERROR: You did not enter a proper signed number or your number was too big. ",13, 10, 0  
inputSummary		BYTE	"You entered the following numbers: ", 0  
inputSumMessage		BYTE	"The sum of these numbers is: ", 0  
inputAverageMsg		BYTE	"The truncated average is: ", 0
goodbyeMessage		BYTE	"Thanks for playing! Goodbye!", 13, 10, 0 

userInputNumbers	BYTE	MAX_INPUT_LENGTH DUP(?)  
convertedStringArr	SDWORD	NUMBER_LIMIT DUP(?)
userInputLength		DWORD	0

spaceChar			BYTE	" ", 0
commaChar			BYTE	",", 0

outStringArray		BYTE	MAX_INPUT_LENGTH DUP(?)

.code
main PROC

;------------------------------------------------------------------------------
;	Display Program Title and Author 
;
;------------------------------------------------------------------------------

	; Addresses of Title and Author strings
	PUSH		OFFSET	titleMessage
	PUSH		OFFSET	dispAuthor

	CALL		displayTitle

;------------------------------------------------------------------------------
;	Introduction and Instructions to Program
;
;------------------------------------------------------------------------------
	
	; Addresses of program instruction
	PUSH		OFFSET	instruction1
	PUSH		OFFSET	instruction2
	PUSH		OFFSET	instruction3

	CALL		introduction

;------------------------------------------------------------------------------
;	Get User Input
;
;------------------------------------------------------------------------------	
;	-	Section sets up the loop to retrieve user input and store it in the 
;		Destination array. This array is then converted into ASCII encoding
;		within the ReadVal procedure. 
;------------------------------------------------------------------------------

	MOV			EDI,  OFFSET convertedStringArr		; Converted string location
	MOV			ECX,  NUMBER_LIMIT					; 10 numbers max

_getNumbers:
	; Data Locations
	PUSH		EDI
	PUSH		OFFSET	convertedStringArr
	PUSH		OFFSET	userInputLength
	PUSH		OFFSET	userInputNumbers
	PUSH		OFFSET	outStringArray

	; String messsages
	PUSH		OFFSET	requestInteger
	PUSH		OFFSET	errorMessage

	CALL		ReadVal

	; Move to next array location (SDWORD), loop till 10 recieved
	ADD			EDI, 4
	LOOP		_getNumbers

;------------------------------------------------------------------------------
;	Display Input : Show Validated User Input
;
;------------------------------------------------------------------------------
;	-	Print numbers and revert Integers to ASCII representation. 
;	-	Calls the WriteVal procedure to reconvert the numbers to ASCII to be
;		printed on screen, by WriteString in the mDisplayString Macro. 
;------------------------------------------------------------------------------

	; Memory Locations
	PUSH		OFFSET	outStringArray
	PUSH		OFFSET	convertedStringArr

	; Character Strings and Summary message
	pUSH		OFFSET	spaceChar
	PUSH		OFFSET	commaChar
	PUSH		OFFSET	inputSummary

	CALL		displayInput

;------------------------------------------------------------------------------
;	Perform Calculations : Calculate and Display Sum and Average
;
;-----------------------------------------------------------------------------
;	-	Performs a summation of user input, and finds the truncated average
;------------------------------------------------------------------------------

	; Memory Locations
	PUSH		OFFSET	outStringArray
	PUSH		OFFSET	convertedStringArr

	; Display messages
	PUSH		OFFSET	inputSumMessage
	PUSH		OFFSET	inputAverageMsg

	CALL		perfromCalculations

;------------------------------------------------------------------------------
;	End of Program Goodbye Message
;
;------------------------------------------------------------------------------
;	-	Displays a leaving salutation and exits program
;------------------------------------------------------------------------------
	
	; Say farewell
	PUSH		OFFSET	goodbyeMessage
	CALL		sayGoodbye

	Invoke ExitProcess,0	; exit to operating system

main ENDP



;------------------------------------------------------------------------------
;	Name : displayTitle
;
;	Displays the program title and the authors name printed to screen. 
;
;	Preconditions : The address of the program title and authors name are 
;					pushed onto the stack. 
;	Recieves  :
;		[EBP + 12]		= Address of program title string
;		[EBP + 8]		= Address of program author string
; 
;	Returns : The title and the author are printed to screen. 
;------------------------------------------------------------------------------

displayTitle PROC

	PUSH		EBP 
	MOV			EBP, ESP  

	; Print Program Title
	mDisplayString	 [EBP + 12]
	CALL		CrLf

	; Print Program Author
	mDisplayString	 [EBP + 8]
	CALL		CrLf
	CALL		CrLf

	POP			EBP  
	RET			8 

displayTitle ENDP

;------------------------------------------------------------------------------
;	Name : introduction
;	
;	This procedure describes how the program works, and instructs the user to
;	enter ten signed integers, that will later be displayed, summed and averaged. 
;
;	Preconditions : The address offsets of the stings are pushed onto the stack
;
;	Recieves  :
;		[EBP + 16]		= Address of the instruction1 string
;		[EBP + 12]		= Address of the instruction2 string
;		[EBP + 8]		= Address of the instruction3 string
;
;	Returns :	All three instructions are printed to screen.
;------------------------------------------------------------------------------

introduction PROC

	PUSH		EBP 
	MOV			EBP, ESP  
	
	; Print Program instructions 1,2,3. New line each string
	mDisplayString	 [EBP + 16] 
	CALL		CrLf
	mDisplayString	 [EBP + 12] 
	CALL		CrLf
	mDisplayString	 [EBP + 8] 
	CALL		CrLf

	CALL		CrLf

	POP			EBP  
	RET			12 

introduction ENDP

;------------------------------------------------------------------------------
;	Name : ReadVal
;
;	Procedure gets input from user and uses WriteString within the called macro
;	to store integer inputs as a string array. The strings are then converted
;	into integers before being stored in their destination array in EDI. 
;
;	Preconditions : All address offsets are pushed onto the stack
;
;	Postconditions : Recorded user input is stored in an array. After being
;					 converted from its ASCII format. 
;
;	Recieves  :
;		[EBP + 32]		= Address of where the where the converted ASCII string
;		[EBP + 28]		= Address of the converted string is stored
;		[EBP + 24]		= Address of user input string length
;		[EBP + 20]		= Address of where the user input numbers are stored
;		[EBP + 16]		= Address of where WriteVal out will be stored
;		[EBP + 12]		= Address of user prompt to enter numbers string
;		[EBP + 8]		= Address of the error message string
;
;	Returns : Array filled with signed integer values stored in an array. 
;------------------------------------------------------------------------------

ReadVal PROC

	PUSH		EBP 
	MOV			EBP, ESP  	

	PUSH		EAX
	PUSH		EBX
	PUSH		ECX
	PUSH		EDX
	PUSH		ESI
	PUSH		EDI

_GetInputFromUser:
	; Pass userPrompt, memoryLocation, userInputLimit, userInputLength to MACRO
	mGetString	[EBP + 12], [EBP + 20], MAX_INPUT_LENGTH, [EBP + 24]

	; ECX - user input string length, ESI - string input
	MOV			ECX, [EBP + 24]
	MOV			ESI, [EBP + 20]

	; Validate string length
	CMP			ECX, 12							; Accomodates sign and null terminator
	JAE			_ErrorMessage
	CMP			ECX, 0
	JBE			_ErrorMessage

	; Load first string character
	XOR			EAX, EAX
	CLD
	LODSB

	; Ignore sign characters if present
	; ASCII value for +
	CMP			AL, 43							
	JE			_LoadNextChar
	; ASCII value for -
	CMP			AL, 45							
	JE			_LoadNextChar

	JMP			_ValidateUserInput

_LoadNextChar:
	; Skip sign, Load next character
	DEC			ECX
	LODSB

_ValidateUserInput:
	; Ensures that user input is within the ASCII code range for integers 0-9
	; ASCII value for 0
	CMP			AL, 48							
	JB			_ErrorMessage
	; ASCII value for 9
	CMP			AL, 57							
	JA			_ErrorMessage

	LODSB
	LOOP		_ValidateUserInput

_ConvertInput:
	; Validation is complete, convert from ASCII representation

	MOV			ESI, [EBP + 20]					; Input array
	MOV			ECX, [EBP + 24]					; String length
	MOV			EDI, [EBP + 32]					; Output array

	; Move past null terminator to read string backwards
	XOR			EBX, EBX
	MOV			EBX, ECX
	SUB			EBX, 1
	
	ADD			ESI, EBX

	; Set registers for Loop
	MOV			EDX, 1
	XOR			EAX, EAX
	XOR			EBX, EBX

_RunConversion:
	; Start from the last input character
	XOR			EAX, EAX
	STD
	LODSB

	; Check if + sign, we've reached the end
	CMP			AL, 43
	JE			_EndConversion

	; Check if - sign, negate number and end
	CMP			AL, 45
	JE			_NegateNumber

	; Perform ASCII conversion, according to explorations
	SUB			AL, 48
	PUSH		EDX
	MUL			EDX
	ADD			EBX, EAX

	; If too big to fit in register throw error
	JO			_ErrorMessage

	; EDX - increases by a factor of 10 each loop
	POP			 EAX
	; Multipy EAX By 10 and store back in EAX, Restore EDX
	IMUL		 EAX, EAX, 10
	MOV			 EDX, EAX

	LOOP		_RunConversion
	JMP			_EndConversion

_NegateNumber:
	; Two's complement the number and save
	NEG			EBX
	MOV			[EDI], EBX
	JMP			_ExitReadVal

_EndConversion:
	; Save and Exit Conversion
	MOV			[EDI], EBX
	JMP			_ExitReadVal

_ErrorMessage:
	; Inform user of invalid input, get user input again
	mDisplayString		[EBP + 8]
	JMP			_GetInputFromUser

_ExitReadVal:

	POP			EDI
	POP			ESI
	POP			EDX
	POP			ECX
	POP			EBX
	POP			EAX
	
	POP			EBP  
	RET			32 

ReadVal ENDP

;------------------------------------------------------------------------------
;	Name : WriteVal
;	
;	Procedure takes a signed numeric value and translates it into ASCII encoding.
;	This procedure is called by the performCalculations to write the integer
;	values into ASCII encoding. After conversion the macro mDisplayString is 
;	invoked to print the string to screen. 
;
;	Preconditions : The address offsets of the array and the 
;
;	Postconditions : The converted value is stored in the outstring array. Value
;					 to be converted must be passed onto the stack.
;	Recieves  :
;		[EBP + 28]		= Address of value to be converted from calling procedure
;		[EBP + 32]		= Address of user input array
; 
;	Returns : Prints the value to screen after converting the number to a string
;------------------------------------------------------------------------------
WriteVal PROC USES EAX EBX ECX EDX EDI

	PUSH		EBP
	MOV			EBP, ESP

	MOV			EAX, [EBP + 28]					; Value to conert
	MOV			EDI, [EBP + 32]					; Output destination

_CheckIfNegative:
	; Determine if number is negative in value
	CMP			EAX, 0
	JL			_MakeNegative

	; Push Null terminator to be popped
	PUSH		0
	JMP			_ConvertToASCII

_MakeNegative:
	; Move "-" sign into AL, so it can be printed
	PUSH		EAX
	MOV			AL, 45
	
	; Print negative sign	
	CLD
	STOSB
	mDisplayString	[EBP + 32]										

	; Return to start of array after sign, negate value
	SUB			EDI, 1
	POP			EAX
	NEG			EAX

	; Push null terminator to be popped later
	PUSH		0

_ConvertToASCII:
	; Sequential divison by 10 to find base number
	XOR			EDX, EDX
	MOV			EBX, 10
	DIV			EBX									

	; Add 48 to value to return to ASCII representation
	MOV			ECX, EDX
	ADD			ECX, 48

	; When we reached the null terminator stop
	PUSH		ECX
	CMP			EAX, 0	
	JE			_RestoreToPrint
	JMP			_ConvertToASCII

_RestoreToPrint:
	; Store null terminator value
	POP			EAX
	STOSB

	; Print value to screen return to previous position
	mDisplayString	[EBP + 32] 
	SUB			EDI, 1

	; When we reached the null terminator stop
	CMP			EAX, 0
	JE			_ExitWriteVal
	JMP			_RestoreToPrint

_ExitWriteVal:
	; Print Final Value
	mDisplayString	[EBP + 32]

	POP			EBP
	RET			8
WriteVal ENDP

;------------------------------------------------------------------------------
;	Name : displayInput
;
;	Procedure takes the user input and converts it back into ASCII encoding
;	by calling the WriteVal procedure. The string of inputs are then printed
;	to screen by invoking the mDisplayString macro. 
;
;	Preconditions : outStringArray must be filled with user input stored as
;					integers. 
;
;	Postconditions : The array of user input is converted and printed
; 
;	Recieves  :
;		[EBP + 24]		= Address of array storing user input
;		[EBP + 20]		= Address of array to store converted ASCII values
;		[EBP + 16]		= Address of the space character string
;		[EBP + 12]		= Address of the comma character string
;		[EBP + 8]		= Address of the recorded user input message string
;
;	Returns : Printed array of user inputs to screen.
;------------------------------------------------------------------------------

displayInput PROC

	PUSH		EBP 
	MOV			EBP, ESP  	

	PUSH		EAX
	PUSH		EBX
	PUSH		ECX
	PUSH		EDX
	PUSH		ESI

	; Display user input numbers message
	CALL		CrLf
	mDisplayString		[EBP + 8]
	CALL		CrLf

	; Register Setup for looping
	MOV			ESI, [EBP + 20]					; Input array
	MOV			ECX, NUMBER_LIMIT

_DisplayUserInput:
	; Load value and Print
	PUSH		[EBP + 24]						; Output array 
	PUSH		[ESI]							; Integer Value to convert to string

	CALL		WriteVal
	ADD			ESI, 4

	; If we are at the last value no need for comma or space
    DEC			ECX
    CMP			ECX, 0
	JE			_ExitDisplayInput

	; Single string characters
	mDisplayString		[EBP + 12]				; Comma string
	mDisplayString		[EBP + 16]				; Space string

	JNZ			_DisplayUserInput
	CALL		CrLf

_ExitDisplayInput:

	POP			ESI
	POP			EDX
	POP			ECX
	POP			EBX
	POP			EAX
	
	POP			EBP  
	RET			20 

displayInput ENDP

;------------------------------------------------------------------------------
;	Name : perfromCalculations
;	
;	Peforms calculations on user input after it has been converted into numeric
;	form. The sum is found first and then subsequently the average is derived
;	by dividing by the total number of inputs (10). Both values are then printed
;	to the screen by using the WriteVal procedure to convert them into their 
;	ASCII format, and mDisplayString is invoked for printing. 
;
;	Preconditions : The user input is properly validated and recorded.
;					the appropriate arrays are declared and their addresses
;					passed onto the stack. 
;	
;	Recieves  :
;		[EBP + 20]		= Address of outString array used for processing
;		[EBP + 16]		= Address of user input array
;		[EBP + 12]		= Address of summation message string
;		[EBP + 8]		= Address of the average message string
;
;	Returns : The calculated sum and average printed to screen. 
;------------------------------------------------------------------------------

perfromCalculations PROC

	PUSH		EBP 
	MOV			EBP, ESP  	

	PUSH		EAX
	PUSH		EBX
	PUSH		ECX
	PUSH		ESI

	; Register Setup
	MOV			ESI, [EBP + 16]					; input array
	MOV			ECX, NUMBER_LIMIT				; Limit is 10
	XOR			EAX, EAX

	;------------------------------------------
	; CALCULATE SUM
	; -  Recursively ADD value from EAX
	; -  Move to next value
	;-------------------------------------------
_FindSum:
	ADD			EAX, [ESI]
	ADD			ESI, 4
	LOOP		_FindSum

	; Display summation message
	CALL		CrLf
	mDisplayString	[EBP + 12]

	; Dislpay Sum by converting to string
	PUSH		[EBP + 20]						; Address to put conversion
	PUSH		EAX								; Holds latest value to convert
	CALL		WriteVal

	;------------------------------------------
	; CALCULATE AVERAGE
	; - Divide by length of array
	; - EAX holds the total sum
	; - Set up divisor, 10 numbers of max input
	;-------------------------------------------
	MOV			ECX, NUMBER_LIMIT
	CDQ
	IDIV		ECX

	; Display average message
	CALL		CrLf
	mDisplayString	[EBP + 8]

	; Display Truncated Average by converting to string
	PUSH		[EBP + 20]
	PUSH		EAX
	CALL		WriteVal

	POP			ESI
	POP			ECX
	POP			EBX
	POP			EAX
	
	POP			EBP  
	RET			16 

perfromCalculations ENDP

;------------------------------------------------------------------------------
;	Name : sayGoodbye
;
;	Procedure thanks the user and says goodbye before ending the program. 
;
;	Recieves  :
;		[EBP + 8]		= Address of goodbye message
; 
;	Returns : Farewell message printed to screen
;------------------------------------------------------------------------------

sayGoodbye PROC

	PUSH		EBP 
	MOV			EBP, ESP  	

	; Display goodbye message to user
	CALL		CrLf
	CALL		CrLf
	mDisplayString	[EBP + 8]
	CALL		CrLf

	POP			EBP  
	RET			8 

sayGoodbye ENDP

END main