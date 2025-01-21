# Music DSL Compiler with Code Optimizations

This repository contains a compiler front-end for a custom domain-specific programming language (DSL) designed for musical composition. It provides functionality to parse, analyze, and transform code describing musical structures and outputs a playable MIDI file. The project also includes several code optimizations that improve the generated output without altering the musical result.

---

## Team Members

- **Name**: Huilin Tai  
- **Name**: Huixuan Huang  

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

This project implements a compiler for a custom domain-specific programming language aimed at musical composition. The language allows users to define musical attributes—such as BPM, instrument, composer, and title—and to write sequences of notes (potentially with loops) for generating MIDI files. The compilation process includes:

1. **Lexical Analysis**: Conversion of source code into a token stream.  
2. **Parsing**: A recursive descent parser constructs an Abstract Syntax Tree (AST) from the tokens.  
3. **Code Generation**: The AST is translated into MIDI instructions, ultimately producing a `.mid` file.  
4. **Code Optimization**: An optional optimization pass refines the intermediate representation to enhance performance without changing the audible result.

---

## Language Structure

### Header Declarations
- **Global Settings**: Specify the `instrument`, `bpm`, `composer`, and `title`.

### Play Commands
- **`play(...)` Block**: Contains sequences of notes.  
- **`repeat(...)`**: Defines a repeated section of notes.

### Music Notes
- **Syntax**: `<Solfege><Octave><Accidental>` (e.g., `Do4#`, `Re4-`).  

### Durations
- Supported durations include `whole`, `half`, `quarter`, `eighth`, `sixteenth`.

### End Command
- **`end`**: Marks the end of the program.

#### Example
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

| Token Type     | Example       | Description                                                   |
|----------------|---------------|---------------------------------------------------------------|
| KEYWORD        | `play`        | Language-reserved words (e.g., `play`, `repeat`, `end`)      |
| IDENTIFIER     | `Piano`       | User-defined or recognized language identifiers              |
| OPERATOR       | `=`           | Assignment operator                                          |
| NUMBER         | `120`         | Numeric literals (e.g., BPM values)                          |
| STRING_LITERAL | `"Beethoven"` | Text enclosed in double quotes                                |
| MUSICNOTE      | `Do5#`        | A musical note (Solfege + Octave + Accidental)               |
| DURATION       | `quarter`     | Supported durations: `whole`, `half`, `quarter`, `eighth`, `sixteenth` |
| LPAREN         | `(`           | Left parenthesis                                             |
| RPAREN         | `)`           | Right parenthesis                                            |
| SEMICOLON      | `;`           | Statement terminator                                         |
| COMMA          | `,`           | Delimiter for sequences                                      |

---

## Grammar Definition (CFG)

```
1. S  -> H T end
2. H  -> E; H | ε
3. E  -> A=V
4. A  -> composer | instrument | bpm | title
5. V  -> NUMBER | STRING_LITERAL | IDENTIFIER
6. T  -> play (M);
7. M  -> melody M' | repeat (M) M'
8. M' -> ε | , M
9. melody -> MUSICNOTE DURATION
```

---

## Installation and Execution

### Prerequisites

- **OCaml Compiler (ocamlc)**
- **opam** (recommended) for managing OCaml packages

Install OCaml through your system’s package manager (e.g., `apt-get`, `brew`) or via the official OCaml distribution.

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
   # Example:
   ./install_and_run.sh t1.txt
   ```
4. **Generate Outputs**:
   - A `.mid` file is produced upon successful compilation.
   - You can also run:
     ```bash
     ./run_all.sh
     ```
     to test all four sample inputs (t1–t4) at once.

---

## Detailed Description of Each Step

### Lexer Algorithm

- Reads the input text character by character.  
- Matches patterns to produce tokens (e.g., keywords, notes, numbers).  
- Raises a `LexingError` when encountering invalid or unknown characters.

### Parser Algorithm

- Implements a recursive descent parser based on the provided CFG.  
- Constructs an AST for valid inputs.  
- Raises a `ParseError` if the syntax is invalid.

### AST Printer

- Outputs a textual representation of the AST.  
- Useful for debugging intermediate representations.

### Code Generator Algorithm

- Translates the AST into MIDI instructions.  
- Applies global headers (tempo, instrument).  
- Produces a `.mid` file containing the resulting music.

### Error Handling

- **LexingError**: For illegal character sequences or unexpected tokens.  
- **ParseError**: For grammar or syntax mismatches.  
- **Semantic Checks**: May occur during code generation (e.g., invalid notes, durations).

---

## Code Optimization

An optimization pass is included to refine the intermediate representation before final code generation. The goal is to minimize redundant instructions without changing the musical output.

### Implemented Optimization Techniques

1. **Peephole Optimization**  
   - Identifies consecutive identical notes and merges them into one with a longer duration.

2. **Dead Store Elimination**  
   - Removes redundant header assignments (e.g., multiple assignments to `instrument`, only the last one is relevant).

3. **Loop Unrolling**  
   - Expands `repeat(...)` constructs into explicit note sequences, removing loop constructs.

4. **Additional Peephole Optimization**  
   - A second pass that further merges any newly consecutive identical notes after other optimizations.

These optimizations are applied sequentially and can be observed in the sample programs below.

### Sample Input Programs and Expected Outputs

Below are four demonstration inputs, each illustrating a specific optimization.

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
**Transformation:** Two identical notes (`Do4# quarter`) are merged into a single note with doubled duration.

**Optimized Representation:**
```
Instrument: piano
Tempo (BPM): 120
Notes:
  Pitch: 61, Length: 960
```

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
**Transformation:** Only the final assignments to `instrument` and `bpm` are retained.

**Optimized Representation:**
```
Instrument: guitar
Tempo (BPM): 90
Notes:
  Pitch: 62, Length: 480
```

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
**Transformation:** The `repeat(...)` pattern is unrolled, duplicating the note sequence inline.

**Optimized Representation:**
```
Instrument: piano
Tempo (BPM): 120
Notes:
  Pitch: 61, Length: 480
  Pitch: 67, Length: 240
  Pitch: 61, Length: 480
  Pitch: 67, Length: 240
  Pitch: 62, Length: 480
```

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
**Transformation:** Four consecutive identical notes (`Do4# quarter`) are merged into a single note with quadruple the original duration.

**Optimized Representation:**
```
Instrument: piano
Tempo (BPM): 120
Notes:
  Pitch: 61, Length: 1920
```

---

## Additional Notes on Code Structure

- **`tokens.ml`, `lexer.ml`, `parser.ml`**: Handle tokenization and parsing.  
- **`ir.ml`**: Defines the intermediate representation for notes and header data.  
- **`optimizer.ml`**: Implements all four optimizations.  
- **`code_generator.ml`**: Generates MIDI code based on the (optimized) AST.  
- **`main.ml`**: Orchestrates the entire compilation process.

The optimizations leverage the existing IR and do not require changes to the core code generator.

---

## Video

For a complete walkthrough demonstrating how to install, run, and verify the outputs, watch the video here:  
[https://youtu.be/dCAIf7JYgzM](https://youtu.be/dCAIf7JYgzM)

---

**Thank you for exploring our music DSL compiler project!** If you have any questions or suggestions, feel free to open an issue or submit a pull request.
