open Lexer
open Tokens
open Parser
(* Comment out ast_printer if not needed *)
(* open Ast_printer *)
open Code_generator  (* Include the code generator *)

let () =
  if Array.length Sys.argv < 2 then
    Printf.printf "Usage: %s <input_file>\n" Sys.argv.(0)
  else
    let filename = Sys.argv.(1) in
    let ic = open_in filename in
    let buffer = Buffer.create 500 in
    (try
       while true do
         let line = input_line ic in
         Buffer.add_string buffer line;
         Buffer.add_char buffer '\n'; 
       done
     with 
     | End_of_file -> ());
    close_in ic;
    let source = Buffer.contents buffer in

    try
      let tokens = lex source in
      let (ast, _) = parse_program tokens in
      (* Optionally print the AST *)
      (* print_ast ast 0 *)
      let output_file = (Filename.remove_extension filename) ^ ".mid" in
      generate_midi ast output_file;
      Printf.printf "Generated MIDI file: %s\n" output_file
    with
    | LexingError msg ->
        Printf.printf "Lexing error: %s\n" msg
    | ParseError msg ->
        Printf.printf "Parsing error: %s\n" msg
    | Failure msg ->
        Printf.printf "Code generation error: %s\n" msg
