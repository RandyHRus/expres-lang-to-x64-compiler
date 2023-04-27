#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    "../compiler.rkt"
    rackunit
    rackunit/text-ui)

(check-equal? 
  (optimize-predicates 
    '(module (begin (set! r15 (bitwise-and r15 r15)) (jump r15))))
  '(module (begin (set! r15 (bitwise-and r15 r15)) (jump r15))))

(check-equal? 
  (optimize-predicates 
    '(module (begin (set! r15 1) (set! r15 (bitwise-and r15 r15)) (jump r15))))
  '(module (begin (set! r15 1) (set! r15 (bitwise-and r15 r15)) (jump r15))))

(check-equal? 
  (optimize-predicates 
    '(module (begin (set! r15 1) (set! r15 (arithmetic-shift-right r15 r15)) (jump r15))))
  '(module
    (begin (set! r15 1) (set! r15 (arithmetic-shift-right r15 r15)) (jump r15))))

(check-equal? 
  (optimize-predicates 
    '(module 
        (if (begin (set! r14 1) (set! r15 (bitwise-and r15 r14)) (> r15 r14))
         (jump r15)
         (jump r15))))
  '(module
    (if (begin (set! r14 1) (set! r15 (bitwise-and r15 r14)) (> r15 r14))
      (jump r15)
      (jump r15))))

(check-equal? 
  (optimize-predicates 
    '(module 
        (if (begin (set! r15 (bitwise-and r15 1)) (> r15 0))
         (jump r15)
         (jump r15))))
  '(module
    (if (begin (set! r15 (bitwise-and r15 1)) (> r15 0)) (jump r15) (jump r15))))

(check-equal? 
  (optimize-predicates 
    '(module 
        (if (begin (set! r15 (bitwise-ior r15 1)) (set! r14 (bitwise-xor r14 2)) (> r15 r14))
         (jump r15)
         (jump r15))))
  '(module
  (if (begin
        (set! r15 (bitwise-ior r15 1))
        (set! r14 (bitwise-xor r14 2))
        (> r15 r14))
    (jump r15)
    (jump r15))))