       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADD-TWO.
      *> Reads two numbers from the user and displays their sum.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-NUM1      PIC S9(9)V99 VALUE ZERO.
       01  WS-NUM2      PIC S9(9)V99 VALUE ZERO.
       01  WS-SUM       PIC S9(10)V99 VALUE ZERO.
       01  WS-SUM-OUT   PIC -(10)9.99.

       PROCEDURE DIVISION.
       MAIN-PARA.
           DISPLAY "Enter first number: " WITH NO ADVANCING
           ACCEPT WS-NUM1
           DISPLAY "Enter second number: " WITH NO ADVANCING
           ACCEPT WS-NUM2

           ADD WS-NUM1 TO WS-NUM2 GIVING WS-SUM
               ON SIZE ERROR
                   DISPLAY "Error: result too large"
                   STOP RUN
           END-ADD

           MOVE WS-SUM TO WS-SUM-OUT
           DISPLAY "Sum = " FUNCTION TRIM(WS-SUM-OUT)
           STOP RUN.
