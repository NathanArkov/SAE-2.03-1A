			ASSUME CS:CSEG, DS:CSEG, ES:CSEG
CSEG		SEGMENT
			ORG 100H
			
MAIN:			JMP DEB

;***********************************Procédures
;--------------------------- Conversion du nombre en BINAIRE

CONVBIN		PROC

			MOV AX,0
			MOV BX,0AH
		
CONVBINBCL:
			MUL BX
			ADD AL,[SI]
			ADC AH,0
			INC SI
			CMP [SI],0DH
			JNE CONVBINBCL
			RET
CONVBIN		ENDP

CONVDEC		PROC
			
			MOV BX,0AH
			
CONVDECBCL:	
			DIV BX
			OR DL,30H
			MOV [DI],DL
			INC DI
			CMP AX,0
			JNE CONVDECBCL
			RET
CONVDEC		ENDP

;PRINT PROC          
     
			;initialize count
;			mov cx,0
;			mov dx,0
;label1:
			; if ax is zero
;			cmp ax,0
;			je print1     
			 
			;initialize bx to 10
;			mov bx,10       
			 
			; extract the last digit
;			div bx                 
			 
			;push it in the stack
;			push dx             
			 
			;increment the count
;			inc cx             
			 
			;set dx to 0
;			xor dx,dx
;			jmp label1
;print1:
			;check if count
			;is greater than zero
;			cmp cx,0
;			je exit
			 
			;pop the top of stack
;			pop dx
			 
			;add 48 so that it
			;represents the ASCII
			;value of digits
;			add dx,48
			 
			;interrupt to print a
			;character
;			mov ah,02h
;			int 21h
			 
			;decrease the count
;			dec cx
;			jmp print1
;exit:
;ret
;PRINT ENDP

;***********************************


DEB:

SAISIEOP:
;--------------------------- Affichage message INT21-40
			LEA DX,br
			MOV AH,9
			INT 21H ;-- Nouvelle ligne
			
			MOV BX,0001H
			LEA DX,MESSAGE3
			MOV CX, L_MESSAGE3 
			MOV AH, 40H
			INT 21H
			
;--------------------------- Saisie de l'opérateur
			MOV CX,1
			LEA DI,OPERATEUR

			MOV AH,01
			INT 21H
			CMP AL,043
			JE SAISIENB
			CMP AL,045
			JE SAISIENB
			CMP AL,042
			JE SAISIENB
			CMP AL,047
			JE SAISIENB
			
ERREUROP:	
;--------------------------- Affichage message INT21-40
			LEA DX,br
			MOV AH,9
			INT 21H ;-- Nouvelle ligne
			
			MOV BX,0001H
			LEA DX,ERREUROPERANDE
			MOV CX, L_ERREUROPERANDE 
			MOV AH, 40H
			INT 21H	
			
			JMP SAISIEOP		


SAISIENB:
;--------------------------- Affichage message INT21-40
			LEA DX,br
			MOV AH,9
			INT 21H ;-- Nouvelle ligne
			
			MOV BX,0001H
			LEA DX,MESSAGE1
			MOV CX,L_MESSAGE1 
			MOV AH, 40H
			INT 21H
			
;--------------------------- Saisie du nombre
			MOV CX,4
			LEA DI,NOMBRE1D
SAISIE1:
			MOV AH,01
			INT 21H 
			
			CMP AL,0DH
			JE SUITE1
			CMP AL,30H
			JB HORSCODE1
			CMP AL,39H
			JA HORSCODE1
			AND AL, 00001111B
			MOV [DI],AL
			INC DI
			DEC CX
			JNZ SAISIE1

SUITE1: 	MOV [DI], 0DH
			LEA SI,NOMBRE1D 
			CALL CONVBIN
			MOV NOMBRE1B,AX

HORSCODE1:

SAISIENB2:
;--------------------------- Affichage message INT21-40
			LEA DX,br
			MOV AH,9
			INT 21H ;-- Nouvelle ligne
			
			MOV BX,0001H
			LEA DX,MESSAGE2
			MOV CX,L_MESSAGE2 
			MOV AH, 40H
			INT 21H

;--------------------------- Saisie du nombre			
			MOV CX,4
			LEA DI,NOMBRE2D
SAISIE2:	
			MOV AH,01
			INT 21H 
			CMP AL,0DH
			
			JE SUITE2
			CMP AL,30H
			JB HORSCODE2
			CMP AL,39H
			JA HORSCODE2
			AND AL, 00001111B
			MOV [DI],AL
			INC DI
			DEC cx
			JNZ SAISIE2
			
SUITE2: 	MOV [DI],0DH	
			LEA SI,NOMBRE2D 
			CALL CONVBIN
			MOV NOMBRE2b,AX
			JMP OPSELEC
			
HORSCODE2:
			




;--------------------------- JMP to opération
OPSELEC:	MOV CX,1
			LEA DI,OPERATEUR

			MOV AH,01
			INT 21H
			CMP AL,043
			JE ADDI
			CMP AL,045
			JE SUBS
			CMP AL,042
			JE MULTI
			CMP AL,047
			JE DIVI
			
;*************************** SOUSTRACTION
SUBS:		MOV AX,NOMBRE1b
			MOV BX,0
			SUB AX,NOMBRE2b
			MOV RESULTAT,AX
			ADC BX,0
			MOV RESULTAT+2,BX
			JMP CONVDECIMAL
;****************************

			
;*************************** ADDITION
ADDI:		MOV AX,NOMBRE1b
			MOV BX,0
			ADD AX,NOMBRE2b
			MOV RESULTAT,AX
			ADC BX,0
			MOV RESULTAT+2,BX
			JMP CONVDECIMAL
;***************************


;*************************** MULTIPLICATION
MULTI:		MOV AX,NOMBRE1b
			MOV BX,0
			MUL NOMBRE2b
			MOV RESULTAT,AX
			ADC BX,0
			MOV RESULTAT+2,BX
			JMP CONVDECIMAL
;***************************


;*************************** DIVISION
DIVI:		MOV AX,NOMBRE1b
			MOV BX,0
			DIV NOMBRE2b
			MOV RESULTAT,AX
			ADC BX,0
			MOV RESULTAT+2,BX
			JMP CONVDECIMAL
;***************************

;--------------------------- Conversion du nombre en DECIMAL

CONVDECIMAL:		
			LEA DI,RESASCII
			MOV AX,RESULTAT
			CALL CONVDEC
			MOV DL,BYTE PTR [DI]
			MOV RESASCII, DL
			
			
;--------------------------- Affichage RESULTAT
AFFRES:		MOV DL, RESASCII
			MOV AX,DL
			MOV CX,0
			MOV DX,0
AFFRESBCL: 	
			CMP AX,0
			JE PRINT1
			MOV BX,10
			DIV BX
			PUSH DX
			INC CX
			XOR DX,DX
			JMP AFFRESBCL
PRINT1:			
			CMP CX,0
			JE SORTIE
			POP DX
			ADD DX,48
			MOV AH,02H
			INT 21H
			DEC CX
			JMP PRINT1
SORTIE:		JMP FIN


;---------------------------

COMMENT /*			
			MOV AH,3FH
			LEA DX, BUFFER
			INT 21H
			
			MOV AH, 40H
			LEA DX, BUFFER
			INT 21H	
*/
;--------------------------- Fin d'execution INT24-4C
FIN:		MOV AH, 4CH
			INT 21H
			

;---------------------------
;------ZONE DE DONNEES------
;---------------------------

br DB 0AH,0DH,"$" ;-- ligne vide
		
NOMBRE1D	db 5 DUP (0DH)
NOMBRE2D	db 5 DUP (0DH)

NOMBRE1b		dW 2 DUP (?)
NOMBRE2b		dW 2 DUP (?)

RESULTAT	dw 2 DUP (?)
RESASCII 	db 2 DUP (?)

OPERATEUR DB 1 DUP (?)
L_OPERATEUR EQU $-OPERATEUR
			
MESSAGE1 	DB "VEUILLEZ SAISIR LE PREMIER NOMBRE"
L_MESSAGE1	EQU $-MESSAGE1
MESSAGE2 	DB "VEUILLEZ SAISIR LE DEUXIEME NOMBRE"
L_MESSAGE2	EQU $-MESSAGE2
MESSAGE3	DB "Quelle operation souhaitez vous realiser ?"
L_MESSAGE3 	EQU $-MESSAGE3
ERREUROPERANDE DB "Erreur lors de la saisie de l'operande"
L_ERREUROPERANDE EQU $-ERREUROPERANDE

BUFFER DB 80,?,80 DUP("$")


;--------------------------- Fin d'assemblage
CSEG		ENDS
			END MAIN
