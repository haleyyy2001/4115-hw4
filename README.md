
---

## **Team Members**

- **Name**: Huilin Tai, Huixuan Huang
- **UNI**: ht2666, hh3101

---

## **Table of Contents**

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
7. [Sample Input Programs and Expected Outputs](#sample-input-programs-and-expected-outputs)  
8. [Additional Notes on Code Structure](#additional-notes-on-code-structure)  
9. [Video](#video)

---

## **Introduction**

This project implements a compiler front-end for a custom domain-specific programming language designed for musical notation and playback commands. The language allows users to specify musical attributes (e.g., BPM, instrument), composer details, and note sequences (including repeats) to ultimately generate music. The compilation pipeline includes:

1. **Lexical Analysis (Lexer)**: Converts the source code into a sequence of tokens.
2. **Parsing (Parser)**: Uses a recursive descent parser to build an Abstract Syntax Tree (AST) from the token stream, enforcing the grammar rules.
3. **Code Generation**: Translates the AST into a lower-level target—here, a MIDI file—enabling playback through standard MIDI players.

The final output demonstrates syntactic analysis, error-handling, and code generation capabilities. Although currently focused on generating MIDI files, this architecture could be extended for other backends or more sophisticated musical transformations.

---

## **Language Structure**

Our custom language is designed to facilitate music composition. It includes:

- **Header Declarations**: Provide global settings such as instrument type, BPM, title, and composer.
- **Play Commands**: Define sequences of notes (including repeated sections) that form the musical piece.
- **Musical Notes**: Specified in a solfege-like notation combined with octave numbers and accidentals.
- **Ending Command**: Marks the conclusion of the input program with the `end` keyword.

### **Key Constructs**:

1. **Instrument Declaration**:  
   ```plaintext
   instrument = Piano;
   ```
   This sets the instrument used for playback. Supported values currently include "Piano" or "Guitar", defaulting to Piano if not recognized.

2. **BPM Declaration**:  
   ```plaintext
   bpm = 120;
   ```
   Sets the tempo of the piece.

3. **Composer and Title Declaration**:  
   ```plaintext
   title = "Some Title";
   composer = "Some Composer";
   ```
   Provides descriptive metadata for the composition.

4. **Play Command**:  
   ```plaintext
   play (Do4# quarter, Re4- half, repeat(Mi4- whole, Fa4# half));
   ```
   Defines a sequence of notes or repeated sequences.

5. **Music Notes**:  
   Represented as `<Solfege><Octave><Accidental>`:
   - **Solfege**: `Do`, `Re`, `Mi`, `Fa`, `So`, `La`, `Ti`
   - **Octave**: An integer from 0 to 7 (used as a relative position in pitch space).
   - **Accidental**: `#` (sharp), `-` (natural), `_` (flat)

   Example: `Do4#` means the note "Do" in the 4th octave, sharpened by one semitone.

6. **End Command**:  
   ```plaintext
   end
   ```
   Signifies the end of the program.

---

## **Lexical Grammar**

### **Token Types and Definitions**

| Token Type     | Example       | Description                               |
|----------------|---------------|-------------------------------------------|
| KEYWORD        | `play`        | Reserved words (`play`, `repeat`, `end`, `instrument`, `bpm`, `title`, `composer`) |
| IDENTIFIER     | `Piano`       | User-defined names or unrecognized words |
| OPERATOR       | `=`           | Assignment operator for setting attributes |
| NUMBER         | `120`         | Numeric literals (used for BPM) |
| STRING_LITERAL | `"Beethoven"` | Text enclosed in double quotes            |
| MUSICNOTE      | `Do5#`        | Music note notation (Solfege + Octave + Accidental) |
| DURATION       | `quarter`     | Note durations: `whole`, `half`, `quarter`, `eighth`, `sixteenth` |
| LPAREN         | `(`           | Left parenthesis                          |
| RPAREN         | `)`           | Right parenthesis                         |
| SEMICOLON      | `;`           | Statement terminator                      |
| COMMA          | `,`           | Separator for sequences                   |

---

## **Grammar Definition (CFG)**

### **Production Rules**

1. **S** -> **H T end**  
   A complete program includes a header section (H), a track section (T), and concludes with `end`.

2. **H** -> **E; H** | ε  
   The header may be empty or consist of multiple expressions separated by semicolons.

3. **E** -> **A=V**  
   Each expression is an assignment of a value V to an attribute A.

4. **A** -> **composer** | **instrument** | **bpm** | **title**  
   Attributes that can be set in the header.

5. **V** -> **NUMBER** | **STRING_LITERAL** | **IDENTIFIER**  
   Values assigned to attributes: a number (for bpm), a string (for title/composer), or an identifier (for instrument).

6. **T** -> **play (M);**  
   The track section is introduced by `play`, followed by a parenthesized music sequence M, and ends with a semicolon.

7. **M** -> **melody M'** | **repeat (M) M'**  
   A music sequence can be a single melody or a `repeat` construct containing another sequence.

8. **M'** -> ε | **, M**  
   Musical sequences can be comma-separated lists.

9. **melody** -> **MUSICNOTE DURATION**  
   A melody element consists of a single MUSICNOTE and a DURATION.

---

## **Installation and Execution**

### **Prerequisites**

- **OCaml Compiler (ocamlc)**:  
  Required to build the project.  
  **Ubuntu/Debian**:
  ```bash
  sudo apt-get install ocaml
  ```
  **macOS (Homebrew)**:
  ```bash
  brew install ocaml
  ```

- **opam** (recommended) to manage OCaml packages:
  ```bash
  brew install opam
  ```
  or
  ```bash
  sudo apt-get install opam
  ```

### **Execution Steps**

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
   Use the provided shell script `install_and_run.sh` to handle installation checks and compile & run steps. Supply the input file to generate tokens, parse, and produce a `.mid` file:

   ```bash
   ./install_and_run.sh Program1.txt
   ```
   
   On success, it generates `program1.mid` as output.  

4. **Alternative Manual Compilation**:
   If desired, you can manually compile and run:
   ```bash
   ocamlc -o compiler.exe tokens.ml lexer.ml parser.ml ast_printer.ml code_generator.ml main.ml
   ./compiler.exe Program1.txt
   ```

   This approach gives you fine-grained control if you need to debug compilation steps.

---

## **Detailed Description of Each Step**

### **Lexer Algorithm**

- The lexer (in `lexer.ml`) processes the input file character by character.
- It identifies tokens according to the rules defined in `tokens.ml`.
- Whitespaces, comments (if any), and irrelevant characters are skipped.
- On encountering errors, such as an invalid character or an improperly closed string literal, the lexer raises a `LexingError` with a descriptive message.

### **Parser Algorithm**

- The parser (in `parser.ml`) uses a **Recursive Descent Parsing** strategy.
- Given that the grammar is LL(1)-friendly and has no left recursion, the parser can process tokens top-down, choosing the correct production rules based on lookahead tokens.
- If a token does not match the expected production rule, a `ParseError` is raised, indicating the location and nature of the syntax issue.

### **AST Printer**

- Implemented in `ast_printer.ml`, the AST printer outputs a readable representation of the parsed structure.
- Each non-terminal is marked with a `$` sign.
- The hierarchy of nodes is visualized with ASCII lines (`├──` and `└──`), and tokens are printed with their type (e.g., `KEYWORD(...)`, `NUMBER(...)`).
- This helps in debugging and verifying that the parsed structure matches the expected grammar.

### **Code Generator Algorithm**

- Implemented in `code_generator.ml`, the code generator takes the AST as input.
- Steps:
  1. **Header Processing**: Retrieves `title`, `composer`, `instrument`, and `bpm` from the AST. Missing attributes default to sensible values (e.g., tempo=120 BPM, instrument=Piano).
  2. **Track Processing**: Reads `play` constructs, identifies `melody` and `repeat` sequences, and translates each note-duration pair into MIDI events.
  3. **MIDI Generation**: Notes are converted to MIDI pitches. Durations are mapped to ticks, and the correct tempo and instrument program changes are inserted.
- The resulting `.mid` file can be played in standard MIDI players.
- If notes or durations are invalid, errors can be printed, aiding in debugging the input program.

### **Error Handling**

- **LexingError**: Triggered by illegal characters or unterminated strings.
- **ParseError**: Triggered by syntax violations, such as missing semicolons, unmatched parentheses, or unexpected tokens.
- **Semantic/Code Generation Errors**: If encountered invalid notes or durations, the code generator can report them. Although the code generator is currently straightforward, it sets the stage for future semantic checks.

---

## **Sample Input Programs and Expected Outputs**

The provided sample programs (`Program1.txt` to `Program6.txt`) test various features and error conditions. To run them, use:

```bash
./install_and_run.sh ProgramX.txt
```

### **Program 1: Basic Music Program**

**Content (`Program1.txt`)**:
```plaintext
title="mymusic";
composer="someone";
instrument=Piano;
bpm=120;
play (Do4# quarter, Re4- half, repeat(Mi4- whole, Fa4# half));
end
```

**Expected Behavior**:
- Lex and parse successfully.
- Print AST representing assignments in header and `play` block.
- Generate `program1.mid` file containing the specified notes and repeats.

### **Program 2: Empty Header Chunk**

**Content (`Program2.txt`)**:
```plaintext
play (Mi5_ whole, Fa5_ half, Mi5_eighth, Re5_ sixteenth, Do5_ whole, Re5_ half, Mi5_quarter);
end
```

**Expected Behavior**:
- No header assignments, just a direct `play` command.
- Produce `program2.mid` with the given notes.

### **Program 3: Nested repeat sequences**

**Content (`Program3.txt`)**:
```plaintext
play (Do4# quarter,
repeat(Do4# quarter),
Do3- half,
repeat(Do4# quarter,repeat(Do4# quarter,repeat(Do4# quarter)))
);
end
```

**Expected Behavior**:
- Complex nested `repeat` constructs.
- Generates `program3.mid` reflecting repeated melodic patterns.

### **Program 4: Missing semicolon**

**Content (`Program4.txt`)**:
```plaintext
title="Composition";
play (
    Do4# quarter
)
end
```

**Expected Behavior**:
- Parsing error due to missing `;` after the `play` block.
- Prints:
  ```
  Parsing error: Syntax error: Expected ';' after track
  ```
- No MIDI file generated.

### **Program 5: Missing music sequence after comma**

**Content (`Program5.txt`)**:
```plaintext
title ="Symphony No. 5";
composer ="Beethoven";
play (Do4_ half,);
end
```

**Expected Behavior**:
- Syntax error due to trailing comma with no subsequent music sequence.
- Prints:
  ```
  Parsing error: Syntax error: Expected a music note or function like 'repeat'
  ```
- No MIDI file generated.

### **Program 6: Missing end token**

**Content (`Program6.txt`)**:
```plaintext
title ="Symphony No. 5";
composer ="Beethoven";
play (Do4_ half);
```

**Expected Behavior**:
- Parsing error due to missing `end`.
- Prints:
  ```
  Parsing error: Unexpected end of input
  ```
- No MIDI file generated.

---

## **Additional Notes on Code Structure**

- **tokens.ml**: Defines token types and their variants.
- **lexer.ml**: Converts raw input into tokens, raising errors on malformed input.
- **parser.ml**: Implements recursive descent parsing, consuming tokens and building the AST.
- **ast_printer.ml**: Provides functions to print the AST in a human-readable tree format.
- **code_generator.ml**: Translates the AST into a `.mid` file, handling tempo, instrument changes, and note events.
- **main.ml**: Entry point that orchestrates the pipeline: reading input, lexing, parsing, printing the AST (optional), and invoking the code generator.
- **install_and_run.sh**: Shell script to automate installation checks, compilation, and running the compiler on a given input file.

The entire pipeline ensures that a valid program transforms from high-level musical instructions into a playable MIDI file.

---

## **Video**

A demonstration video showing the entire process, from installation to execution and verification of outputs, is available at:  
[https://www.youtube.com/watch?v=yMmpJsR8iAI](https://www.youtube.com/watch?v=yMmpJsR8iAI)

 
