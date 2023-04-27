#lang racket
(require
rackunit
rackunit/text-ui
cpsc411/test-suite/public/v3
"compiler.rkt")

(define compile
  (apply
   compose   (reverse
    (list
     Uniquify
     implement-fafe-primops
     specify-representation
     remove-complex-opera*
     Sequentialize-let
     normalize-bind
     impose-calling-conventions
     select-instructions
     uncover-locals
     undead-analysis
     conflict-analysis
     assign-call-undead-variables
     allocate-frames
     assign-registers
     assign-frame-variables
     replace-locations
     implement-fvars
     expose-basic-blocks
     resolve-predicates
     flatten-program
     patch-instructions
     generate-x64))))


(compile 
    '(module (define swap (lambda (x y) (if (call < y x) x (call swap y x)))) (call swap 1 2)))
