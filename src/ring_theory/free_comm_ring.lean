import group_theory.free_abelian_group data.equiv.algebra data.polynomial ring_theory.ideal_operations

universes u v

def free_comm_ring (α : Type u) : Type u :=
free_abelian_group $ multiset α

namespace free_comm_ring

variables (α : Type u)

instance : add_comm_group (free_comm_ring α) :=
{ .. free_abelian_group.add_comm_group (multiset α) }

instance : semigroup (free_comm_ring α) :=
{ mul := λ x, free_abelian_group.lift $ λ s2, free_abelian_group.lift (λ s1, free_abelian_group.of $ s1 + s2) x,
  mul_assoc := λ x y z, begin
    unfold has_mul.mul,
    refine free_abelian_group.induction_on z rfl _ _ _,
    { intros s3, rw [free_abelian_group.lift.of, free_abelian_group.lift.of],
      refine free_abelian_group.induction_on y rfl _ _ _,
      { intros s2, iterate 3 { rw free_abelian_group.lift.of },
        refine free_abelian_group.induction_on x rfl _ _ _,
        { intros s1, iterate 3 { rw free_abelian_group.lift.of }, rw add_assoc },
        { intros s1 ih, iterate 3 { rw free_abelian_group.lift.neg }, rw ih },
        { intros x1 x2 ih1 ih2, iterate 3 { rw free_abelian_group.lift.add }, rw [ih1, ih2] } },
      { intros s2 ih, iterate 4 { rw free_abelian_group.lift.neg }, rw ih },
      { intros y1 y2 ih1 ih2, iterate 4 { rw free_abelian_group.lift.add }, rw [ih1, ih2] } },
    { intros s3 ih, iterate 3 { rw free_abelian_group.lift.neg }, rw ih },
    { intros z1 z2 ih1 ih2, iterate 2 { rw free_abelian_group.lift.add }, rw [ih1, ih2],
      exact (free_abelian_group.lift.add _ _ _).symm }
  end }

instance : ring (free_comm_ring α) :=
{ one := free_abelian_group.of 0,
  mul_one := λ x, begin
    unfold has_mul.mul semigroup.mul has_one.one,
    rw free_abelian_group.lift.of,
    refine free_abelian_group.induction_on x rfl _ _ _,
    { intros s, rw [free_abelian_group.lift.of, add_zero] },
    { intros s ih, rw [free_abelian_group.lift.neg, ih] },
    { intros x1 x2 ih1 ih2, rw [free_abelian_group.lift.add, ih1, ih2] }
  end,
  one_mul := λ x, begin
    unfold has_mul.mul semigroup.mul has_one.one,
    refine free_abelian_group.induction_on x rfl _ _ _,
    { intros s, rw [free_abelian_group.lift.of, free_abelian_group.lift.of, zero_add] },
    { intros s ih, rw [free_abelian_group.lift.neg, ih] },
    { intros x1 x2 ih1 ih2, rw [free_abelian_group.lift.add, ih1, ih2] }
  end,
  left_distrib := λ x y z, free_abelian_group.lift.add _ _ _,
  right_distrib := λ x y z, begin
    unfold has_mul.mul semigroup.mul,
    refine free_abelian_group.induction_on z rfl _ _ _,
    { intros s, iterate 3 { rw free_abelian_group.lift.of }, rw free_abelian_group.lift.add, refl },
    { intros s ih, iterate 3 { rw free_abelian_group.lift.neg }, rw [ih, neg_add], refl },
    { intros z1 z2 ih1 ih2, iterate 3 { rw free_abelian_group.lift.add }, rw [ih1, ih2],
      rw [add_assoc, add_assoc], congr' 1, apply add_left_comm }
  end,
  .. free_comm_ring.add_comm_group α,
  .. free_comm_ring.semigroup α }

instance : comm_ring (free_comm_ring α) :=
{ mul_comm := λ x y, begin
    refine free_abelian_group.induction_on x (zero_mul y) _ _ _,
    { intros s, refine free_abelian_group.induction_on y (zero_mul _).symm _ _ _,
      { intros t, unfold has_mul.mul semigroup.mul ring.mul,
        iterate 4 { rw free_abelian_group.lift.of }, rw add_comm },
      { intros t ih, rw [mul_neg_eq_neg_mul_symm, ih, neg_mul_eq_neg_mul] },
      { intros y1 y2 ih1 ih2, rw [mul_add, add_mul, ih1, ih2] } },
    { intros s ih, rw [neg_mul_eq_neg_mul_symm, ih, neg_mul_eq_mul_neg] },
    { intros x1 x2 ih1 ih2, rw [add_mul, mul_add, ih1, ih2] }
  end
  .. free_comm_ring.ring α }

variables {α}
def of (x : α) : free_comm_ring α :=
free_abelian_group.of [x]

@[elab_as_eliminator] protected lemma induction_on
  {C : free_comm_ring α → Prop} (z : free_comm_ring α)
  (hn1 : C (-1)) (hb : ∀ b, C (of b))
  (ha : ∀ x y, C x → C y → C (x + y))
  (hm : ∀ x y, C x → C y → C (x * y)) : C z :=
have hn : ∀ x, C x → C (-x), from λ x ih, neg_one_mul x ▸ hm _ _ hn1 ih,
have h1 : C 1, from neg_neg (1 : free_comm_ring α) ▸ hn _ hn1,
free_abelian_group.induction_on z
  (add_left_neg (1 : free_comm_ring α) ▸ ha _ _ hn1 h1)
  (λ m, multiset.induction_on m h1 $ λ a m ih, hm _ _ (hb a) ih)
  (λ m ih, hn _ ih)
  ha
section lift

variables {β : Type v} [comm_ring β] (f : α → β)

def lift : free_comm_ring α → β :=
free_abelian_group.lift $ λ s, (s.map f).prod

@[simp] lemma lift_zero : lift f 0 = 0 := rfl

@[simp] lemma lift_one : lift f 1 = 1 :=
free_abelian_group.lift.of _ _

@[simp] lemma lift_of (x : α) : lift f (of x) = f x :=
(free_abelian_group.lift.of _ _).trans $ mul_one _

@[simp] lemma lift_add (x y) : lift f (x + y) = lift f x + lift f y :=
free_abelian_group.lift.add _ _ _

@[simp] lemma lift_neg (x) : lift f (-x) = -lift f x :=
free_abelian_group.lift.neg _ _

@[simp] lemma lift_sub (x y) : lift f (x - y) = lift f x - lift f y :=
free_abelian_group.lift.sub _ _ _

@[simp] lemma lift_mul (x y) : lift f (x * y) = lift f x * lift f y :=
begin
  refine free_abelian_group.induction_on y (mul_zero _).symm _ _ _,
  { intros s2, conv { to_lhs, dsimp only [(*), mul_zero_class.mul, semiring.mul, ring.mul, semigroup.mul] },
    rw [free_abelian_group.lift.of, lift, free_abelian_group.lift.of],
    refine free_abelian_group.induction_on x (zero_mul _).symm _ _ _,
    { intros s1, iterate 3 { rw free_abelian_group.lift.of }, rw [multiset.map_add, multiset.prod_add] },
    { intros s1 ih, iterate 3 { rw free_abelian_group.lift.neg }, rw [ih, neg_mul_eq_neg_mul] },
    { intros x1 x2 ih1 ih2, iterate 3 { rw free_abelian_group.lift.add }, rw [ih1, ih2, add_mul] } },
  { intros s2 ih, rw [mul_neg_eq_neg_mul_symm, lift_neg, lift_neg, mul_neg_eq_neg_mul_symm, ih] },
  { intros y1 y2 ih1 ih2, rw [mul_add, lift_add, lift_add, mul_add, ih1, ih2] },
end

instance : is_ring_hom (lift f) :=
{ map_one := lift_one f,
  map_mul := lift_mul f,
  map_add := lift_add f }

@[simp] lemma lift_pow (x) (n : ℕ) : lift f (x ^ n) = lift f x ^ n :=
is_semiring_hom.map_pow _ x n

@[simp] lemma lift_comp_of (f : free_comm_ring α → β) [is_ring_hom f] : lift (f ∘ of) = f :=
funext $ λ x, free_comm_ring.induction_on x
  (by rw [lift_neg, lift_one, is_ring_hom.map_neg f, is_ring_hom.map_one f])
  (lift_of _)
  (λ x y ihx ihy, by rw [lift_add, is_ring_hom.map_add f, ihx, ihy])
  (λ x y ihx ihy, by rw [lift_mul, is_ring_hom.map_mul f, ihx, ihy])

end lift

variables {β : Type v} (f : α → β)

def map : free_comm_ring α → free_comm_ring β :=
lift $ of ∘ f

@[simp] lemma map_zero : map f 0 = 0 := rfl
@[simp] lemma map_one : map f 1 = 1 := rfl
@[simp] lemma map_of (x : α) : map f (of x) = of (f x) := lift_of _ _
@[simp] lemma map_add (x y) : map f (x + y) = map f x + map f y := lift_add _ _ _
@[simp] lemma map_neg (x) : map f (-x) = -map f x := lift_neg _ _
@[simp] lemma map_sub (x y) : map f (x - y) = map f x - map f y := lift_sub _ _ _
@[simp] lemma map_mul (x y) : map f (x * y) = map f x * map f y := lift_mul _ _ _
@[simp] lemma map_pow (x) (n : ℕ) : map f (x ^ n) = (map f x) ^ n := lift_pow _ _ _

end free_comm_ring

def free_comm_ring_pempty_equiv_int : free_comm_ring pempty.{u+1} ≃r ℤ :=
{ to_fun := free_comm_ring.lift $ pempty.rec _,
  inv_fun := coe,
  left_inv := λ x, free_abelian_group.induction_on x rfl
    (λ s, multiset.induction_on s rfl $ pempty.rec _)
    (λ s ih, by rw [free_comm_ring.lift_neg, int.cast_neg, ih])
    (λ x1 x2 ih1 ih2, by rw [free_comm_ring.lift_add, int.cast_add, ih1, ih2]),
  right_inv := λ i, int.induction_on i rfl
    (λ i ih, by rw [int.cast_add, int.cast_one, free_comm_ring.lift_add, free_comm_ring.lift_one, ih])
    (λ i ih, by rw [int.cast_sub, int.cast_one, free_comm_ring.lift_sub, free_comm_ring.lift_one, ih]),
  hom := by apply_instance }

def free_comm_ring_punit_equiv_polynomial_int : free_comm_ring punit.{u+1} ≃r polynomial ℤ :=
{ to_fun := free_comm_ring.lift $ λ _, polynomial.X,
  inv_fun := polynomial.eval₂ coe (free_comm_ring.of punit.star),
  left_inv := λ x, begin
    haveI : is_semiring_hom (coe : int → free_comm_ring punit.{u+1}) :=
      @@is_ring_hom.is_semiring_hom _ _ _ (@@int.cast.is_ring_hom _),
    exact free_abelian_group.induction_on x rfl
    (λ s, multiset.induction_on s rfl $ λ hd tl ih, show polynomial.eval₂ coe (free_comm_ring.of punit.star)
          (free_comm_ring.lift (λ (_x : punit), polynomial.X) (free_comm_ring.of hd * free_abelian_group.of tl)) =
        free_comm_ring.of hd * free_abelian_group.of tl,
      by cases hd; rw [free_comm_ring.lift_mul, free_comm_ring.lift_of, polynomial.eval₂_mul, polynomial.eval₂_X, ih])
    (λ s ih, by rw [free_comm_ring.lift_neg, ← neg_one_mul, polynomial.eval₂_mul,
        ← polynomial.C_1, ← polynomial.C_neg, polynomial.eval₂_C,
        int.cast_neg, int.cast_one, neg_one_mul, ih])
    (λ x1 x2 ih1 ih2, by rw [free_comm_ring.lift_add, polynomial.eval₂_add, ih1, ih2])
  end,
  right_inv := λ x, begin
    haveI : is_semiring_hom (coe : int → free_comm_ring punit.{u+1}) :=
      @@is_ring_hom.is_semiring_hom _ _ _ (@@int.cast.is_ring_hom _),
    have : ∀ i : ℤ, free_comm_ring.lift (λ _ : punit, polynomial.X) ↑i = polynomial.C i,
    { exact λ i, int.induction_on i
      (by rw [int.cast_zero, free_comm_ring.lift_zero, polynomial.C_0])
      (λ i ih, by rw [int.cast_add, int.cast_one, free_comm_ring.lift_add, free_comm_ring.lift_one, ih, polynomial.C_add, polynomial.C_1])
      (λ i ih, by rw [int.cast_sub, int.cast_one, free_comm_ring.lift_sub, free_comm_ring.lift_one, ih, polynomial.C_sub, polynomial.C_1]) },
    exact polynomial.induction_on x
    (λ i, by rw [polynomial.eval₂_C, this])
    (λ p q ihp ihq, by rw [polynomial.eval₂_add, free_comm_ring.lift_add, ihp, ihq])
    (λ n i ih, by rw [polynomial.eval₂_mul, polynomial.eval₂_pow, polynomial.eval₂_C, polynomial.eval₂_X,
        free_comm_ring.lift_mul, free_comm_ring.lift_pow, free_comm_ring.lift_of, this])
  end,
  hom := by apply_instance }
