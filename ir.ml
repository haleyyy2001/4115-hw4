(* ir.ml *)
type header_assignment =
  | SetTempo of int
  | SetInstrument of string
  | SetTitle of string
  | SetComposer of string

type ir_note = {
  pitch : int;
  length : int;
}

type ir_program = {
  mutable final_instrument : string;
  mutable final_tempo : int;
  mutable notes : ir_note list;
}
