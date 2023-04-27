#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    "../compiler.rkt"
    rackunit
    rackunit/text-ui)

(check-equal? (assign-registers '(module
  ((locals (tmp-ra.10))
   (conflicts
    ((tmp-ra.10 (fv0 fv1 rbp))
     (rbp (r15 fv0 fv1 tmp-ra.10))
     (fv1 (r15 fv0 rbp tmp-ra.10))
     (fv0 (r15 rbp fv1 tmp-ra.10))
     (r15 (rbp fv0 fv1))))
   (assignment ()))
  (define L.swap.1
    ((locals (y.2 x.1 z.3))
     (conflicts
      ((y.2 (rbp tmp-ra.7 x.1 nfv.9))
       (x.1 (y.2 rbp tmp-ra.7 fv1))
       (tmp-ra.7 (y.2 x.1 rbp fv1 fv0 rax z.3))
       (z.3 (rbp tmp-ra.7))
       (nfv.9 (r15 nfv.8 rbp y.2))
       (nfv.8 (r15 rbp nfv.9))
       (rbp (y.2 x.1 tmp-ra.7 rax z.3 r15 nfv.8 nfv.9))
       (r15 (rbp nfv.8 nfv.9))
       (rax (rbp tmp-ra.7))
       (fv0 (tmp-ra.7))
       (fv1 (x.1 tmp-ra.7))))
     (assignment ((tmp-ra.7 fv2) (nfv.8 fv3) (nfv.9 fv4))))
    (begin
      (set! tmp-ra.7 r15)
      (set! x.1 fv0)
      (set! y.2 fv1)
      (if (< y.2 x.1)
        (begin (set! rax x.1) (jump tmp-ra.7 rbp rax))
        (begin
          (begin
            (set! rbp (- rbp 24))
            (return-point
             L.rp.3
             (begin
               (set! nfv.9 x.1)
               (set! nfv.8 y.2)
               (set! r15 L.rp.3)
               (jump L.swap.1 rbp r15 nfv.8 nfv.9)))
            (set! rbp (+ rbp 24)))
          (set! z.3 rax)
          (set! rax z.3)
          (jump tmp-ra.7 rbp rax)))))
  (begin
    (set! tmp-ra.10 r15)
    (set! fv1 2)
    (set! fv0 1)
    (set! r15 tmp-ra.10)
    (jump L.swap.1 rbp r15 fv0 fv1))))
              '(module
  ((locals ())
   (conflicts
    ((tmp-ra.10 (fv0 fv1 rbp))
     (rbp (r15 fv0 fv1 tmp-ra.10))
     (fv1 (r15 fv0 rbp tmp-ra.10))
     (fv0 (r15 rbp fv1 tmp-ra.10))
     (r15 (rbp fv0 fv1))))
   (assignment ((tmp-ra.10 r15))))
  (define L.swap.1
    ((locals ())
     (conflicts
      ((y.2 (rbp tmp-ra.7 x.1 nfv.9))
       (x.1 (y.2 rbp tmp-ra.7 fv1))
       (tmp-ra.7 (y.2 x.1 rbp fv1 fv0 rax z.3))
       (z.3 (rbp tmp-ra.7))
       (nfv.9 (r15 nfv.8 rbp y.2))
       (nfv.8 (r15 rbp nfv.9))
       (rbp (y.2 x.1 tmp-ra.7 rax z.3 r15 nfv.8 nfv.9))
       (r15 (rbp nfv.8 nfv.9))
       (rax (rbp tmp-ra.7))
       (fv0 (tmp-ra.7))
       (fv1 (x.1 tmp-ra.7))))
     (assignment
      ((tmp-ra.7 fv2) (nfv.8 fv3) (nfv.9 fv4) (x.1 r15) (y.2 r14) (z.3 r15))))
    (begin
      (set! tmp-ra.7 r15)
      (set! x.1 fv0)
      (set! y.2 fv1)
      (if (< y.2 x.1)
        (begin (set! rax x.1) (jump tmp-ra.7 rbp rax))
        (begin
          (begin
            (set! rbp (- rbp 24))
            (return-point
             L.rp.3
             (begin
               (set! nfv.9 x.1)
               (set! nfv.8 y.2)
               (set! r15 L.rp.3)
               (jump L.swap.1 rbp r15 nfv.8 nfv.9)))
            (set! rbp (+ rbp 24)))
          (set! z.3 rax)
          (set! rax z.3)
          (jump tmp-ra.7 rbp rax)))))
  (begin
    (set! tmp-ra.10 r15)
    (set! fv1 2)
    (set! fv0 1)
    (set! r15 tmp-ra.10)
    (jump L.swap.1 rbp r15 fv0 fv1))))

(check-equal? (parameterize ([current-assignable-registers '(r15)]) (assign-registers '(module
  ((locals (tmp-ra.10))
   (conflicts
    ((tmp-ra.10 (fv0 fv1 rbp))
     (rbp (r15 fv0 fv1 tmp-ra.10))
     (fv1 (r15 fv0 rbp tmp-ra.10))
     (fv0 (r15 rbp fv1 tmp-ra.10))
     (r15 (rbp fv0 fv1))))
   (assignment ()))
  (define L.swap.1
    ((locals (y.2 x.1 z.3))
     (conflicts
      ((y.2 (rbp tmp-ra.7 x.1 nfv.9))
       (x.1 (y.2 rbp tmp-ra.7 fv1))
       (tmp-ra.7 (y.2 x.1 rbp fv1 fv0 rax z.3))
       (z.3 (rbp tmp-ra.7))
       (nfv.9 (r15 nfv.8 rbp y.2))
       (nfv.8 (r15 rbp nfv.9))
       (rbp (y.2 x.1 tmp-ra.7 rax z.3 r15 nfv.8 nfv.9))
       (r15 (rbp nfv.8 nfv.9))
       (rax (rbp tmp-ra.7))
       (fv0 (tmp-ra.7))
       (fv1 (x.1 tmp-ra.7))))
     (assignment ((tmp-ra.7 fv2) (nfv.8 fv3) (nfv.9 fv4))))
    (begin
      (set! tmp-ra.7 r15)
      (set! x.1 fv0)
      (set! y.2 fv1)
      (if (< y.2 x.1)
        (begin (set! rax x.1) (jump tmp-ra.7 rbp rax))
        (begin
          (begin
            (set! rbp (- rbp 24))
            (return-point
             L.rp.3
             (begin
               (set! nfv.9 x.1)
               (set! nfv.8 y.2)
               (set! r15 L.rp.3)
               (jump L.swap.1 rbp r15 nfv.8 nfv.9)))
            (set! rbp (+ rbp 24)))
          (set! z.3 rax)
          (set! rax z.3)
          (jump tmp-ra.7 rbp rax)))))
  (begin
    (set! tmp-ra.10 r15)
    (set! fv1 2)
    (set! fv0 1)
    (set! r15 tmp-ra.10)
    (jump L.swap.1 rbp r15 fv0 fv1)))))
              '(module
  ((locals ())
   (conflicts
    ((tmp-ra.10 (fv0 fv1 rbp))
     (rbp (r15 fv0 fv1 tmp-ra.10))
     (fv1 (r15 fv0 rbp tmp-ra.10))
     (fv0 (r15 rbp fv1 tmp-ra.10))
     (r15 (rbp fv0 fv1))))
   (assignment ((tmp-ra.10 r15))))
  (define L.swap.1
    ((locals (y.2))
     (conflicts
      ((y.2 (rbp tmp-ra.7 x.1 nfv.9))
       (x.1 (y.2 rbp tmp-ra.7 fv1))
       (tmp-ra.7 (y.2 x.1 rbp fv1 fv0 rax z.3))
       (z.3 (rbp tmp-ra.7))
       (nfv.9 (r15 nfv.8 rbp y.2))
       (nfv.8 (r15 rbp nfv.9))
       (rbp (y.2 x.1 tmp-ra.7 rax z.3 r15 nfv.8 nfv.9))
       (r15 (rbp nfv.8 nfv.9))
       (rax (rbp tmp-ra.7))
       (fv0 (tmp-ra.7))
       (fv1 (x.1 tmp-ra.7))))
     (assignment ((tmp-ra.7 fv2) (nfv.8 fv3) (nfv.9 fv4) (x.1 r15) (z.3 r15))))
    (begin
      (set! tmp-ra.7 r15)
      (set! x.1 fv0)
      (set! y.2 fv1)
      (if (< y.2 x.1)
        (begin (set! rax x.1) (jump tmp-ra.7 rbp rax))
        (begin
          (begin
            (set! rbp (- rbp 24))
            (return-point
             L.rp.3
             (begin
               (set! nfv.9 x.1)
               (set! nfv.8 y.2)
               (set! r15 L.rp.3)
               (jump L.swap.1 rbp r15 nfv.8 nfv.9)))
            (set! rbp (+ rbp 24)))
          (set! z.3 rax)
          (set! rax z.3)
          (jump tmp-ra.7 rbp rax)))))
  (begin
    (set! tmp-ra.10 r15)
    (set! fv1 2)
    (set! fv0 1)
    (set! r15 tmp-ra.10)
    (jump L.swap.1 rbp r15 fv0 fv1))))

(check-equal? (parameterize ([current-assignable-registers '()]) (assign-registers '(module
  ((locals (tmp-ra.10))
   (conflicts
    ((tmp-ra.10 (fv0 fv1 rbp))
     (rbp (r15 fv0 fv1 tmp-ra.10))
     (fv1 (r15 fv0 rbp tmp-ra.10))
     (fv0 (r15 rbp fv1 tmp-ra.10))
     (r15 (rbp fv0 fv1))))
   (assignment ()))
  (define L.swap.1
    ((locals (y.2 x.1 z.3))
     (conflicts
      ((y.2 (rbp tmp-ra.7 x.1 nfv.9))
       (x.1 (y.2 rbp tmp-ra.7 fv1))
       (tmp-ra.7 (y.2 x.1 rbp fv1 fv0 rax z.3))
       (z.3 (rbp tmp-ra.7))
       (nfv.9 (r15 nfv.8 rbp y.2))
       (nfv.8 (r15 rbp nfv.9))
       (rbp (y.2 x.1 tmp-ra.7 rax z.3 r15 nfv.8 nfv.9))
       (r15 (rbp nfv.8 nfv.9))
       (rax (rbp tmp-ra.7))
       (fv0 (tmp-ra.7))
       (fv1 (x.1 tmp-ra.7))))
     (assignment ((tmp-ra.7 fv2) (nfv.8 fv3) (nfv.9 fv4))))
    (begin
      (set! tmp-ra.7 r15)
      (set! x.1 fv0)
      (set! y.2 fv1)
      (if (< y.2 x.1)
        (begin (set! rax x.1) (jump tmp-ra.7 rbp rax))
        (begin
          (begin
            (set! rbp (- rbp 24))
            (return-point
             L.rp.3
             (begin
               (set! nfv.9 x.1)
               (set! nfv.8 y.2)
               (set! r15 L.rp.3)
               (jump L.swap.1 rbp r15 nfv.8 nfv.9)))
            (set! rbp (+ rbp 24)))
          (set! z.3 rax)
          (set! rax z.3)
          (jump tmp-ra.7 rbp rax)))))
  (begin
    (set! tmp-ra.10 r15)
    (set! fv1 2)
    (set! fv0 1)
    (set! r15 tmp-ra.10)
    (jump L.swap.1 rbp r15 fv0 fv1)))))
              '(module
  ((locals (tmp-ra.10))
   (conflicts
    ((tmp-ra.10 (fv0 fv1 rbp))
     (rbp (r15 fv0 fv1 tmp-ra.10))
     (fv1 (r15 fv0 rbp tmp-ra.10))
     (fv0 (r15 rbp fv1 tmp-ra.10))
     (r15 (rbp fv0 fv1))))
   (assignment ()))
  (define L.swap.1
    ((locals (z.3 y.2 x.1))
     (conflicts
      ((y.2 (rbp tmp-ra.7 x.1 nfv.9))
       (x.1 (y.2 rbp tmp-ra.7 fv1))
       (tmp-ra.7 (y.2 x.1 rbp fv1 fv0 rax z.3))
       (z.3 (rbp tmp-ra.7))
       (nfv.9 (r15 nfv.8 rbp y.2))
       (nfv.8 (r15 rbp nfv.9))
       (rbp (y.2 x.1 tmp-ra.7 rax z.3 r15 nfv.8 nfv.9))
       (r15 (rbp nfv.8 nfv.9))
       (rax (rbp tmp-ra.7))
       (fv0 (tmp-ra.7))
       (fv1 (x.1 tmp-ra.7))))
     (assignment ((tmp-ra.7 fv2) (nfv.8 fv3) (nfv.9 fv4))))
    (begin
      (set! tmp-ra.7 r15)
      (set! x.1 fv0)
      (set! y.2 fv1)
      (if (< y.2 x.1)
        (begin (set! rax x.1) (jump tmp-ra.7 rbp rax))
        (begin
          (begin
            (set! rbp (- rbp 24))
            (return-point
             L.rp.3
             (begin
               (set! nfv.9 x.1)
               (set! nfv.8 y.2)
               (set! r15 L.rp.3)
               (jump L.swap.1 rbp r15 nfv.8 nfv.9)))
            (set! rbp (+ rbp 24)))
          (set! z.3 rax)
          (set! rax z.3)
          (jump tmp-ra.7 rbp rax)))))
  (begin
    (set! tmp-ra.10 r15)
    (set! fv1 2)
    (set! fv0 1)
    (set! r15 tmp-ra.10)
    (jump L.swap.1 rbp r15 fv0 fv1))))