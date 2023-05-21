;ALGORITMO DE CONVERSIÓN HEX-BCD

$MOD51

;Se utiliza el último segmento de memoria de datos: 70H a 7FH, quince POSMEMS
;Algoritmo de conversión HEX-BCD hasta 65.535 --> 16 bits
;BCDDM	 --> decenas de mil BCD
;BCDM	 --> unidades de mil BCD
;BCDC	 --> centenas BCD
;BCDD	 --> decenas BCD
;BCDU	 --> unidades BCD
;7FH 7EH --> 00 0AH --> 10
;7DH 7CH --> 00 64H --> 100
;7BH 7AH --> 03 E8H --> 1000
;79H 78H --  27 10H --  10000
;72H 71H --> número HEX a convertir
;R3 --> Cantidad de BCD-1 obtenidos, ej: para 8 bits se resta de a 10 y 100, entonces R3 = 2
;R2 --> Cantidad de restas sucesivas realizadas
;R1 --> Apunta a la posmem donde van a kedar los resultados BCD
;R0 --> Apuntador del numero a restar 10, 100 o 1000

DMILH	EQU 7FH		;Constantes para la conversion BCD - HEX
DMILL	EQU 7EH         ;10, 100, 1000, 10.000
MILH	EQU 7DH         
MILL	EQU 7CH
CIENH	EQU 7BH
CIENL	EQU 7AH
DIEZH	EQU 79H
DIEZL	EQU 78H

BCDDM	EQU 77H
BCDM	EQU 76H
BCDC	EQU 75H
BCDD	EQU 74H
BCDU	EQU 73H	;Apunta la POSMEM donde se almacenará el resultado de las unidades

HEXH 	EQU 72H	;Almacena parte alta del número HEX
HEXL 	EQU 71H	;Almacena parte baja del número HEX

;Constantes para la resta
		MOV DIEZH,#00H
		MOV DIEZL,#0AH		;Para restar 10
		MOV CIENH,#0H
		MOV CIENL,#064H		;Para restar 100
		MOV MILH,#03H
		MOV MILL,#0E8H		;Para restar 1000
		MOV DMILH,#27H
		MOV DMILL,#10H		;Para restar 10,000
HEX_BCD:	MOV R3,#04H
		MOV R2,#0H		;Cuenta la cantidad de restas sucesivas
		MOV R1,#BCDDM
		MOV R0,#DMILH           ;R0 apunta a 10, 100 o 1000 para la resta.
REST_HEX:	DEC R0			;Apunta de nuevo parte baja del sustraendo para la suma
		MOV A,HEXL
		SUBB A,@R0		;Resta parte baja de 10, 100, 1000 o 10.000
		PUSH ACC
		INC R0			;Apunta a parte alta del sustraendo.
		MOV A,HEXH
		SUBB A,@R0
		MOV HEXH,A		;Almacena parte alta del resultado de la resta.
		POP ACC
		MOV HEXL,A		;Almacena parte baja del resultado de la resta
		INC R2			;Toma en cuenta la cantidad de restas sucesivas.
		JNC REST_HEX
		DEC R2			;Ya ke se hace una resta de más.
		DEC R0
		MOV A,HEXL		;Se debe sumar lo ke se restó.
		ADD A,@R0               ;Suma parte baja.
		MOV HEXL,A		;Salva el resultado de la suma.
		INC R0			;Apunta a la parte alta del sustraendo.
		MOV A,HEXH
		ADDC A,@R0		;Suma con carry parte alta.
		MOV HEXH,A		;Salva el resultado de la suma de las partes altas.
		MOV @R1,02H		;Almacena el resultado BCD.
		DEC R1			;Direcciona próxima POSMEM para guardar resultado BCD
		CLR C
		DEC R0
		DEC R0
		MOV R2,#00H
		DJNZ R3,REST_HEX
		MOV BCDU,HEXL		;El último BCD keda en HEXL al final y son las unidades
		RET
END
