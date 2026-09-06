# Password Strength Checker

A simple **Password Strength Checker written in x86 Assembly (MASM)** for DOS/real-mode environments.

The program accepts a password from the user, scans it character by character, identifies different character types, and calculates a strength score from **0 to 5**.

This project was developed as a learning exercise to practice **8086/x86 Assembly, DOS interrupts, keyboard input, ASCII character classification, loops, conditional branching, and basic scoring logic**.

## Features

The password is evaluated using five criteria:

| Criterion         | Requirement                 | Points |
| ----------------- | --------------------------- | -----: |
| Length            | 8 or more characters        |     +1 |
| Uppercase         | Contains `A-Z`              |     +1 |
| Lowercase         | Contains `a-z`              |     +1 |
| Digit             | Contains `0-9`              |     +1 |
| Special Character | Contains a printable symbol |     +1 |

The maximum possible score is **5/5**.

### Strength Levels

| Score | Strength |
| ----- | -------- |
| 0–2   | Weak     |
| 3     | Moderate |
| 4–5   | Strong   |

## Example

```text
Password Strength Checker
-------------------------
Enter a password to test: Test@123

Score: 4/5

Strength: STRONG (Excellent!)
```

## Technologies Used

* **x86 Assembly**
* **MASM (Microsoft Macro Assembler)**
* **DOS / Real Mode**
* **DOS Interrupt 21h**
* **ASCII character classification**
* **VS Code** (development environment)

## How It Works

### 1. Initialize the Data Segment

The program begins by loading the address of the data segment into `DS`:

```asm
MOV AX, @DATA
MOV DS, AX
```

This allows the program to access its variables and messages stored in the `.DATA` segment.

### 2. Read the Password

The program uses DOS interrupt `INT 21h` with `AH = 0Ah` for **buffered keyboard input**:

```asm
LEA DX, max_len
MOV AH, 0Ah
INT 21h
```

The input buffer follows the DOS-required structure:

```text
[max length][actual length][password characters...]
```

The program allows a maximum of **20 characters**.

### 3. Scan Each Character

After receiving the password, the program processes each character individually.

It checks whether the character belongs to one of these ASCII ranges:

```text
A-Z  → Uppercase
a-z  → Lowercase
0-9  → Digit
21h-7Eh → Printable special character
```

The checks are implemented using Assembly comparison and conditional jump instructions such as:

```asm
CMP
JB
JA
JMP
```

### 4. Track Character Types

Four flags keep track of whether the password contains:

```text
has_upper
has_lower
has_digit
has_special
```

Each flag is initially `0` and becomes `1` when the corresponding character type is detected.

The password is scanned once from beginning to end.

### 5. Calculate the Score

After scanning the password, the program starts with a score of `0`.

It awards:

* `+1` if the password is at least 8 characters long
* `+1` for an uppercase letter
* `+1` for a lowercase letter
* `+1` for a digit
* `+1` for a printable special character

The resulting score is stored in:

```asm
total_score
```

### 6. Display the Result

The score is displayed using DOS interrupt `INT 21h` with `AH = 02h`.

The program then determines the strength level:

```text
0–2 → WEAK
3   → MODERATE
4–5 → STRONG
```

Finally, the program exits using DOS interrupt `INT 21h` with `AH = 4Ch`.

## Project Structure

```text
Password-Strength-Checker/
│
├── PasswordStrengthChecker.asm
└── README.md
```

## Requirements

To assemble and run this project, you need:

* MASM or a compatible x86 Assembly assembler
* A DOS/real-mode environment or emulator such as DOSBox
* A compatible linker
* VS Code is optional

> The exact commands may differ depending on the MASM/TASM version and whether the project is being built directly in DOSBox or through a configured development environment.

## Build and Run

### Assemble

```text
ml /c PasswordStrengthChecker.asm
```

### Link

```text
link PasswordStrengthChecker.obj
```

### Run

```text
PasswordStrengthChecker.exe
```

If you are using a 16-bit MASM/TASM toolchain through DOSBox, the commands and executable format may vary slightly.

## Limitations

This project is intentionally a **basic educational password strength checker**, not a production-grade password security tool.

It does not currently perform:

* Password entropy calculation
* Dictionary or common-password detection
* Detection of repeated characters
* Detection of sequential patterns such as `1234` or `abcd`
* Unicode or multi-byte character handling
* Password masking while typing
* Password storage or encryption

For example, a password could receive a high score because it contains different character types even if it is a commonly used password.

## Possible Future Improvements

Potential extensions include:

* Add password masking using `*`
* Detect common passwords
* Detect repeated characters
* Detect sequential patterns
* Implement a more advanced scoring system
* Add entropy estimation
* Support a larger input buffer
* Improve input validation
* Add a password-generation mode
* Create a menu-driven Assembly application

## Learning Objectives

This project provides practice with:

* x86 Assembly syntax
* MASM directives
* DOS interrupts
* Buffered keyboard input
* Memory and data segments
* ASCII character ranges
* Registers such as `AX`, `DX`, `SI`, `CX`, and `AL`
* `CMP` and conditional jumps
* Loops using the `LOOP` instruction
* Boolean-style flags
* Basic program flow and branching
* Console output in DOS environments

## License

This project is intended for **educational and learning purposes**.
