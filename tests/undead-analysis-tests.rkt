#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    cpsc411/langs/v5
    "../compiler.rkt"
    rackunit)

(check-equal?
    (undead-analysis
        '(module ((locals ()) (new-frames (()))) 
            (begin 
                (jump r15))))
    '(module
        ((locals ()) (new-frames (())) (call-undead ()) (undead-out (())))
        (begin (jump r15))))

(check-equal?
    (undead-analysis
        '(module ((locals ()) (new-frames (()))) 
            (begin 
                (set! rax 5) 
                (jump r15))))
    '(module
        ((locals ()) (new-frames (())) (call-undead ()) 
            (undead-out 
                ((r15) 
                 ())))
        (begin (set! rax 5) (jump r15))))

(check-equal?
    (undead-analysis
        '(module ((locals (x.1 y.1 z.1)) (new-frames (()))) (begin (set! x.1 1) (set! y.1 x.1) (set! y.1 (+ y.1 1)) (set! z.1 y.1) (set! z.1 (+ z.1 1)) (begin (set! rax z.1) (jump r15)))))
    '(module
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

(check-equal?
    (undead-analysis
        '(module ((locals (x.1)) (new-frames (()))) (begin (set! x.1 5) (begin (set! rax x.1) (jump r15)))))
        '(module
            ((locals (x.1))
            (new-frames (()))
            (call-undead ())
            (undead-out ((x.1 r15) ((r15) ()))))
            (begin (set! x.1 5) (begin (set! rax x.1) (jump r15)))))
    
(check-equal?
    (undead-analysis
        '(module ((locals (x.1 y.2 b.3 c.4)) (new-frames (()))) (begin (set! x.1 5) (set! y.2 x.1) (begin (set! b.3 x.1) (set! b.3 (+ b.3 y.2)) (set! c.4 b.3) (if (= c.4 b.3) (begin (set! rax c.4) (jump r15)) (begin (set! x.1 c.4) (begin (set! rax c.4) (jump r15))))))))
    '(module
        ((locals (x.1 y.2 b.3 c.4))
        (new-frames (()))
        (call-undead ())
        (undead-out
            ((x.1 r15)
            (x.1 y.2 r15)
            ((y.2 b.3 r15)
            (b.3 r15)
            (b.3 c.4 r15)
            ((c.4 r15) ((r15) ()) ((c.4 r15) ((r15) ())))))))
        (begin
            (set! x.1 5)
            (set! y.2 x.1)
            (begin
            (set! b.3 x.1)
            (set! b.3 (+ b.3 y.2))
            (set! c.4 b.3)
            (if (= c.4 b.3)
                (begin (set! rax c.4) (jump r15))
                (begin (set! x.1 c.4) (begin (set! rax c.4) (jump r15))))))))

(check-equal?
    (undead-analysis
        '(module ((locals (w.1 y.1 x.1)) (new-frames (()))) 
            (begin (set! x.1 0) 
                (set! w.1 0) (set! y.1 x.1)
                (set! w.1 (+ w.1 x.1)) 
                (set! w.1 (+ w.1 y.1)) 
                (begin (set! rax w.1) 
                (jump r15)))))
        '(module
            ((locals (w.1 y.1 x.1))
            (new-frames (()))
            (call-undead ())
            (undead-out
                ((x.1 r15)
                (x.1 w.1 r15)
                (x.1 w.1 y.1 r15)
                (y.1 w.1 r15)
                (w.1 r15)
                ((r15) ()))))
            (begin
                (set! x.1 0)
                (set! w.1 0)
                (set! y.1 x.1)
                (set! w.1 (+ w.1 x.1))
                (set! w.1 (+ w.1 y.1))
                (begin (set! rax w.1) (jump r15)))))

(check-equal?
    (undead-analysis
        '(module ((locals ()) (new-frames (()))) 
            (begin 
                (set! rax 5) 
                (return-point L.test.1 
                    (jump r14))
                (jump r15))))
    '(module
        ((locals ())
        (new-frames (()))
        (call-undead ())
        (undead-out ((r14 r15) ((r15) ()) ())))
        (begin (set! rax 5) (return-point L.test.1 (jump r14)) (jump r15))))

(check-equal?
    (undead-analysis
        '(module ((locals ()) (new-frames (()))) 
            (begin 
                (set! rax 5) 
                (return-point L.test.1 
                    (jump r14 r13 r12))
                (jump r15 r13 r12))))
    '(module
        ((locals ())
            (new-frames (()))
            (call-undead ())
            (undead-out ((r14 r12 r13 r15) ((r12 r13 r15) (r13 r12)) (r13 r12))))
        (begin
            (set! rax 5)
            (return-point L.test.1 (jump r14 r13 r12))
            (jump r15 r13 r12))))

(check-equal?
    (undead-analysis
        '(module ((locals (x.1)) (new-frames (()))) 
            (begin 
                (set! rax 5) 
                (return-point L.test.1 
                    (jump r14 r13 r12))
                (set! x.1 2)
                (begin
                    (set! x.1 3)
                    (return-point L.test.2
                        (jump r14 r13 r12)))
                (jump r15))))
    '(module
        ((locals (x.1))
            (new-frames (()))
            (call-undead ())
            (undead-out
            ((r14 r13 r12 r15)
            ((r14 r13 r12 r15) (r13 r12))
            (r14 r13 r12 r15)
            ((r14 r13 r12 r15) ((r15) (r13 r12)))
            ())))
        (begin
            (set! rax 5)
            (return-point L.test.1 (jump r14 r13 r12))
            (set! x.1 2)
            (begin (set! x.1 3) (return-point L.test.2 (jump r14 r13 r12)))
            (jump r15))))


(check-equal?
    (undead-analysis
        '(module
            ((new-frames ())
                (locals (tmp-ra.2)))
            (define L.swap.1
                ((new-frames (()))
                (locals (z.3 tmp-ra.1 x.1 y.2)))
                (begin
                    (set! tmp-ra.1 r15)
                    (set! x.1 rdi)
                    (set! y.2 rsi)
                    (if (< y.2 x.1)
                        (begin 
                            (set! rax x.1) 
                            (jump tmp-ra.1 rbp rax))
                        (begin
                            (return-point L.rp.1
                                (begin
                                (set! rsi x.1)
                                (set! rdi y.2)
                                (set! r15 L.rp.1)
                                (jump L.swap.1 rbp r15 rdi rsi)))
                            (set! z.3 rax)
                            (set! rax z.3)
                            (jump tmp-ra.1 rbp rax)))))
            (begin
                (set! tmp-ra.2 r15)
                (set! rsi 2)
                (set! rdi 1)
                (set! r15 tmp-ra.2)
                (jump L.swap.1 rbp r15 rdi rsi))))
    '(module
        ((new-frames ())
            (locals (tmp-ra.2))
            (call-undead ())
            (undead-out
            ((tmp-ra.2 rbp)
            (tmp-ra.2 rsi rbp)
            (tmp-ra.2 rsi rdi rbp)
            (rsi rdi r15 rbp)
            (rbp r15 rdi rsi))))
        (define L.swap.1
            ((new-frames (()))
            (locals (z.3 tmp-ra.1 x.1 y.2))
            (call-undead (y.2 x.1 tmp-ra.1))
            (undead-out
            ((rdi rsi rbp tmp-ra.1)
                (rsi x.1 rbp tmp-ra.1)
                (y.2 x.1 rbp tmp-ra.1)
                ((y.2 x.1 rbp tmp-ra.1)
                ((rax rbp tmp-ra.1) (rbp rax))
                (((rax rbp tmp-ra.1)
                ((y.2 rsi rbp) (rsi rdi rbp) (rsi rdi r15 rbp) (rbp r15 rdi rsi)))
                (z.3 rbp tmp-ra.1)
                (rax rbp tmp-ra.1)
                (rbp rax))))))
            (begin
            (set! tmp-ra.1 r15)
            (set! x.1 rdi)
            (set! y.2 rsi)
            (if (< y.2 x.1)
                (begin (set! rax x.1) (jump tmp-ra.1 rbp rax))
                (begin
                (return-point L.rp.1
                    (begin
                    (set! rsi x.1)
                    (set! rdi y.2)
                    (set! r15 L.rp.1)
                    (jump L.swap.1 rbp r15 rdi rsi)))
                (set! z.3 rax)
                (set! rax z.3)
                (jump tmp-ra.1 rbp rax)))))
        (begin
            (set! tmp-ra.2 r15)
            (set! rsi 2)
            (set! rdi 1)
            (set! r15 tmp-ra.2)
            (jump L.swap.1 rbp r15 rdi rsi))))


(check-equal?
    (undead-analysis
        '(module
            ((new-frames ())
                (locals (tmp-ra.2)))
            (define L.swap.1
                ((new-frames (()))
                (locals (z.3 tmp-ra.1 x.1 y.2)))
                (begin
                    (set! tmp-ra.1 r15)
                    (set! x.1 rdi)
                    (set! y.2 rsi)
                    (begin
                        (return-point L.rp.1
                            (jump L.swap.1 rbp r15 rdi rsi))
                        (set! z.3 rax)
                        (set! rax z.3)
                        (jump tmp-ra.2 rbp rax))))
            (jump r15)))
    '(module
        ((new-frames ()) (locals (tmp-ra.2)) (call-undead ()) (undead-out ()))
        (define L.swap.1
            ((new-frames (()))
            (locals (z.3 tmp-ra.1 x.1 y.2))
            (call-undead (tmp-ra.2))
            (undead-out
            ((r15 rdi rsi rbp tmp-ra.2)
                (r15 rdi rsi rbp tmp-ra.2)
                (r15 rdi rsi rbp tmp-ra.2)
                (((rax rbp tmp-ra.2) (rbp r15 rdi rsi))
                (z.3 rbp tmp-ra.2)
                (rax rbp tmp-ra.2)
                (rbp rax)))))
            (begin
            (set! tmp-ra.1 r15)
            (set! x.1 rdi)
            (set! y.2 rsi)
            (begin
                (return-point L.rp.1 (jump L.swap.1 rbp r15 rdi rsi))
                (set! z.3 rax)
                (set! rax z.3)
                (jump tmp-ra.2 rbp rax))))
        (jump r15)))

(check-equal?
  (undead-analysis '(module ((new-frames ()) (locals (z.64 y.63 x.62 tmp-ra.117))) (begin (set! tmp-ra.117 r15) (set! x.62 20) (set! y.63 21) (if (not (> x.62 12)) (if (if (begin (set! z.64 x.62) (< y.63 z.64)) (true) (false)) (begin (set! rax 10) (jump tmp-ra.117 rbp rax)) (begin (set! rax 12) (jump tmp-ra.117 rbp rax))) (begin (set! rax x.62) (set! rax (+ rax y.63)) (jump tmp-ra.117 rbp rax))))))
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
       ((y.63 rax rbp tmp-ra.117) (rax rbp tmp-ra.117) (rbp rax))))))
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