INCLUDE Irvine32.inc
main EQU start@0

Item STRUCT
	Index WORD ?
	Content BYTE 50 DUP(0)
	ContentSize DWORD ?
	Year WORD ?
	Month WORD ?
	Day WORD ?
	Expense DWORD ?
	Category BYTE ?
	IO BYTE ?
Item ENDS

.data
data Item 500 DUP(<>)
temp Item <>
filename BYTE "AccountingBook.txt",0
titleStr BYTE "Accounting book",0
titleSize DWORD $-titleStr

nextLine BYTE 0Dh, 0Ah
nextLineSize DWORD $-nextLine
firstLine BYTE "Date        Type    Category       Item             Price",0Dh,0Ah
firstLineSize DWORD $-firstLine  

errorMsg BYTE "Invalid Operation!",0
errorMsgSize DWORD $-errorMsg
noDataMsg BYTE "There is no data in this day!",0
noDataMsgSize DWORD $-noDataMsg
noData BYTE "There is no data now! Please add datas by Add option!",0
noDataSize DWORD $-noData
optionStr BYTE "Please Choose An Option:",0
optionSize DWORD $-optionStr
options BYTE "Options: (1)Add (2)Delete (3)Modify (4)Search (5)Statistics (6)Exit",0
optionsSize DWORD $-options
inoutCome BYTE "Type: (1)Income (2)Outcome",0
inoutComeSize DWORD $-inoutCome
inoutComeStr BYTE "Please Choose A Type:",0
inoutComeStrSize DWORD $-inoutComeStr
dateStr BYTE "Please Input Date:",0
dateSize DWORD $-dateStr
slash BYTE "/",0
slashSize DWORD $-slash
categoryStr BYTE "Please Choose Category:",0
categorySize DWORD $-categoryStr
categories BYTE "Category: (1)Food (2)Traffic (3)Entertainment (4)Shopping (5)Medical (6)Home (7)Learning (8)Salary",0
categoriesSize DWORD $-categories
itemStr BYTE "Please Input Item(MAX: 15 words):",0
itemSize DWORD $-itemStr
priceStr BYTE "Please Input Price:",0
priceSize DWORD $-priceStr
curSizeStr BYTE "Current Items Quantity(MAX: 500 items):",0
curSizeSize DWORD $-curSizeStr
indexStr BYTE "Please Choose An Index:",0
indexStrSize DWORD $-indexStr
inTotalStr BYTE "Total Income:",0
inTotalStrSize DWORD $-inTotalStr
outTotalStr BYTE "Total Outcome:",0
outTotalStrSize DWORD $-outTotalStr
balanceStr BYTE "Balance:",0
balanceStrSize DWORD $-balanceStr
itemsQ DWORD 0
InTotal DWORD 0
OutTotal DWORD 0
balance DWORD 0

buffer BYTE 50 DUP(0)
bufferSize DWORD ?
ten DWORD 10
reset BYTE 50 DUP(0)

outputHandle DWORD ?
fileHandle DWORD ?
optHandle DWORD ?

cnt DWORD 0
count DWORD 0
Index DWORD ?
last DWORD ?
sIndex DWORD ?
list BYTE 500 DUP(?)
negFlag BYTE 0

bytesWritten DWORD ?
xyPosition COORD <0,0>

.code
main PROC
	;Title
	INVOKE SetConsoleTitle, ADDR titleStr
	
	;Get Handle
	INVOKE GetStdHandle, STD_OUTPUT_HANDLE
	mov outputHandle, eax

START:
	;reset xyPosition
	mov xyPosition.x, 0
	mov xyPosition.y,0

	;clear screen
	call Clrscr
	
	;current items quantity
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR curSizeStr, curSizeSize, xyPosition, ADDR bytesWritten
	add xyPosition.x, SIZEOF curSizeStr
	INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
	mov eax, itemsQ
	call WriteDec
	
	;option	
OPT:
	mov xyPosition.x, 0
	add xyPosition.y, 2
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR options, optionsSize, xyPosition, ADDR bytesWritten
	inc xyPosition.y
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR optionStr, optionSize, xyPosition, ADDR bytesWritten
	add xyPosition.x, SIZEOF optionStr
	INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
	call ReadDec
	mov optHandle, eax
	.IF eax > 6
		mov xyPosition.x, 0
		add xyPosition.y, 2
		INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR errorMsg, errorMsgSize, xyPosition, ADDR bytesWritten
		jmp OPT
	.ENDIF
	.IF eax == 1
		inc itemsQ
	.ENDIF
	.IF eax == 2 || eax == 3 || eax == 4
		.IF itemsQ == 0
			mov xyPosition.x, 0
			add xyPosition.y, 2
			INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
			mov edx, OFFSET noData
			call WriteString
			call Crlf
			call Crlf
			call WaitMsg
			jmp START
		.ELSE
			jmp DAT
		.ENDIF
	.ENDIF
	.IF eax == 5
		jmp SHOW_DATA
	.ENDIF
	.IF eax == 6
		jmp DONE
	.ENDIF
	mov eax, count
	mov ebx, itemsQ
	mov (Item PTR [data+eax]).Index, bx

	;income or outcome
IOC:
	mov xyPosition.x, 0
	add xyPosition.y, 2
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR inoutCome, inoutComeSize, xyPosition, ADDR bytesWritten
	inc xyPosition.y
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR inoutComeStr, inoutComeStrSize, xyPosition, ADDR bytesWritten
	add xyPosition.x, SIZEOF inoutComeStr
	INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
	call ReadInt
	.IF eax > 2
		mov xyPosition.x, 0
		add xyPosition.y, 2
		INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR errorMsg, errorMsgSize, xyPosition, ADDR bytesWritten
		jmp IOC
	.ENDIF
	.IF optHandle == 3
		mov (Item PTR [temp]).IO, al
		jmp CAT
	.ENDIF
	mov ebx, count
	mov (Item PTR [data+ebx]).IO, al

	;category
CAT:
	mov xyPosition.x, 0
	add xyPosition.y, 2
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR categories, categoriesSize, xyPosition, ADDR bytesWritten
	inc xyPosition.y
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR categoryStr, categorySize, xyPosition, ADDR bytesWritten
	add xyPosition.x, SIZEOF categoryStr
	INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
	call ReadInt
	.IF eax > 8
		mov xyPosition.x, 0
		add xyPosition.y, 2
		INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR errorMsg, errorMsgSize, xyPosition, ADDR bytesWritten
		jmp CAT
	.ENDIF
	.IF optHandle == 3
		mov (Item PTR [temp]).Category, al
		jmp CON
	.ENDIF
	mov ebx, count
	mov (Item PTR [data+ebx]).Category, al

	;date
DAT:
	mov xyPosition.x, 0
	add xyPosition.y, 2
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR dateStr, dateSize, xyPosition, ADDR bytesWritten
	add xyPosition.X, SIZEOF dateStr
	mov cnt, 0
	mov ecx, 3
D:
	push ecx
	INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
	;mov edx, OFFSET buffer 
    ;mov ecx, (SIZEOF buffer) - 1
    ;call ReadString
	call ReadInt
	.IF eax > 80000000h
		mov xyPosition.x, 0
		add xyPosition.y, 2
		INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR errorMsg, errorMsgSize, xyPosition, ADDR bytesWritten
		jmp DAT
	.ENDIF
	.IF cnt == 1
		.IF eax > 12
			mov xyPosition.x, 0
			add xyPosition.y, 2
			INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR errorMsg, errorMsgSize, xyPosition, ADDR bytesWritten
			jmp DAT
		.ENDIF
	.ENDIF
	.IF cnt == 2
		.IF eax > 31
			mov xyPosition.x, 0
			add xyPosition.y, 2
			INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR errorMsg, errorMsgSize, xyPosition, ADDR bytesWritten
			jmp DAT
		.ENDIF
	.ENDIF
	cmp eax, 32
	pop ecx
	push eax
	push ecx
	jb NotYear
	cmp eax, 1000
	jb Chinese
	inc xyPosition.x
Chinese:
	cmp eax, 100
	jb NotYear
	inc xyPosition.x
NotYear:
	add xyPosition.x, 2
	pop ecx
	cmp ecx, 1
	push ecx
	je D_STOP
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR slash, slashSize, xyPosition, ADDR bytesWritten
	inc xyPosition.x
D_STOP:
	inc cnt
	pop ecx
	loop DFlag
	.IF optHandle == 1
		mov eax, count
		pop ebx
		mov (Item PTR [data+eax]).Day, bx
		pop ebx
		mov (Item PTR [data+eax]).Month, bx
		pop ebx
		mov (Item PTR [data+eax]).Year, bx
		jmp CON
	.ENDIF
	.IF optHandle > 1
		pop ebx
		mov (Item PTR [temp]).Day, bx
		pop ebx
		mov (Item PTR [temp]).Month, bx
		pop ebx
		mov (Item PTR [temp]).Year, bx
		jmp search_item
	.ENDIF
DFlag:
	jmp D

	;item
CON:
	mov xyPosition.x, 0
	add xyPosition.y, 2
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR itemStr, itemSize, xyPosition, ADDR bytesWritten
	add xyPosition.x, SIZEOF itemStr
	INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
	mov edx, OFFSET buffer 
    mov ecx, (SIZEOF buffer) - 1
    call ReadString
	.IF optHandle == 1
		mov ebx, count
		mov (Item PTR [data+ebx]).ContentSize, eax
		mov ecx, 50
		cld
		mov esi, OFFSET buffer
		lea edi, (Item PTR [data+ebx]).Content
		rep movsb
	.ENDIF
	.IF optHandle == 3
		mov (Item PTR [temp]).ContentSize, eax
		mov ecx, 50
		cld
		mov esi, OFFSET buffer
		lea edi, (Item PTR [temp]).Content
		rep movsb
		jmp EXP
	.ENDIF
	
	;price
EXP:
	mov xyPosition.x, 0
	add xyPosition.y, 2
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR priceStr, priceSize, xyPosition, ADDR bytesWritten
	add xyPosition.x, SIZEOF priceStr
	INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
	call ReadInt
	.IF eax > 80000000h
		mov xyPosition.x, 0
		add xyPosition.y, 2
		INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR errorMsg, errorMsgSize, xyPosition, ADDR bytesWritten
		jmp EXP
	.ENDIF
	mov ebx, count
	mov dl, (Item PTR [data+ebx]).IO
	.IF optHandle == 1 && dl == 1
		mov (Item PTR [data+ebx]).Expense, eax
		add InTotal, eax
		add balance, eax
	.ELSEIF optHandle == 1 && dl == 2
		mov (Item PTR [data+ebx]).Expense, eax
		add OutTotal, eax
		sub balance, eax
	.ENDIF
	.IF optHandle == 3
		mov (Item PTR [temp]).Expense, eax
		.IF dl == 1
			add InTotal, eax
			add balance, eax
		.ELSEIF dl == 2
			add OutTotal, eax
			sub balance, eax
		.ENDIF
		jmp mod_start
	.ENDIF
	;count++
	mov eax, count
	mov last, eax
	add count, TYPE data
	mov ecx, 50
	cld
	mov esi, OFFSET reset
	mov edi, OFFSET buffer
	rep movsb
	jmp START
	
	;delete
del_item:
	dec itemsQ
	sub count, TYPE data
	mov xyPosition.x, 0
	mov eax, sIndex
	add xyPosition.y, ax
del_again:
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR indexStr, indexStrSize, xyPosition, ADDR bytesWritten
	add xyPosition.x, SIZEOF indexStr
	INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
	call ReadDec
	.IF eax >= sIndex
		mov xyPosition.x, 0
		add xyPosition.y, 2
		INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
		mov edx, OFFSET errorMsg
		call WriteString
		add xyPosition.y, 2
		jmp del_again
	.ENDIF
	dec eax
	xor ebx, ebx
	mov bl, [list+eax]
	mov Index, ebx
	dec Index
	xor eax, eax
	mov al, TYPE data
	mul Index
	mov edx, last
	mov bx, (Item PTR [data+edx]).Year
	mov (Item PTR [data+ax]).Year, bx
	mov bx, (Item PTR [data+edx]).Month
	mov (Item PTR [data+ax]).Month, bx
	mov bx, (Item PTR [data+edx]).Day
	mov (Item PTR [data+ax]).Day, bx
	mov bl, (Item PTR [data+ax]).IO
	push edx
	.IF bl == 1
		mov edx, (Item PTR [data+ax]).Expense
		sub InTotal, edx
		sub balance, edx
	.ENDIF
	.IF bl == 2
		mov edx, (Item PTR [data+ax]).Expense
		sub OutTotal, edx
		add balance, edx
	.ENDIF
	pop edx
	mov bl, (Item PTR [data+edx]).IO
	mov (Item PTR [data+ax]).IO, bl
	mov ebx, (Item PTR [data+edx]).Expense
	mov (Item PTR [data+ax]).Expense, ebx
	mov bl, (Item PTR [data+edx]).Category
	mov (Item PTR [data+ax]).Category, bl
	mov ebx, (Item PTR [data+edx]).ContentSize
	mov (Item PTR [data+ax]).ContentSize, ebx
	mov ecx, 50
	cld
	lea esi, (Item PTR [data+edx]).Content
	lea edi, (Item PTR [data+ax]).Content
	rep movsb
	jmp START
	
	;modify
mod_item:
	mov xyPosition.x, 0
	mov eax, sIndex
	add xyPosition.y, ax
mod_again:
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR indexStr, indexStrSize, xyPosition, ADDR bytesWritten
	add xyPosition.x, SIZEOF indexStr
	INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
	call ReadDec
	.IF eax >= sIndex
		mov xyPosition.x, 0
		add xyPosition.y, 2
		INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
		mov edx, OFFSET errorMsg
		call WriteString
		add xyPosition.y, 2
		jmp mod_again
	.ENDIF
	dec eax
	xor ebx, ebx
	mov bl, [list+eax]
	mov Index, ebx
	jmp IOC
mod_start:
	dec Index
	xor eax, eax
	mov al, TYPE data
	mul Index
	mov bx, (Item PTR [temp]).Year
	mov (Item PTR [data+ax]).Year, bx
	mov bx, (Item PTR [temp]).Month
	mov (Item PTR [data+ax]).Month, bx
	mov bx, (Item PTR [temp]).Day
	mov (Item PTR [data+ax]).Day, bx
	mov bl, (Item PTR [data+ax]).IO
	.IF bl == 1
		mov edx, (Item PTR [data+ax]).Expense
		sub InTotal, edx
		sub balance, edx
	.ENDIF
	.IF bl == 2
		mov edx, (Item PTR [data+ax]).Expense
		sub OutTotal, edx
		add balance, edx
	.ENDIF
	mov bl, (Item PTR [temp]).IO
	mov (Item PTR [data+ax]).IO, bl
	mov ebx, (Item PTR [temp]).Expense
	mov (Item PTR [data+ax]).Expense, ebx
	mov bl, (Item PTR [temp]).Category
	mov (Item PTR [data+ax]).Category, bl
	mov ebx, (Item PTR [temp]).ContentSize
	mov (Item PTR [data+ax]).ContentSize, ebx
	mov ecx, 50
	cld
	lea esi, (Item PTR [temp]).Content
	lea edi, (Item PTR [data+ax]).Content
	rep movsb
	jmp START
	
	;search
search_item:
	mov xyPosition.x, 0
	add xyPosition.y, 2
	INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
	mov ecx, itemsQ
	mov ebx, 0
	mov sIndex, 1
sLoop:
	mov dx, (Item PTR [data+ebx]).Year
	mov ax, (Item PTR [temp]).Year
	.IF dx != ax
		jmp incorrect
	.ENDIF
	mov dx, (Item PTR [data+ebx]).Month
	mov ax, (Item PTR [temp]).Month
	.IF dx != ax
		jmp incorrect
	.ENDIF
	mov dx, (Item PTR [data+ebx]).Day
	mov ax, (Item PTR [temp]).Day
	.IF dx != ax
		jmp incorrect
	.ENDIF
	mov eax, sIndex
	call WriteDec
	mov al, ' '
	call WriteChar
	call WriteChar
	mov ax, (Item PTR [data+ebx]).Year
	call WriteDec
	mov al, '/'
	call WriteChar
	mov ax, (Item PTR [data+ebx]).Month
	call WriteDec
	mov al, '/'
	call WriteChar
	mov ax, (Item PTR [data+ebx]).Day
	call WriteDec
	mov al, ' '
	call WriteChar
	push ecx
	mov al, (Item PTR [data+ebx]).IO
	.IF al == 1
		mov bufferSize, 6
		mov ecx, bufferSize
		cld
		mov esi, OFFSET inoutCome
		add esi, 9
		mov edi, OFFSET buffer
		rep movsb
	.ENDIF
	.IF al == 2
		mov bufferSize, 7
		mov ecx, bufferSize
		cld
		mov esi, OFFSET inoutCome
		add esi, 19
		mov edi, OFFSET buffer
		rep movsb
	.ENDIF
	mov edx, OFFSET buffer
	call WriteString
	mov ecx, 50
	cld
	mov esi, OFFSET reset
	mov edi, OFFSET buffer
	rep movsb
	mov al, ' '
	call WriteChar
	mov al, (Item PTR [data+ebx]).Category
	.IF al == 1
		mov bufferSize, 4
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 13
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 2
		mov bufferSize, 7
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 21
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 3
		mov bufferSize, 13
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 32
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 4
		mov bufferSize, 8
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 49
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 5
		mov bufferSize, 7
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 61
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 6
		mov bufferSize, 4
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 72
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 7
		mov bufferSize, 8
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 80
		mov edi, OFFSET buffer
		rep movsb
	.ELSE
		mov bufferSize, 6
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 92
		mov edi, OFFSET buffer
		rep movsb
	.ENDIF
	mov edx, OFFSET buffer
	call WriteString
	mov ecx, 50
	cld
	mov esi, OFFSET reset
	mov edi, OFFSET buffer
	rep movsb
	mov al, ' '
	call WriteChar
	lea edx, (Item PTR [data+ebx]).Content
	call WriteString
	mov al, ' '
	call WriteChar
	mov eax, (Item PTR [data+ebx]).Expense
	call WriteDec
	call Crlf
	mov ax, (Item PTR [data+ebx]).Index
	mov edx, sIndex
	dec edx
	mov [list+edx], al
	inc sIndex
	pop ecx
incorrect:
	add ebx, TYPE data
	loop sFlag
	.IF sIndex == 1
		mov edx, OFFSET noDataMsg
		call WriteString
		call Crlf
		jmp P
	.ENDIF
	.IF optHandle == 2
		jmp del_item
	.ELSEIF optHandle == 3
		jmp mod_item
	.ENDIF
P:
	call Crlf
	call WaitMsg
	jmp START
sFlag:
	jmp sLoop
	
	;statistics
SHOW_DATA:
	mov xyPosition.x, 0
	add xyPosition.y, 2
	INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
	mov ebx, 0
	mov ecx, itemsQ
	.IF ecx == 0
		mov edx, OFFSET noData
		call WriteString
		call Crlf
		call Crlf
		call WaitMsg
		jmp START
	.ENDIF
L:
	mov ax, (Item PTR [data+ebx]).Index
	call WriteDec
	mov al, ' '
	call WriteChar
	call WriteChar
	mov ax, (Item PTR [data+ebx]).Year
	call WriteDec
	mov al, '/'
	call WriteChar
	mov ax, (Item PTR [data+ebx]).Month
	call WriteDec
	mov al, '/'
	call WriteChar
	mov ax, (Item PTR [data+ebx]).Day
	call WriteDec
	mov al, ' '
	call WriteChar
	push ecx
	mov al, (Item PTR [data+ebx]).IO
	.IF al == 1
		mov bufferSize, 6
		mov ecx, bufferSize
		cld
		mov esi, OFFSET inoutCome
		add esi, 9
		mov edi, OFFSET buffer
		rep movsb
	.ENDIF
	.IF al == 2
		mov bufferSize, 7
		mov ecx, bufferSize
		cld
		mov esi, OFFSET inoutCome
		add esi, 19
		mov edi, OFFSET buffer
		rep movsb
	.ENDIF
	mov edx, OFFSET buffer
	call WriteString
	mov ecx, 50
	cld
	mov esi, OFFSET reset
	mov edi, OFFSET buffer
	rep movsb
	mov al, ' '
	call WriteChar
	mov al, (Item PTR [data+ebx]).Category
	.IF al == 1
		mov bufferSize, 4
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 13
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 2
		mov bufferSize, 7
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 21
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 3
		mov bufferSize, 13
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 32
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 4
		mov bufferSize, 8
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 49
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 5
		mov bufferSize, 7
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 61
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 6
		mov bufferSize, 4
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 72
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 7
		mov bufferSize, 8
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 80
		mov edi, OFFSET buffer
		rep movsb
	.ELSE
		mov bufferSize, 6
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 92
		mov edi, OFFSET buffer
		rep movsb
	.ENDIF
	mov edx, OFFSET buffer
	call WriteString
	mov ecx, 50
	cld
	mov esi, OFFSET reset
	mov edi, OFFSET buffer
	rep movsb
	mov al, ' '
	call WriteChar
	lea edx, (Item PTR [data+ebx]).Content
	call WriteString
	mov al, ' '
	call WriteChar
	mov eax, (Item PTR [data+ebx]).Expense
	call WriteDec
	call Crlf
	add ebx, TYPE data
	pop ecx
	dec ecx
	jnz L
	mov xyPosition.x, 0
	mov eax, itemsQ
	inc eax
	add xyPosition.y, ax
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR inTotalStr, inTotalStrSize, xyPosition, ADDR bytesWritten
	add xyPosition.x, SIZEOF inTotalStr
	INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
	mov eax, InTotal
	call WriteDec
	mov xyPosition.x, 0
	inc xyPosition.y
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR outTotalStr, outTotalStrSize, xyPosition, ADDR bytesWritten
	add xyPosition.x, SIZEOF outTotalStr
	INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
	mov eax, OutTotal
	call WriteDec
	mov xyPosition.x, 0
	inc xyPosition.y
	INVOKE WriteConsoleOutputCharacter, outputHandle, ADDR balanceStr, balanceStrSize, xyPosition, ADDR bytesWritten
	add xyPosition.x, SIZEOF balanceStr
	INVOKE SetConsoleCursorPosition, outputHandle, xyPosition
	mov eax, balance
	call WriteInt
	call Crlf
	call Crlf
	call WaitMsg
	jmp START

	;output to a file
DONE:
	INVOKE CreateFile, ADDR filename, GENERIC_WRITE, DO_NOT_SHARE, NULL, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0
	mov fileHandle, eax
	INVOKE WriteFile, fileHandle, ADDR firstLine, firstLineSize, ADDR bytesWritten, 0
	mov count, 0
	mov ecx, itemsQ
	.IF ecx == 0
		jmp FINAL
	.ENDIF
toFile:
	push ecx
	mov ecx, 4
	mov ebx, count
	mov al, slash
	mov [buffer+4], al
	;date to ascii
yLoop:
	xor edx, edx
	xor eax, eax
	mov ax, (Item PTR [data+ebx]).Year
	div ten
	add edx, 30h
	mov [buffer+ecx-1], dl
	mov (Item PTR [data+ebx]).Year, ax
	.IF ax >= 10
		loop yLoop
	.ELSE
		add al, 30h
		mov [buffer+ecx-2], al
		sub ecx, 2
		cmp ecx, 1
		jb yFlag
remainder:
		mov [buffer+ecx-1], " "
		loop remainder
	.ENDIF
yFlag:
	mov ecx, 2
	mov al, slash
	mov [buffer+7], al
mLoop:
	xor edx, edx
	xor eax, eax
	mov ax, (Item PTR [data+ebx]).Month
	div ten
	add edx, 30h
	mov [buffer+ecx+4], dl
	mov (Item PTR [data+ebx]).Month, ax
	loop mLoop
	mov ecx, 2
dLoop:
	xor edx, edx
	xor eax, eax
	mov ax, (Item PTR [data+ebx]).Day
	div ten
	add edx, 30h
	mov [buffer+ecx+7], dl
	mov (Item PTR [data+ebx]).Day, ax
	loop dLoop
	mov [buffer+10], " "
	mov [buffer+11], " "
	INVOKE WriteFile, fileHandle, ADDR buffer, 12, ADDR bytesWritten, 0
	;in/outcome
	mov al, (Item PTR [data+ebx]).IO
	.IF al == 1
		mov bufferSize, 6
		mov ecx, bufferSize
		cld
		mov esi, OFFSET inoutCome
		add esi, 9
		mov edi, OFFSET buffer
		rep movsb
	.ENDIF
	.IF al == 2
		mov bufferSize, 7
		mov ecx, bufferSize
		cld
		mov esi, OFFSET inoutCome
		add esi, 19
		mov edi, OFFSET buffer
		rep movsb
	.ENDIF
	mov eax, bufferSize
	mov ecx, 8
	sub ecx, bufferSize
IOL:
	mov [buffer+eax+ecx-1], " "
	loop IOL
	INVOKE WriteFile, fileHandle, ADDR buffer, 8, ADDR bytesWritten, 0
	;category
	mov al, (Item PTR [data+ebx]).Category
	.IF al == 1
		mov bufferSize, 4
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 13
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 2
		mov bufferSize, 7
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 21
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 3
		mov bufferSize, 13
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 32
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 4
		mov bufferSize, 8
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 49
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 5
		mov bufferSize, 7
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 61
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 6
		mov bufferSize, 4
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 72
		mov edi, OFFSET buffer
		rep movsb
	.ELSEIF al == 7
		mov bufferSize, 8
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 80
		mov edi, OFFSET buffer
		rep movsb
	.ELSE
		mov bufferSize, 6
		mov ecx, bufferSize
		cld
		mov esi, OFFSET categories
		add esi, 92
		mov edi, OFFSET buffer
		rep movsb
	.ENDIF
	mov eax, bufferSize
	mov ecx, 15
	sub ecx, bufferSize
cLoop:
	mov [buffer+eax+ecx-1], " "
	loop cLoop
	INVOKE WriteFile, fileHandle, ADDR buffer, 15, ADDR bytesWritten, 0
	;item
	INVOKE WriteFile, fileHandle, ADDR (Item PTR [data+ebx]).Content, (Item PTR [data+ebx]).ContentSize, ADDR bytesWritten, 0
	mov ecx, 17
	sub ecx, (Item PTR [data+ebx]).ContentSize
	mov bufferSize, ecx
iLoop:
	mov [buffer+ecx-1], " "
	loop iLoop
	INVOKE WriteFile, fileHandle, ADDR buffer, bufferSize, ADDR bytesWritten, 0
	;price to ascii
	mov ecx, 50
	mov bufferSize, 0
pLoop:
	xor edx, edx
	xor eax, eax
	mov eax, (Item PTR [data+ebx]).Expense
	div ten
	add edx, 30h
	mov [buffer+ecx-1], dl
	inc bufferSize
	.IF eax < 10
		add al, 30h
		mov [buffer+ecx-2], al
		inc bufferSize
		mov ecx, 1
	.ELSEIF eax == 0
		mov ecx, 1
	.ELSE
		mov (Item PTR [data+ebx]).Expense, eax
	.ENDIF
	loop pLoop
	mov ecx, bufferSize
	mov eax, 50
	sub eax, bufferSize
	mov esi, OFFSET buffer
	add esi, eax
	mov edi, OFFSET buffer
	rep movsb
	INVOKE WriteFile, fileHandle, ADDR buffer, bufferSize, ADDR bytesWritten, 0
	INVOKE WriteFile, fileHandle, ADDR nextLine, nextLineSize, ADDR bytesWritten, 0
	add count, TYPE data
	pop ecx
	dec ecx
	jnz toFile
FINAL:
	;incomeTotal to ascii
	mov ecx, 50
	mov bufferSize, 0
inLoop:
	xor edx, edx
	xor eax, eax
	mov eax, InTotal
	.IF eax == 0
		add eax, 30h
		mov [buffer+ecx-1], al
		inc bufferSize
		jmp inFlag
	.ENDIF
	div ten
	add edx, 30h
	mov [buffer+ecx-1], dl
	inc bufferSize
	.IF eax < 10
		add al, 30h
		mov [buffer+ecx-2], al
		inc bufferSize
		jmp inFlag
	.ELSE
		mov InTotal, eax
	.ENDIF
	loop inLoop
inFlag:
	mov ecx, inTotalStrSize
	mov esi, OFFSET inTotalStr
	mov edi, OFFSET buffer
	rep movsb
	mov ecx, bufferSize
	mov eax, 50
	sub eax, bufferSize
	mov esi, OFFSET buffer
	add esi, eax
	mov eax, inTotalStrSize
	mov edi, OFFSET buffer
	add edi, eax
	rep movsb
	add bufferSize, SIZEOF inTotalStr
	INVOKE WriteFile, fileHandle, ADDR buffer, bufferSize, ADDR bytesWritten, 0
	INVOKE WriteFile, fileHandle, ADDR nextLine, nextLineSize, ADDR bytesWritten, 0
	;outcomeTotal to ascii
	mov ecx, 50
	mov bufferSize, 0
outLoop:
	xor edx, edx
	xor eax, eax
	mov eax, OutTotal
	.IF eax == 0
		add eax, 30h
		mov [buffer+ecx-1], al
		inc bufferSize
		jmp outFlag
	.ENDIF
	div ten
	add edx, 30h
	mov [buffer+ecx-1], dl
	inc bufferSize
	.IF eax < 10
		add al, 30h
		mov [buffer+ecx-2], al
		inc bufferSize
		jmp outFlag
	.ELSE
		mov OutTotal, eax
	.ENDIF
	loop outLoop
outFlag:
	mov ecx, outTotalStrSize
	mov esi, OFFSET outTotalStr
	mov edi, OFFSET buffer
	rep movsb
	mov ecx, bufferSize
	mov eax, 50
	sub eax, bufferSize
	mov esi, OFFSET buffer
	add esi, eax
	mov eax, outTotalStrSize
	mov edi, OFFSET buffer
	add edi, eax
	rep movsb
	add bufferSize, SIZEOF outTotalStr
	INVOKE WriteFile, fileHandle, ADDR buffer, bufferSize, ADDR bytesWritten, 0
	INVOKE WriteFile, fileHandle, ADDR nextLine, nextLineSize, ADDR bytesWritten, 0
	;balance to ascii
	mov ecx, 50
	mov bufferSize, 0
bLoop:
	xor edx, edx
	xor eax, eax
	mov eax, balance
	.IF eax == 0
		add eax, 30h
		mov [buffer+ecx-1], al
		inc bufferSize
		jmp bFlag
	.ENDIF
	.IF eax > 80000000h
		neg eax
		inc negFlag
	.ENDIF
	div ten
	add edx, 30h
	mov [buffer+ecx-1], dl
	inc bufferSize
	.IF eax < 10
		add al, 30h
		mov [buffer+ecx-2], al
		inc bufferSize
		.IF negFlag == 1
			mov [buffer+ecx-3], "-"
			inc bufferSize
		.ENDIF
		jmp bFlag
	.ELSE
		mov balance, eax
	.ENDIF
	loop bLoop
bFlag:
	mov ecx, balanceStrSize
	mov esi, OFFSET balanceStr
	mov edi, OFFSET buffer
	rep movsb
	mov ecx, bufferSize
	mov eax, 50
	sub eax, bufferSize
	mov esi, OFFSET buffer
	add esi, eax
	mov eax, balanceStrSize
	mov edi, OFFSET buffer
	add edi, eax
	rep movsb
	add bufferSize, SIZEOF balanceStr
	INVOKE WriteFile, fileHandle, ADDR buffer, bufferSize, ADDR bytesWritten, 0
	exit
main ENDP
END main