open Tokens
open Parser


let rec print_token token =
  match token with
  | KEYWORD s-> "KEYWORD(" ^ s ^ ")"
  | OPERATOR s-> "OPERATOR(" ^ s ^ ")"
  | IDENTIFIER s->"IDENTIFIER(" ^ s ^ ")"
  | NUMBER s->"NUMBER(" ^ string_of_int s ^ ")"
  | STRING_LITERAL s->"STRING_LITERAL(" ^ s ^ ")"
  | MUSICNOTE s ->"MUSICNOTE(" ^ s ^ ")"
  | DURATION s-> "DURATION(" ^ s ^ ")"
  | LPAREN->"LPAREN"
  | RPAREN-> "RPAREN"
  | SEMICOLON-> "SEMICOLON"
  | COMMA->"COMMA"


let rec print_ast node indent =
  let prefix=String.make indent ' ' in
  match node with
  | Program (header,track,end_token)->
      Printf.printf "%s$Program\n" prefix;
      print_ast_header header (indent + 2);
      print_ast_track track (indent + 2);
      Printf.printf "%s└── %s\n" prefix (print_token end_token)
and print_ast_header header indent=
  let prefix = String.make indent ' ' in
  match header with
  | Empty->()
  | Set (expr,semicolon_token,rest)->
      Printf.printf "%s$Header chunk\n" prefix;
      print_ast_expr expr (indent + 2);
      Printf.printf "%s└── %s\n" prefix (print_token semicolon_token);
      print_ast_header rest indent


and print_ast_expr expr indent=
  let prefix = String.make indent ' ' in
  match expr with
  | Assign (attr_token, operator_token, value_token) ->
      Printf.printf "%s$Expression - Attribute Assignment\n" prefix;
      Printf.printf "%s├── %s\n" prefix (print_token attr_token);
      Printf.printf "%s├── %s\n" prefix (print_token operator_token);
      Printf.printf "%s└── %s\n" prefix (print_token value_token)


and print_ast_track track indent =
  let prefix = String.make indent ' ' in
  match track with
  | Play (play_token, lparen_token, music_seq, rparen_token, semicolon_token) ->
      Printf.printf "%s$Track chunk\n" prefix;
      Printf.printf "%s├── %s\n" prefix (print_token play_token);
      Printf.printf "%s├── %s\n" prefix (print_token lparen_token);
      print_ast_music_sequence music_seq (indent + 2);
      Printf.printf "%s├── %s\n" prefix (print_token rparen_token);
      Printf.printf "%s└── %s\n" prefix (print_token semicolon_token)

and print_ast_music_sequence music_seq indent =
  let prefix = String.make indent ' ' in
  match music_seq with
  | Note (melody, m_suc) ->
      Printf.printf "%s$Music sequence\n" prefix;
      print_ast_melody melody (indent + 2);
      print_ast_music_sequence_suc m_suc indent
  | Repeat (repeat_token, lparen_token,inner_seq,rparen_token,m_suc) ->
      Printf.printf "%s$Repeat Sequence\n" prefix;
      Printf.printf "%s├── %s\n" prefix (print_token repeat_token);
      Printf.printf "%s├── %s\n" prefix (print_token lparen_token);
      print_ast_music_sequence inner_seq (indent + 2);
      Printf.printf "%s├── %s\n" prefix (print_token rparen_token);
      print_ast_music_sequence_suc m_suc indent

and print_ast_music_sequence_suc m_suc indent =
  let prefix = String.make indent ' ' in
  match m_suc with
  | Empty -> ()
  | Next (comma_token, music_seq) ->
      Printf.printf "%s├── %s\n" prefix (print_token comma_token);
      print_ast_music_sequence music_seq indent


and print_ast_melody melody indent =
  let prefix = String.make indent ' ' in
  match melody with
  | Melody (note_token, duration_token) ->
      Printf.printf "%s$Melody\n" prefix;
      Printf.printf "%s├── %s\n" prefix (print_token note_token);
      Printf.printf "%s└── %s\n" prefix (print_token duration_token)