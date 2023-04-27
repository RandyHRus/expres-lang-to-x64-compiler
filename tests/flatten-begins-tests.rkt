#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    cpsc411/langs/v5
    "../compiler.rkt"
    rackunit)

;;------------------------------------------------------------------------
;;-----No longer used. These tests are form previous milestones-----------
;;------------------------------------------------------------------------

; (check-equal? 
;     (flatten-begins
;         '(begin (set! fv2 1) (set! fv1 fv2) (set! fv1 (+ fv1 1)) (set! fv0 fv1) (set! fv0 (+ fv0 1)) (halt fv0)))
;     '(begin
;         (set! fv2 1)
;         (set! fv1 fv2)
;         (set! fv1 (+ fv1 1))
;         (set! fv0 fv1)
;         (set! fv0 (+ fv0 1))
;         (halt fv0)))

; (check-equal?
;     (flatten-begins
;         '(begin 
;             (begin (set! fv0 1) (set! fv1 2)) 
;             (begin (begin (set! fv0 (+ fv0 fv1)))) 
;             (halt fv0)))
;     '(begin 
;         (set! fv0 1) 
;         (set! fv1 2) 
;         (set! fv0 (+ fv0 fv1)) 
;         (halt fv0)))

; (check-equal?
;     (flatten-begins
;         '(begin 
;             (begin 
;                 (set! fv0 1) 
;                 (begin (set! fv1 2) (set! fv2 3))) 
;             (begin 
;                 (begin (set! fv0 (+ fv0 fv1)))) 
;             (halt fv0)))
;     '(begin
;         (set! fv0 1)
;         (set! fv1 2)
;         (set! fv2 3)
;         (set! fv0 (+ fv0 fv1))
;         (halt fv0)))

; (check-equal?
;     (flatten-begins
;             '(halt 5))
;     '(begin (halt 5)))