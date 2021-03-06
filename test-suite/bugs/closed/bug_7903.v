(* Slightly improving interpretation of Ltac subterms in notations *)

Notation bar x f := (let z := ltac:(exact 1) in (fun x : nat => f)).
Check fun x => bar x (x + x).
