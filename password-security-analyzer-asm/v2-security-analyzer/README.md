# Password Security Analyzer

A console-based **Password Security Analyzer** written in **8086/x86 Assembly (MASM)** for DOS/real-mode environments.

The program analyzes a user-provided password and evaluates its security using multiple criteria, including password length, character variety, repeated-character patterns, sequential patterns, common-password detection, and estimated entropy.

---

## Features

The analyzer performs the following checks:

### 1. Password Length

The password can contain up to **20 characters**.

Length contributes up to **3 points** to the base score:

| Length      | Points |
| ----------- | -----: |
| Less than 8 |      0 |
| 8–11        |      1 |
| 12–15       |      2 |
| 16–20       |      3 |

---

### 2. Character Variety

The program checks whether the password contains:

* Lowercase letters (`a-z`)
* Uppercase letters (`A-Z`)
* Digits (`0-9`)
* Special characters (`!` through `~`)

Each character category contributes **1 point** to the base score.

Therefore, the maximum base score is **7/7**:

**3 points for length + 4 points for character variety**

---

### 3. Repeated Character Detection

The analyzer detects **three or more consecutive identical characters**.

For example:

```text
aaa
111
!!!
```

If such a pattern is detected, the password is flagged as containing a repeated pattern.

---

### 4. Sequential Pattern Detection

The program detects ascending or descending sequences of **three or more consecutive characters**.

Examples include:

```text
abc
123
xyz
321
cba
```

Both ascending and descending sequences are checked.

---

### 5. Common Password Detection

The analyzer compares the entered password against a small built-in list of commonly used passwords.

The current demonstration list contains:

```text
password
123456
12345678
qwerty
admin
welcome
letmein
password123
```

A password matching one of these entries is marked as a **common password**.

> **Note:** This is a demonstration list and is not intended to represent a comprehensive database of compromised or commonly used passwords.

---

### 6. Estimated Entropy

The program estimates password entropy using:

```text
Entropy = Password Length × log2(Character Set Size)
```

The character-set size is determined by the categories detected in the password.

The implementation uses a precomputed lookup table for:

```text
log2(character-set size) × 10
```

This allows the calculation to be performed efficiently using integer arithmetic rather than floating-point operations.

The result is displayed in **bits**.

---

## Strength Classification

After calculating the base score, the password is assigned an initial strength tier.

| Base Score | Classification |
| ---------: | -------------- |
|        0–2 | VERY WEAK      |
|        3–4 | WEAK           |
|        5–6 | MODERATE       |
|          7 | STRONG         |

The analyzer then applies additional security rules.

### Common Password Override

If the password is detected as a common password, its final classification is forced to:

```text
WEAK
```

This override takes precedence over the base score.

### Pattern Penalty

If a repeated or sequential pattern is detected, the final strength is reduced by **one tier**, unless the password is already classified as **VERY WEAK**.

---

## Output

The program displays:

* Password length
* Lowercase character presence
* Uppercase character presence
* Digit presence
* Special character presence
* Repeated pattern detection
* Sequential pattern detection
* Common password detection
* Estimated entropy
* Base score
* Final password strength

Example output structure:

```text
Password Security Analyzer
===========================
Enter a password to test:

Length: 16

Character Analysis:
  Lowercase : YES
  Uppercase : YES
  Digit     : YES
  Special   : YES

Security Checks:
  Repeated pattern  : NO
  Sequential pattern: NO
  Common password    : NO

Estimated Entropy: XX bits

Base Score: 7/7

Strength: STRONG (Excellent!)
```

---

## Technical Details

| Component               | Details                     |
| ----------------------- | --------------------------- |
| Language                | x86 Assembly                |
| Architecture            | 8086/x86                    |
| Assembler               | MASM                        |
| Environment             | DOS / Real Mode             |
| Memory Model            | SMALL                       |
| Maximum Password Length | 20 characters               |
| Input Method            | DOS buffered keyboard input |
| DOS Interrupt           | `INT 21h`                   |
| Entropy Calculation     | Lookup-table based          |
| Output                  | Console                     |

The program uses the **SMALL memory model** and a `100h` byte stack:

```asm
.MODEL SMALL
.STACK 100h
```

## Password input is handled using DOS interrupt `21h`, function `0Ah` for buffered input.

## Program Structure

The program is divided into several procedures, each responsible for a specific part of the analysis.

### `MAIN`

Handles:

* Program initialization
* DOS input
* Character classification
* Calling security-check procedures
* Base-score calculation
* Strength classification
* Result display
* Program termination

---

### `CHECK_REPEATED`

Detects three or more consecutive identical characters.

```text
aaa
111
###
```

The procedure scans the password and maintains a count of consecutive matching characters.

---

### `CHECK_SEQUENTIAL`

Checks for ascending and descending three-character sequences.

For example:

```text
abc
123
cba
321
```

The procedure compares the differences between adjacent characters to identify sequential patterns.

---

### `CHECK_COMMON_PASSWORD`

Iterates through the built-in common-password table and checks whether the entered password matches one of the stored passwords.

---

### `COMPARE_COMMON`

Compares the entered password with an individual null-terminated password from the common-password list.

The procedure first checks the lengths and then uses the x86 string comparison instruction:

```asm
REPE CMPSB
```

The carry flag is used to indicate whether a match was found.

---

### `CALCULATE_ENTROPY`

Calculates the estimated entropy based on:

```text
Password Length × log2(Character Set Size)
```

A lookup table is used to avoid floating-point calculations.

---

### `PRINT_DECIMAL`

Converts an unsigned integer in `AX` into decimal output using repeated division by 10.

This allows values such as password length and entropy to be displayed through DOS console output.

---

## Flag-Based Design

The analyzer stores its security findings inside a single byte called `flags`.

Each bit represents a different condition:

|   Bit | Flag          | Meaning                     |
| ----: | ------------- | --------------------------- |
| `01h` | `LOWER_BIT`   | Lowercase detected          |
| `02h` | `UPPER_BIT`   | Uppercase detected          |
| `04h` | `DIGIT_BIT`   | Digit detected              |
| `08h` | `SPECIAL_BIT` | Special character detected  |
| `10h` | `REPEAT_BIT`  | Repeated pattern detected   |
| `20h` | `SEQ_BIT`     | Sequential pattern detected |
| `40h` | `COMMON_BIT`  | Common password detected    |

This allows multiple characteristics to be represented efficiently in a single byte.

---

## Scoring Logic

The base score is calculated from two groups of criteria.

### Length

```text
8+ characters   → +1
12+ characters  → +1
16+ characters  → +1
```

### Character Variety

```text
Lowercase       → +1
Uppercase       → +1
Digit           → +1
Special         → +1
```

Therefore:

```text
Maximum Base Score = 7
```

The implementation calculates these values before applying the common-password and pattern overrides.

---

## Security Model

The program intentionally uses more than just a numerical score.

A password can have a high base score but still receive a lower final classification if it contains an obvious weakness.

For example:

```text
P@ssword123!!!
```

may contain several character categories and sufficient length, but repeated patterns or common-password characteristics can affect the final classification.

This demonstrates an important security concept:

> **Password strength should not be determined solely by length and character diversity.**

---

## Limitations

This project is designed as an educational Assembly programming project rather than a production-grade password auditing system.

Current limitations include:

* Maximum password length is 20 characters.
* The common-password database contains only 8 entries.
* Sequential detection focuses on three-character ascending/descending sequences.
* Repeated-pattern detection focuses on consecutive identical characters.
* Entropy is an estimate based on character categories rather than measured password randomness.
* The program does not check passwords against real-world breach databases.
* The program does not perform cryptographic password-strength analysis.
* Password input is not hidden from the console.
* The analyzer is designed for DOS/real-mode execution.

---

## Learning Objectives

This project demonstrates practical use of several x86 Assembly concepts:

* DOS interrupts
* Buffered keyboard input
* Registers and memory addressing
* Conditional jumps
* Loops
* Procedures
* Stack operations
* Bitwise flags
* String instructions
* `CMPSB`
* `REPE`
* Integer multiplication and division
* Lookup tables
* ASCII character classification
* Modular program design

---

## Possible Future Improvements

Potential improvements include:

* Expand the common-password database.
* Add dictionary-based password detection.
* Detect keyboard patterns such as `qwerty` and `asdf`.
* Detect repeated substrings rather than only repeated characters.
* Improve sequential-pattern detection.
* Add password masking during input.
* Allow passwords longer than 20 characters.
* Add password recommendations.
* Provide a more detailed security report.
* Add breach-database integration in a higher-level implementation.
* Improve entropy estimation using a more rigorous password model.

---

## Project Purpose

This project was created to explore **low-level programming and cybersecurity concepts using x86 Assembly**.

Rather than simply checking whether a password contains uppercase letters, numbers, and special characters, the analyzer combines multiple security indicators to provide a more meaningful assessment.

It demonstrates how a cybersecurity-oriented application can be implemented using low-level operations, registers, memory, bitwise flags, loops, and DOS services.

---

## Disclaimer

This project is intended for **educational purposes**.

The strength classifications and entropy values are simplified estimates and should not be treated as a professional password-security assessment.

For real-world security applications, password strength evaluation should consider modern password-strength estimation techniques, breached-password databases, password managers, rate limiting, multi-factor authentication, and secure password storage practices.

---

## Author

**Aun Raza**

BS Cyber Security Student
Islamia University Bahawalpur (IUB)

---

## License

This project is available for educational and learning purposes.
