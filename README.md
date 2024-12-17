
## Team Members

- **Name**: Huilin Tai (ht2666), Huixuan Huang (hh3101)

---

## Table of Contents

1. [Introduction](#introduction)  
2. [Language Structure](#language-structure)  
3. [Lexical Grammar](#lexical-grammar)  
   - [Token Types and Definitions](#token-types-and-definitions)  
4. [Grammar Definition (CFG)](#grammar-definition-cfg)  
5. [Installation and Execution](#installation-and-execution)  
   - [Prerequisites](#prerequisites)  
   - [Execution Steps](#execution-steps)  
6. [Detailed Description of Each Step](#detailed-description-of-each-step)  
   - [Lexer Algorithm](#lexer-algorithm)  
   - [Parser Algorithm](#parser-algorithm)  
   - [AST Printer](#ast-printer)  
   - [Code Generator Algorithm](#code-generator-algorithm)  
   - [Error Handling](#error-handling)  
7. [Code Optimization](#code-optimization)  
   - [Implemented Optimization Techniques](#implemented-optimization-techniques)  
   - [Sample Input Programs for Optimization](#sample-input-programs-for-optimization)  
8. [Additional Notes on Code Structure](#additional-notes-on-code-structure)  
9. [Video](#video)

---

## Introduction

This project implements a compiler front-end for a custom domain-specific programming language designed for musical notation and playback commands. The language allows users to specify musical attributes (BPM, instrument, composer, title) and define sequences of notes (with optional repeats) to generate a MIDI file. The compilation pipeline includes:

1. **Lexical Analysis (Lexer)**: Converts the source code into a sequence of tokens.
2. **Parsing (Parser)**: Uses a recursive descent parser to build an Abstract Syntax Tree (AST).
3. **Code Generation**: Translates the AST into a MIDI file, playable by standard MIDI players.
4. **Code Optimization (New)**: Applies multiple optimization techniques to produce more efficient intermediate code before generating the final MIDI.

---

## Language Structure

- **Header Declarations**: Set global attributes such as instrument, BPM, title, and composer.
- **Play Commands**: Define sequences of notes and repeated patterns.
- **Music Notes**: Defined using solfege (Do, Re, Mi, Fa, So, La, Ti), octave, and an accidental (#, -, _).
- **End Command**: The `end` keyword signifies the conclusion of the program.

### Example:

```plaintext
composer = "Bach";
title = "Fugue";
bpm = 120;
instrument = Piano;

play (
  Do4# quarter, Re4- half, repeat(Mi4_ quarter, Fa4_ quarter)
);
end
```

---

## Lexical Grammar

### Token Types and Definitions

| Token Type     | Example       | Description                                                         |
|----------------|---------------|---------------------------------------------------------------------|
| KEYWORD        | `play`        | Reserved words (`play`, `repeat`, `end`, `instrument`, `bpm`, etc.) |
| IDENTIFIER     | `Piano`       | User-defined names                                                  |
| OPERATOR       | `=`           | Used for assignments                                                |
| NUMBER         | `120`         | Numeric literals                                                    |
| STRING_LITERAL | `"Beethoven"` | Text enclosed in quotes                                             |
| MUSICNOTE      | `Do5#`        | A musical note (solfege, octave, accidental)                        |
| DURATION       | `quarter`     | Note durations (`whole`, `half`, `quarter`, `eighth`, `sixteenth`)  |
| LPAREN         | `(`           | Left parenthesis                                                    |
| RPAREN         | `)`           | Right parenthesis                                                   |
| SEMICOLON      | `;`           | Statement terminator                                                |
| COMMA          | `,`           | Separator for sequences                                             |

---

## Grammar Definition (CFG)

1. **S** -> **H T end**  
2. **H** -> **E; H** | ε  
3. **E** -> **A=V**  
4. **A** -> **composer** | **instrument** | **bpm** | **title**  
5. **V** -> **NUMBER** | **STRING_LITERAL** | **IDENTIFIER**  
6. **T** -> **play (M);**  
7. **M** -> **melody M'** | **repeat (M) M'**  
8. **M'** -> ε | **, M**  
9. **melody** -> **MUSICNOTE DURATION**

---

## Installation and Execution

### Prerequisites

- **OCaml Compiler (ocamlc)**  
  Install via `apt-get` or `brew`.
  
- **opam** (recommended)  
  For managing OCaml packages.

### Execution Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/haleyyy2001/4115-hw3.git
   cd 4115-hw3
   ```

2. **Make Script Executable**:
   ```bash
   chmod +x install_and_run.sh
   ```

3. **Run the Compiler**:
   ```bash
   ./install_and_run.sh <input_file>
   ```
   For example:
   ```bash
   ./install_and_run.sh Program1.txt
   ```

4. **Output**:
   A `.mid` file is generated on success, which can be played by any MIDI-compatible player.

---

## Detailed Description of Each Step

### Lexer Algorithm

- Processes source code to produce tokens.
- Skips whitespace.
- Raises `LexingError` on invalid input.

### Parser Algorithm

- Uses recursive descent parsing.
- Follows the given CFG.
- Raises `ParseError` on syntax violations.

### AST Printer

- Prints the AST in a human-readable tree format for debugging.

### Code Generator Algorithm

- Translates the AST into MIDI instructions.
- Sets tempo, instrument, and sequences notes.
- Generates `.mid` file events.

### Error Handling

- **LexingError** for invalid lexemes.
- **ParseError** for syntax errors.
- Potential semantic errors in code generation if notes/durations are invalid.

---

## Code Optimization

The project introduces a code optimization stage that operates on an intermediate representation (IR) of the music before generating the final MIDI. This IR includes lists of notes and global attributes (instrument, tempo, etc.).

### Implemented Optimization Techniques

We implemented four optimization methods:

1. **Dead Store Elimination (Header Attributes)**:
   Removes redundant assignments to attributes like `bpm`, `instrument`, `title`, and `composer`. Only the final assignment of each attribute is retained.

2. **Redundant Instrument Changes Removal**:
   A specialized form of dead store elimination focusing on `instrument`. If `instrument` is set multiple times, only the last setting is considered.

3. **Peephole Optimization (Merging Consecutive Identical Notes)**:
   Consecutive identical notes with the same duration are merged into a single note with a longer duration, reducing repetitive instructions.

4. **Loop Unrolling (Repeat Sequences)**:
   Expands `repeat(...)` constructs in the music sequences directly, removing loops and leaving fully unrolled sequences of notes.

After optimization, the compiler prints the final IR (instrument, tempo, and notes) so you can see the optimized code before the MIDI file is generated.

### Sample Input Programs for Optimization

We provide separate test inputs, each highlighting one optimization:

1. **Dead Store Elimination**: `test_dead_store.txt`
   ```plaintext
   composer="Mozart";
   title="Symphony";
   bpm=120;
   instrument=Piano;

   composer="Beethoven";
   bpm=150;
   instrument=Guitar;
   title="Concerto";

   composer="Bach";
   bpm=90;
   instrument=Piano;
   title="Fugue";

   play (Do4# quarter);
   end
   ```
   **Expected Result**:  
   Final attributes after optimization: composer="Bach", title="Fugue", bpm=90, instrument="piano".

2. **Redundant Instrument Changes**: `test_instrument_changes.txt`
   ```plaintext
   instrument=Piano;
   instrument=Guitar;
   instrument=Piano;
   instrument=Guitar;
   bpm=120;
   composer="Vivaldi";
   title="Concert";

   play (Do4# quarter);
   end
   ```
   **Expected Result**:  
   Final instrument is "guitar". No unnecessary intermediate instrument changes remain.

3. **Peephole Optimization (Merging Notes)**: `test_peephole.txt`
   ```plaintext
   instrument=Piano;
   bpm=120;
   composer="Chopin";
   title="Nocturne";

   play (
     Do4# quarter,
     Do4# quarter,
     Do4# quarter,
     So4- eighth,
     So4- eighth,
     So4- eighth
   );
   end
   ```
   **Expected Result**:  
   Consecutive identical notes are merged into fewer, longer notes. For instance, three consecutive `Do4# quarter` notes may become a single note with triple the duration.

4. **Loop Unrolling (Repeat Sequences)**: `test_loop_unrolling.txt`
   ```plaintext
   instrument=Piano;
   bpm=100;
   composer="Haydn";
   title="Theme";

   play (
     repeat(Do4# quarter, So4- half),
     repeat(La4_ quarter),
     Do4# quarter
   );
   end
   ```
   **Expected Result**:  
   The `repeat` constructs are fully expanded inline. For example, `repeat(Do4# quarter, So4- half)` if repeated twice becomes `Do4# quarter, So4- half, Do4# quarter, So4- half`. No loops remain in the IR after optimization.

**Note**: When you run these tests, the compiler prints the optimized IR. You can see the final attributes and notes, confirming that optimization techniques have taken effect.

---

## Additional Notes on Code Structure

- `tokens.ml`, `lexer.ml`, `parser.ml` handle the front-end tasks.
- `ir.ml` defines the IR used by `optimizer.ml` and `code_generator.ml`.
- `optimizer.ml` implements the optimization techniques.
- `code_generator.ml` generates MIDI files and prints the optimized IR.
- `main.ml` orchestrates the overall flow.

The build and run steps are automated by `install_and_run.sh`. The project can be easily extended or modified to support more complex optimizations or different output formats.

---

## Video

A demonstration video showing installation, execution, and code optimization results is available at:  
[https://youtu.be/gQDpoBTRWrY](https://youtu.be/gQDpoBTRWrY)

 
