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
   - [AST printer](#ast-printer)
   - [Error Handling](#error-handling)
7. [Sample Input Programs and Expected Outputs](#sample-input-programs-and-expected-outputs)
8. [Video](https://www.youtube.com/watch?v=yMmpJsR8iAI)

---

## **Introduction**

This project involves creating a lexer and parser for a custom programming language designed for musical notation and playback commands. The lexer reads source code written in this language, producing a list of tokens, while the parser generates an Abstract Syntax Tree (AST) based on defined grammatical rules. The final output demonstrates syntactic analysis and error-handling capabilities, which could be extended to support MIDI file generation in future work.

---

## **Language Structure**

Our custom language is designed for composing music and issuing playback commands. It allows users to declare instruments, beats per minute (BPM), composers, and titles, as well as specify musical notes with associated durations.

### **Key Constructs**:

1. **Instrument Declaration**: Specifies the instrument (e.g., `Piano` or `Violin`).
   
   ```plaintext
   instrument = Piano;
   ```

2. **BPM Declaration**: Sets the tempo for playback.
   
   ```plaintext
   bpm = 120;
   ```

3. **Composer and Title Declaration**: Specifies the title and composer of the piece.
   
   ```plaintext
   title = "Some Title";
   composer = "Some Composer";
   ```

4. **Play Command**: Defines the notes to be played along with their durations.
   
   ```plaintext
   play (Do4# quarter);
   ```

5. **Music Notes**: Expressed in solfege notation (e.g., `Do`, `Re`), followed by an octave number (0-7), and an accidental (`#` stands for sharp, `-` stands for natural, `_` stands for flat).

6. **End Command**: Marks the end of the music declaration.
   
   ```plaintext
   end
   ```

---

## **Lexical Grammar**

### **Token Types and Definitions**

| Token Type     | Example       | Description                               |
|----------------|---------------|-------------------------------------------|
| KEYWORD        | `play`        | Reserved words                            |
| IDENTIFIER     | `Piano`       | User-defined names                        |
| OPERATOR       | `=`           | Assignment operator                       |
| NUMBER         | `120`         | Numeric literals                          |
| STRING_LITERAL | `"Beethoven"` | Text enclosed in double quotes            |
| MUSICNOTE      | `Do5#`        | Music note notation                       |
| DURATION       | `quarter`     | Note durations                            |
| LPAREN         | `(`           | Left parenthesis                          |
| RPAREN         | `)`           | Right parenthesis                         |
| SEMICOLON      | `;`           | Statement terminator                      |
| COMMA          | `,`           | Separator                                 |

---

## **Grammar Definition (CFG)**

### **Production Rules**

1. **S** -> **H T end**  
   A complete program consists of a header chunk, followed by a track section, and ending with the `end` keyword. `end` is a terminal

2. **H** -> **E; H** | ε  
   The header chunk can be empty or consists of list of expressions (e.g. assignment`A=V`) followed by a semicolon, which are recursively followed by zero or more expressions.

3. **E** -> **A=V**  
   Each expression can be an assignment, where a value is assigned to a specific attribute. This structure allows for future functionality expansions.

4. **A** -> **composer** | **instrument** | **bpm** | **title**  
   Attributes in the header can include `composer`, `instrument`, `bpm`, or `title`. The nonterminal `A` is a set of terminals.

5. **V** -> **NUMBER** | **STRING_LITERAL** | **IDENTIFIER**  
   The values assigned to attributes can be numbers, string literals, or identifiers (such as instrument names). The non-terminal `V` is a set of terminals.

6. **T** -> **play (M);**  
   The track section starts with the `play` keyword, followed by a parenthesized sequence of musical notes/statements, and end with a semicolon. 

7. **M** -> **melody M'** | **repeat (M) M'**  
   Music sequence can be individual melody or a `repeat` statement containing a nested sequence.

8. **M'** -> ε | **, M**  
   Musical sequences are comma-separated lists, which can be empty or continue with additional notes/statements.

9. **melody** -> **MUSICNOTE DURATION**  
    A melody consists of a music note to specify the pitch and duration of the note to specify the rhythm. Here `MUSICNOTE` is defined above in the key construct section. Each note is expressed in solfege notation (e.g., `Do`, `Re`), followed by an octave number (0-7), and an accidental (`#`, `-`, `_`). `DURATION` can be `whole`, `half`, `quater`, `eighth`,`sixteenth`.
---

## **Installation and Execution**

### **Prerequisites**

- **OCaml Compiler**: Ensure that the OCaml compiler (`ocamlc`) is installed on your system.
  
  - **Installation on Ubuntu/Debian**:
    ```bash
    sudo apt-get install ocaml
    ```

  - **Installation on macOS (using Homebrew)**:
    ```bash
    brew install ocaml
    ```

### **Execution Steps**

1. **Clone the Repository**: Download or clone the project files.

2. **Make the Script Executable**: Ensure the `install_and_run.sh` script has execute permissions.

   ```bash
   chmod +x install_and_run.sh
   ```

3. **Run the Parser with the Provided Shell Script**

   ```bash
   ./install_and_run.sh <input_file>
   ```

   **Example**:
   ```bash
   ./install_and_run.sh Program1.txt
   ```

4. **Alternative Compilation and Execution**

   - Run the following commands:
   
     ```bash
     ocamlc -o lexer.exe tokens.ml lexer.ml parser.ml ast_printer.ml main.ml
     ```

   - Run the executable:
   
     ```bash
     ./lexer.exe <input_file>
     ```

---

## **Detailed Description of Each Step**

### **Lexer Algorithm**

The scanner reads the input source code character by character, tokenizing it based on the defined lexical grammar. Finite automata are used to process complex tokens, such as music notes and string literals, and to manage error handling.

### **Parser Algorithm**

The parser program uses a **Recursive Descent Parsing algorithm**. Given that our language is designed as an LL(1) grammar with no left recursion, recursive descent parsing can process the token stream efficiently and without ambiguity. Seven of the nine non-terminals (`S`, `H`, `E`, `T`, `M`, `M'`, `melody`) have explicitly defined parsing functions, while `A` and `V` are sets of non-terminals that are checked implicitly.

### **AST printer**

The ast-printer program print the AST in a specific format. Each non-terminal is marked with a `$`

### **Error Handling**

The lexer and parser raise a `LexingError` or `ParseError` with descriptive messages when they encounter syntactical or lexical issues. These errors help users identify issues in the input code, such as unrecognized characters or missing punctuation.

---

## **Sample Input Programs and Expected Outputs**

### **Program 1: Basic Music Program**

**Content**:

```plaintext
title="mymusic";
composer="someone";
instrument=Piano;
bpm=120;
play (Do4# quarter, Re4- half, repeat(Mi4- whole, Fa4# half));
end
```

**Expected AST**:
```
$Program
  $Header chunk
    $Expression - Attribute Assignment
    ├── KEYWORD(title)
    ├── OPERATOR(=)
    └── STRING_LITERAL(mymusic)
  └── SEMICOLON
  $Header chunk
    $Expression - Attribute Assignment
    ├── KEYWORD(composer)
    ├── OPERATOR(=)
    └── STRING_LITERAL(someone)
  └── SEMICOLON
  $Header chunk
    $Expression - Attribute Assignment
    ├── KEYWORD(instrument)
    ├── OPERATOR(=)
    └── IDENTIFIER(Piano)
  └── SEMICOLON
  $Header chunk
    $Expression - Attribute Assignment
    ├── KEYWORD(bpm)
    ├── OPERATOR(=)
    └── NUMBER(120)
  └── SEMICOLON
  $Track chunk
  ├── KEYWORD(play)
  ├── LPAREN
    $Music sequence
      $Melody
      ├── MUSICNOTE(Do4#)
      └── DURATION(quarter)
    ├── COMMA
    $Music sequence
      $Melody
      ├── MUSICNOTE(Re4-)
      └── DURATION(half)
    ├── COMMA
    $Repeat Sequence
    ├── KEYWORD(repeat)
    ├── LPAREN
      $Music sequence
        $Melody
        ├── MUSICNOTE(Mi4-)
        └── DURATION(whole)
      ├── COMMA
      $Music sequence
        $Melody
        ├── MUSICNOTE(Fa4#)
        └── DURATION(half)
    ├── RPAREN
  ├── RPAREN
  └── SEMICOLON
└── KEYWORD(end)
```

### **Program 2: Empty Header Chunk**

**Content**:

```plaintext
play (Mi5_ whole, Fa5_ half, Mi5_eighth, Re5_ sixteenth, Do5_ whole, Re5_ half, Mi5_quarter);
end          
```

**Expected Tokens**:
```
$Program
  $Track chunk
  ├── KEYWORD(play)
  ├── LPAREN
    $Music sequence
      $Melody
      ├── MUSICNOTE(Mi5_)
      └── DURATION(whole)
    ├── COMMA
    $Music sequence
      $Melody
      ├── MUSICNOTE(Fa5_)
      └── DURATION(half)
    ├── COMMA
    $Music sequence
      $Melody
      ├── MUSICNOTE(Mi5_)
      └── DURATION(eighth)
    ├── COMMA
    $Music sequence
      $Melody
      ├── MUSICNOTE(Re5_)
      └── DURATION(sixteenth)
    ├── COMMA
    $Music sequence
      $Melody
      ├── MUSICNOTE(Do5_)
      └── DURATION(whole)
    ├── COMMA
    $Music sequence
      $Melody
      ├── MUSICNOTE(Re5_)
      └── DURATION(half)
    ├── COMMA
    $Music sequence
      $Melody
      ├── MUSICNOTE(Mi5_)
      └── DURATION(quarter)
  ├── RPAREN
  └── SEMICOLON
└── KEYWORD(end)
```

### **Program 3: Nested repeat sequences**

**Content**:

```plaintext
play (Do4# quarter,
repeat(Do4# quarter),
Do3- half,
repeat(Do4# quarter,repeat(Do4# quarter,repeat(Do4# quarter)))
);
end
```

**Expected Output**:
```
$Program
  $Track chunk
  ├── KEYWORD(play)
  ├── LPAREN
    $Music sequence
      $Melody
      ├── MUSICNOTE(Do4#)
      └── DURATION(quarter)
    ├── COMMA
    $Repeat Sequence
    ├── KEYWORD(repeat)
    ├── LPAREN
      $Music sequence
        $Melody
        ├── MUSICNOTE(Do4#)
        └── DURATION(quarter)
    ├── RPAREN
    ├── COMMA
    $Music sequence
      $Melody
      ├── MUSICNOTE(Do3-)
      └── DURATION(half)
    ├── COMMA
    $Repeat Sequence
    ├── KEYWORD(repeat)
    ├── LPAREN
      $Music sequence
        $Melody
        ├── MUSICNOTE(Do4#)
        └── DURATION(quarter)
      ├── COMMA
      $Repeat Sequence
      ├── KEYWORD(repeat)
      ├── LPAREN
        $Music sequence
          $Melody
          ├── MUSICNOTE(Do4#)
          └── DURATION(quarter)
        ├── COMMA
        $Repeat Sequence
        ├── KEYWORD(repeat)
        ├── LPAREN
          $Music sequence
            $Melody
            ├── MUSICNOTE(Do4#)
            └── DURATION(quarter)
        ├── RPAREN
      ├── RPAREN
    ├── RPAREN
  ├── RPAREN
  └── SEMICOLON
└── KEYWORD(end)
```

### **Program 4: Missing semicolon**

**Content**:

```plaintext
title="Composition";
play (
    Do4# quarter
)
end
```

**Expected Output**:
```
Parsing error: Syntax error: Expected ';' after track
```

### **Program 5: Missing music sequence after comma**

**Content**:

```plaintext
title ="Symphony No. 5";
composer ="Beethoven";
play (Do4_ half,);
end
```

**Expected Output**:
```
Parsing error: Syntax error: Expected a music note or function like 'repeat'
```
### **Program 6: Missing end token**

**Content**:

```plaintext
title ="Symphony No. 5";
composer ="Beethoven";
play (Do4_ half);
```

**Expected Output**:
```
Parsing error: Unexpected end of input
```
