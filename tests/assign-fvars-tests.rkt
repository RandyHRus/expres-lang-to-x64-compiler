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

; ;; Test case with no local
; (check-equal?
;     (assign-fvars
;         '(module
;             ((locals ()))
;             (begin
;                 (halt 1))))
;     '(module ((locals ()) (assignment ())) (begin (halt 1))))

; ;; Test case with one local
; (check-equal?
;     (assign-fvars
;         '(module
;             ((locals (x.1)))
;             (begin
;                 (set! x.1 0)
;                 (halt x.1))))
;         '(module
;             ((locals (x.1)) (assignment ((x.1 fv0))))
;             (begin (set! x.1 0) (halt x.1))))

; ;; Test case with multiple locals
; (check-equal?
;     (assign-fvars
;         '(module
;             ((locals (x.1 y.1 w.1)))
;             (begin
;                 (set! x.1 0)
;                 (set! y.1 x.1)
;                 (set! w.1 1)
;                 (set! w.1 (+ w.1 y.1))
;                 (halt w.1))))
;     '(module
;         ((locals (x.1 y.1 w.1)) (assignment ((x.1 fv2) (y.1 fv1) (w.1 fv0))))
;             (begin
;                 (set! x.1 0)
;                 (set! y.1 x.1)
;                 (set! w.1 1)
;                 (set! w.1 (+ w.1 y.1))
;                 (halt w.1))))