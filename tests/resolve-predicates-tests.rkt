#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    cpsc411/langs/v5
    "../compiler.rkt"
    rackunit)

(check-equal?
    (resolve-predicates
        '(module
            (define L.__main.231
                (begin
                (set! r15 r15)
                (if (true) (jump L.__nested.229) (jump L.__nested.230))))
            (define L.__nested.229
                (begin (set! r14 112) (set! r14 96) (jump L.__join.228)))
            (define L.__nested.230 (begin (set! r14 120) (jump L.__join.228)))
            (define L.__join.228 (begin (set! rax r14) (jump r15)))))
    '(module
        (define L.__main.231 (begin (set! r15 r15) (jump L.__nested.229)))
        (define L.__nested.229
            (begin (set! r14 112) (set! r14 96) (jump L.__join.228)))
        (define L.__nested.230 (begin (set! r14 120) (jump L.__join.228)))
        (define L.__join.228 (begin (set! rax r14) (jump r15)))))

(check-equal?
    (resolve-predicates
        '(module
            (define L.__main.292
                (begin
                (set! r15 r15)
                (set! r14 0)
                (if (true) (jump L.__nested.290) (jump L.__nested.291))))
            (define L.__nested.290
                (begin
                (set! r14 r14)
                (set! r14 (+ r14 136))
                (set! r14 96)
                (jump L.__join.289)))
            (define L.__nested.291 (begin (set! r14 120) (jump L.__join.289)))
            (define L.__join.289 (begin (set! rax r14) (jump r15)))))
    '(module
        (define L.__main.292
            (begin (set! r15 r15) (set! r14 0) (jump L.__nested.290)))
        (define L.__nested.290
            (begin
            (set! r14 r14)
            (set! r14 (+ r14 136))
            (set! r14 96)
            (jump L.__join.289)))
        (define L.__nested.291 (begin (set! r14 120) (jump L.__join.289)))
        (define L.__join.289 (begin (set! rax r14) (jump r15)))))

(check-equal?
    (resolve-predicates
        '(module
            (define L.__main.142
                (begin
                (set! r15 r15)
                (set! r14 40)
                (if (true) (jump L.__nested.140) (jump L.__nested.141))))
            (define L.__nested.140
                (begin
                (set! r14 r14)
                (set! r14 (+ r14 136))
                (set! r14 96)
                (jump L.__join.139)))
            (define L.__nested.141 (begin (set! r14 120) (jump L.__join.139)))
            (define L.__join.139 (begin (set! rax r14) (jump r15)))))
    '(module
        (define L.__main.142
            (begin (set! r15 r15) (set! r14 40) (jump L.__nested.140)))
        (define L.__nested.140
            (begin
            (set! r14 r14)
            (set! r14 (+ r14 136))
            (set! r14 96)
            (jump L.__join.139)))
        (define L.__nested.141 (begin (set! r14 120) (jump L.__join.139)))
        (define L.__join.139 (begin (set! rax r14) (jump r15)))))

(check-equal?
    (resolve-predicates
        '(module
            (define L.__main.286
                (begin
                (set! r15 r15)
                (if (true) (jump L.__nested.284) (jump L.__nested.285))))
            (define L.__nested.284
                (begin
                (set! r14 32)
                (set! r14 (+ r14 40))
                (set! r14 r14)
                (set! r14 r14)
                (jump L.__join.283)))
            (define L.__nested.285 (begin (set! r14 r14) (jump L.__join.283)))
            (define L.__join.283 (begin (set! rax r14) (jump r15)))))
    '(module
        (define L.__main.286 (begin (set! r15 r15) (jump L.__nested.284)))
        (define L.__nested.284
            (begin
            (set! r14 32)
            (set! r14 (+ r14 40))
            (set! r14 r14)
            (set! r14 r14)
            (jump L.__join.283)))
        (define L.__nested.285 (begin (set! r14 r14) (jump L.__join.283)))
        (define L.__join.283 (begin (set! rax r14) (jump r15)))))

(check-equal?
    (resolve-predicates
         '(module
            (define L.__main.149
                (begin
                (set! r15 r15)
                (set! r14 8)
                (set! r14 r14)
                (set! r13 r14)
                (set! r13 (+ r13 r14))
                (set! r14 64)
                (set! r13 r14)
                (if (true) (jump L.__nested.147) (jump L.__nested.148))))
            (define L.__nested.147
                (begin (set! r13 r14) (set! r13 (+ r13 56)) (set! rax 64) (jump r15)))
            (define L.__nested.148 (begin (set! rax 72) (jump r15)))))
    '(module
        (define L.__main.149
            (begin
            (set! r15 r15)
            (set! r14 8)
            (set! r14 r14)
            (set! r13 r14)
            (set! r13 (+ r13 r14))
            (set! r14 64)
            (set! r13 r14)
            (jump L.__nested.147)))
        (define L.__nested.147
            (begin (set! r13 r14) (set! r13 (+ r13 56)) (set! rax 64) (jump r15)))
        (define L.__nested.148 (begin (set! rax 72) (jump r15)))))