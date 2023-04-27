#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    "../compiler.rkt"
    rackunit
    rackunit/text-ui)

(check-equal? 
    (impose-calling-conventions 
        '(module (define L.start.1 (lambda (x.1) 0)) 0))
    '(module
        ((new-frames ()))
        (define L.start.1
            ((new-frames ()))
            (begin
                (set! tmp-ra.1 r15)
                (begin (set! x.1 rdi) (begin (set! rax 0) (jump tmp-ra.1 rbp rax)))))
        (begin (set! tmp-ra.2 r15) (begin (set! rax 0) (jump tmp-ra.2 rbp rax)))))

(check-equal? 
    (impose-calling-conventions 
        '(module (define L.start.1 (lambda (x.1 x.2) 0)) 0))
    '(module
        ((new-frames ()))
        (define L.start.1
            ((new-frames ()))
            (begin
            (set! tmp-ra.3 r15)
            (begin
                (set! x.1 rdi)
                (set! x.2 rsi)
                (begin (set! rax 0) (jump tmp-ra.3 rbp rax)))))
        (begin (set! tmp-ra.4 r15) (begin (set! rax 0) (jump tmp-ra.4 rbp rax)))))            

(check-equal? 
    (impose-calling-conventions 
        '(module (define L.start.1 (lambda (x.1 x.2 y.3 z.4) 0)) 0))
        '(module
            ((new-frames ()))
            (define L.start.1
                ((new-frames ()))
                (begin
                (set! tmp-ra.5 r15)
                (begin
                    (set! x.1 rdi)
                    (set! x.2 rsi)
                    (set! y.3 rdx)
                    (set! z.4 rcx)
                    (begin (set! rax 0) (jump tmp-ra.5 rbp rax)))))
            (begin (set! tmp-ra.6 r15) (begin (set! rax 0) (jump tmp-ra.6 rbp rax)))))

(check-equal? 
    (impose-calling-conventions 
        '(module (define L.start.1 (lambda (x.1 x.2 y.3 z.4) 0))
                 (define L.start.2 (lambda (k.5 k.6 k.7) 0)) 
                 0))
        '(module
            ((new-frames ()))
            (define L.start.1
                ((new-frames ()))
                (begin
                (set! tmp-ra.7 r15)
                (begin
                    (set! x.1 rdi)
                    (set! x.2 rsi)
                    (set! y.3 rdx)
                    (set! z.4 rcx)
                    (begin (set! rax 0) (jump tmp-ra.7 rbp rax)))))
            (define L.start.2
                ((new-frames ()))
                (begin
                (set! tmp-ra.8 r15)
                (begin
                    (set! k.5 rdi)
                    (set! k.6 rsi)
                    (set! k.7 rdx)
                    (begin (set! rax 0) (jump tmp-ra.8 rbp rax)))))
            (begin (set! tmp-ra.9 r15) (begin (set! rax 0) (jump tmp-ra.9 rbp rax)))))

(check-equal? 
    (impose-calling-conventions 
        '(module 
            (define L.start.1 (lambda (x.1 x.2 y.3 z.4)
                (begin 
                    (set! x.1 3)
                    (if (true)
                        1
                        2))))
            (if (false)
                (begin (set! x.2 1) 1)
                2)))
    '(module
        ((new-frames ()))
        (define L.start.1
            ((new-frames ()))
            (begin
            (set! tmp-ra.10 r15)
            (begin
                (set! x.1 rdi)
                (set! x.2 rsi)
                (set! y.3 rdx)
                (set! z.4 rcx)
                (begin
                (set! x.1 3)
                (if (true)
                    (begin (set! rax 1) (jump tmp-ra.10 rbp rax))
                    (begin (set! rax 2) (jump tmp-ra.10 rbp rax)))))))
        (begin
            (set! tmp-ra.11 r15)
            (if (false)
            (begin (set! x.2 1) (begin (set! rax 1) (jump tmp-ra.11 rbp rax)))
            (begin (set! rax 2) (jump tmp-ra.11 rbp rax))))))

(check-equal? (impose-calling-conventions
    '(module 
        (define L.start.1 (lambda (x.1 y.2 z.3)
            (call x.1 y.2))) (call x.1 y.2 z.3)))
    '(module
        ((new-frames ()))
        (define L.start.1
            ((new-frames ()))
            (begin
            (set! tmp-ra.12 r15)
            (begin
                (set! x.1 rdi)
                (set! y.2 rsi)
                (set! z.3 rdx)
                (begin (set! rdi y.2) (set! r15 tmp-ra.12) (jump x.1 rbp r15 rdi)))))
        (begin
            (set! tmp-ra.13 r15)
            (begin
            (set! rsi z.3)
            (set! rdi y.2)
            (set! r15 tmp-ra.13)
            (jump x.1 rbp r15 rdi rsi)))))

(check-equal? (impose-calling-conventions
    '(module 
        (define L.start.1 (lambda (x.1 y.2 z.3)
            (begin 
                (set! x.1 2)
                (if (= y.2 z.3)
                    (set! y.2 1)
                    (set! x.2 1))
                (call x.1 y.2)))) 
        (if (true)
            (call x.1 y.2 z.3)
            (call z.3 y.2 x.1))))
    '(module
        ((new-frames ()))
        (define L.start.1
            ((new-frames ()))
            (begin
            (set! tmp-ra.14 r15)
            (begin
                (set! x.1 rdi)
                (set! y.2 rsi)
                (set! z.3 rdx)
                (begin
                (set! x.1 2)
                (if (= y.2 z.3) (set! y.2 1) (set! x.2 1))
                (begin (set! rdi y.2) (set! r15 tmp-ra.14) (jump x.1 rbp r15 rdi))))))
        (begin
            (set! tmp-ra.15 r15)
            (if (true)
            (begin
                (set! rsi z.3)
                (set! rdi y.2)
                (set! r15 tmp-ra.15)
                (jump x.1 rbp r15 rdi rsi))
            (begin
                (set! rsi x.1)
                (set! rdi y.2)
                (set! r15 tmp-ra.15)
                (jump z.3 rbp r15 rdi rsi))))))

(check-equal? (impose-calling-conventions
    '(module 
        (define L.start.1 (lambda (x.1 y.2 z.3 x.4 y.5 z.6 x.7 y.8)
            (call x.1 y.2))) (call x.1 y.2 z.3 x.4 y.5 z.6 x.7 y.8)))
    '(module
        ((new-frames ()))
        (define L.start.1
            ((new-frames ()))
            (begin
            (set! tmp-ra.16 r15)
            (begin
                (set! x.1 rdi)
                (set! y.2 rsi)
                (set! z.3 rdx)
                (set! x.4 rcx)
                (set! y.5 r8)
                (set! z.6 r9)
                (set! x.7 fv0)
                (set! y.8 fv1)
                (begin (set! rdi y.2) (set! r15 tmp-ra.16) (jump x.1 rbp r15 rdi)))))
        (begin
            (set! tmp-ra.17 r15)
            (begin
            (set! fv0 y.8)
            (set! r9 x.7)
            (set! r8 z.6)
            (set! rcx y.5)
            (set! rdx x.4)
            (set! rsi z.3)
            (set! rdi y.2)
            (set! r15 tmp-ra.17)
            (jump x.1 rbp r15 rdi rsi rdx rcx r8 r9 fv0)))))

(check-equal? (impose-calling-conventions
    '(module 
        (define L.start.1 (lambda (x.1 y.2 z.3 x.4 y.5 z.6 x.7 y.8) 1))
        (define L.start.1 (lambda (o.1 o.2 o.3 o.4 o.5 o.6 o.7 o.8 o.9 o.10 o.11) 1))
        (call x.1 y.2 z.3 x.4 y.5 z.6 x.7 y.8 o.1 o.2 o.3 o.4 o.5 o.6 o.7)))
    '(module
        ((new-frames ()))
        (define L.start.1
            ((new-frames ()))
            (begin
            (set! tmp-ra.18 r15)
            (begin
                (set! x.1 rdi)
                (set! y.2 rsi)
                (set! z.3 rdx)
                (set! x.4 rcx)
                (set! y.5 r8)
                (set! z.6 r9)
                (set! x.7 fv0)
                (set! y.8 fv1)
                (begin (set! rax 1) (jump tmp-ra.18 rbp rax)))))
        (define L.start.1
            ((new-frames ()))
            (begin
            (set! tmp-ra.19 r15)
            (begin
                (set! o.1 rdi)
                (set! o.2 rsi)
                (set! o.3 rdx)
                (set! o.4 rcx)
                (set! o.5 r8)
                (set! o.6 r9)
                (set! o.7 fv0)
                (set! o.8 fv1)
                (set! o.9 fv2)
                (set! o.10 fv3)
                (set! o.11 fv4)
                (begin (set! rax 1) (jump tmp-ra.19 rbp rax)))))
        (begin
            (set! tmp-ra.20 r15)
            (begin
            (set! fv7 o.7)
            (set! fv6 o.6)
            (set! fv5 o.5)
            (set! fv4 o.4)
            (set! fv3 o.3)
            (set! fv2 o.2)
            (set! fv1 o.1)
            (set! fv0 y.8)
            (set! r9 x.7)
            (set! r8 z.6)
            (set! rcx y.5)
            (set! rdx x.4)
            (set! rsi z.3)
            (set! rdi y.2)
            (set! r15 tmp-ra.20)
            (jump
            x.1
            rbp
            r15
            rdi
            rsi
            rdx
            rcx
            r8
            r9
            fv0
            fv1
            fv2
            fv3
            fv4
            fv5
            fv6
            fv7)))))

(check-equal? 
    (impose-calling-conventions 
        '(module 
            (define L.start.1 (lambda (x.1 x.2 y.3 z.4)
                (begin 
                    (set! x.1 (call x.1 y.2))
                    (if (true)
                        1
                        2))))
            2))
    '(module
        ((new-frames ()))
        (define L.start.1
            ((new-frames (())))
            (begin
            (set! tmp-ra.21 r15)
            (begin
                (set! x.1 rdi)
                (set! x.2 rsi)
                (set! y.3 rdx)
                (set! z.4 rcx)
                (begin
                    (begin
                        (return-point
                        L.tmp.1
                        (begin (set! rdi y.2) (set! r15 L.tmp.1) (jump x.1 rbp r15 rdi)))
                        (set! x.1 rax))
                    (if (true)
                        (begin (set! rax 1) (jump tmp-ra.21 rbp rax))
                        (begin (set! rax 2) (jump tmp-ra.21 rbp rax)))))))
        (begin (set! tmp-ra.22 r15) (begin (set! rax 2) (jump tmp-ra.22 rbp rax)))))

(check-equal? 
    (impose-calling-conventions 
        '(module 
            (define L.start.1 (lambda (x.1 x.2 y.3 z.4)
                (begin 
                    (set! x.2 1)
                    (set! x.1 (call x.1 y.2))
                    (if (true)
                        (begin
                            (set! y.3 (call x.1 y.3 z.4))
                            1)
                        2))))
            2))
    '(module
        ((new-frames ()))
        (define L.start.1
            ((new-frames (() ())))
            (begin
            (set! tmp-ra.23 r15)
            (begin
                (set! x.1 rdi)
                (set! x.2 rsi)
                (set! y.3 rdx)
                (set! z.4 rcx)
                (begin
                (set! x.2 1)
                (begin
                    (return-point L.tmp.3
                    (begin
                        (set! rdi y.2)
                        (set! r15 L.tmp.3)
                        (jump x.1 rbp r15 rdi)))
                    (set! x.1 rax))
                (if (true)
                    (begin
                    (begin
                        (return-point L.tmp.2
                        (begin
                            (set! rsi z.4)
                            (set! rdi y.3)
                            (set! r15 L.tmp.2)
                            (jump x.1 rbp r15 rdi rsi)))
                        (set! y.3 rax))
                    (begin (set! rax 1) (jump tmp-ra.23 rbp rax)))
                    (begin (set! rax 2) (jump tmp-ra.23 rbp rax)))))))
        (begin (set! tmp-ra.24 r15) (begin (set! rax 2) (jump tmp-ra.24 rbp rax)))))

(check-equal? 
    (impose-calling-conventions 
        '(module (define L.start.1 (lambda (x.1) (- 1 2))) (* 3 5)))
    '(module
        ((new-frames ()))
        (define L.start.1
            ((new-frames ()))
            (begin
            (set! tmp-ra.25 r15)
            (begin
                (set! x.1 rdi)
                (begin (set! rax (- 1 2)) (jump tmp-ra.25 rbp rax)))))
        (begin
            (set! tmp-ra.26 r15)
            (begin (set! rax (* 3 5)) (jump tmp-ra.26 rbp rax)))))

(check-equal? (impose-calling-conventions
    '(module 
        (define L.start.1 (lambda (x.1 y.2 z.3 x.4 y.5 z.6 x.7 y.8 y.9 z.10)
            (call x.1 y.2))) 
            (begin 
                (set! x.1 (call x.1 y.2 z.3 x.4 y.5 z.6 x.7 y.8 y.9 z.10))
                (call x.1))))
    '(module
        ((new-frames ((nfv.29 nfv.30 nfv.31))))
        (define L.start.1
            ((new-frames ()))
            (begin
            (set! tmp-ra.27 r15)
            (begin
                (set! x.1 rdi)
                (set! y.2 rsi)
                (set! z.3 rdx)
                (set! x.4 rcx)
                (set! y.5 r8)
                (set! z.6 r9)
                (set! x.7 fv0)
                (set! y.8 fv1)
                (set! y.9 fv2)
                (set! z.10 fv3)
                (begin (set! rdi y.2) (set! r15 tmp-ra.27) (jump x.1 rbp r15 rdi)))))
        (begin
            (set! tmp-ra.28 r15)
            (begin
            (begin
                (return-point L.tmp.4
                (begin
                    (set! nfv.31 z.10)
                    (set! nfv.30 y.9)
                    (set! nfv.29 y.8)
                    (set! r9 x.7)
                    (set! r8 z.6)
                    (set! rcx y.5)
                    (set! rdx x.4)
                    (set! rsi z.3)
                    (set! rdi y.2)
                    (set! r15 L.tmp.4)
                    (jump x.1 rbp r15 rdi rsi rdx rcx r8 r9 nfv.29 nfv.30 nfv.31)))
                (set! x.1 rax))
            (begin (set! r15 tmp-ra.28) (jump x.1 rbp r15))))))


(check-equal? (impose-calling-conventions
    '(module 
        (define L.start.1 (lambda (x.1 y.2 z.3 x.4 y.5 z.6 x.7 y.8 y.9 z.10)
            (call x.1 y.2))) 
            (begin 
                (set! x.1 (call x.1 y.2 z.3 x.4 y.5 z.6 x.7 y.8 y.9 z.10))
                (set! x.1 (call x.1 y.2 z.3 x.4 y.5 z.6 x.7 y.8 y.9))
                (call x.1))))
    '(module
        ((new-frames ((nfv.37 nfv.38) (nfv.34 nfv.35 nfv.36))))
        (define L.start.1
            ((new-frames ()))
            (begin
            (set! tmp-ra.32 r15)
            (begin
                (set! x.1 rdi)
                (set! y.2 rsi)
                (set! z.3 rdx)
                (set! x.4 rcx)
                (set! y.5 r8)
                (set! z.6 r9)
                (set! x.7 fv0)
                (set! y.8 fv1)
                (set! y.9 fv2)
                (set! z.10 fv3)
                (begin (set! rdi y.2) (set! r15 tmp-ra.32) (jump x.1 rbp r15 rdi)))))
        (begin
            (set! tmp-ra.33 r15)
            (begin
            (begin
                (return-point L.tmp.5
                (begin
                    (set! nfv.36 z.10)
                    (set! nfv.35 y.9)
                    (set! nfv.34 y.8)
                    (set! r9 x.7)
                    (set! r8 z.6)
                    (set! rcx y.5)
                    (set! rdx x.4)
                    (set! rsi z.3)
                    (set! rdi y.2)
                    (set! r15 L.tmp.5)
                    (jump x.1 rbp r15 rdi rsi rdx rcx r8 r9 nfv.34 nfv.35 nfv.36)))
                (set! x.1 rax))
            (begin
                (return-point L.tmp.6
                (begin
                    (set! nfv.38 y.9)
                    (set! nfv.37 y.8)
                    (set! r9 x.7)
                    (set! r8 z.6)
                    (set! rcx y.5)
                    (set! rdx x.4)
                    (set! rsi z.3)
                    (set! rdi y.2)
                    (set! r15 L.tmp.6)
                    (jump x.1 rbp r15 rdi rsi rdx rcx r8 r9 nfv.37 nfv.38)))
                (set! x.1 rax))
            (begin (set! r15 tmp-ra.33) (jump x.1 rbp r15))))))


(check-equal? (impose-calling-conventions
    '(module 
        (define L.start.1 (lambda (x.1 y.2 z.3 x.4 y.5 z.6 x.7 y.8 y.9 z.10)
            (call x.1 y.2))) 
            (begin 
                (call x.1 y.2 z.3 x.4 y.5 z.6 x.7 y.8 y.9 z.10))))
    '(module
        ((new-frames ()))
        (define L.start.1
            ((new-frames ()))
            (begin
            (set! tmp-ra.39 r15)
            (begin
                (set! x.1 rdi)
                (set! y.2 rsi)
                (set! z.3 rdx)
                (set! x.4 rcx)
                (set! y.5 r8)
                (set! z.6 r9)
                (set! x.7 fv0)
                (set! y.8 fv1)
                (set! y.9 fv2)
                (set! z.10 fv3)
                (begin (set! rdi y.2) (set! r15 tmp-ra.39) (jump x.1 rbp r15 rdi)))))
        (begin
            (set! tmp-ra.40 r15)
            (begin
            (begin
                (set! fv2 z.10)
                (set! fv1 y.9)
                (set! fv0 y.8)
                (set! r9 x.7)
                (set! r8 z.6)
                (set! rcx y.5)
                (set! rdx x.4)
                (set! rsi z.3)
                (set! rdi y.2)
                (set! r15 tmp-ra.40)
                (jump x.1 rbp r15 rdi rsi rdx rcx r8 r9 fv0 fv1 fv2))))))


(check-equal? 
    (impose-calling-conventions 
        '(module 
            (define L.start.1 (lambda (x.1 x.2 y.3 z.4)
                (begin 
                    (set! x.1 3)
                    (if (begin (set! x.1 2) (true))
                        1
                        2))))
            (if (false)
                (begin (set! x.2 1) 1)
                2)))
    '(module
        ((new-frames ()))
        (define L.start.1
            ((new-frames ()))
            (begin
            (set! tmp-ra.41 r15)
            (begin
                (set! x.1 rdi)
                (set! x.2 rsi)
                (set! y.3 rdx)
                (set! z.4 rcx)
                (begin
                (set! x.1 3)
                (if (begin (set! x.1 2) (true))
                    (begin (set! rax 1) (jump tmp-ra.41 rbp rax))
                    (begin (set! rax 2) (jump tmp-ra.41 rbp rax)))))))
        (begin
            (set! tmp-ra.42 r15)
            (if (false)
            (begin (set! x.2 1) (begin (set! rax 1) (jump tmp-ra.42 rbp rax)))
            (begin (set! rax 2) (jump tmp-ra.42 rbp rax))))))

(check-equal? 
    (impose-calling-conventions 
        '(module 
            (define L.start.1 (lambda (x.1 x.2 y.3 z.4)
                (begin 
                    (set! x.1 3)
                    (if (begin (set! x.1 (call x.1 y.2)) (true))
                        1
                        2))))
            (if (false)
                (begin (set! x.2 1) 1)
                2)))
    '(module
        ((new-frames ()))
        (define L.start.1
            ((new-frames (())))
            (begin
            (set! tmp-ra.43 r15)
            (begin
                (set! x.1 rdi)
                (set! x.2 rsi)
                (set! y.3 rdx)
                (set! z.4 rcx)
                (begin
                (set! x.1 3)
                (if (begin
                        (begin
                        (return-point
                        L.tmp.7
                        (begin
                            (set! rdi y.2)
                            (set! r15 L.tmp.7)
                            (jump x.1 rbp r15 rdi)))
                        (set! x.1 rax))
                        (true))
                    (begin (set! rax 1) (jump tmp-ra.43 rbp rax))
                    (begin (set! rax 2) (jump tmp-ra.43 rbp rax)))))))
        (begin
            (set! tmp-ra.44 r15)
            (if (false)
            (begin (set! x.2 1) (begin (set! rax 1) (jump tmp-ra.44 rbp rax)))
            (begin (set! rax 2) (jump tmp-ra.44 rbp rax))))))