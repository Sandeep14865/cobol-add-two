       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADD-TWO.
      *> Reads two numbers from the user and displays their sum.
      *> Each input is validated; invalid input is re-prompted.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       01  WS-NUM1          PIC S9(9)V99 VALUE ZERO.
       01  WS-NUM2          PIC S9(9)V99 VALUE ZERO.
       01  WS-SUM           PIC S9(10)V99 VALUE ZERO.
       01  WS-SUM-OUT       PIC -(11)9.99.

      *> Shared by GET-NUMBER and VALIDATE-INPUT.
       01  WS-LABEL         PIC X(6).
       01  WS-INPUT         PIC X(80).
       01  WS-INPUT-LEN     PIC 9(3).
       01  WS-WIDE          PIC S9(19)V9(19).
       01  WS-VALUE         PIC S9(9)V99.
       01  WS-ATTEMPTS      PIC 9.
       01  WS-VALID-FLAG    PIC X.
           88  WS-VALID     VALUE "Y".

       01  WS-MAX-VALUE     PIC 9(9)V99 VALUE 999999999.99.
       01  WS-MAX-LEN       PIC 9(3)    VALUE 20.
       01  WS-MAX-ATTEMPTS  PIC 9       VALUE 3.

       PROCEDURE DIVISION.
       MAIN-PARA.
           MOVE "first" TO WS-LABEL
           PERFORM GET-NUMBER
           MOVE WS-VALUE TO WS-NUM1

           MOVE "second" TO WS-LABEL
           PERFORM GET-NUMBER
           MOVE WS-VALUE TO WS-NUM2

           ADD WS-NUM1 TO WS-NUM2 GIVING WS-SUM
               ON SIZE ERROR
                   DISPLAY "Error: result too large"
                   MOVE 1 TO RETURN-CODE
                   STOP RUN
           END-ADD

           MOVE WS-SUM TO WS-SUM-OUT
           DISPLAY "Sum = " FUNCTION TRIM(WS-SUM-OUT)
           STOP RUN.

      *> Prompts until a valid number is entered (at most
      *> WS-MAX-ATTEMPTS tries) and leaves it in WS-VALUE.
       GET-NUMBER.
           MOVE "N" TO WS-VALID-FLAG
           MOVE ZERO TO WS-ATTEMPTS
           PERFORM UNTIL WS-VALID OR WS-ATTEMPTS >= WS-MAX-ATTEMPTS
               ADD 1 TO WS-ATTEMPTS
               DISPLAY "Enter " FUNCTION TRIM(WS-LABEL) " number: "
                   WITH NO ADVANCING
               MOVE SPACES TO WS-INPUT
               ACCEPT WS-INPUT
                   ON EXCEPTION
                       DISPLAY " "
                       DISPLAY "Error: no input received"
                       MOVE 1 TO RETURN-CODE
                       STOP RUN
               END-ACCEPT
               PERFORM VALIDATE-INPUT
           END-PERFORM

           IF NOT WS-VALID
               DISPLAY "Error: too many invalid attempts"
               MOVE 1 TO RETURN-CODE
               STOP RUN
           END-IF.

      *> Checks WS-INPUT; on success sets WS-VALID and WS-VALUE,
      *> otherwise explains what is wrong.
       VALIDATE-INPUT.
           IF WS-INPUT = SPACES
               MOVE ZERO TO WS-INPUT-LEN
           ELSE
               MOVE FUNCTION LENGTH(FUNCTION TRIM(WS-INPUT))
                   TO WS-INPUT-LEN
           END-IF

           EVALUATE TRUE
               WHEN WS-INPUT-LEN = ZERO
                   DISPLAY "  Please enter a number."
               WHEN WS-INPUT-LEN > WS-MAX-LEN
                   DISPLAY "  Input is too long."
               WHEN FUNCTION TEST-NUMVAL(WS-INPUT) NOT = ZERO
                   DISPLAY "  '" FUNCTION TRIM(WS-INPUT)
                       "' is not a valid number."
               WHEN OTHER
                   COMPUTE WS-WIDE = FUNCTION NUMVAL(WS-INPUT)
                   EVALUATE TRUE
                       WHEN FUNCTION ABS(WS-WIDE) > WS-MAX-VALUE
                           DISPLAY "  Number must be between "
                               "-999999999.99 and 999999999.99."
                       WHEN WS-WIDE * 100
                            NOT = FUNCTION INTEGER-PART(WS-WIDE * 100)
                           DISPLAY "  Use at most 2 decimal places."
                       WHEN OTHER
                           MOVE WS-WIDE TO WS-VALUE
                           SET WS-VALID TO TRUE
                   END-EVALUATE
           END-EVALUATE.
