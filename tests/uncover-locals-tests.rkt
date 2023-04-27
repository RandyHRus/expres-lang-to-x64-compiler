#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    "../compiler.rkt"
    rackunit
    rackunit/text-ui)

(check-equal? (uncover-locals
    '(module ((new-frames ())) (begin (set! x.1 0) (set! y.1 x.1) (set! y.1 (+ y.1 x.1)) (jump r15))))
    '(module
        ((new-frames ()) (locals (y.1 x.1)))
        (begin (set! x.1 0) (set! y.1 x.1) (set! y.1 (+ y.1 x.1)) (jump r15))))

(check-equal? (uncover-locals
        '(module ((new-frames ())) (begin (set! x.1 0) (set! y.1 x.1) (set! y.1 (+ y.1 x.1)) (jump r15))))
        '(module
            ((new-frames ()) (locals (y.1 x.1)))
            (begin (set! x.1 0) (set! y.1 x.1) (set! y.1 (+ y.1 x.1)) (jump r15))))

(check-equal? 
    (uncover-locals
        '(module ((new-frames ())) 
            (begin 
                (set! x.1 0) 
                (set! y.1 x.1)
                (set! y.1 (+ y.1 x.1))
                (if (< p.5 5)
                    (if (< o.6 i.7)
                        (set! k.3 5)
                        (set! k.4 6))
                    (set! k.3 5))
                (if (< e.5 5)
                    (if (< e.6 e.7)
                        (set! g.3 5)
                        (begin 
                            (set! j.3 5)
                            (set! p.3 5)))
                    (set! k.3 5))
                (jump r15))))
        '(module
            ((new-frames ())
            (locals (e.5 j.3 p.3 g.3 e.7 e.6 p.5 k.4 k.3 i.7 o.6 y.1 x.1)))
            (begin
                (set! x.1 0)
                (set! y.1 x.1)
                (set! y.1 (+ y.1 x.1))
                (if (< p.5 5) (if (< o.6 i.7) (set! k.3 5) (set! k.4 6)) (set! k.3 5))
                (if (< e.5 5)
                (if (< e.6 e.7) (set! g.3 5) (begin (set! j.3 5) (set! p.3 5)))
                (set! k.3 5))
                (jump r15))))

;; new uncover-locals tests

(check-equal? (uncover-locals
    '(module
        ((new-frames ()))
        (define L.main.1
            ((new-frames ()))
            (begin
            (set! x.1 10)
            (if (true)
                (begin (set! x.2 11) (set! x.3 12) (jump L.main.1 x.1 r10 fv0))
                (jump r15))))
        (jump L.main.1 x.2)))
    '(module
        ((new-frames ()) (locals ()))
        (define L.main.1
            ((new-frames ()) (locals (x.1 x.2 x.3)))
            (begin
            (set! x.1 10)
            (if (true)
                (begin (set! x.2 11) (set! x.3 12) (jump L.main.1 x.1 r10 fv0))
                (jump r15))))
        (jump L.main.1 x.2)))

(check-equal? (uncover-locals
    '(module
        ((new-frames ()))
        (define L.main.1
            ((new-frames ()))
            (begin
                (set! x.1 10)
                (jump r15)))
        (begin
            (set! y.2 1)
            (jump r15))))
    '(module
        ((new-frames ()) (locals (y.2)))
        (define L.main.1
            ((new-frames ()) (locals (x.1)))
            (begin (set! x.1 10) (jump r15)))
        (begin (set! y.2 1) (jump r15))))

(check-equal? (uncover-locals
    '(module
        ((new-frames ()))
        (define L.main.1
            ((new-frames ()))
            (begin
                (set! x.1 10)
                (jump r15)))
        (define L.main.2
            ((new-frames ()))
            (begin
                (set! x.1 10)
                (jump o.10 p.11 t.6)))
        (begin
            (set! y.2 u.8)
            (jump r15))))
    '(module
        ((new-frames ()) (locals (y.2 u.8)))
        (define L.main.1
            ((new-frames ()) (locals (x.1)))
            (begin (set! x.1 10) (jump r15)))
        (define L.main.2
            ((new-frames ()) (locals (x.1 o.10)))
            (begin (set! x.1 10) (jump o.10 p.11 t.6)))
        (begin (set! y.2 u.8) (jump r15))))


(check-equal? (uncover-locals
    '(module
        ((new-frames ()))
        (define L.main.1
            ((new-frames ()))
            (begin
                (set! x.1 fv1)
                (jump r15)))
        (define L.main.2
            ((new-frames ()))
            (begin
                (set! x.1 r10)
                (jump o.10 p.11 t.6)))
        (begin
            (set! fv10 u.8)
            (jump r15))))
    '(module
        ((new-frames ()) (locals (u.8)))
        (define L.main.1
            ((new-frames ()) (locals (x.1)))
            (begin (set! x.1 fv1) (jump r15)))
        (define L.main.2
            ((new-frames ()) (locals (x.1 o.10)))
            (begin (set! x.1 r10) (jump o.10 p.11 t.6)))
        (begin (set! fv10 u.8) (jump r15))))

(check-equal? (uncover-locals
    '(module
        ((new-frames ()))
        (define L.main.1
            ((new-frames ()))
            (begin
                (set! x.1 fv1)
                (return-point L.rp.1
                    (begin
                        (set! k.4 1)
                        (jump k.5 k.6 k.7)))
                (jump r15)))
        (define L.main.2
            ((new-frames ()))
            (begin
                (return-point L.rp.1
                    (begin
                        (set! t.3 1)
                        (jump r15)))
                (set! x.1 r10)
                (jump o.10 p.11 t.6)))
        (begin
            (return-point L.rp.1
            (begin
                (set! k.8 1)
                (jump k.8 k.10 k.11)))
            (set! fv10 u.8)
            (jump r15))))
    '(module
        ((new-frames ()) (locals (u.8 k.8)))
        (define L.main.1
            ((new-frames ()) (locals (k.5 k.4 x.1)))
            (begin
            (set! x.1 fv1)
            (return-point L.rp.1 (begin (set! k.4 1) (jump k.5 k.6 k.7)))
            (jump r15)))
        (define L.main.2
            ((new-frames ()) (locals (x.1 t.3 o.10)))
            (begin
            (return-point L.rp.1 (begin (set! t.3 1) (jump r15)))
            (set! x.1 r10)
            (jump o.10 p.11 t.6)))
        (begin
            (return-point L.rp.1 (begin (set! k.8 1) (jump k.8 k.10 k.11)))
            (set! fv10 u.8)
            (jump r15))))