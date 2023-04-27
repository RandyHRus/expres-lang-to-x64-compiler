#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    "../compiler.rkt"
    rackunit
    rackunit/text-ui)

(parameterize ([current-parameter-registers '()])
  (check-equal?
    (allocate-frames
      '(module(
    (new-frames
    ((nfv.12 nfv.13 nfv.14 nfv.15 nfv.16 nfv.17 nfv.18 nfv.19)
     (nfv.3 nfv.4 nfv.5 nfv.6 nfv.7 nfv.8 nfv.9 nfv.10 nfv.11)))
   (locals
    (x.1
     nfv.3
     nfv.4
     nfv.5
     nfv.6
     nfv.7
     nfv.8
     nfv.9
     nfv.10
     nfv.11
     z.10
     nfv.12
     nfv.13
     nfv.14
     nfv.15
     nfv.16
     nfv.17
     nfv.18
     nfv.19))
   (call-undead (y.2 z.3 x.4 y.5 z.6 x.7 y.8 y.9 tmp-ra.2))
   (conflicts ())
   (assignment
    ((tmp-ra.2 fv0)
     (y.9 fv1)
     (y.8 fv1)
     (x.7 fv1)
     (z.6 fv1)
     (y.5 fv1)
     (x.4 fv1)
     (z.3 fv1)
     (y.2 fv1))))
  (define L.start.1
    ((new-frames ())
     (locals (x.1 tmp-ra.1 y.2 z.3 x.4 y.5 z.6 x.7 y.8 y.9 z.10))
     (call-undead ())
     (conflicts ())
     (assignment ()))
    (begin
      (set! tmp-ra.1 r15)
      (set! x.1 fv0)
      (set! y.2 fv1)
      (set! z.3 fv2)
      (set! x.4 fv3)
      (set! y.5 fv4)
      (set! z.6 fv5)
      (set! x.7 fv6)
      (set! y.8 fv7)
      (set! y.9 fv8)
      (set! z.10 fv9)
      (set! fv0 y.2)
      (set! r15 tmp-ra.1)
      (jump x.1 rbp r15 fv0)))
  (begin
    (set! tmp-ra.2 r15)
    (return-point L.rp.1
      (begin
        (set! nfv.11 z.10)
        (set! nfv.10 y.9)
        (set! nfv.9 y.8)
        (set! nfv.8 x.7)
        (set! nfv.7 z.6)
        (set! nfv.6 y.5)
        (set! nfv.5 x.4)
        (set! nfv.4 z.3)
        (set! nfv.3 y.2)
        (set! r15 L.rp.1)
        (jump
         x.1
         rbp
         r15
         nfv.3
         nfv.4
         nfv.5
         nfv.6
         nfv.7
         nfv.8
         nfv.9
         nfv.10
         nfv.11)))
    (set! x.1 rax)
    (return-point L.rp.2
      (begin
        (set! nfv.19 y.9)
        (set! nfv.18 y.8)
        (set! nfv.17 x.7)
        (set! nfv.16 z.6)
        (set! nfv.15 y.5)
        (set! nfv.14 x.4)
        (set! nfv.13 z.3)
        (set! nfv.12 y.2)
        (set! r15 L.rp.2)
        (jump
         x.1
         rbp
         r15
         nfv.12
         nfv.13
         nfv.14
         nfv.15
         nfv.16
         nfv.17
         nfv.18
         nfv.19)))
    (set! x.1 rax)
    (set! r15 tmp-ra.2)
    (jump x.1 rbp r15))))
  '(module
   ((locals (z.10 x.1))
    (conflicts ())
    (assignment
     ((nfv.11 fv17)
      (nfv.10 fv16)
      (nfv.9 fv15)
      (nfv.8 fv14)
      (nfv.7 fv13)
      (nfv.6 fv12)
      (nfv.5 fv11)
      (nfv.4 fv10)
      (nfv.3 fv9)
      (nfv.19 fv16)
      (nfv.18 fv15)
      (nfv.17 fv14)
      (nfv.16 fv13)
      (nfv.15 fv12)
      (nfv.14 fv11)
      (nfv.13 fv10)
      (nfv.12 fv9)
      (tmp-ra.2 fv0)
      (y.9 fv1)
      (y.8 fv1)
      (x.7 fv1)
      (z.6 fv1)
      (y.5 fv1)
      (x.4 fv1)
      (z.3 fv1)
      (y.2 fv1))))
   (define L.start.1
     ((locals (z.10 y.9 y.8 x.7 z.6 y.5 x.4 z.3 y.2 tmp-ra.1 x.1))
      (conflicts ())
      (assignment ()))
     (begin
       (set! tmp-ra.1 r15)
       (set! x.1 fv0)
       (set! y.2 fv1)
       (set! z.3 fv2)
       (set! x.4 fv3)
       (set! y.5 fv4)
       (set! z.6 fv5)
       (set! x.7 fv6)
       (set! y.8 fv7)
       (set! y.9 fv8)
       (set! z.10 fv9)
       (set! fv0 y.2)
       (set! r15 tmp-ra.1)
       (jump x.1 rbp r15 fv0)))
   (begin
     (set! tmp-ra.2 r15)
     (begin
       (set! rbp (- rbp 72))
       (return-point L.rp.1
         (begin
           (set! nfv.11 z.10)
           (set! nfv.10 y.9)
           (set! nfv.9 y.8)
           (set! nfv.8 x.7)
           (set! nfv.7 z.6)
           (set! nfv.6 y.5)
           (set! nfv.5 x.4)
           (set! nfv.4 z.3)
           (set! nfv.3 y.2)
           (set! r15 L.rp.1)
           (jump
            x.1
            rbp
            r15
            nfv.3
            nfv.4
            nfv.5
            nfv.6
            nfv.7
            nfv.8
            nfv.9
            nfv.10
            nfv.11)))
       (set! rbp (+ rbp 72)))
     (set! x.1 rax)
     (begin
       (set! rbp (- rbp 72))
       (return-point L.rp.2
         (begin
           (set! nfv.19 y.9)
           (set! nfv.18 y.8)
           (set! nfv.17 x.7)
           (set! nfv.16 z.6)
           (set! nfv.15 y.5)
           (set! nfv.14 x.4)
           (set! nfv.13 z.3)
           (set! nfv.12 y.2)
           (set! r15 L.rp.2)
           (jump
            x.1
            rbp
            r15
            nfv.12
            nfv.13
            nfv.14
            nfv.15
            nfv.16
            nfv.17
            nfv.18
            nfv.19)))
       (set! rbp (+ rbp 72)))
     (set! x.1 rax)
     (set! r15 tmp-ra.2)
     (jump x.1 rbp r15)))))


(check-equal? 
  (allocate-frames  
    '(module ((new-frames ()) 
      (locals (z.83 y.82 y.86 z.85 z.84 tmp-ra.99)) 
      (call-undead ()) 
      (undead-out 
        ((rbp tmp-ra.99) 
         ((rbp tmp-ra.99) 
          (((y.82 rbp tmp-ra.99)
           (z.83 y.82 rbp tmp-ra.99) 
           (rbp tmp-ra.99)) 
           ((rax rbp tmp-ra.99) (rbp rax)) 
           ((rax rbp tmp-ra.99) (rbp rax)))
           ((rbp tmp-ra.99) 
           (z.85 rbp tmp-ra.99) 
           (z.85 y.86 rbp tmp-ra.99)
            (y.86 rax rbp tmp-ra.99)
             (rax rbp tmp-ra.99) 
             (rbp rax))))) 
        (conflicts 
          ((tmp-ra.99 (y.86 z.85 z.84 rax z.83 y.82 rbp)) (rbp (y.86 z.85 z.84 rax z.83 y.82 tmp-ra.99)) (y.82 (z.83 tmp-ra.99 rbp)) (z.83 (tmp-ra.99 rbp y.82)) (rax (y.86 tmp-ra.99 rbp)) (z.84 (tmp-ra.99 rbp)) (z.85 (y.86 tmp-ra.99 rbp)) (y.86 (rax tmp-ra.99 rbp z.85)))) (assignment ())) (begin (set! tmp-ra.99 r15) (if (true) (if (begin (set! y.82 11) (set! z.83 15) (> y.82 z.83)) (begin (set! rax 14) (jump tmp-ra.99 rbp rax)) (begin (set! rax 15) (jump tmp-ra.99 rbp rax))) (begin (set! z.84 12) (set! z.85 15) (set! y.86 1) (set! rax z.85) (set! rax (+ rax y.86)) 
          (jump tmp-ra.99 rbp rax))))))
  '(module
  ((locals (tmp-ra.99 z.84 z.85 y.86 y.82 z.83))
   (conflicts
    ((tmp-ra.99 (y.86 z.85 z.84 rax z.83 y.82 rbp))
     (rbp (y.86 z.85 z.84 rax z.83 y.82 tmp-ra.99))
     (y.82 (z.83 tmp-ra.99 rbp))
     (z.83 (tmp-ra.99 rbp y.82))
     (rax (y.86 tmp-ra.99 rbp))
     (z.84 (tmp-ra.99 rbp))
     (z.85 (y.86 tmp-ra.99 rbp))
     (y.86 (rax tmp-ra.99 rbp z.85))))
   (assignment ()))
  (begin
    (set! tmp-ra.99 r15)
    (if (true)
      (if (begin (set! y.82 11) (set! z.83 15) (> y.82 z.83))
        (begin (set! rax 14) (jump tmp-ra.99 rbp rax))
        (begin (set! rax 15) (jump tmp-ra.99 rbp rax)))
      (begin
        (set! z.84 12)
        (set! z.85 15)
        (set! y.86 1)
        (set! rax z.85)
        (set! rax (+ rax y.86))
        (jump tmp-ra.99 rbp rax))))))

(parameterize ([current-parameter-registers '()])
  (check-equal?
    (allocate-frames
      '(module
        ((new-frames ())
        (locals (tmp-ra.10))
        (call-undead ())
        (undead-out
          ((tmp-ra.10 rbp)
          (tmp-ra.10 fv1 rbp)
          (tmp-ra.10 fv1 fv0 rbp)
          (fv1 fv0 r15 rbp)
          (fv1 fv0 r15 rbp)))
        (conflicts
          ((tmp-ra.10 (fv0 fv1 rbp))
          (rbp (r15 fv0 fv1 tmp-ra.10))
          (fv1 (r15 fv0 rbp tmp-ra.10))
          (fv0 (r15 rbp fv1 tmp-ra.10))
          (r15 (rbp fv0 fv1))))
        (assignment ()))
        (define L.swap.1
          ((new-frames ((nfv.8 nfv.9)))
          (locals (y.2 x.1 z.3 nfv.9 nfv.8))
          (undead-out
            ((fv0 fv1 tmp-ra.7 rbp)
            (fv1 x.1 tmp-ra.7 rbp)
            (y.2 x.1 tmp-ra.7 rbp)
            ((y.2 x.1 tmp-ra.7 rbp)
              ((tmp-ra.7 rax rbp) (rax rbp))
              (((rax tmp-ra.7 rbp)
                ((y.2 nfv.9 rbp)
                (nfv.9 nfv.8 rbp)
                (nfv.9 nfv.8 r15 rbp)
                (nfv.9 nfv.8 r15 rbp)))
              (z.3 tmp-ra.7 rbp)
              (tmp-ra.7 rax rbp)
              (rax rbp)))))
          (call-undead (tmp-ra.7))
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
          (assignment ((tmp-ra.7 fv2))))
          (begin
            (set! tmp-ra.7 r15)
            (set! x.1 fv0)
            (set! y.2 fv1)
            (if (< y.2 x.1)
              (begin (set! rax x.1) (jump tmp-ra.7 rbp rax))
              (begin
                (return-point L.rp.3
                  (begin
                    (set! nfv.9 x.1)
                    (set! nfv.8 y.2)
                    (set! r15 L.rp.3)
                    (jump L.swap.1 rbp r15 nfv.8 nfv.9)))
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
   ((locals (tmp-ra.10))
    (conflicts
     ((tmp-ra.10 (fv0 fv1 rbp))
      (rbp (r15 fv0 fv1 tmp-ra.10))
      (fv1 (r15 fv0 rbp tmp-ra.10))
      (fv0 (r15 rbp fv1 tmp-ra.10))
      (r15 (rbp fv0 fv1))))
    (assignment ()))
   (define L.swap.1
     ((locals (z.3 x.1 y.2))
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
      (assignment ((nfv.9 fv4) (nfv.8 fv3) (tmp-ra.7 fv2))))
     (begin
       (set! tmp-ra.7 r15)
       (set! x.1 fv0)
       (set! y.2 fv1)
       (if (< y.2 x.1)
         (begin (set! rax x.1) (jump tmp-ra.7 rbp rax))
         (begin
           (begin
             (set! rbp (- rbp 24))
             (return-point L.rp.3
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