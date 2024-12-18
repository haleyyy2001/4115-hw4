
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

This project implements a compiler front-end for a custom domain-specific programming language designed for musical composition. The language allows specifying musical attributes (BPM, instrument, composer, title) and defining sequences of notes, including repeated sections, to generate a MIDI file. The compilation pipeline includes:

1. **Lexical Analysis (Lexer)**: Converts source code into tokens.  
2. **Parsing (Parser)**: Builds an AST from tokens according to the grammar rules.  
3. **Code Generation**: Translates the AST into a MIDI file.  
4. **Code Optimization (New)**: Optimizes the intermediate representation (IR) before generating the final MIDI.

By adding a code optimization stage, we improve efficiency without changing the musical result, achieving reduced execution time, minimized resource utilization, and improved overall performance.

---

## Language Structure

- **Header Declarations**: Set global attributes (instrument, bpm, composer, title).
- **Play Commands**: Introduce sequences of notes, possibly using `repeat(...)` to define loops.
- **Music Notes**: Defined as `<Solfege><Octave><Accidental>` (e.g., `Do4#`, `Re4-`).
- **Durations**: `whole`, `half`, `quarter`, `eighth`, `sixteenth`.
- **End Command**: `end` marks the end of the program.

Example:

```plaintext
instrument = Piano;
bpm = 120;

play (
  Do4# quarter,
  repeat(Mi4_ quarter, Fa4_ quarter),
  So4- half
);
end
```

---

## Lexical Grammar

### Token Types and Definitions

| Token Type     | Example       | Description                                                            |
|----------------|---------------|------------------------------------------------------------------------|
| KEYWORD        | `play`        | Reserved words (play, repeat, end, etc.)                               |
| IDENTIFIER     | `Piano`       | User-defined or recognized names                                        |
| OPERATOR       | `=`           | Assignment operator                                                     |
| NUMBER         | `120`         | Numeric literals                                                        |
| STRING_LITERAL | `"Bach"`      | Text in double quotes                                                   |
| MUSICNOTE      | `Do5#`        | Musical note (solfege, octave, accidental)                              |
| DURATION       | `quarter`     | Note duration keywords (`whole`, `half`, `quarter`, `eighth`, etc.)     |
| LPAREN         | `(`           | Left parenthesis                                                        |
| RPAREN         | `)`           | Right parenthesis                                                       |
| SEMICOLON      | `;`           | Statement terminator                                                    |
| COMMA          | `,`           | List separator                                                          |

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

- **OCaml Compiler (ocamlc)**: Install via `apt-get` or `brew`.  
- **opam** (recommended) to manage OCaml packages.

### Execution Steps

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/haleyyy2001/4115-hw3.git
   cd 4115-hw3
   ```

2. **Make the Script Executable**:
   ```bash
   chmod +x install_and_run.sh
   ```

3. **Run the Compiler**:
   ```bash
   ./install_and_run.sh <input_file>
   ```
   For example:
   ```bash
   ./install_and_run.sh t1.txt
   ```

4. **Outputs**:
   On success, a `.mid` file is generated, playable by standard MIDI players.

You can also run `./run_all.sh` to test `t1.txt`, `t2.txt`, `t3.txt`, and `t4.txt` in sequence, demonstrating all optimizations at once.

---

## Detailed Description of Each Step

### Lexer Algorithm

- Converts input into tokens.
- Raises `LexingError` on invalid characters.

### Parser Algorithm

- Recursive descent parsing based on the CFG.
- Raises `ParseError` on syntax errors.

### AST Printer

- Prints a readable AST tree for debugging.

### Code Generator Algorithm

- Translates AST to MIDI events.
- Sets tempo, instrument, and note sequences.
- Outputs `.mid` file.

### Error Handling

- **LexingError** for invalid input.
- **ParseError** for grammar violations.
- Potential checks in code generation for invalid notes/durations.

---

## Code Optimization

We introduce a code optimization stage on the IR of notes and headers before MIDI generation. Optimizations improve efficiency without changing the musical output.

### Implemented Optimization Techniques

1. **Peephole Optimization (Merging Identical Notes)**  
   Consecutive identical notes are merged into a single longer note. This reduces redundancy and the number of note events.

2. **Dead Store Elimination (Headers)**  
   Multiple assignments to `instrument` or `bpm` appear in the headers. Only the last assignment is effective, removing unnecessary intermediate assignments.

3. **Loop Unrolling (Expanding `repeat(...)` Constructs)**  
   `repeat(...)` sequences are expanded inline. Instead of loops, the notes are duplicated, showing a fully unrolled sequence with no loops.

4. **Another Peephole Optimization (Second Pass)**  
   After loop unrolling or other transformations, a second peephole pass ensures that if multiple identical notes are formed, they are merged again, achieving a fully optimized note sequence.

These four optimizations are applied in sequence, producing a more efficient IR. The resulting IR is printed before MIDI generation.

### Sample Input Programs for Optimization

We provide four test inputs (`t1.txt`, `t2.txt`, `t3.txt`, `t4.txt`), each demonstrating one or more of the implemented optimizations:

- **t1.txt (Peephole Optimization)**:
  Input: Two identical notes (`Do4# quarter, Do4# quarter`)  
  After Optimization: Merged into a single `Do4#` note with doubled length.  
  **Demonstrated Optimization:** Peephole merging of identical notes.

- **t2.txt (Dead Store Elimination)**:
  Input: Multiple instrument and BPM assignments.  
  After Optimization: Only the last `instrument` and `bpm` settings remain effective.  
  **Demonstrated Optimization:** Dead store elimination on headers.

- **t3.txt (Loop Unrolling)**:
  Input: Uses `repeat(...)`. After optimization, repeated sequences are expanded inline.  
  Example: `repeat(Do4# quarter, So4- eighth)` becomes `Do4# quarter, So4- eighth, Do4# quarter, So4- eighth` if repeated twice.  
  **Demonstrated Optimization:** Loop unrolling.

- **t4.txt (Another Peephole Optimization)**:
  Input: Multiple identical notes (e.g., four identical `Do4# quarter` notes).  
  After Optimization: Fully merged into a single note with quadruple the duration.  
  **Demonstrated Optimization:** Another peephole pass to ensure full merging after previous optimizations.

After running `./create_test_inputs.sh` and `./run_all.sh`, you will see the final IR printed. For each test:

- **t1.txt**: Two identical notes → One merged note.  
- **t2.txt**: Multiple header assignments → Only last assignments retained.  
- **t3.txt**: `repeat(...)` sequences expanded → Notes duplicated inline, no loops remain.  
- **t4.txt**: Multiple identical notes fully merge → One long note.

These outputs confirm that all four optimization methods work as intended.

---

## Additional Notes on Code Structure

- `tokens.ml`, `lexer.ml`, `parser.ml` handle the front-end.  
- `ir.ml` defines the IR (list of notes and header assignments).  
- `optimizer.ml` applies the four chosen optimizations.  
- `code_generator.ml` produces the final MIDI after optimization.  
- `main.ml` coordinates the entire pipeline.

No code generator modifications were needed to demonstrate these optimizations. All changes are confined to the optimizer and the test inputs.

---

## Video

A demonstration video shows the installation steps, running the compiler, and verifying that the optimizations produce the expected results:  
[https://youtu.be/gQDpoBTRWrY](https://youtu.be/gQDpoBTRWrY)

 
