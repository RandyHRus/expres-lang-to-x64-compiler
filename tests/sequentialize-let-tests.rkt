#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    cpsc411/langs/v5
    "../compiler.rkt"
    rackunit)

(check-equal? (sequentialize-let '(module
  (let ((x.1 1))
    (let ((y.2 (let ((z.3 3)) z.3)))
      (let ((z.4 (let ((y.5 2)) (+ y.5 y.5))))
        (if (let ((x.6 6)) (> x.6 7)) 
            (call x.1 y.2 3) 
            (call x.1 y.2 3) ))))))
    '(module
    (begin
        (set! x.1 1)
        (begin
        (set! y.2 (begin (set! z.3 3) z.3))
        (begin
            (set! z.4 (begin (set! y.5 2) (+ y.5 y.5)))
            (if (begin (set! x.6 6) (> x.6 7))
            (call x.1 y.2 3)
            (call x.1 y.2 3)))))))

(check-equal? (sequentialize-let '(module
    (define L.test.1 (lambda (k.1 k.2) (call L.test.1 3)) )
    (call x.1 y.2 3)))      
    '(module
        (define L.test.1 (lambda (k.1 k.2) (call L.test.1 3)))
        (call x.1 y.2 3)))

(check-equal? (sequentialize-let '(module
  (let ((x.1 1))
    (let ((y.2 (let ((z.3 (bitwise-xor y.5 y.5))) (bitwise-ior y.5 y.5))))
      (let ((z.4 (let ((y.5 (arithmetic-shift-right y.5 y.5))) (bitwise-and y.5 y.5))))
        (if (let ((x.6 6)) (> x.6 7)) 
            (call x.1 y.2 3) 
            (call x.1 y.2 3) ))))))     
    '(module
        (begin
            (set! x.1 1)
            (begin
            (set! y.2 (begin (set! z.3 (bitwise-xor y.5 y.5)) (bitwise-ior y.5 y.5)))
            (begin
                (set! z.4
                (begin
                    (set! y.5 (arithmetic-shift-right y.5 y.5))
                    (bitwise-and y.5 y.5)))
                (if (begin (set! x.6 6) (> x.6 7))
                (call x.1 y.2 3)
                (call x.1 y.2 3)))))))