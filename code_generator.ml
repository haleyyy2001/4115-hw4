

(* code_generator.ml *)
open Tokens
open Parser
open Ir
open Optimizer
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

(* Temporary storage for header assignments and IR *)
let header_assignments = ref []
let ir = {final_instrument = "piano"; final_tempo=120; notes=[]}

(* A helper function to print the optimized IR *)
let print_ir (ir: ir_program) =
  Printf.printf "\n=== Optimized IR ===\n";
  Printf.printf "Instrument: %s\n" ir.final_instrument;
  Printf.printf "Tempo (BPM): %d\n" ir.final_tempo;
  Printf.printf "Notes:\n";
  List.iter (fun n ->
    Printf.printf "  Pitch: %d, Length: %d\n" n.pitch n.length
  ) ir.notes;
  Printf.printf "====================\n\n"

let generate_midi ast output_file =
  let ticks_per_quarter = 480 in

  let rec process_program = function
    | Program (header, track, _) ->
        process_header header;
        process_track track;
        (* Optimize IR *)
        let optimized_ir = optimize !header_assignments ir in
        (* Print the IR after optimization for debugging *)
        print_ir optimized_ir;
        write_midi_file output_file optimized_ir

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
               header_assignments := !header_assignments @ [SetTempo (int_of_string value)]
           | "instrument" ->
               let v = String.lowercase_ascii value in
               header_assignments := !header_assignments @ [SetInstrument v]
           | "composer" ->
               header_assignments := !header_assignments @ [SetComposer value]
           | "title" ->
               header_assignments := !header_assignments @ [SetTitle value]
           | _ -> ());
          aux rest
    in
    aux header

  and process_track track =
    match track with
    | Play (_, _, music_seq, _, _) ->
        process_music_sequence music_seq

  and process_music_sequence music_seq =
    match music_seq with
    | Note (Melody (note_token, duration_token), m_suc) ->
        let note_str = extract_string note_token in
        let duration_str = extract_string duration_token in
        let midi_note, note_length = parse_note note_str duration_str in
        ir.notes <- ir.notes @ [{pitch=midi_note; length=note_length}];
        process_music_sequence_suc m_suc
    | Repeat (_, _, inner_seq, _, m_suc) ->
        let repeat_count = 2 in
        for _ = 1 to repeat_count do
          process_music_sequence inner_seq
        done;
        process_music_sequence_suc m_suc

  and process_music_sequence_suc m_suc =
    match m_suc with
    | MusicSeqEmpty -> ()
    | MusicSeqNext (_, music_seq) ->
        process_music_sequence music_seq

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

  and instrument_program_number instr =
    match instr with
    | "guitar" -> 24
    | "piano" -> 0
    | _ -> 0

  and write_midi_file filename optimized_ir =
    let events = ref [] in
    let current_time = ref 0 in

    List.iter (fun n ->
      let delta_time = !current_time in
      let note_on_event = (`Note_on (0, n.pitch, 64), delta_time) in
      let note_off_event = (`Note_off (0, n.pitch, 64), delta_time + n.length) in
      events := !events @ [note_on_event; note_off_event];
      current_time := !current_time + n.length
    ) optimized_ir.notes;

    let sorted_events = List.sort (fun (_, t1) (_, t2) -> compare t1 t2) !events in
    let midi_events = ref [] in
    let last_time = ref 0 in

    List.iter (fun (event, abs_time) ->
      let delta_time = abs_time - !last_time in
      last_time := abs_time;
      let delta_bytes = write_variable_length_quantity delta_time in
      let event_bytes =
        match event with
        | `Note_on (channel, note, velocity) ->
            delta_bytes @ [0x90 + channel; note; velocity]
        | `Note_off (channel, note, velocity) ->
            delta_bytes @ [0x80 + channel; note; velocity]
      in
      midi_events := !midi_events @ event_bytes
    ) sorted_events;

    let microseconds_per_quarter = 60000000 / optimized_ir.final_tempo in
    let tempo_event = [
      0x00;
      0xFF; 0x51; 0x03;
      (microseconds_per_quarter lsr 16) land 0xFF;
      (microseconds_per_quarter lsr 8) land 0xFF;
      microseconds_per_quarter land 0xFF;
    ] in

    let prog_num = instrument_program_number optimized_ir.final_instrument in
    let program_change_event = [
      0x00;
      0xC0;
      prog_num
    ] in

    let end_of_track = [
      0x00;
      0xFF; 0x2F; 0x00
    ] in

    let track_data = tempo_event @ program_change_event @ !midi_events @ end_of_track in

    let header = [
      0x4D; 0x54; 0x68; 0x64; (* MThd *)
      0x00; 0x00; 0x00; 0x06;
      0x00; 0x00;
      0x00; 0x01;
      (480 lsr 8) land 0xFF; (480 land 0xFF);
    ] in

    let track_chunk_header = [0x4D; 0x54; 0x72; 0x6B] in (* MTrk *)
    let track_length = List.length track_data in
    let track_length_bytes = [
      (track_length lsr 24) land 0xFF;
      (track_length lsr 16) land 0xFF;
      (track_length lsr 8) land 0xFF;
      track_length land 0xFF;
    ] in

    let midi_bytes = header @ track_chunk_header @ track_length_bytes @ track_data in
    let oc = open_out_bin filename in
    List.iter (fun byte -> output_byte oc byte) midi_bytes;
    close_out oc;
    Printf.printf "MIDI file '%s' generated successfully.\n" filename
  in
  process_program ast
