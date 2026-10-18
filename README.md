# COBOL: Add Two Numbers

A small COBOL program that asks for two numbers, adds them, and prints the sum.

```
Enter first number: 20
Enter second number: 30
Sum = 50.00
```

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

A COBOL program is split into **divisions**. This one uses three.

### 1. IDENTIFICATION DIVISION

```cobol
       IDENTIFICATION DIVISION.
       PROGRAM-ID. ADD-TWO.
```

Names the program `ADD-TWO`.

### 2. DATA DIVISION

```cobol
       WORKING-STORAGE SECTION.
       01  WS-NUM1      PIC S9(9)V99 VALUE ZERO.
       01  WS-NUM2      PIC S9(9)V99 VALUE ZERO.
       01  WS-SUM       PIC S9(10)V99 VALUE ZERO.
       01  WS-SUM-OUT   PIC -(10)9.99.
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

### 3. PROCEDURE DIVISION

This is the logic that runs.

```cobol
           DISPLAY "Enter first number: " WITH NO ADVANCING
           ACCEPT WS-NUM1
```

`DISPLAY` prints a prompt and `WITH NO ADVANCING` keeps the cursor on the same line. `ACCEPT` reads what the user types into the variable. The same is done for the second number.

```cobol
           ADD WS-NUM1 TO WS-NUM2 GIVING WS-SUM
               ON SIZE ERROR
                   DISPLAY "Error: result too large"
                   STOP RUN
           END-ADD
```

Adds the two numbers and stores the result in `WS-SUM`. `ON SIZE ERROR` runs only if the result is too big to fit in `WS-SUM`.

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

That is why every line is indented.
