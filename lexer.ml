(* lexer.ml *)
open Tokens
exception LexingError of string 

let lex source =
  let length=String.length source in
  let tokens=ref [] in
  let pos=ref 0 in
  let is_letter c = ('a'<= c&&c<= 'z') || ('A'<=c&&c<='Z') in
  let is_digit c =
    match c with
    |'0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' ->true
    | _ -> false 
  in
  let is_whitespace c = c= ' '||c='\t'||c='\n'||c='\r' in
  let is_accidental c = c ='#'||c ='-' ||c ='_' in
  let is_identifier_char c = is_letter c||is_digit c||c = '_' in
  let rec skip_whitespace () =
    while !pos<length &&is_whitespace source.[!pos] do
      pos:= !pos+1
    done 
  in

  let read_identifier () =
    let buffer = Buffer.create 10 in
    while !pos < length && is_identifier_char source.[!pos] do
      Buffer.add_char buffer source.[!pos];
      pos:= !pos+1
    done;
    Buffer.contents buffer
  in

  let read_number () =
    let buffer = Buffer.create 10 in
    while !pos < length && is_digit source.[!pos] do
      Buffer.add_char buffer source.[!pos];
      pos:= !pos+1
    done;
    int_of_string (Buffer.contents buffer)
  in

  let read_string_literal () =
    let buffer = Buffer.create 10 in
    pos:= !pos+1; 
    while !pos<length && source.[!pos] <> '"' && source.[!pos] <> '\n' && source.[!pos] <> '\r' do
      Buffer.add_char buffer source.[!pos];
      pos:= !pos+1
    done;
    if !pos >= length||source.[!pos] <> '"' then
      raise (LexingError "String literal not terminated before end of line")
    else
      pos:= !pos+1;
    Buffer.contents buffer
  in

  let match_keyword word =
    match String.lowercase_ascii word with
    | "instrument"|"bpm"|"play"| "repeat"| "end"| "title"| "composer" ->
        KEYWORD word
    | "whole"|"half" | "quarter" |"eighth"| "sixteenth" ->
        DURATION word
    | _ ->
        IDENTIFIER word
  in

  let match_music_note () =
    let start_pos= !pos in
    let buffer=Buffer.create 4 in
    if !pos <length&&is_letter source.[!pos] then begin
      Buffer.add_char buffer source.[!pos];
      pos:=!pos+1
    end 
    else
      raise (LexingError (Printf.sprintf "Invalid music note at position %d" start_pos));

    if !pos <length&&is_letter source.[!pos] then begin
      Buffer.add_char buffer source.[!pos];
      pos:=!pos+1
    end 
    else
      raise (LexingError (Printf.sprintf "Invalid music note at position %d" start_pos));

    if !pos <length&&is_digit source.[!pos] then begin
      Buffer.add_char buffer source.[!pos];
      pos:=!pos+1
    end 
    else
      raise (LexingError (Printf.sprintf "Invalid music note at position %d" start_pos));

    if !pos <length&&is_accidental source.[!pos] then begin
      Buffer.add_char buffer source.[!pos];
      pos:=!pos+1
    end 
    else
      raise (LexingError (Printf.sprintf "Invalid music note at position %d" start_pos));

    let note = Buffer.contents buffer in
    let solfege = String.sub note 0 2 in
    let octave =int_of_string (String.sub note 2 1) in
    let valid_solfege = ["do"; "re"; "mi"; "fa"; "so"; "la"; "ti"] in
    if List.mem (String.lowercase_ascii solfege) valid_solfege && octave<=8 &&octave>=0 then
      MUSICNOTE note
    else
      raise (LexingError (Printf.sprintf "Invalid solfege \"%s\" in music note at position %d" solfege start_pos))
  in

  while !pos<length do
    skip_whitespace ();
    if !pos<length then
      let c=source.[!pos] in
      if is_letter c then begin
        let start_pos= !pos in
        try
          let token = match_music_note () in
          tokens:=token::!tokens
        with
        | LexingError _ ->
            pos:=start_pos;
            let word=read_identifier () in
            tokens:=(match_keyword word)::!tokens
      end 
      else if is_digit c then begin
        let number=read_number () in
        tokens:=NUMBER number::!tokens
      end 
      else 
        match c with
        | '=' | ':'->
            tokens:=OPERATOR (String.make 1 c)::!tokens;
            pos:= !pos+1
        | '"' ->
            let str_literal=read_string_literal () in
            tokens:=STRING_LITERAL str_literal::!tokens
        | '('->
            tokens:=LPAREN::!tokens;
            pos:= !pos+1
        | ')' ->
            tokens:=RPAREN::!tokens;
            pos:= !pos+1
        | ';' ->
            tokens:=SEMICOLON::!tokens;
            pos:= !pos+1
        | ',' ->
            tokens:=COMMA::!tokens;
            pos:= !pos+1
        | _ when is_whitespace c->
            pos:= !pos+1
        | _->
            raise(LexingError (Printf.sprintf "Invalid character '%c' at position %d" c !pos))
  done;
  List.rev !tokens
