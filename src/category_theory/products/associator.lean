-- Copyright (c) 2017 Scott Morrison. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Authors: Stephen Morgan, Scott Morrison

import category_theory.products
import category_theory.equivalence
import category_theory.eq_to_hom

universes v₁ v₂ v₃ u₁ u₂ u₃

open category_theory

namespace category_theory.prod

variables (C : Type u₁) [𝒞 : category.{v₁+1} C] (D : Type u₂) [𝒟 : category.{v₂+1} D]
include 𝒞 𝒟
variables (E : Type u₃) [ℰ : category.{v₃+1} E]
include ℰ

def associator : ((C × D) × E) ⥤ (C × (D × E)) :=
{ obj := λ X, (X.1.1, (X.1.2, X.2)),
  map := λ _ _ f, (f.1.1, (f.1.2, f.2)) }

@[simp] lemma associator_obj (X) :
  (associator C D E).obj X = (X.1.1, (X.1.2, X.2)) :=
rfl
@[simp] lemma associator_map {X Y} (f : X ⟶ Y) :
  (associator C D E).map f = (f.1.1, (f.1.2, f.2)) :=
rfl

def inverse_associator : (C × (D × E)) ⥤ ((C × D) × E) :=
{ obj := λ X, ((X.1, X.2.1), X.2.2),
  map := λ _ _ f, ((f.1, f.2.1), f.2.2) }

@[simp] lemma inverse_associator_obj (X) :
  (inverse_associator C D E).obj X = ((X.1, X.2.1), X.2.2) :=
rfl
@[simp] lemma inverse_associator_map {X Y} (f : X ⟶ Y) :
  (inverse_associator C D E).map f = ((f.1, f.2.1), f.2.2) :=
rfl

def associativity : equivalence ((C × D) × E) (C × (D × E)) :=
{ functor := associator C D E,
  inverse := inverse_associator C D E,
  fun_inv_id' := nat_iso.of_components (λ X, eq_to_iso (by simp)) (by tidy),
  inv_fun_id' := nat_iso.of_components (λ X, eq_to_iso (by simp)) (by tidy) }

-- TODO pentagon natural transformation? ...satisfying?
end category_theory.prod
