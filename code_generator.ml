open Tokens
open Parser
open Printf

let extract_string token =
  match token with
  | KEYWORD s | IDENTIFIER s | STRING_LITERAL s | MUSICNOTE s | DURATION s -> s
  | _ -> failwith "Expected a string token"

let extract_number token =
  match token with
  | NUMBER n -> n
  | _ -> failwith "Expected a number token"

let note_to_midi note octave accidental =
  let base_pitch =
    match note with
    | "Do" -> 0
    | "Re" -> 2
    | "Mi" -> 4
    | "Fa" -> 5
    | "So" -> 7
    | "La" -> 9
    | "Ti" -> 11
    | _ -> failwith ("Unknown note: " ^ note)
  in
  let accidental_offset =
    match accidental with
    | "#" -> 1
    | "_" -> -1
    | "-" -> 0
    | _ -> failwith ("Unknown accidental: " ^ accidental)
  in
  (octave + 1)*12 + base_pitch + accidental_offset

let duration_to_ticks duration ticks_per_quarter =
  match duration with
  | "whole"     -> ticks_per_quarter * 4
  | "half"      -> ticks_per_quarter * 2
  | "quarter"   -> ticks_per_quarter
  | "eighth"    -> ticks_per_quarter / 2
  | "sixteenth" -> ticks_per_quarter / 4
  | _ -> failwith ("Unknown duration: " ^ duration)

let write_variable_length_quantity n =
  let rec aux acc n =
    let c = n land 0x7F in
    let n = n lsr 7 in
    let c = if acc <> [] then c lor 0x80 else c in
    let acc = c::acc in
    if n=0 then acc else aux acc n
  in
   (aux [] n)

(* Globals for header attributes *)
let composer = ref ""
let title = ref ""
let instrument_type = ref "piano" (* default instrument *)
let tempo = ref 120 (* default BPM *)

(* Generate MIDI from AST *)
let generate_midi ast output_file =
  let ticks_per_quarter = 480 in
  let events = ref [] in

  let rec process_program = function
    | Program (header, track, _) ->
        process_header header;
        process_track track;
        write_midi_file output_file !events

  and process_header header =
    let rec aux = function
      | HeaderEmpty -> ()
      | HeaderSet (Assign (attr_token, _, value_token), _, rest) ->
          let attr = extract_string attr_token in
          let value =
            match value_token with
            | STRING_LITERAL s | IDENTIFIER s -> s
            | NUMBER n -> string_of_int n
            | _ -> failwith "Expected value"
          in
          (match attr with
           | "bpm" ->
               tempo := int_of_string value
           | "instrument" ->
               let v = String.lowercase_ascii value in
               if v = "guitar" then (
                 instrument_type := "guitar";
                 printf "Instrument set to: Guitar\n"
               ) else if v = "piano" then (
                 instrument_type := "piano";
                 printf "Instrument set to: Piano\n"
               ) else (
                 instrument_type := "piano";
                 printf "Instrument not recognized. Defaulting to Piano.\n"
               )
           | "composer" ->
               composer := value;
               printf "Composer set to: %s\n" !composer
           | "title" ->
               title := value;
               printf "Title set to: %s\n" !title
           | _ -> ());
          aux rest
    in
    aux header

  and process_track track =
    match track with
    | Play (_, _, music_seq, _, _) ->
        let current_time = ref 0 in
        process_music_sequence music_seq current_time

  and process_music_sequence music_seq current_time =
    match music_seq with
    | Note (Melody (note_token, duration_token), m_suc) ->
        let note_str = extract_string note_token in
        let duration_str = extract_string duration_token in
        let midi_note, note_length = parse_note note_str duration_str in
        add_note_event midi_note note_length current_time;
        process_music_sequence_suc m_suc current_time
    | Repeat (_, _, inner_seq, _, m_suc) ->
        let repeat_count = 2 in
        for _ = 1 to repeat_count do
          process_music_sequence inner_seq current_time
        done;
        process_music_sequence_suc m_suc current_time

  and process_music_sequence_suc m_suc current_time =
    match m_suc with
    | MusicSeqEmpty -> ()
    | MusicSeqNext (_, music_seq) ->
        process_music_sequence music_seq current_time

  and parse_note note_str duration_str =
    if String.length note_str < 3 then failwith ("Invalid note format: " ^ note_str)
    else
      let note_name = String.sub note_str 0 2 in
      let rest = String.sub note_str 2 (String.length note_str - 2) in
      let octave_char = String.get rest 0 in
      let octave = int_of_string (String.make 1 octave_char) in
      let accidental =
        if String.length rest > 1 then String.sub rest 1 1 else "-"
      in
      let midi_note = note_to_midi note_name octave accidental in
      let note_length = duration_to_ticks duration_str ticks_per_quarter in
      (midi_note, note_length)

  and add_note_event midi_note note_length current_time =
    let delta_time = !current_time in
    let note_on_event = (`Note_on (0, midi_note, 64), delta_time) in
    let note_off_event = (`Note_off (0, midi_note, 64), delta_time + note_length) in
    events := !events @ [note_on_event; note_off_event];
    current_time := !current_time + note_length;
    Printf.printf "Debug: Added note on at %d, note off at %d, note=%d\n" delta_time (delta_time+note_length) midi_note

  (* Determine the program number based on instrument_type *)
  (* Piano (Acoustic Grand Piano) = program 0
     Guitar (Acoustic Guitar Nylon) = program 24 *)
  and instrument_program_number () =
    match !instrument_type with
    | "guitar" -> 24
    | "piano" -> 0
    | _ -> 0 (* default to piano if something else shows up *)

  and write_midi_file filename events =
    let sorted_events = List.sort (fun (_, t1) (_, t2) -> compare t1 t2) events in
    let midi_events = ref [] in
    let last_time = ref 0 in

    List.iter (fun (event, abs_time) ->
      let delta_time = abs_time - !last_time in
      last_time := abs_time;
      let delta_bytes = write_variable_length_quantity delta_time in
      let event_bytes =
        match event with
        | `Note_on (channel, note, velocity) ->
            Printf.printf "Debug: Note On: note=%d velocity=%d delta_time=%d\n" note velocity delta_time;
            delta_bytes @ [0x90 + channel; note; velocity]
        | `Note_off (channel, note, velocity) ->
            Printf.printf "Debug: Note Off: note=%d velocity=%d delta_time=%d\n" note velocity delta_time;
            delta_bytes @ [0x80 + channel; note; velocity]
      in
      midi_events := !midi_events @ event_bytes
    ) sorted_events;

    let microseconds_per_quarter = 60000000 / !tempo in

    (* Tempo meta-event *)
    let tempo_event = [
      0x00;
      0xFF; 0x51; 0x03;
      (microseconds_per_quarter lsr 16) land 0xFF;
      (microseconds_per_quarter lsr 8) land 0xFF;
      microseconds_per_quarter land 0xFF;
    ] in

    (* Program Change event to set instrument *)
    let prog_num = instrument_program_number () in
    let program_change_event = [
      0x00;       (* delta time 0 *)
      0xC0;       (* Program Change on channel 0 *)
      prog_num
    ] in

    let end_of_track = [
      0x00;
      0xFF; 0x2F; 0x00
    ] in

    let track_data = tempo_event @ program_change_event @ !midi_events @ end_of_track in

    (* MIDI header: format=0, one track *)
    let header = [
      0x4D; 0x54; 0x68; 0x64; (* 'MThd' *)
      0x00; 0x00; 0x00; 0x06;
      0x00; 0x00;             (* format 0 *)
      0x00; 0x01;             (* one track *)
      (ticks_per_quarter lsr 8) land 0xFF; (ticks_per_quarter land 0xFF);
    ] in

    let track_chunk_header = [0x4D; 0x54; 0x72; 0x6B] in (* 'MTrk' *)
    let track_length = List.length track_data in
    let track_length_bytes = [
      (track_length lsr 24) land 0xFF;
      (track_length lsr 16) land 0xFF;
      (track_length lsr 8) land 0xFF;
      track_length land 0xFF;
    ] in

    let midi_bytes = header @ track_chunk_header @ track_length_bytes @ track_data in

    (* Print hex output with commentary *)
    Printf.printf "MIDI hex output:\n";
    List.iteri (fun i byte ->
      Printf.printf "%02X " byte;
      if i = 3 then Printf.printf("\n-- 'MThd' header done\n");
      if i = 13 then Printf.printf("\n-- 'MTrk' track header and length done\n");
      if i = 21 then Printf.printf("\n-- Track events start here\n");
    ) midi_bytes;

    Printf.printf "\n\nDetailed Commentary:\n";
    if !title <> "" then Printf.printf "- Title: %s\n" !title;
    if !composer <> "" then Printf.printf "- Composer: %s\n" !composer;
    Printf.printf "- Instrument: %s (Program %d)\n" !instrument_type prog_num;
    Printf.printf "- BPM: %d\n" !tempo;
    Printf.printf "- 'MThd': format=0, one track, 480 ticks/quarter.\n";
    Printf.printf "- 'MTrk': track data.\n";
    Printf.printf "- Tempo event sets %d BPM.\n" !tempo;
    Printf.printf "- Program Change sets instrument to %s.\n" !instrument_type;
    Printf.printf "- Notes: encoded as Note On (0x90) and Note Off (0x80) events.\n";
    Printf.printf "- End of track (FF 2F 00) ends track.\n";

    let oc = open_out_bin filename in
    List.iter (fun byte -> output_byte oc byte) midi_bytes;
    close_out oc;
    Printf.printf "MIDI file '%s' generated successfully.\n" filename

  in
  process_program ast
