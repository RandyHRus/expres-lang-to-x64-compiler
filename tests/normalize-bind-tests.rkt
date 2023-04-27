#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    cpsc411/langs/v5
    "../compiler.rkt"
    rackunit)

(check-equal? (normalize-bind '(module
  (define L.id1.1 (lambda (x.1) x.1))
  (define L.id2.2 (lambda (x.2) x.2))
  (begin (set! y.3 (if (true) L.id1.1 L.id2.2)) (call y.3 5))))
          '(module
  (define L.id1.1 (lambda (x.1) x.1))
  (define L.id2.2 (lambda (x.2) x.2))
  (begin (if (true) (set! y.3 L.id1.1) (set! y.3 L.id2.2)) (call y.3 5))))

(check-equal? (normalize-bind '(module
  (if (true)
    (if (begin (set! y.2 11) (set! z.1 15) (> y.2 z.1)) 14 15)
    (begin (set! z.3 12) (begin (set! z.5 15) (set! y.4 1) (+ z.5 y.4))))))
'(module
  (if (true)
    (if (begin (set! y.2 11) (set! z.1 15) (> y.2 z.1)) 14 15)
    (begin (set! z.3 12) (begin (set! z.5 15) (set! y.4 1) (+ z.5 y.4))))))

(check-equal? (normalize-bind '(module
  (define L.id1.1 (lambda (x.1 x.3) x.1))
  (define L.id2.2 (lambda (x.2 x.4) x.2))
  (begin (set! y.3 (if (true) L.id1.1 L.id2.2)) (call y.3 5 1))))
'(module
  (define L.id1.1 (lambda (x.1 x.3) x.1))
  (define L.id2.2 (lambda (x.2 x.4) x.2))
  (begin (if (true) (set! y.3 L.id1.1) (set! y.3 L.id2.2)) (call y.3 5 1))))

(check-equal? (normalize-bind '(module
  (define L.id1.1 (lambda (x.1 x.3) x.1))
  (define L.id2.2 (lambda (x.2 x.4) (begin (set! x.2 (if (true) 1 0)) x.2)))
  (begin (set! y.3 (if (true) L.id1.1 L.id2.2)) (call y.3 5 1))))
              '(module
  (define L.id1.1 (lambda (x.1 x.3) x.1))
  (define L.id2.2
    (lambda (x.2 x.4) (begin (if (true) (set! x.2 1) (set! x.2 0)) x.2)))
  (begin (if (true) (set! y.3 L.id1.1) (set! y.3 L.id2.2)) (call y.3 5 1))))

(check-equal? (normalize-bind '(module
  (define L.id1.1 (lambda (x.1 x.3) x.1))
  (define L.id2.2 (lambda (x.2 x.4) (begin (set! x.2 (begin (set! x.2 2) x.2)) x.2)))
  (begin (set! y.3 (if (true) L.id1.1 L.id2.2)) (call y.3 5 1))))
              '(module
  (define L.id1.1 (lambda (x.1 x.3) x.1))
  (define L.id2.2
    (lambda (x.2 x.4) (begin (begin (set! x.2 2) (set! x.2 x.2)) x.2)))
  (begin (if (true) (set! y.3 L.id1.1) (set! y.3 L.id2.2)) (call y.3 5 1))))

(check-equal? (normalize-bind '(module
  (define L.id1.1 (lambda (x.1 x.3) x.1))
  (define L.id2.2 (lambda (x.2 x.4) (begin (set! x.2 (begin (set! x.2 2) x.2)) x.2)))
  (begin (set! y.3 (begin (set! x.2 (begin (set! x.2 L.id1.1) x.2)) x.2)) (call y.3 5 1))))
   '(module
  (define L.id1.1 (lambda (x.1 x.3) x.1))
  (define L.id2.2
    (lambda (x.2 x.4) (begin (begin (set! x.2 2) (set! x.2 x.2)) x.2)))
  (begin
    (begin (begin (set! x.2 L.id1.1) (set! x.2 x.2)) (set! y.3 x.2))
    (call y.3 5 1))))

(check-equal? 
    (normalize-bind 
        '(module
            (begin
                (set! x.62 20)
                (set! y.63 21)
                (if (not (> x.62 12))
                    (if
                    (if
                    (begin
                        (set! z.64 x.62)
                        (< y.63 z.64))
                    (true)
                    (false))
                    10
                    12)
                    (+ x.62 y.63)))))
    '(module
    (begin
        (set! x.62 20)
        (set! y.63 21)
        (if (not (> x.62 12))
        (if (if (begin (set! z.64 x.62) (< y.63 z.64)) (true) (false)) 10 12)
        (+ x.62 y.63)))))