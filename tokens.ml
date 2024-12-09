type token =
  | KEYWORD of string
  | OPERATOR of string
  | IDENTIFIER of string
  | NUMBER of int
  | STRING_LITERAL of string
  | MUSICNOTE of string
  | DURATION of string
  | LPAREN       
  | RPAREN        
  | SEMICOLON     
  | COMMA         

exception LexingError of string  (* Error message for lexing issues *)


(* type expr =(*A=V*)
  | Assign of token * token * token 

type header =(*H->A=V;H*)
  | Empty
  | Set of expr*token*header           
  | EndHeader                        (* To signify the end of header assignments *)
type melody=
| Melody of token*token (*pitch + duration*)
type track =(*T->play (M)*)
  | Play of token * token * music_sequence * token * token (* play ( music_sequence ) ; *)

and music_sequence = (*M->note M'| repeat (M) M'*)
  | Note of melody  * music_sequence_suc         
  | Repeat of token *token* music_sequence * token *music_sequence_suc
and music_sequence_suc=(*M'-> epsilon|,M*)
  | Empty
  | Next of token*music_sequence

type program =(*S->HT end*)
  | Program of header * track * token *)
