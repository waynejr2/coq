Require Import Int63.

Set Universe Polymorphism.

Primitive array := #array_type.

Primitive make : forall A, int -> A -> array A := #array_make.
Arguments make {_} _ _.

Primitive get : forall A, array A -> int -> A := #array_get.
Arguments get {_} _ _.

Primitive default : forall A, array A -> A:= #array_default.
Arguments default {_} _.

Primitive set : forall A, array A -> int -> A -> array A := #array_set.
Arguments set {_} _ _ _.

Primitive length : forall A, array A -> int := #array_length.
Arguments length {_} _.

Primitive copy : forall A, array A -> array A := #array_copy.
Arguments copy {_} _.

(* [reroot t] produces an array that is extensionaly equal to [t], but whose
   history has been squashed. Useful when performing multiple accesses in an old
   copy of an array that has been updated. *)
Primitive reroot : forall A, array A -> array A := #array_reroot.
Arguments reroot {_} _.

Module Export PArrayNotations.

Declare Scope array_scope.
Delimit Scope array_scope with array.
Notation "t .[ i ]" := (get t i)
  (at level 2, left associativity, format "t .[ i ]").
Notation "t .[ i <- a ]" := (set t i a)
  (at level 2, left associativity, format "t .[ i <- a ]").

End PArrayNotations.

Local Open Scope int63_scope.
Local Open Scope array_scope.

Primitive max_length := #array_max_length.

(** Axioms *)
Axiom get_out_of_bounds : forall A (t:array A) i, (i < length t) = false -> t.[i] = default t.

Axiom get_set_same : forall A t i (a:A), (i < length t) = true -> t.[i<-a].[i] = a.
Axiom get_set_other : forall A t i j (a:A), i <> j -> t.[i<-a].[j] = t.[j].
Axiom default_set : forall A t i (a:A), default t.[i<-a] = default t.


Axiom get_make : forall A (a:A) size i, (make size a).[i] = a.

Axiom leb_length : forall A (t:array A), length t <= max_length = true.

Axiom length_make : forall A size (a:A),
  length (make size a) = if size <= max_length then size else max_length.
Axiom length_set : forall A t i (a:A),
  length t.[i<-a] = length t.

Axiom get_copy : forall A (t:array A) i, (copy t).[i] = t.[i].
Axiom length_copy : forall A (t:array A), length (copy t) = length t.

Axiom get_reroot : forall A (t:array A) i, (reroot t).[i] = t.[i].
Axiom length_reroot : forall A (t:array A), length (reroot t) = length t.

Axiom array_ext : forall A (t1 t2:array A),
  length t1 = length t2 ->
  (forall i, i < length t1 = true -> t1.[i] = t2.[i]) ->
  default t1 = default t2 ->
  t1 = t2.

(* Lemmas *)

Lemma default_copy A (t:array A) : default (copy t) = default t.
Proof.
  assert (irr_lt : length t < length t = false).
    destruct (Int63.ltbP (length t) (length t)); try reflexivity.
    exfalso; eapply BinInt.Z.lt_irrefl; eassumption.
  assert (get_copy := get_copy A t (length t)).
  rewrite !get_out_of_bounds in get_copy; try assumption.
  rewrite length_copy; assumption.
Qed.

Lemma default_make A (a : A) size : default (make size a) = a.
Proof.
  assert (irr_lt : length (make size a) < length (make size a) = false).
    destruct (Int63.ltbP (length (make size a)) (length (make size a))); try reflexivity.
    exfalso; eapply BinInt.Z.lt_irrefl; eassumption.
  assert (get_make := get_make A a size (length (make size a))).
  rewrite !get_out_of_bounds in get_make; assumption.
Qed.

Lemma default_reroot A (t:array A) : default (reroot t) = default t.
Proof.
  assert (irr_lt : length t < length t = false).
    destruct (Int63.ltbP (length t) (length t)); try reflexivity.
    exfalso; eapply BinInt.Z.lt_irrefl; eassumption.
  assert (get_reroot := get_reroot A t (length t)).
  rewrite !get_out_of_bounds in get_reroot; try assumption.
  rewrite length_reroot; assumption.
Qed.

Lemma get_set_same_default A (t : array A) (i : int) :
  t.[i <- default t].[i] = default t.
Proof.
 case_eq (i < length t); intros.
   rewrite get_set_same; trivial.
 rewrite get_out_of_bounds, default_set; trivial.
 rewrite length_set; trivial.
Qed.

Lemma get_not_default_lt A (t:array A) x :
 t.[x] <> default t -> (x < length t) = true.
Proof.
 intros Hd.
 case_eq (x < length t); intros Heq; [trivial | ].
 elim Hd; rewrite get_out_of_bounds; trivial.
Qed.
