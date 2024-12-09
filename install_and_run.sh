#!/bin/bash

# Installation and execution script for the compiler

# Check if OCaml is installed
if ! command -v ocamlc &> /dev/null
then
    echo "OCaml compiler could not be found. Please install OCaml."
    exit 1
fi

echo "OCaml compiler found."

# Check if opam is installed
if ! command -v opam &> /dev/null
then
    echo "opam could not be found. Please install opam to manage OCaml packages."
    exit 1
fi

echo "opam found."

# Initialize opam environment
eval $(opam env)

# Check if ocamlfind is installed
if ! command -v ocamlfind &> /dev/null
then
    echo "Installing ocamlfind..."
    opam install ocamlfind
else
    echo "ocamlfind is already installed."
fi

# Clean previous builds
echo "Cleaning previous builds..."
rm -f compiler.exe *.cmo *.cmi *.mid

# Compile the code
echo "Compiling the compiler..."

# Compile each module
ocamlc -c tokens.ml
ocamlc -c lexer.ml
ocamlc -c parser.ml
ocamlc -c code_generator.ml
ocamlc -c main.ml

# Link the object files into an executable
ocamlc -o compiler.exe tokens.cmo lexer.cmo parser.cmo code_generator.cmo main.cmo

if [ $? -ne 0 ]; then
    echo "Compilation failed."
    exit 1
fi

echo "Compilation successful."

# Run the compiler with input file provided as argument
if [ $# -eq 0 ]; then
    echo "No input file provided. Usage: ./install_and_run.sh <input_file>"
    exit 1
fi

INPUT_FILE=$1
OUTPUT_FILE="${INPUT_FILE%.*}.mid"

echo "Running the compiler on input file: $INPUT_FILE"
./compiler.exe "$INPUT_FILE"

if [ $? -ne 0 ]; then
    echo "Compiler execution failed."
    exit 1
fi

echo "MIDI file generated: $OUTPUT_FILE"
