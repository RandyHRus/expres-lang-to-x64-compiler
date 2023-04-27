#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    cpsc411/langs/v5
    "../compiler.rkt"
    rackunit)

(check-equal? (assign-frame-variables `(module
  ((locals (x.1 tmp-ra.4 y.2 z.3))
   (conflicts
    ((tmp-ra.4 (fv0 fv1 rbp))
     (x.1 (fv0 z.3))
     (y.2 (fv0))
     (z.3 (fv0 x.1))
     (rbp (r15 fv0 fv1 tmp-ra.4))
     (fv1 (r15 fv0 rbp tmp-ra.4))
     (fv0 (r15 rbp fv1 tmp-ra.4))
     (r15 (rbp fv0 fv1))))
   (assignment ((tmp-ra.4 r15) (z.3 r9))))
  (define L.swap.1
    ((locals ())
     (conflicts
      ((y.2 (rbp tmp-ra.1 x.1 nfv.3))
       (x.1 (y.2 rbp tmp-ra.1 fv1))
       (tmp-ra.1 (y.2 x.1 rbp fv1 fv0 rax z.3))
       (z.3 (rbp tmp-ra.1))
       (nfv.3 (r15 nfv.2 rbp y.2))
       (nfv.2 (r15 rbp nfv.3))
       (rbp (y.2 x.1 tmp-ra.1 rax z.3 r15 nfv.2 nfv.3))
       (r15 (rbp nfv.2 nfv.3))
       (rax (rbp tmp-ra.1))
       (fv0 (tmp-ra.1))
       (fv1 (x.1 tmp-ra.1))))
     (assignment
      ((tmp-ra.1 fv2) (nfv.2 fv3) (nfv.3 fv4) (y.2 r15) (x.1 r14) (z.3 r15))))
    (begin
      (set! tmp-ra.1 r15)
      (set! x.1 fv0)
      (set! y.2 fv1)
      (if (< y.2 x.1)
        (begin (set! rax x.1) (jump tmp-ra.1 rbp rax))
        (begin
          (begin
            (set! rbp (- rbp 24))
            (return-point L.rp.1
              (begin
                (set! nfv.3 x.1)
                (set! nfv.2 y.2)
                (set! r15 L.rp.1)
                (jump L.swap.1 rbp r15 nfv.2 nfv.3)))
            (set! rbp (+ rbp 24)))
          (set! z.3 rax)
          (set! rax z.3)
          (jump tmp-ra.1 rbp rax)))))
  (begin
    (set! tmp-ra.4 r15)
    (set! fv1 2)
    (set! fv0 1)
    (set! r15 tmp-ra.4)
    (jump L.swap.1 rbp r15 fv0 fv1))))
    `(module
  ((locals (x.1 tmp-ra.4 y.2 z.3))
   (conflicts
    ((tmp-ra.4 (fv0 fv1 rbp))
     (x.1 (fv0 z.3))
     (y.2 (fv0))
     (z.3 (fv0 x.1))
     (rbp (r15 fv0 fv1 tmp-ra.4))
     (fv1 (r15 fv0 rbp tmp-ra.4))
     (fv0 (r15 rbp fv1 tmp-ra.4))
     (r15 (rbp fv0 fv1))))
   (assignment ((tmp-ra.4 fv2) (z.3 fv1) (y.2 fv1) (x.1 fv2))))
  (define L.swap.1
    ((locals ())
     (conflicts
      ((y.2 (rbp tmp-ra.1 x.1 nfv.3))
       (x.1 (y.2 rbp tmp-ra.1 fv1))
       (tmp-ra.1 (y.2 x.1 rbp fv1 fv0 rax z.3))
       (z.3 (rbp tmp-ra.1))
       (nfv.3 (r15 nfv.2 rbp y.2))
       (nfv.2 (r15 rbp nfv.3))
       (rbp (y.2 x.1 tmp-ra.1 rax z.3 r15 nfv.2 nfv.3))
       (r15 (rbp nfv.2 nfv.3))
       (rax (rbp tmp-ra.1))
       (fv0 (tmp-ra.1))
       (fv1 (x.1 tmp-ra.1))))
     (assignment
      ((tmp-ra.1 fv2) (nfv.2 fv3) (nfv.3 fv4) (y.2 r15) (x.1 r14) (z.3 r15))))
    (begin
      (set! tmp-ra.1 r15)
      (set! x.1 fv0)
      (set! y.2 fv1)
      (if (< y.2 x.1)
        (begin (set! rax x.1) (jump tmp-ra.1 rbp rax))
        (begin
          (begin
            (set! rbp (- rbp 24))
            (return-point
             L.rp.1
             (begin
               (set! nfv.3 x.1)
               (set! nfv.2 y.2)
               (set! r15 L.rp.1)
               (jump L.swap.1 rbp r15 nfv.2 nfv.3)))
            (set! rbp (+ rbp 24)))
          (set! z.3 rax)
          (set! rax z.3)
          (jump tmp-ra.1 rbp rax)))))
  (begin
    (set! tmp-ra.4 r15)
    (set! fv1 2)
    (set! fv0 1)
    (set! r15 tmp-ra.4)
    (jump L.swap.1 rbp r15 fv0 fv1))))

(check-equal? (assign-frame-variables '(module
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
    `(module
  ((locals (tmp-ra.10))
   (conflicts
    ((tmp-ra.10 (fv0 fv1 rbp))
     (rbp (r15 fv0 fv1 tmp-ra.10))
     (fv1 (r15 fv0 rbp tmp-ra.10))
     (fv0 (r15 rbp fv1 tmp-ra.10))
     (r15 (rbp fv0 fv1))))
   (assignment ((tmp-ra.10 fv2))))
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
     (assignment
      ((tmp-ra.7 fv2) (nfv.8 fv3) (nfv.9 fv4) (x.1 fv0) (y.2 fv1) (z.3 fv0))))
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

    (check-equal? 
      (assign-frame-variables 
        '(module 
          ((locals ()) 
            (conflicts 
              ((tmp-ra.153 (rdi rbp)) 
              (rbp (r15 rdi tmp-ra.153)) 
              (rdi (r15 rbp tmp-ra.153)) 
              (r15 (rbp rdi)))) 
            (assignment ((tmp-ra.153 r15)))) 
          (define L.odd?.11 
            ((locals ()) 
              (conflicts 
                ((tmp-ra.151 (y.90 rax x.89 rbp rdi)) 
                (rdi (r15 rbp tmp-ra.151)) 
                (rbp (r15 rdi y.90 rax x.89 tmp-ra.151)) 
                (x.89 (tmp-ra.151 rbp)) 
                (rax (tmp-ra.151 rbp)) 
                (y.90 (rbp tmp-ra.151)) 
                (r15 (rbp rdi)))) 
              (assignment ((x.89 r14) (y.90 r14) (tmp-ra.151 r15)))) 
            (begin 
              (set! tmp-ra.151 r15) 
              (set! x.89 rdi) 
              (if (= x.89 0) 
                (begin (set! rax 0) (jump tmp-ra.151 rbp rax)) 
                (begin (set! y.90 x.89) (set! y.90 (+ y.90 -1)) (set! rdi y.90) (set! r15 tmp-ra.151) (jump L.even?.12 rbp r15 rdi))))) 
          (define L.even?.12 
            ((locals ()) 
              (conflicts 
                ((tmp-ra.152 (y.92 rax x.91 rbp rdi)) 
                (rdi (r15 rbp tmp-ra.152)) 
                (rbp (r15 rdi y.92 rax x.91 tmp-ra.152)) 
                (x.91 (tmp-ra.152 rbp)) 
                (rax (tmp-ra.152 rbp)) 
                (y.92 (rbp tmp-ra.152)) 
                (r15 (rbp rdi)))) 
              (assignment ((x.91 r14) (y.92 r14) (tmp-ra.152 r15)))) 
            (begin 
              (set! tmp-ra.152 r15) 
              (set! x.91 rdi) 
              (if (= x.91 0) 
                (begin (set! rax 1) (jump tmp-ra.152 rbp rax)) 
                (begin (set! y.92 x.91) (set! y.92 (+ y.92 -1)) (set! rdi y.92) (set! r15 tmp-ra.152) (jump L.odd?.11 rbp r15 rdi))))) 
          (begin (set! tmp-ra.153 r15) (set! rdi 5) (set! r15 tmp-ra.153) (jump L.even?.12 rbp r15 rdi))) ) 
        '(module 
          ((locals ()) 
            (conflicts ((tmp-ra.153 (rdi rbp)) (rbp (r15 rdi tmp-ra.153)) (rdi (r15 rbp tmp-ra.153)) (r15 (rbp rdi)))) 
            (assignment ((tmp-ra.153 r15)))) 
          (define L.odd?.11 
            ((locals ()) 
              (conflicts 
                ((tmp-ra.151 (y.90 rax x.89 rbp rdi)) 
                (rdi (r15 rbp tmp-ra.151)) 
                (rbp (r15 rdi y.90 rax x.89 tmp-ra.151)) 
                (x.89 (tmp-ra.151 rbp)) 
                (rax (tmp-ra.151 rbp)) 
                (y.90 (rbp tmp-ra.151)) 
                (r15 (rbp rdi)))) 
              (assignment ((x.89 r14) (y.90 r14) (tmp-ra.151 r15)))) 
            (begin 
              (set! tmp-ra.151 r15) 
              (set! x.89 rdi) 
              (if (= x.89 0) 
                (begin (set! rax 0) (jump tmp-ra.151 rbp rax)) 
                (begin (set! y.90 x.89) (set! y.90 (+ y.90 -1)) (set! rdi y.90) (set! r15 tmp-ra.151) (jump L.even?.12 rbp r15 rdi))))) 
          (define L.even?.12 
            ((locals ()) 
              (conflicts 
                ((tmp-ra.152 (y.92 rax x.91 rbp rdi)) 
                (rdi (r15 rbp tmp-ra.152)) 
                (rbp (r15 rdi y.92 rax x.91 tmp-ra.152)) 
                (x.91 (tmp-ra.152 rbp)) 
                (rax (tmp-ra.152 rbp)) 
                (y.92 (rbp tmp-ra.152)) 
                (r15 (rbp rdi)))) 
              (assignment ((x.91 r14) (y.92 r14) (tmp-ra.152 r15)))) 
            (begin 
              (set! tmp-ra.152 r15) 
              (set! x.91 rdi) 
              (if (= x.91 0) 
                (begin (set! rax 1) (jump tmp-ra.152 rbp rax)) 
                (begin (set! y.92 x.91) (set! y.92 (+ y.92 -1)) (set! rdi y.92) (set! r15 tmp-ra.152) (jump L.odd?.11 rbp r15 rdi))))) 
          (begin (set! tmp-ra.153 r15) (set! rdi 5) (set! r15 tmp-ra.153) (jump L.even?.12 rbp r15 rdi))))