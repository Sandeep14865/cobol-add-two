# COBOL: Add Two Numbers

A small COBOL program that asks for two numbers, checks that each one is a valid number, adds them, and prints the sum.

```
Enter first number: 20
Enter second number: 30
Sum = 50.00
```

If an input is not a number, the program stops with an error:

```
Enter first number: abc
Error: 'abc' is not a valid number
```

## Dependencies

### Required to compile and run

| Software | Tested version | Purpose | How to get it (macOS) |
|---|---|---|---|
| [GnuCOBOL](https://gnucobol.sourceforge.io/) (`cobc`) | 3.2 | The COBOL compiler. Translates the COBOL source into C. | `brew install gnucobol` |
| C compiler (Apple Clang) | 21.0 | Compiles the C that GnuCOBOL generates into an executable. | `xcode-select --install` (Command Line Tools for Xcode) |
| [GMP](https://gmplib.org/) | 6.3.0 | Exact decimal arithmetic used by GnuCOBOL. | Installed automatically with GnuCOBOL |
| [Berkeley DB](https://www.oracle.com/database/technologies/related/berkeleydb.html) | 18.1 | Indexed-file support in GnuCOBOL (not used by this program, but required by the package). | Installed automatically with GnuCOBOL |
| [Homebrew](https://brew.sh/) | — | macOS package manager used to install GnuCOBOL. | See brew.sh |

Homebrew also installs a few support packages for GnuCOBOL (`json-c`, `openssl`, `ca-certificates`). You do not need to manage them yourself.

### Optional: to work with the code on GitHub

| Software | Tested version | Purpose | How to get it (macOS) |
|---|---|---|---|
| git | 2.55 | Version history (commit, push, pull). | Included with Command Line Tools |
| GitHub CLI (`gh`) | 2.96 | Sign in to GitHub and clone the repo. | `brew install gh` |

Tested on macOS 26.4. GnuCOBOL is also available on Linux (for example `apt install gnucobol`) and Windows.

### Setup on a new Mac

```bash
xcode-select --install
```

```bash
brew install gnucobol
```

```bash
cobc --version
```

## Build and run

```bash
cobc -x ADD-TWO.cbl
./ADD-TWO
```

`-x` tells the compiler to build a standalone executable. The source uses COBOL's traditional fixed format, so do not pass `-free`.

How the build works: `ADD-TWO.cbl` → GnuCOBOL translates it to C → Clang compiles the C → the `ADD-TWO` executable.

## Input rules

| Input | Result |
|---|---|
| `20`, `-7.5`, `+4`, ` 12 `, `.5` | Accepted |
| `5-` | Accepted as -5 (COBOL trailing-sign notation) |
| `abc`, `1,000`, `1e3`, blank | `Error: '...' is not a valid number`, exit code 1 |

On success the exit code is 0.

### Known limitations

Each number must fit in `S9(9)V99` (up to 999,999,999.99, with 2 decimal places). Input that is a valid number but does not fit is cut down silently:

- `1.239` is used as `1.23`.
- `12345678901` loses its leading digits and is used as `345678901.00`.

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
       01  WS-INPUT     PIC X(40).
       01  WS-NUM1      PIC S9(9)V99 VALUE ZERO.
       01  WS-NUM2      PIC S9(9)V99 VALUE ZERO.
       01  WS-SUM       PIC S9(10)V99 VALUE ZERO.
       01  WS-SUM-OUT   PIC -(10)9.99.
```

Declares the variables. The `PIC` (picture) clause describes the shape of each value:

| Symbol | Meaning |
|---|---|
| `X(40)` | Up to 40 characters of any kind (text) |
| `S` | Signed, so the value can be negative |
| `9(9)` | Up to 9 digits |
| `V` | Implied decimal point (not stored as a character) |
| `99` | 2 digits after the decimal point |
| `-(10)` | Display a minus sign for negatives; suppress leading zeros |
| `.` | A real decimal point, used for display |

- `WS-INPUT` holds what the user types, as text, so it can be checked before it is used as a number.
- `WS-NUM1` and `WS-NUM2` hold the two numbers (up to 999,999,999.99 each).
- `WS-SUM` has one extra digit, so adding two maximum-size numbers still fits.
- `WS-SUM-OUT` is an edited field that formats the sum for display, for example `-25.00` instead of raw digits.

The `WS-` prefix is a common naming convention for working-storage items.

### 3. PROCEDURE DIVISION

This is the logic that runs, top to bottom, with no loops.

**Reading and checking each number:**

```cobol
           DISPLAY "Enter first number: " WITH NO ADVANCING
           ACCEPT WS-INPUT
           IF FUNCTION TEST-NUMVAL(WS-INPUT) NOT = ZERO
               DISPLAY "Error: '" FUNCTION TRIM(WS-INPUT)
                   "' is not a valid number"
               MOVE 1 TO RETURN-CODE
               STOP RUN
           END-IF
           COMPUTE WS-NUM1 = FUNCTION NUMVAL(WS-INPUT)
```

- `DISPLAY ... WITH NO ADVANCING` prints the prompt and keeps the cursor on the same line.
- `ACCEPT` reads the line the user types into `WS-INPUT`.
- `FUNCTION TEST-NUMVAL` returns 0 if the text is a valid number, or the position of the first bad character otherwise.
- If the text is not a number, the program prints an error, sets `RETURN-CODE` to 1 (which tells the shell the run failed) and stops.
- Otherwise `FUNCTION NUMVAL` converts the text into a number and `COMPUTE` stores it in `WS-NUM1`.

The same steps are repeated for the second number.

**Adding:**

```cobol
           ADD WS-NUM1 TO WS-NUM2 GIVING WS-SUM
               ON SIZE ERROR
                   DISPLAY "Error: result too large"
                   STOP RUN
           END-ADD
```

Adds the two numbers and stores the result in `WS-SUM`. `ON SIZE ERROR` runs only if the result is too big to fit in `WS-SUM`.

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
