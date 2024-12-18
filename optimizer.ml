(* optimizer.ml *)
open Ir

(* Dead store elimination on headers *)
let remove_redundant_header_assignments assigns =
  let tempo_opt = List.fold_left (fun acc a ->
    match a with
    | SetTempo t -> Some t
    | _ -> acc
  ) None assigns in
  let instr_opt = List.fold_left (fun acc a ->
    match a with
    | SetInstrument i -> Some i
    | _ -> acc
  ) None assigns in
  (tempo_opt, instr_opt)

(* Merge identical consecutive notes repeatedly until no more merges can occur *)
let rec merge_consecutive_identical_notes notes =
  let rec one_pass acc = function
    | [] -> List.rev acc
    | [x] -> List.rev (x::acc)
    | x::y::rest ->
       if x.pitch = y.pitch && x.length = y.length then
         one_pass acc ({x with length = x.length + y.length}::rest)
       else
         one_pass (x::acc) (y::rest)
  in
  let merged = one_pass [] notes in
  if merged <> notes then merge_consecutive_identical_notes merged else merged

(* Unreachable Code Elimination:
   Assume that encountering a note with pitch=999 means all subsequent notes are unreachable.
   We'll remove them. This is a conceptual scenario to show unreachable code elimination.
*)
let remove_unreachable_notes notes =
  let rec aux acc = function
    | [] -> List.rev acc
    | {pitch=999; _}::rest ->
       (* Everything after pitch=999 is unreachable *)
       List.rev acc
    | x::rest -> aux (x::acc) rest
  in
  aux [] notes

(* Another Peephole Pass:
   After removing unreachable code and merging once, run another merge pass to ensure full merging.
*)
let another_peephole_pass notes =
  merge_consecutive_identical_notes notes

let optimize (assigns : header_assignment list) (ir : ir_program) : ir_program =
  let (tempo_opt, instr_opt) = remove_redundant_header_assignments assigns in

  (* 1) Peephole Optimization - initial merging of identical notes *)
  ir.notes <- merge_consecutive_identical_notes ir.notes;

  (* 2) Unreachable Code Elimination - remove notes after marker *)
  ir.notes <- remove_unreachable_notes ir.notes;

  (* 3) Another Peephole Pass - fully merge after potential changes *)
  ir.notes <- another_peephole_pass ir.notes;

  (* Dead Store Elimination on headers *)
  (match tempo_opt with Some t -> ir.final_tempo <- t | None -> ());
  (match instr_opt with Some i -> ir.final_instrument <- i | None -> ());

  ir
