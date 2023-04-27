#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    "../compiler.rkt"
    rackunit
    rackunit/text-ui)

(check-equal? 
    (replace-locations
        '(module
            ((assignment ((tmp-ra.2 r15))))
            (define L.swap.1
                ((assignment ((tmp-ra.1 fv0) (y.2 r15) (x.1 r14) (z.3 r15))))
                (begin
                (set! tmp-ra.1 r15)
                (set! x.1 rdi)
                (set! y.2 rsi)
                (if (< y.2 x.1)
                    (begin (set! rax x.1) (jump tmp-ra.1 rbp rax))
                    (begin
                    (begin
                        (set! rbp (- rbp 8))
                        (return-point L.rp.1
                        (begin
                            (set! rsi x.1)
                            (set! rdi y.2)
                            (set! r15 L.rp.1)
                            (jump L.swap.1 rbp r15 rdi rsi)))
                        (set! rbp (+ rbp 8)))
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
        (define L.swap.1
            (begin
            (set! fv0 r15)
            (set! r14 rdi)
            (set! r15 rsi)
            (if (< r15 r14)
                (begin (set! rax r14) (jump fv0))
                (begin
                (begin
                    (set! rbp (- rbp 8))
                    (return-point
                    L.rp.1
                    (begin
                    (set! rsi r14)
                    (set! rdi r15)
                    (set! r15 L.rp.1)
                    (jump L.swap.1)))
                    (set! rbp (+ rbp 8)))
                (set! r15 rax)
                (set! rax r15)
                (jump fv0)))))
        (begin
            (set! r15 r15)
            (set! rsi 2)
            (set! rdi 1)
            (set! r15 r15)
            (jump L.swap.1))))



(check-equal? 
    (replace-locations
        '(module
            ((assignment ((tmp-ra.2 r15) (tmp-ra.1 fv0) (y.2 r15) (x.1 r14) (z.3 r15) (k.4 fv1))))
            (define L.swap.1
                ((assignment ((tmp-ra.1 fv0) (y.2 r15) (x.1 r14) (z.3 r15) (k.4 fv1))))
                (begin
                (set! tmp-ra.1 r15)
                (set! x.1 rdi)
                (set! y.2 rsi)
                (if (< y.2 x.1)
                    (begin (set! rax x.1) (jump tmp-ra.1 rbp rax))
                    (begin
                    (begin
                        (set! rbp (- rbp 8))
                        (return-point L.rp.1
                        (begin
                            (set! rsi x.1)
                            (set! rdi y.2)
                            (set! r15 L.rp.1)
                            (jump L.swap.1 rbp r15 rdi rsi)))
                        (set! rbp (+ rbp 8)))
                    (set! z.3 rax)
                    (set! rax z.3)
                    (jump tmp-ra.1 rbp rax)))))
            (begin
                (set! tmp-ra.2 r15)
                (return-point L.rp.2
                        (begin
                            (set! rsi x.1)
                            (set! rdi k.4)
                            (set! r15 L.rp.2)
                            (jump L.swap.1 rbp r15 rdi rsi)))
                (set! rsi 2)
                (set! rdi 1)
                (set! r15 tmp-ra.2)
                (jump L.swap.1 rbp r15 rdi rsi))))
    '(module
        (define L.swap.1
            (begin
            (set! fv0 r15)
            (set! r14 rdi)
            (set! r15 rsi)
            (if (< r15 r14)
                (begin (set! rax r14) (jump fv0))
                (begin
                (begin
                    (set! rbp (- rbp 8))
                    (return-point
                    L.rp.1
                    (begin
                    (set! rsi r14)
                    (set! rdi r15)
                    (set! r15 L.rp.1)
                    (jump L.swap.1)))
                    (set! rbp (+ rbp 8)))
                (set! r15 rax)
                (set! rax r15)
                (jump fv0)))))
        (begin
            (set! r15 r15)
            (return-point
            L.rp.2
            (begin (set! rsi r14) (set! rdi fv1) (set! r15 L.rp.2) (jump L.swap.1)))
            (set! rsi 2)
            (set! rdi 1)
            (set! r15 r15)
            (jump L.swap.1))))
            