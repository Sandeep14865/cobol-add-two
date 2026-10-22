       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADD-TWO.
      *> Reads two numbers from the user and displays their sum.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-INPUT     PIC X(40).
       01  WS-NUM1      PIC S9(9)V99 VALUE ZERO.
       01  WS-NUM2      PIC S9(9)V99 VALUE ZERO.
       01  WS-SUM       PIC S9(10)V99 VALUE ZERO.
       01  WS-SUM-OUT   PIC -(10)9.99.

       PROCEDURE DIVISION.
       MAIN-PARA.
           DISPLAY "Enter first number: " WITH NO ADVANCING
           ACCEPT WS-INPUT
           IF FUNCTION TEST-NUMVAL(WS-INPUT) NOT = ZERO
               DISPLAY "Error: '" FUNCTION TRIM(WS-INPUT)
                   "' is not a valid number"
               MOVE 1 TO RETURN-CODE
               STOP RUN
           END-IF
           COMPUTE WS-NUM1 = FUNCTION NUMVAL(WS-INPUT)

           DISPLAY "Enter second number: " WITH NO ADVANCING
           ACCEPT WS-INPUT
           IF FUNCTION TEST-NUMVAL(WS-INPUT) NOT = ZERO
               DISPLAY "Error: '" FUNCTION TRIM(WS-INPUT)
                   "' is not a valid number"
               MOVE 1 TO RETURN-CODE
               STOP RUN
           END-IF
           COMPUTE WS-NUM2 = FUNCTION NUMVAL(WS-INPUT)

           ADD WS-NUM1 TO WS-NUM2 GIVING WS-SUM
               ON SIZE ERROR
                   DISPLAY "Error: result too large"
                   STOP RUN
           END-ADD

           MOVE WS-SUM TO WS-SUM-OUT
           DISPLAY "Sum = " FUNCTION TRIM(WS-SUM-OUT)
           STOP RUN.
