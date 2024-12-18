  
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
     - [t1.txt (Peephole Optimization)](#t1txt-peephole-optimization)  
     - [t2.txt (Dead Store Elimination)](#t2txt-dead-store-elimination)  
     - [t3.txt (Loop Unrolling)](#t3txt-loop-unrolling)  
     - [t4.txt (Another Peephole Optimization)](#t4txt-another-peephole-optimization)
8. [Additional Notes on Code Structure](#additional-notes-on-code-structure)  
9. [Video](#video)

---

## Introduction

This project implements a compiler front-end for a custom domain-specific programming language designed for musical composition. The language allows specifying musical attributes (BPM, instrument, composer, title) and defining sequences of notes, including repeated sections, to generate a MIDI file. The compilation pipeline includes:

1. **Lexical Analysis (Lexer)**: Converts the source code into tokens.  
2. **Parsing (Parser)**: Builds an Abstract Syntax Tree (AST) from tokens according to the grammar rules.  
3. **Code Generation**: Translates the AST into a MIDI file playable by standard MIDI players.  
4. **Code Optimization (New)**: Optimizes the intermediate representation (IR) before generating the final MIDI, improving efficiency without changing the musical result.

---

## Language Structure

- **Header Declarations**: Specify global settings such as instrument, bpm, composer, and title.
- **Play Commands**: Introduce sequences of notes, potentially including `repeat(...)` constructs to define repeated sections.
- **Music Notes**: Specified as `<Solfege><Octave><Accidental>` (e.g., `Do4#`, `Re4-`, `Mi4_`).
- **Durations**: `whole`, `half`, `quarter`, `eighth`, `sixteenth`.
- **End Command**: The `end` keyword marks the conclusion of the program.

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

| Token Type     | Example       | Description                                                         |
|----------------|---------------|---------------------------------------------------------------------|
| KEYWORD        | `play`        | Reserved words (`play`, `repeat`, `end`, etc.)                      |
| IDENTIFIER     | `Piano`       | User-defined or recognized words                                    |
| OPERATOR       | `=`           | Assignment operator                                                  |
| NUMBER         | `120`         | Numeric literals                                                    |
| STRING_LITERAL | `"Bach"`      | Text enclosed in double quotes                                       |
| MUSICNOTE      | `Do5#`        | Musical note notation (Solfege+Octave+Accidental)                   |
| DURATION       | `quarter`     | Note durations: `whole`, `half`, `quarter`, `eighth`, `sixteenth`   |
| LPAREN         | `(`           | Left parenthesis                                                    |
| RPAREN         | `)`           | Right parenthesis                                                   |
| SEMICOLON      | `;`           | Statement terminator                                                |
| COMMA          | `,`           | Separator for lists                                                  |

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
   On success, a `.mid` file is generated, which can be played by any MIDI-compatible player.

You can also run `./run_all.sh` to execute `t1.txt`, `t2.txt`, `t3.txt`, and `t4.txt` in sequence, demonstrating all optimizations at once.

---

## Detailed Description of Each Step

### Lexer Algorithm

- Processes the source file character by character.
- Converts recognized patterns into tokens.
- Raises a `LexingError` if an invalid character is encountered.

### Parser Algorithm

- Uses recursive descent parsing according to the given CFG.
- Raises `ParseError` on syntax violations.

### AST Printer

- Outputs a readable tree representation of the AST for debugging and verification.

### Code Generator Algorithm

- Translates the AST into MIDI instructions.
- Sets the tempo, instrument, and note durations.
- Produces a `.mid` file as the final output.

### Error Handling

- **LexingError** for invalid or unexpected characters.
- **ParseError** for grammar mismatches.
- The code generator may also detect and report invalid notes or durations at runtime.

---

## Code Optimization

We add a code optimization stage that processes the IR of notes and headers before MIDI generation. These optimizations improve efficiency (reducing redundant operations, removing unnecessary assignments) without altering the resulting music.

### Implemented Optimization Techniques

1. **Peephole Optimization (Merging Identical Notes)**:  
   Consecutive identical notes are merged into one longer note. This reduces redundancy and the number of MIDI events.

2. **Dead Store Elimination (Headers)**:  
   Multiple assignments to `instrument` or `bpm` in the headers appear during parsing. Dead store elimination ensures only the last assignment is retained, removing intermediate assignments that never affect the final output.

3. **Loop Unrolling (Expanding `repeat(...)` Constructs)**:  
   Detects `repeat(...)` sequences and duplicates the notes inline, removing loops. Instead of processing loops at runtime, we produce a fully expanded sequence of notes.

4. **Another Peephole Optimization (Second Pass)**:  
   After loop unrolling (or other changes) may introduce new identical consecutive notes. A second peephole pass ensures multiple identical notes fully merge into the minimal number of notes, achieving maximum efficiency.

These optimizations are applied in sequence to produce a more efficient and cleaner IR. The compiler then prints the final IR (instrument, tempo, and notes) so you can see the optimized code before the MIDI file is generated.

### Sample Input Programs for Optimization

We provide four test inputs (`t1.txt`, `t2.txt`, `t3.txt`, `t4.txt`), each illustrating one of the chosen optimizations. After running these tests, the compiler prints the optimized IR, letting you verify the effects of each optimization.

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
**What it Shows:**  
Two identical notes (`Do4# quarter, Do4# quarter`) appear in sequence.

**After Optimization:**  
They merge into a single `Do4#` note with double the length. For example:
```plaintext
Instrument: piano
Tempo (BPM): 120
Notes:
  Pitch: 61, Length: 960
```
This confirms that peephole optimization merged identical notes into one.

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
**What it Shows:**  
Multiple assignments to `instrument` and `bpm`. Without optimization, intermediate assignments would remain.

**After Optimization:**  
Only the last `instrument` (Guitar) and `bpm` (90) remain:
```plaintext
Instrument: guitar
Tempo (BPM): 90
Notes:
  Pitch: 62, Length: 480
```
This confirms dead store elimination on headers is working as intended.

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
**What it Shows:**  
A `repeat(...)` construct that repeats `(Do4# quarter, So4- eighth)` twice is included.

**After Optimization (Loop Unrolling):**  
The repeated sequence is expanded inline. If `repeat(M)` duplicates M twice, `(Do4# quarter, So4- eighth)` becomes `(Do4# quarter, So4- eighth, Do4# quarter, So4- eighth)`:
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
This shows notes from `repeat(...)` are duplicated, no loops remain.

#### t4.txt (Another Peephole Optimization Pass)

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
**What it Shows:**  
Four identical `Do4# quarter` notes appear in a row.

**After Optimization (Second Peephole Pass):**  
All four merge into one single note of quadruple the length:
```plaintext
Instrument: piano
Tempo (BPM): 120
Notes:
  Pitch: 61, Length: 1920
```
This demonstrates that multiple passes of peephole optimization can achieve a fully merged sequence.

---

## Additional Notes on Code Structure

- `tokens.ml`, `lexer.ml`, `parser.ml` form the front-end (lexing and parsing).
- `ir.ml` defines the IR (list of notes, header assignments).
- `optimizer.ml` implements the four optimizations.
- `code_generator.ml` uses the optimized IR to produce the final MIDI.
- `main.ml` orchestrates the entire process.

No modifications to the code generator are necessary. All optimizations rely on the existing language constructs and IR representation.

---

## Video

A demonstration video is available at:  
[https://youtu.be/gQDpoBTRWrY](https://youtu.be/gQDpoBTRWrY)

This video shows installation, execution, and verification of the optimizations and their results as described above.

 
