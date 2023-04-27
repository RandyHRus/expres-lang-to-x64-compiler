#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    cpsc411/langs/v5
    "../compiler.rkt"
    rackunit)

(check-equal? (conflict-analysis '(module
  ((new-frames ())
   (locals (ra.12))
   (call-undead ())
   (undead-out ((ra.12 rbp) (ra.12 fv0 rbp) (fv0 r15 rbp) (fv0 r15 rbp))))
  (define L.fact.4
    ((new-frames ((nfv.16)))
     (locals (ra.13 x.9 tmp.14 tmp.15 new-n.10 nfv.16 factn-1.11 tmp.17))
     (call-undead (x.9 ra.13))
     (undead-out
      ((r15 x.9 rbp)
       (x.9 ra.13 rbp)
       ((x.9 ra.13 rbp)
        ((ra.13 rax rbp) (rax rbp))
        ((tmp.14 x.9 ra.13 rbp)
         (tmp.14 tmp.15 x.9 ra.13 rbp)
         (tmp.15 x.9 ra.13 rbp)
         (new-n.10 x.9 ra.13 rbp)
         ((rax x.9 ra.13 rbp) ((nfv.16 rbp) (nfv.16 r15 rbp) (nfv.16 r15 rbp)))
         (x.9 factn-1.11 ra.13 rbp)
         (factn-1.11 tmp.17 ra.13 rbp)
         (tmp.17 ra.13 rbp)
         (ra.13 rax rbp)
         (rax rbp))))))
    (begin
      (set! x.9 fv0)
      (set! ra.13 r15)
      (if (= x.9 0)
        (begin (set! rax 1) (jump ra.13 rbp rax))
        (begin
          (set! tmp.14 -1)
          (set! tmp.15 x.9)
          (set! tmp.15 (+ tmp.15 tmp.14))
          (set! new-n.10 tmp.15)
          (return-point
           L.rp.6
           (begin
             (set! nfv.16 new-n.10)
             (set! r15 L.rp.6)
             (jump L.fact.4 rbp r15 nfv.16)))
          (set! factn-1.11 rax)
          (set! tmp.17 x.9)
          (set! tmp.17 (* tmp.17 factn-1.11))
          (set! rax tmp.17)
          (jump ra.13 rbp rax)))))
  (begin
    (set! ra.12 r15)
    (set! fv0 5)
    (set! r15 ra.12)
    (jump L.fact.4 rbp r15 fv0))))
              '(module
  ((new-frames ())
   (locals (ra.12))
   (call-undead ())
   (undead-out ((ra.12 rbp) (ra.12 fv0 rbp) (fv0 r15 rbp) (fv0 r15 rbp)))
   (conflicts
    ((ra.12 (fv0 rbp))
     (rbp (r15 fv0 ra.12))
     (fv0 (r15 rbp ra.12))
     (r15 (rbp fv0)))))
  (define L.fact.4
    ((new-frames ((nfv.16)))
     (locals (ra.13 x.9 tmp.14 tmp.15 new-n.10 nfv.16 factn-1.11 tmp.17))
     (undead-out
      ((r15 x.9 rbp)
       (x.9 ra.13 rbp)
       ((x.9 ra.13 rbp)
        ((ra.13 rax rbp) (rax rbp))
        ((tmp.14 x.9 ra.13 rbp)
         (tmp.14 tmp.15 x.9 ra.13 rbp)
         (tmp.15 x.9 ra.13 rbp)
         (new-n.10 x.9 ra.13 rbp)
         ((rax x.9 ra.13 rbp) ((nfv.16 rbp) (nfv.16 r15 rbp) (nfv.16 r15 rbp)))
         (x.9 factn-1.11 ra.13 rbp)
         (factn-1.11 tmp.17 ra.13 rbp)
         (tmp.17 ra.13 rbp)
         (ra.13 rax rbp)
         (rax rbp)))))
     (call-undead (x.9 ra.13))
     (conflicts
      ((tmp.17 (rbp ra.13 factn-1.11))
       (factn-1.11 (tmp.17 rbp ra.13 x.9))
       (nfv.16 (r15 rbp))
       (new-n.10 (rbp ra.13 x.9))
       (tmp.15 (x.9 rbp ra.13 tmp.14))
       (tmp.14 (tmp.15 rbp ra.13 x.9))
       (x.9 (ra.13 rbp r15 factn-1.11 new-n.10 tmp.15 tmp.14))
       (ra.13 (rbp x.9 rax tmp.17 factn-1.11 new-n.10 tmp.15 tmp.14))
       (rbp
        (ra.13 x.9 rax tmp.17 factn-1.11 r15 nfv.16 new-n.10 tmp.15 tmp.14))
       (r15 (x.9 rbp nfv.16))
       (rax (rbp ra.13)))))
    (begin
      (set! x.9 fv0)
      (set! ra.13 r15)
      (if (= x.9 0)
        (begin (set! rax 1) (jump ra.13 rbp rax))
        (begin
          (set! tmp.14 -1)
          (set! tmp.15 x.9)
          (set! tmp.15 (+ tmp.15 tmp.14))
          (set! new-n.10 tmp.15)
          (return-point
           L.rp.6
           (begin
             (set! nfv.16 new-n.10)
             (set! r15 L.rp.6)
             (jump L.fact.4 rbp r15 nfv.16)))
          (set! factn-1.11 rax)
          (set! tmp.17 x.9)
          (set! tmp.17 (* tmp.17 factn-1.11))
          (set! rax tmp.17)
          (jump ra.13 rbp rax)))))
  (begin
    (set! ra.12 r15)
    (set! fv0 5)
    (set! r15 ra.12)
    (jump L.fact.4 rbp r15 fv0))))

(check-equal? (conflict-analysis '(module
  ((locals (x.1 y.1 z.1))
   (new-frames (()))
   (call-undead ())
   (undead-out ((x.1 r15) (y.1 r15) (y.1 r15) (z.1 r15) (z.1 r15) ((r15) ()))))
  (begin
    (set! x.1 1)
    (set! y.1 x.1)
    (set! y.1 (+ y.1 1))
    (set! z.1 y.1)
    (set! z.1 (+ z.1 1))
    (begin (set! rax z.1) (jump r15)))))
              '(module
  ((new-frames (()))
   (locals (x.1 y.1 z.1))
   (call-undead ())
   (undead-out ((x.1 r15) (y.1 r15) (y.1 r15) (z.1 r15) (z.1 r15) ((r15) ())))
   (conflicts
    ((z.1 (r15)) (y.1 (r15)) (x.1 (r15)) (rax (r15)) (r15 (z.1 y.1 x.1 rax)))))
  (begin
    (set! x.1 1)
    (set! y.1 x.1)
    (set! y.1 (+ y.1 1))
    (set! z.1 y.1)
    (set! z.1 (+ z.1 1))
    (begin (set! rax z.1) (jump r15)))))

(check-equal? (conflict-analysis '(module ((new-frames ()) (locals (z.64 y.63 x.62 tmp-ra.117)) (call-undead ()) (undead-out ((rbp tmp-ra.117) (x.62 rbp tmp-ra.117) (x.62 y.63 rbp tmp-ra.117) ((x.62 y.63 rbp tmp-ra.117) ((((z.64 y.63 rbp tmp-ra.117) (rbp tmp-ra.117)) (rbp tmp-ra.117) (rbp tmp-ra.117)) ((rax rbp tmp-ra.117) (rbp rax)) ((rax rbp tmp-ra.117) (rbp rax))) ((y.63 rax rbp tmp-ra.117) (rax rbp tmp-ra.117) (rbp rax)))))) (begin (set! tmp-ra.117 r15) (set! x.62 20) (set! y.63 21) (if (not (> x.62 12)) (if (if (begin (set! z.64 x.62) (< y.63 z.64)) (true) (false)) (begin (set! rax 10) (jump tmp-ra.117 rbp rax)) (begin (set! rax 12) (jump tmp-ra.117 rbp rax))) (begin (set! rax x.62) (set! rax (+ rax y.63)) (jump tmp-ra.117 rbp rax))))))
               '(module
  ((new-frames ())
   (locals (z.64 y.63 x.62 tmp-ra.117))
   (call-undead ())
   (undead-out
    ((rbp tmp-ra.117)
     (x.62 rbp tmp-ra.117)
     (x.62 y.63 rbp tmp-ra.117)
     ((x.62 y.63 rbp tmp-ra.117)
      ((((z.64 y.63 rbp tmp-ra.117) (rbp tmp-ra.117))
        (rbp tmp-ra.117)
        (rbp tmp-ra.117))
       ((rax rbp tmp-ra.117) (rbp rax))
       ((rax rbp tmp-ra.117) (rbp rax)))
      ((y.63 rax rbp tmp-ra.117) (rax rbp tmp-ra.117) (rbp rax)))))
   (conflicts
    ((tmp-ra.117 (y.63 x.62 rbp z.64 rax))
     (x.62 (y.63 tmp-ra.117 rbp))
     (y.63 (tmp-ra.117 rbp x.62 z.64 rax))
     (z.64 (tmp-ra.117 rbp y.63))
     (rax (tmp-ra.117 rbp y.63))
     (rbp (y.63 x.62 tmp-ra.117 z.64 rax)))))
  (begin
    (set! tmp-ra.117 r15)
    (set! x.62 20)
    (set! y.63 21)
    (if (not (> x.62 12))
      (if (if (begin (set! z.64 x.62) (< y.63 z.64)) (true) (false))
        (begin (set! rax 10) (jump tmp-ra.117 rbp rax))
        (begin (set! rax 12) (jump tmp-ra.117 rbp rax)))
      (begin
        (set! rax x.62)
        (set! rax (+ rax y.63))
        (jump tmp-ra.117 rbp rax))))))