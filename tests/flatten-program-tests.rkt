#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    cpsc411/langs/v5
    "../compiler.rkt"
    rackunit)


(check-equal?
    (flatten-program
        '(module 
            (define L.start.1 
                (begin
                    (set! rax 1)
                    (jump L.test.2)))
            (define L.test.2
                (begin
                    (set! rax 1)
                    (halt rdi)))))
    '(begin
        (with-label L.start.1 (set! rax 1))
        (jump L.test.2)
        (with-label L.test.2 (set! rax 1))
        (halt rdi)))

(check-equal?
    (flatten-program
        '(module 
            (define L.start.1 
                (begin
                    (set! rax 1)
                    (if (< r8 5) (jump L.start.1) (jump rax))))))
    '(begin
        (with-label L.start.1 (set! rax 1))
        (compare r8 5)
        (jump-if < L.start.1)
        (jump rax)))

(check-equal?
    (flatten-program
        '(module 
            (define L.start.1 
                (begin
                    (set! rax 1)
                    (begin
                        (set! r8 1)
                        (jump r9))))
            (define L.start.2
                (begin
                    (set! rax 1)
                    (if (>= r8 5) (jump L.start.1) (jump rax))))))
    '(begin
        (with-label L.start.1 (set! rax 1))
        (set! r8 1)
        (jump r9)
        (with-label L.start.2 (set! rax 1))
        (compare r8 5)
        (jump-if >= L.start.1)
        (jump rax)))


(check-equal?
    (flatten-program
        '(module 
            (define L.start.1 
                (begin
                    (set! rax 1)
                    (set! rax 2)
                    (set! rdi rax)
                    (jump L.test.2)))
            (define L.test.2
                (begin
                    (set! rax 1)
                    (halt rdi)))))
    '(begin
        (with-label L.start.1 (set! rax 1))
        (set! rax 2)
        (set! rdi rax)
        (jump L.test.2)
        (with-label L.test.2 (set! rax 1))
        (halt rdi)))