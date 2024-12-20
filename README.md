 
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
   - [Sample Input Programs and Expected Outputs](#sample-input-programs-and-expected-outputs)  
     - [t1.txt (Peephole Optimization)](#t1txt-peephole-optimization)  
     - [t2.txt (Dead Store Elimination)](#t2txt-dead-store-elimination)  
     - [t3.txt (Loop Unrolling)](#t3txt-loop-unrolling)  
     - [t4.txt (Another Peephole Optimization)](#t4txt-another-peephole-optimization)
8. [Additional Notes on Code Structure](#additional-notes-on-code-structure)  
9. [Video](#video)

---

## Introduction

This project implements a compiler front-end for a custom domain-specific programming language designed for musical composition. The language allows specifying musical attributes (BPM, instrument, composer, title) and defining sequences of notes, including repeated sections, to ultimately generate music (MIDI files). The compilation pipeline includes:

1. **Lexical Analysis (Lexer)**: Converts the source code into tokens.
2. **Parsing (Parser)**: Uses a recursive descent parser to build an Abstract Syntax Tree (AST) from the token stream.
3. **Code Generation**: Translates the AST into a MIDI file.
4. **Code Optimization**: (New) Optimizes an intermediate representation of the code before generating the MIDI, improving efficiency without altering the musical result.

---

## Language Structure

- **Header Declarations**: Provide global settings (instrument, bpm, composer, title).
- **Play Commands**: Define sequences of notes, including `repeat(...)` constructs for loops.
- **Music Notes**: Specified as `<Solfege><Octave><Accidental>` (e.g., `Do4#`, `Re4-`).
- **Durations**: `whole`, `half`, `quarter`, `eighth`, `sixteenth`.
- **End Command**: `end` keyword marks the end of the program.

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

| Token Type     | Example       | Description                                               |
|----------------|---------------|-----------------------------------------------------------|
| KEYWORD        | `play`        | Reserved words (`play`, `repeat`, `end`, etc.)           |
| IDENTIFIER     | `Piano`       | User-defined or recognized words                          |
| OPERATOR       | `=`           | Assignment operator                                       |
| NUMBER         | `120`         | Numeric literals (e.g., for BPM)                          |
| STRING_LITERAL | `"Beethoven"` | Text enclosed in double quotes                            |
| MUSICNOTE      | `Do5#`        | Musical note (Solfege+Octave+Accidental)                  |
| DURATION       | `quarter`     | Note durations: `whole`, `half`, `quarter`, `eighth`, etc.|
| LPAREN         | `(`           | Left parenthesis                                          |
| RPAREN         | `)`           | Right parenthesis                                         |
| SEMICOLON      | `;`           | Statement terminator                                      |
| COMMA          | `,`           | Separator for sequences                                   |

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
   On success, a `.mid` file is generated. You can also run:
   ```bash
   ./run_all.sh
   ```
   to test all t1-t4 optimizations at once.

---

## Detailed Description of Each Step

### Lexer Algorithm

- Processes source code character by character.
- Converts recognized patterns into tokens.
- Raises a `LexingError` on invalid input.

### Parser Algorithm

- Uses recursive descent parsing according to the CFG.
- Raises `ParseError` on syntax violations.

### AST Printer

- Prints a readable AST tree for debugging.

### Code Generator Algorithm

- Translates the AST into MIDI events.
- Sets tempo, instrument, note sequences.
- Produces `.mid` file output.

### Error Handling

- **LexingError** for invalid characters.
- **ParseError** for grammar mismatches.
- Potential semantic checks in code generation for invalid notes or durations.

---

## Code Optimization

We introduce a code optimization stage to improve efficiency without changing the musical outcome.

### Implemented Optimization Techniques

1. **Peephole Optimization (Merging Identical Notes)**:  
   Merges consecutive identical notes into a single note with a longer duration.

2. **Dead Store Elimination (Headers)**:  
   Multiple assignments to `instrument` or `bpm` are reduced so only the last assignment is used.

3. **Loop Unrolling (Expanding `repeat(...)`)**:  
   `repeat(...)` constructs are expanded inline, eliminating loops and leaving fully duplicated notes.

4. **Another Peephole Optimization (Second Pass)**:  
   After other transformations, a second peephole pass ensures multiple identical notes fully merge into the minimal number of notes.

These four optimizations are applied in sequence.

### Sample Input Programs and Expected Outputs

Below are the four test inputs (`t1.txt`, `t2.txt`, `t3.txt`, `t4.txt`), each demonstrating one optimization. We also show the final IR (instrument, tempo, and notes) printed after optimization.

#### t1.txt (Peephole Optimization)

**Initial Input:**
```plaintext
title="Peephole Test";
instrument=Piano;
bpm=120;

play (
  Do4# quarter,
  Do4# quarter
);

end
```

**What Happens:** Two identical `Do4# quarter` notes are merged into one longer note.

**After Optimization:**
```plaintext
Instrument: piano
Tempo (BPM): 120
Notes:
  Pitch: 61, Length: 960
```
A single merged note replaces the two identical ones.

#### t2.txt (Dead Store Elimination)

**Initial Input:**
```plaintext
title="Dead Store Test";
instrument=Piano;
instrument=Guitar;
bpm=120;
bpm=90;

play (
  Re4- quarter
);

end
```

**What Happens:** Multiple instrument and BPM assignments appear. Only the last assignments remain effective.

**After Optimization:**
```plaintext
Instrument: guitar
Tempo (BPM): 90
Notes:
  Pitch: 62, Length: 480
```
Intermediate assignments are removed, demonstrating dead store elimination.

#### t3.txt (Loop Unrolling)

**Initial Input:**
```plaintext
title="Loop Unrolling Test";
instrument=Piano;
bpm=120;

play (
  repeat(Do4# quarter, So4- eighth),
  Re4- quarter
);

end
```

**What Happens:** The `repeat(...)` construct is expanded. If `repeat(M)` duplicates M twice, `(Do4# quarter, So4- eighth)` appear twice in sequence.

**After Optimization:**
```plaintext
Instrument: piano
Tempo (BPM): 120
Notes:
  Pitch: 61, Length: 480
  Pitch: 67, Length: 240
  Pitch: 61, Length: 480
  Pitch: 67, Length: 240
  Pitch: 62, Length: 480
```
The notes from `repeat(...)` are duplicated, no loops remain.

#### t4.txt (Another Peephole Optimization)

**Initial Input:**
```plaintext
title="Additional Peephole Test";
instrument=Piano;
bpm=120;

play (
  Do4# quarter,
  Do4# quarter,
  Do4# quarter,
  Do4# quarter
);

end
```

**What Happens:** Four identical `Do4# quarter` notes appear. After two passes of peephole optimization, they fully merge into one note with four times the length.

**After Optimization:**
```plaintext
Instrument: piano
Tempo (BPM): 120
Notes:
  Pitch: 61, Length: 1920
```
All four identical notes merged into a single long note.

---

## Additional Notes on Code Structure

- `tokens.ml`, `lexer.ml`, `parser.ml` handle lexical and syntactic analysis.
- `ir.ml` defines the IR (list of notes and header assignments).
- `optimizer.ml` applies the chosen optimizations.
- `code_generator.ml` finalizes MIDI generation after optimization.
- `main.ml` orchestrates the entire pipeline.

No modifications to the code generator were needed. The optimizations rely on existing constructs, demonstrating all four techniques clearly.

---

## Video

A demonstration video showing the entire process, from installation to execution and verification of outputs, is available at:
[https://youtu.be/dCAIf7JYgzM](https://youtu.be/dCAIf7JYgzM)

 
