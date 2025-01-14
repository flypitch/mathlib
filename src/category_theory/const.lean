-- Copyright (c) 2018 Scott Morrison. All rights reserved.
-- Released under Apache 2.0 license as described in the file LICENSE.
-- Authors: Scott Morrison

import category_theory.functor_category
import category_theory.isomorphism
import category_theory.opposites

universes v₁ v₂ v₃ u₁ u₂ u₃ -- declare the `v`'s first; see `category_theory.category` for an explanation

open category_theory

namespace category_theory.functor

variables (J : Sort u₁) [𝒥 : category.{v₁} J]
variables {C : Sort u₂} [𝒞 : category.{v₂} C]
include 𝒥 𝒞

def const : C ⥤ (J ⥤ C) :=
{ obj := λ X,
  { obj := λ j, X,
    map := λ j j' f, 𝟙 X },
  map := λ X Y f, { app := λ j, f } }

namespace const
variables {J}

@[simp] lemma obj_obj (X : C) (j : J) : ((const J).obj X).obj j = X := rfl
@[simp] lemma obj_map (X : C) {j j' : J} (f : j ⟶ j') : ((const J).obj X).map f = 𝟙 X := rfl
@[simp] lemma map_app {X Y : C} (f : X ⟶ Y) (j : J) : ((const J).map f).app j = f := rfl

def op_obj_op (X : C) :
  (const Jᵒᵖ).obj (op X) ≅ ((const J).obj X).op :=
{ hom := { app := λ j, 𝟙 _ },
  inv := { app := λ j, 𝟙 _ } }

@[simp] lemma op_obj_op_hom_app (X : C) (j : Jᵒᵖ) : (op_obj_op X).hom.app j = 𝟙 _ := rfl
@[simp] lemma op_obj_op_inv_app (X : C) (j : Jᵒᵖ) : (op_obj_op X).inv.app j = 𝟙 _ := rfl

def op_obj_unop (X : Cᵒᵖ) :
  (const Jᵒᵖ).obj (unop X) ≅ ((const J).obj X).left_op :=
{ hom := { app := λ j, 𝟙 _ },
  inv := { app := λ j, 𝟙 _ } }

-- Lean needs some help with universes here.
@[simp] lemma op_obj_unop_hom_app (X : Cᵒᵖ) (j : Jᵒᵖ) : (op_obj_unop.{v₁ v₂} X).hom.app j = 𝟙 _ := rfl
@[simp] lemma op_obj_unop_inv_app (X : Cᵒᵖ) (j : Jᵒᵖ) : (op_obj_unop.{v₁ v₂} X).inv.app j = 𝟙 _ := rfl

end const



section
variables {D : Sort u₃} [𝒟 : category.{v₃} D]
include 𝒟

/-- These are actually equal, of course, but not definitionally equal
  (the equality requires F.map (𝟙 _) = 𝟙 _). A natural isomorphism is
  more convenient than an equality between functors (compare id_to_iso). -/
@[simp] def const_comp (X : C) (F : C ⥤ D) :
  (const J).obj X ⋙ F ≅ (const J).obj (F.obj X) :=
{ hom := { app := λ _, 𝟙 _ },
  inv := { app := λ _, 𝟙 _ } }

@[simp] lemma const_comp_hom_app (X : C) (F : C ⥤ D) (j : J) :
  (const_comp J X F).hom.app j = 𝟙 _ := rfl

@[simp] lemma const_comp_inv_app (X : C) (F : C ⥤ D) (j : J) :
  (const_comp J X F).inv.app j = 𝟙 _ := rfl

end

end category_theory.functor
