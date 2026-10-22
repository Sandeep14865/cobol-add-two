# COBOL: Add Two Numbers

A small COBOL program that asks for two numbers, adds them, and prints the sum. It checks every input and asks again if one is invalid.

```
Enter first number: abc
  'abc' is not a valid number.
Enter first number: 20
Enter second number: 30.5
Sum = 50.50
```

## Input rules

| Input | Result |
|---|---|
| `20`, `-7.5`, `+4`, ` 12 `, `.5` | Accepted |
| `5-` | Accepted as -5 (COBOL trailing-sign notation) |
| Blank | "Please enter a number." |
| `abc`, `1,000`, `1e3` | "... is not a valid number." |
| `1.239` | "Use at most 2 decimal places." |
| `12345678901` | "Number must be between -999999999.99 and 999999999.99." |
| More than 20 characters | "Input is too long." |

After 3 invalid tries for the same number, or if input ends (for example Ctrl+D), the program stops with an error and exit code 1. On success the exit code is 0.

## Requirements

[GnuCOBOL](https://gnucobol.sourceforge.io/) 3.x. On macOS:

```bash
brew install gnucobol
```

## Build and run

```bash
cobc -x ADD-TWO.cbl
./ADD-TWO
```

`-x` tells the compiler to build a standalone executable. The source uses COBOL's traditional fixed format, so do not pass `-free`.

## How the code works

A COBOL program is split into **divisions**. This one uses three. The PROCEDURE DIVISION is further split into **paragraphs** (named blocks of code) that call each other with `PERFORM`.

### 1. IDENTIFICATION DIVISION

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADD-TWO.
```

Names the program `ADD-TWO`.

### 2. DATA DIVISION

```cobol
       WORKING-STORAGE SECTION.
       01  WS-NUM1          PIC S9(9)V99 VALUE ZERO.
       01  WS-NUM2          PIC S9(9)V99 VALUE ZERO.
       01  WS-SUM           PIC S9(10)V99 VALUE ZERO.
       01  WS-SUM-OUT       PIC -(11)9.99.
```

Declares the variables. The `PIC` (picture) clause describes the shape of each value:

| Symbol | Meaning |
|---|---|
| `S` | Signed, so the value can be negative |
| `9(9)` | Up to 9 digits |
| `V` | Implied decimal point (not stored as a character) |
| `99` | 2 digits after the decimal point |
| `-(10)` | Display a minus sign for negatives; suppress leading zeros |
| `.` | A real decimal point, used for display |

- `WS-NUM1` and `WS-NUM2` hold the two inputs (up to 999,999,999.99 each).
- `WS-SUM` has one extra digit, so adding two maximum-size numbers still fits.
- `WS-SUM-OUT` is an edited field that formats the sum for display, for example `-25.00` instead of raw digits.

The `WS-` prefix is a common naming convention for working-storage items.

The remaining fields support input checking:

| Field | Purpose |
|---|---|
| `WS-INPUT PIC X(80)` | The raw text the user typed (`X` = any character) |
| `WS-WIDE PIC S9(19)V9(19)` | A very wide number used while checking, so nothing is cut off before the range and decimal checks run |
| `WS-VALUE` | The checked number handed back to the main logic |
| `WS-VALID-FLAG` with `88 WS-VALID` | An `88` level is a named condition: `IF WS-VALID` means "flag is Y", and `SET WS-VALID TO TRUE` sets it |
| `WS-MAX-VALUE`, `WS-MAX-LEN`, `WS-MAX-ATTEMPTS` | Limits, kept in one place so they are easy to change |

### 3. PROCEDURE DIVISION

This is the logic that runs, in three paragraphs.

**`MAIN-PARA`** asks for each number, then adds and prints:

```cobol
           MOVE "first" TO WS-LABEL
           PERFORM GET-NUMBER
           MOVE WS-VALUE TO WS-NUM1
```

`PERFORM GET-NUMBER` runs that paragraph and comes back. The same is done for the second number.

```cobol
           ADD WS-NUM1 TO WS-NUM2 GIVING WS-SUM
               ON SIZE ERROR
                   DISPLAY "Error: result too large"
                   MOVE 1 TO RETURN-CODE
                   STOP RUN
           END-ADD
```

Adds the two numbers and stores the result in `WS-SUM`. Because inputs are range-checked and `WS-SUM` has an extra digit, the size error should never happen; it is kept as a safety net.

**`GET-NUMBER`** prompts in a loop:

```cobol
           PERFORM UNTIL WS-VALID OR WS-ATTEMPTS >= WS-MAX-ATTEMPTS
               ...
               ACCEPT WS-INPUT
                   ON EXCEPTION
                       ...
               END-ACCEPT
               PERFORM VALIDATE-INPUT
           END-PERFORM
```

`DISPLAY ... WITH NO ADVANCING` prints the prompt and keeps the cursor on the same line. `ACCEPT` reads the line as text, so the program can inspect it before treating it as a number. `ON EXCEPTION` catches the end of input, which would otherwise loop forever. Setting `RETURN-CODE` to 1 makes the program report failure to the shell.

**`VALIDATE-INPUT`** checks the text with `EVALUATE TRUE`, COBOL's version of a chain of if/else-if. The first matching `WHEN` wins:

1. Blank → "Please enter a number."
2. Longer than 20 characters → "Input is too long."
3. `FUNCTION TEST-NUMVAL` returns 0 for valid numeric text, or the position of the first bad character. Non-zero → "not a valid number."
4. Otherwise `FUNCTION NUMVAL` converts the text into `WS-WIDE`, then:
   - Bigger than 999,999,999.99 either way → range message.
   - `WS-WIDE * 100` has a fractional part → more than 2 decimals.
   - Otherwise the value is copied to `WS-VALUE` and marked valid.

**Printing the result:**

```cobol
           MOVE WS-SUM TO WS-SUM-OUT
           DISPLAY "Sum = " FUNCTION TRIM(WS-SUM-OUT)
           STOP RUN.
```

`MOVE` copies the sum into the display field, which applies the formatting. `FUNCTION TRIM` removes leading spaces before printing, and `STOP RUN` ends the program.

## A note on the layout

In fixed-format COBOL, column position matters:

- Columns 1–6 are for sequence numbers (left blank here).
- Column 7 is the indicator area. A `*` there marks a comment line.
- Code starts at column 8 (division and paragraph headers) or column 12 (statements).
- Anything past column 72 is ignored, so long statements are split across lines.

That is why every line is indented.
