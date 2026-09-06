# Password Security Analyzer — 8086 Assembly

A cybersecurity-focused password analysis project developed in **8086/x86 Assembly (MASM)** for DOS/real-mode environments.

This repository demonstrates the evolution of a basic **Password Strength Checker (V1)** into a more comprehensive **Password Security Analyzer (V2)**.

The project focuses on low-level programming while applying fundamental cybersecurity concepts such as password strength evaluation, predictable-pattern detection, common-password detection, and entropy estimation.

---

## Table of Contents

- [Project Evolution](#project-evolution)
- [V1 vs V2](#v1-vs-v2)
- [Why V2?](#why-v2)
- [V1 — Basic Password Strength Checker](#v1--basic-password-strength-checker)
- [V2 — Password Security Analyzer](#v2--password-security-analyzer)
- [Technical Implementation](#technical-implementation)
- [Bit-Based Security Flags](#bit-based-security-flags)
- [V2 Program Structure](#v2-program-structure)
- [Screenshots](#screenshots)
- [Project Structure](#project-structure)
- [How to Run](#how-to-run)
- [Limitations](#limitations)
- [Future Improvements](#future-improvements)
- [Learning Objectives](#learning-objectives)
- [Project Purpose](#project-purpose)
- [Disclaimer](#disclaimer)
- [Author](#author)
- [License](#license)

---

## Project Evolution

The project was developed in two versions.

### V1 — Basic Password Strength Checker

The original implementation evaluates a password using:

- Password length
- Uppercase characters
- Lowercase characters
- Digits
- Special characters

It calculates a basic score from **0 to 5** and classifies the password as:

| Score | Strength |
|-------|----------|
| 0–2   | WEAK     |
| 3     | MODERATE |
| 4–5   | STRONG   |

V1 was primarily developed to practice 8086 Assembly programming, DOS interrupts, keyboard input, ASCII character classification, loops, conditional branching, and basic scoring logic.

### V2 — Password Security Analyzer

V2 expands the original implementation into a more security-focused analyzer.

It introduces:

- Improved length-based scoring
- Character variety analysis
- Repeated-character detection
- Sequential-pattern detection
- Common-password detection
- Estimated password entropy
- Bit-based security flags
- Security-aware strength classification
- Common-password override logic
- Pattern-based strength penalties

The base score was also expanded from 5 points to 7 points.

```text
V1                          V2
Basic Password Strength     Password Security Analysis
        │                          ▲
        └───── Improved analysis ──┘
```

---

## V1 vs V2

| Feature                              | V1  | V2  |
|---------------------------------------|:---:|:---:|
| Password length analysis              | ✅  | ✅  |
| Lowercase detection                   | ✅  | ✅  |
| Uppercase detection                   | ✅  | ✅  |
| Digit detection                       | ✅  | ✅  |
| Special-character detection           | ✅  | ✅  |
| Basic strength scoring                | ✅  | ✅  |
| Improved length scoring               | ❌  | ✅  |
| Repeated-pattern detection            | ❌  | ✅  |
| Sequential-pattern detection          | ❌  | ✅  |
| Common-password detection             | ❌  | ✅  |
| Entropy estimation                    | ❌  | ✅  |
| Bit-based security flags              | ❌  | ✅  |
| Security-aware final classification   | ❌  | ✅  |

---

## Why V2?

V1 demonstrated that password strength can be estimated using length and character diversity.

However, this approach has an important limitation: a password can satisfy multiple complexity requirements and still be predictable or commonly used.

For example, `P@ssword123!!!` may contain:

- Uppercase characters
- Lowercase characters
- Numbers
- Special characters
- Sufficient length

Yet it can still contain predictable or repeated patterns.

This motivated the development of V2. Instead of relying only on a numerical score, V2 combines multiple security indicators before producing its final classification.

> Password strength should not be determined solely by length and character diversity.

---

## V1 — Basic Password Strength Checker

V1 is the original implementation of the project. The program accepts a password, scans it character by character, identifies different character categories, and calculates a score from 0 to 5.

### V1 Scoring

| Criterion          | Requirement                  | Points |
|---------------------|-------------------------------|:------:|
| Length              | 8 or more characters          | +1     |
| Uppercase           | Contains A–Z                  | +1     |
| Lowercase           | Contains a–z                  | +1     |
| Digit               | Contains 0–9                  | +1     |
| Special Character   | Contains a printable symbol   | +1     |

### V1 Strength Levels

| Score | Strength |
|-------|----------|
| 0–2   | Weak     |
| 3     | Moderate |
| 4–5   | Strong   |

### V1 Learning Focus

V1 focuses on fundamental Assembly concepts including:

- 8086/x86 Assembly
- MASM
- DOS interrupts
- Buffered keyboard input
- ASCII character classification
- Registers
- Memory addressing
- Loops
- Conditional jumps
- Boolean-style flags
- Basic scoring logic
- Console output

---

## V2 — Password Security Analyzer

V2 builds upon the V1 foundation and introduces additional security-oriented analysis.

### V2 Scoring

Password length contributes up to 3 points:

| Length     | Points |
|------------|:------:|
| Less than 8 | 0     |
| 8–11        | +1    |
| 12–15       | +2    |
| 16–20       | +3    |

Character variety contributes another 4 points:

| Character Type     | Points |
|----------------------|:------:|
| Lowercase            | +1     |
| Uppercase            | +1     |
| Digit                | +1     |
| Special character    | +1     |

**Maximum Base Score = 7/7**

### Security Checks

V2 performs additional checks after calculating the base score.

**Repeated Characters**
Detects three or more consecutive identical characters.
Examples: `aaa`, `111`, `!!!`

**Sequential Patterns**
Detects ascending and descending sequences of three or more characters.
Examples: `abc`, `123`, `xyz`, `321`, `cba`

**Common Passwords**
V2 compares the entered password against a small built-in demonstration list containing passwords such as:

- `password`
- `123456`
- `12345678`
- `qwerty`
- `admin`
- `welcome`
- `letmein`
- `password123`

The list is intentionally small and is only a demonstration. It is not a comprehensive database of commonly used or compromised passwords.

**Estimated Entropy**
V2 estimates entropy using:

```
Entropy = Password Length × log2(Character Set Size)
```

A precomputed lookup table is used to perform the calculation using integer arithmetic rather than floating-point operations. The result is displayed in bits.

### V2 Strength Classification

V2 first calculates the base score and then applies additional security rules.

**Base Classification**

| Base Score | Classification |
|------------|-----------------|
| 0–2        | VERY WEAK       |
| 3–4        | WEAK            |
| 5–6        | MODERATE        |
| 7          | STRONG          |

**Common Password Override**
If the password is detected as a common password, the final classification is forced to **WEAK**. This takes precedence over the base score.

**Pattern Penalty**
If a repeated or sequential pattern is detected, the final classification is reduced by one tier, unless the password is already classified as VERY WEAK.

This allows V2 to consider obvious weaknesses that a simple complexity score may overlook.

---

## Technical Implementation

Both versions are implemented using low-level x86 Assembly concepts.

### Technologies

- 8086/x86 Assembly
- MASM
- DOS / Real Mode
- DOS Interrupt INT 21h
- ASCII character classification
- Buffered keyboard input
- Bitwise flags
- String instructions
- Lookup tables
- Integer arithmetic

### V2 Environment

V2 uses the MASM SMALL memory model:

```asm
.MODEL SMALL
.STACK 100h
```

The password input is handled using DOS interrupt 21h, function 0Ah for buffered keyboard input.

---

## Bit-Based Security Flags

V2 stores multiple security findings inside a single byte called `flags`.

| Bit  | Flag         | Meaning                     |
|------|--------------|------------------------------|
| 01h  | LOWER_BIT    | Lowercase detected           |
| 02h  | UPPER_BIT    | Uppercase detected           |
| 04h  | DIGIT_BIT    | Digit detected                |
| 08h  | SPECIAL_BIT  | Special character detected    |
| 10h  | REPEAT_BIT   | Repeated pattern detected      |
| 20h  | SEQ_BIT      | Sequential pattern detected    |
| 40h  | COMMON_BIT   | Common password detected       |

This allows multiple password characteristics and security findings to be represented efficiently in a single byte.

---

## V2 Program Structure

The V2 implementation is divided into procedures responsible for different parts of the analysis.

| Procedure               | Responsibility |
|--------------------------|----------------|
| `MAIN`                   | Program initialization, password input, character classification, security checks, base-score calculation, strength classification, result display, program termination |
| `CHECK_REPEATED`         | Detects three or more consecutive identical characters |
| `CHECK_SEQUENTIAL`       | Checks for ascending and descending three-character sequences |
| `CHECK_COMMON_PASSWORD`  | Iterates through the built-in common-password list |
| `COMPARE_COMMON`         | Compares the entered password against an individual common-password entry using `REPE CMPSB` |
| `CALCULATE_ENTROPY`      | Calculates estimated entropy using password length and detected character-set categories |
| `PRINT_DECIMAL`          | Converts an unsigned integer into decimal output using integer division |

---

## Screenshots

### V1 — Original Implementation

The following screenshots demonstrate the original V1 password strength checker.

| Weak Password | Moderate Password | Strong Password |
|:---:|:---:|:---:|
| ![V1 Weak Password](screenshots/v1/v1-weak.png) | ![V1 Moderate Password](screenshots/v1/v1-moderate.png) | ![V1 Strong Password](screenshots/v1/v1-strong.png) |

### V2 — Improved Security Analyzer

The following screenshots demonstrate the additional security analysis introduced in V2.

| Common Password Detection | Pattern Detection | Strong Password Analysis |
|:---:|:---:|:---:|
| ![V2 Common Password Detection](screenshots/v2/v2-common-password.png) | ![V2 Pattern Detection](screenshots/v2/v2-pattern-detection.png) | ![V2 Strong Password Analysis](screenshots/v2/v2-strong-password.png) |

---

## Project Structure

```text
password-security-analyzer-asm/
│
├── README.md
│
├── v1-basic-strength-checker/
│   ├── PasswordStrengthChecker.asm
│   └── README.md
│
├── v2-security-analyzer/
│   ├── PasswordSecurityAnalyzer_v2.asm
│   └── README.md
│
├── screenshots/
│   ├── v1/
│   │   ├── v1-weak.png
│   │   ├── v1-moderate.png
│   │   └── v1-strong.png
│   │
│   └── v2/
│       ├── v2-common-password.png
│       ├── v2-pattern-detection.png
│       └── v2-strong-password.png
│
└── LICENSE
```

---

## How to Run

Both versions are designed for DOS/real-mode execution using a compatible MASM toolchain or DOS emulator.

### V1

Navigate to the V1 directory:

```bash
cd v1-basic-strength-checker/
```

Assemble and link:

```bash
ml /c PasswordStrengthChecker.asm
link PasswordStrengthChecker.obj
```

Run:

```bash
PasswordStrengthChecker.exe
```

### V2

Navigate to the V2 directory:

```bash
cd v2-security-analyzer/
```

Assemble and link:

```bash
ml /c PasswordSecurityAnalyzer_v2.asm
link PasswordSecurityAnalyzer_v2.obj
```

Run:

```bash
PasswordSecurityAnalyzer_v2.exe
```

> The exact commands may vary depending on the MASM/TASM version and DOS environment being used.

---

## Limitations

This project is designed as an educational cybersecurity and Assembly programming project, rather than a production-grade password auditing system.

Current limitations include:

- V2 supports a maximum password length of 20 characters
- The common-password database contains only a small demonstration list
- No real-world breached-password database is used
- Sequential detection focuses on three-character ascending/descending sequences
- Repeated-pattern detection focuses on consecutive identical characters
- Entropy is a theoretical estimate based on detected character categories
- Password input is not hidden from the console
- The application is designed for DOS/real-mode execution

---

## Future Improvements

Potential future versions could include:

- Larger common-password and dictionary databases
- Keyboard-pattern detection such as `qwerty` and `asdf`
- Repeated-substring detection
- More advanced sequential-pattern detection
- Password masking during input
- Support for longer passwords
- Password recommendations
- More detailed security reports
- More rigorous entropy estimation
- Integration with breached-password databases in a higher-level implementation

---

## Learning Objectives

This project provided practical experience with:

- 8086/x86 Assembly
- MASM
- DOS interrupts
- Buffered keyboard input
- Registers and memory addressing
- ASCII character classification
- Conditional jumps
- Loops
- Procedures
- Stack operations
- Bitwise flags
- String instructions (`CMPSB`, `REPE`)
- Integer multiplication and division
- Lookup tables
- Modular program design
- Basic password-security concepts

---

## Project Purpose

This project was created to explore the intersection of low-level programming and cybersecurity.

The project began with a simple password-strength checker and was progressively developed into a security-focused analyzer.

V1 established the basic password-scoring mechanism. V2 extended that foundation by introducing:

- Pattern detection
- Common-password detection
- Entropy estimation
- Bitwise security flags
- Improved scoring
- Security-aware classification

The project demonstrates how a simple programming concept can be iteratively improved by identifying limitations and introducing additional security considerations.

---

## Disclaimer

This project is intended for educational purposes.

The strength classifications and entropy values are simplified estimates and should not be treated as professional password-security assessments.

Real-world password security should also consider modern password-strength estimation techniques, breached-password detection, password managers, multi-factor authentication, rate limiting, and secure password storage.

---

## Author

**Aun Raza**
BS Cyber Security Student
Islamia University Bahawalpur (IUB)

---

## License

This project is available for educational and learning purposes.