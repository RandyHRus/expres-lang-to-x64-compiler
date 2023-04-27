#lang racket

(require
 cpsc411/compiler-lib
 cpsc411/ptr-run-time
 cpsc411/langs/v2
 cpsc411/graph-lib
 cpsc411/info-lib
 racket/set
 rackunit)

(provide
 uniquify
 implement-safe-primops
 specify-representation
 remove-complex-opera*
 sequentialize-let
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
 optimize-predicates
 expose-basic-blocks
 resolve-predicates
 flatten-program
 patch-instructions
 generate-x64)

;; Stubs; remove or replace with your definitions.
(define-values (;uniquify
                ;implement-safe-primops
                ;specify-representation
                ;remove-complex-opera*
                ;sequentialize-let
                ;normalize-bind
                ;impose-calling-conventions
                ;select-instructions
                ;uncover-locals
                ;undead-analysis
                ;conflict-analysis
                ;assign-call-undead-variables
                ;allocate-frames
                ;assign-registers
                ;replace-locations
                ;assign-frame-variables
                ;implement-fvars
                ;optimize-predicates
                ;expose-basic-blocks
                ;resolve-predicates
                ;flatten-program
                ;patch-instructions
                ;generate-x64
                )
  (values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ;values
   ))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                          MILESTONE 2                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; asm-lang-v2 -> nested-asm-lang-v2
;; Compiles Asm-lang v2 to Nested-asm-lang v2, replacing each abstract location with a physical location.
(define (assign-homes p)
  (replace-locations (assign-fvars (uncover-locals p))))


;; asm-lang-v2/locals -> asm-lang-v2/assignments
;; Compiles Asm-lang v2/locals to Asm-lang v2/assignments, by assigning each abstract location from the locals info
;; field to a fresh frame variable.
(define (assign-fvars p)
  (match p
    [`(module ((locals (,ls ...))) ,tail)
     (define fvar-i 0)
     (define dict
       (for/fold
           ([ctx `()])
           ([l ls])
         (begin0
           (dict-set ctx l (make-fvar fvar-i))
           (set! fvar-i (add1 fvar-i)))))

     (define asmts
       (for/fold
        ([ctx '()])
        ([key (dict-keys dict)]
         [val (dict-values dict)])
         (cons (list key val) ctx)))

     (set! asmts (reverse asmts))
     
     `(module ((locals ,ls) (assignment ,asmts)) ,tail)]))

;; nested-asm-lang-v2 -> para-asm-lang-v2
;; Flatten all nested begin expressions.
(define (flatten-begins p)

  ;; (nested-asm-lang-v2 tail) -> List of (para-asm-lang-v2 effect) and `(halt ,triv)
  (define (fb-tail t)
    (match t
      [`(halt ,triv) (list `(halt ,triv))]
      [`(begin ,efx ... ,tail)
       (define fb-efx
         (apply append (map fb-effect efx)))
       (define fb-t-efx (fb-tail tail))
       (append fb-efx fb-t-efx)]))

  ;; (nested-asm-lang-v2 effect) -> List of (para-asm-lang-v2 effect)
  (define (fb-effect e)
    (match e
      [`(set! ,loc1 (,binop ,loc1 ,triv)) (list e)]
      [`(set! ,loc1 ,triv) (list e)]
      [`(begin ,efx ... ,ef) (append efx (list ef))]))
  
  (match p
    [tail
     (define efx (fb-tail tail))
     (make-begin-effect efx)]))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                          MILESTONE 3                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Compiles Asm-lang v2 to Nested-asm-lang v2, 
;; replacing each abstract location with a physical location. 
;; This version performs graph-colouring register allocation.
;;
;; asm-lang-v2? -> nested-asm-lang-v2?
(define (assign-homes-opt p)
  (replace-locations (assign-registers (conflict-analysis (undead-analysis (uncover-locals p))))))
 

;; Values-lang v3 -> x64
;; compiles using assign-homes
#;
(define (compile-m2 p)
    (parameterize ([current-pass-list (list
                      check-values-lang
                      uniquify
                      sequentialize-let
                      normalize-bind
                      select-instructions
                      assign-homes
                      flatten-begins
                      patch-instructions
                      implement-fvars
                      generate-x64
                      wrap-x64-run-time
                      wrap-x64-boilerplate)])
      (compile p)))

;; Values-lang v3 -> x64
;; compiles using assign-homes-opt
#;
(define (compile-m3 p)
  (parameterize ([current-pass-list (list
                      check-values-lang
                      uniquify
                      sequentialize-let
                      normalize-bind
                      select-instructions
                      assign-homes-opt
                      flatten-begins
                      patch-instructions
                      implement-fvars
                      generate-x64
                      wrap-x64-run-time
                      wrap-x64-boilerplate)])
      (compile p)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                          MILESTONE 4                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(define (link-paren-x64 p)
  (TODO "Design and implement link-paren-x64 for Exercise 2."))

;; Exercise 3
;; paren-x64-rt-v4 -> int64
#;
(define (interp-paren-x64 p)

  ;; dict-of(loc -> int64) Natural (listof statement) statement -> int64
  ;; Runs statement `s`, which is expected to be the `pc`th instruction of
  ;; `los`, modifying the environment and incrementing the program counter,
  ;; before executing the next instruction in `los`.
  (define (eval-statement env pc los s)
    (....
     (eval-program (.... env) (.... (add1 pc)) los)))

  ;; dict-of(loc -> int64) Natural (listof statements) -> int64
  ;; Runs the program represented by `los` starting from instruction number
  ;; indicated by the program counter `pc`, represented as a natural number.
  ;; Program is finished when `pc` reaches the final instruction of `los`.
  (define (eval-program env pc los)
    (if (= pc (length los))
        (dict-ref env 'rax)
        (eval-statement env pc los (list-ref los pc))))

  (TODO "Redesign and implement interp-paren-x64 for Exercise 3."))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                          MILESTONE 7                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; block-asm-lang-v7? -> para-asm-lang-v7?
;; Compile Block-asm-lang v7 to Para-asm-lang v7
;; by flattening basic blocks into labeled instructions.
(define (flatten-program p)
  
  (define (flatten-b b)
    (match b
      [`(define ,label ,tail)
        (define flattened-tail (flatten-tail tail))
        (if (< (length flattened-tail) 1)
          `((with-label ,label ,(first flattened-tail)))
          `((with-label ,label ,(first flattened-tail)) ,@(rest flattened-tail)))]))
  
  ;; (block-asm-lang-v7? tail) -> (para-asm-lang-v7? tail)
  (define (flatten-tail tail)
    (match tail
      [`(halt ,opand)
        `(,tail)]
      [`(jump ,trg)
        `(,tail)]
      [`(begin ,effects ... ,tail)
        `(,@effects ,@(flatten-tail tail))]
      [`(if (,relop ,loc ,opand) (jump ,trg1) (jump ,trg2))
        `((compare ,loc ,opand) (jump-if ,relop ,trg1) (jump ,trg2))]))

  (match p
    [`(module ,bs ...)
      (define flattened-bs 
        (for/fold ([acc '()])
                  ([b bs]) 
          (append acc (flatten-b b))))
      `(begin ,@flattened-bs)]))

;; block-pred-lang-v4? -> block-asm-lang-v4?
;; Compile the Block-pred-lang v4 to Block-asm-lang v4 by
;; manipulating the branches of if statements to resolve branches.
(define (resolve-predicates p)

  ;; (block-pred-lang-v4? b) -> (block-asm-lang-v4? b)
  ;; Compiles a single b statement
  (define (resolve-predicates-b b)
    (match b
      [`(define ,label ,tail)
       `(define ,label ,(resolve-predicates-t tail))]))

  ;; (block-pred-lang-v4? tail) -> (block-asm-lang-v4? tail)
  ;; Compiles a single tail
  (define (resolve-predicates-t t)
    (match t
      [`(halt ,opand) t]
      [`(jump ,trg) t]
      [`(begin ,effects ... ,tail)
       (define rs-effects
         (map resolve-predicates-e effects))
       `(begin ,@rs-effects ,(resolve-predicates-t tail))]
      [`(if ,pred (jump ,trg1) (jump ,trg2))
       (resolve-predicates-p pred trg1 trg2)]))

  ;; (block-pred-lang-v4? pred trg trg) -> (block-asm-lang-v4? tail)
  ;; Resolves predicates for a simplified tail
  (define (resolve-predicates-p p trg1 trg2)
    (match p
      [`(,relop ,loc ,opand) `(if (,relop ,loc ,opand) (jump ,trg1) (jump ,trg2))]
      [`(true) `(jump ,trg1)]
      [`(false) `(jump ,trg2)]
      [`(not ,pred) (resolve-predicates-p pred trg2 trg1)]))

  ;; (block-pred-lang-v4? effect) -> (block-asm-lang-v4? effect)
  ;; Compiles a single effect 
  (define (resolve-predicates-e e)
    (match e
      [`(set! ,loc ,triv) e]
      [`(set! ,loc (,binop ,loc ,opand)) e]))
  
  (match p
    [`(module ,bs ...)
     `(module ,@(map resolve-predicates-b bs))]))

;; Values-bits-lang-v7? -> imp-mf-lang-v7?
; Compiles Values-bits-lang-v7 to imp-mf-lang-v7 by picking a particular order to implement let expressions using set!.
(define (sequentialize-let p)

  (define (convert-set as bs)
    (apply map (lambda(a b) `(set! ,a ,b)) (list as bs)))

  ;; (Values-bits-lang-v7 tail) -> (imp-mf-lang-v7 tail)
  (define (seq-let-tail tail)
    (match tail
      [`(let ([,als ,vs] ...) ,tail)
       (define svals
         (for/list ([val vs])
           (seq-let-value val)))
       (define set-stmts
         (convert-set als svals))
       `(begin ,@set-stmts ,(seq-let-tail tail))]
      [`(if ,pred ,tail1 ,tail2)
       (define new-pred (seq-let-pred pred))
       (define new-tail1 (seq-let-tail tail1))
       (define new-tail2 (seq-let-tail tail2))
       `(if ,new-pred ,new-tail1 ,new-tail2)]
      [`(call ,triv ,opand ...) tail]
      [value
       (seq-let-value value)]))

  ;; (Values-bits-lang-v7 value) -> (imp-mf-lang-v7 value)
  (define (seq-let-value val)
    (match val
      [`(let ([,als ,vs] ...) ,value)
       (define svals
         (for/list ([v vs])
           (seq-let-value v)))
       (define set-stmts
         (convert-set als svals))
       `(begin ,@set-stmts ,(seq-let-value value))]
      [`(,binop ,opand1 ,opand2) val]
      [`(if ,pred ,value1 ,value2)
       (define new-pred (seq-let-pred pred))
       (define new-value1 (seq-let-value value1))
       (define new-value2 (seq-let-value value2))
       `(if ,new-pred ,new-value1 ,new-value2)]
      [`(call ,triv ,opand ...) val]
      [triv triv]))

  ;; (Values-bits-lang-v7 pred) -> (imp-mf-lang-v7 pred)
  (define (seq-let-pred p)
    (match p
      [`(let ([,als ,vs] ...) ,pred)
       (define svals
         (for/list ([v vs])
           (seq-let-value v)))
       (define set-stmts
         (convert-set als svals))
       `(begin ,@set-stmts ,(seq-let-pred pred))]
      [`(if ,pred1 ,pred2 ,pred3)
       (define new-pred1 (seq-let-pred pred1))
       (define new-pred2 (seq-let-pred pred2))
       (define new-pred3 (seq-let-pred pred3))
       `(if ,new-pred1 ,new-pred2 ,new-pred3)]
      [`(not ,pred)
       `(not ,(seq-let-pred pred))]
      [`(false) p]
      [`(true) p]
      [`(,relop ,opand1 ,opand2) p]))

  ;; definition? -> definition?
  (define (seq-let-def d)
    (match d
      [`(define ,label (lambda (,aloc ...) ,tail))
       `(define ,label (lambda (,@aloc) ,(seq-let-tail tail)))]))
    
  (match p
    [`(module ,definitions ... ,tail)
     (define new-defs
       (for/list ([def definitions])
       (seq-let-def def)))
     `(module ,@new-defs ,(seq-let-tail tail))]))

; imp-mf-lang-v7? -> proc-imp-cmf-lang-v7?
; Compiles Imp-mf-lang v7 to Proc-imp-cmf-lang v7,
; pushing set! under begin so that the right-hand-side of each set!
; is simple value-producing operation.
(define (normalize-bind p)

  (define (triv? triv)
    (or (aloc? triv) (int64? triv)))

  ; creates a (set! aloc value) at position in value where there is no more rest-of-computation
  (define (append-to-last v aloc)
    (match v
      [`(begin ,effects ... ,value)
        `(begin ,@effects ,(append-to-last value aloc))]
      [`(if ,pred ,val1 ,val2)
        `(if ,pred
          ,(append-to-last val1 aloc)
          ,(append-to-last val2 aloc))]
      [_ `(set! ,aloc ,v)]))

  ; imp-mf-lang-v7? (tail) -> proc-imp-cmf-lang-v7? (tail)
  (define (nb-tail t)
    (match t
      [`(begin ,efx ... ,tail)
       (define nb-efx
            (for/list ([ef efx])
              (nb-effect ef)))
       `(begin ,@nb-efx ,(nb-tail tail))]
      [`(if ,pred1 ,tail1 ,tail2)
       (define nb-p-result (nb-pred pred1))
       `(if ,(nb-pred pred1) ,(nb-tail tail1) ,(nb-tail tail2))]
      [`(call ,triv ,opands ...) t]
      [value (nb-value value)]))

  ; imp-mf-lang-v7? (value) -> proc-imp-cmf-lang-v7? (value)
  (define (nb-value v) 
    (match v
      [`(begin ,efx ... ,value)
        (define nb-efx
         (for/list ([ef efx])
           (nb-effect ef)))
        `(begin ,@nb-efx ,(nb-value value))]
      [`(if ,pred ,value1 ,value2)
        `(if ,(nb-pred pred) ,(nb-value value1) ,(nb-value value2))]
      [`(call ,triv ,opands ...) v]
      [`(,binop ,opand1 ,opand2) v]
      [triv triv]))

  ; imp-mf-lang-v7? (effect) -> proc-imp-cmf-lang-v7? (effect)
  (define (nb-effect e)
    (match e
      [`(set! ,aloc ,value)
        (append-to-last (nb-value value) aloc)]
      [`(begin ,efx ... ,ef2)
       (define nb-efx
         (for/list ([ef efx])
           (nb-effect ef)))
       `(begin ,@nb-efx ,(nb-effect ef2))]
      [`(if ,pred1 ,effect1 ,effect2)
        `(if ,(nb-pred pred1) ,(nb-effect effect1) ,(nb-effect effect2))]))

  ; imp-mf-lang-v7? (pred) -> proc-imp-cmf-lang-v7? (pred)
  (define (nb-pred p)
    (match p
      [`(true)
       p]
      [`(false)
       p]
      [`(not ,pred)
       `(not ,(nb-pred pred))]
      [`(begin ,efx ... ,pred)
       (define nb-efx
         (for/list ([ef efx])
           (nb-effect ef)))
       `(begin ,@nb-efx ,(nb-pred pred))]
      [`(if ,pred1 ,pred2 ,pred3)
       `(if ,(nb-pred pred1) ,(nb-pred pred2) ,(nb-pred pred3))]
      [`(,relop ,opand1 ,opand2)
       p]))

  ; imp-mf-lang-v7? (definition) -> proc-imp-cmf-lang-v7? (definition)
  (define (nb-definition d)
    (match d
      [`(define ,label (lambda (,alocs ...) ,tail))
       `(define ,label (lambda (,@alocs) ,(nb-tail tail)))]))
  
   (match p
     [`(module ,definitions ... ,tail)
      (define def-result
        (for/list ([def definitions])
          (nb-definition def)))
      `(module ,@def-result ,(nb-tail tail))]))

;; asm-pred-lang-v7/locals? -> asm-pred-lang-v7/undead?
;; Performs undead analysis, compiling asm-pred-lang-v7/locals to 
;; asm-pred-lang-v7/undead by decorating programs with their undead-set trees.
(define (undead-analysis p)

  ;; (asm-pred-lang-v7/locals? tail) undead-set -> (values undead-set-tree undead-set call-undead-set)
  (define (analyse-tail t undead-out)
    (match t
      [`(begin ,effects ... ,tail) 
        (define-values (ust1 new-undead-out call-undead-set)
          (analyse-tail tail undead-out))
        (if (empty? effects)
          (let ()
            (values 
              (list ust1)
              new-undead-out
              call-undead-set))
          (let ()
            (define-values (ust2 new-undead-out-2 call-undead-set2)
              (analyse-effects effects new-undead-out))
            (values 
              `(,@ust2 ,ust1)
              new-undead-out-2
              (set-union call-undead-set call-undead-set2))))]
      [`(if ,pred ,tail1 ,tail2)
        (define-values (ust1 new-undead-out-1 call-undead-set)
          (analyse-tail tail1 undead-out))
        (define-values (ust2 new-undead-out-2 call-undead-set2)
          (analyse-tail tail2 undead-out))
        (define-values (ust3 new-undead-out-3 call-undead-set3)
          (analyse-pred pred (set-union new-undead-out-1 new-undead-out-2)))
        (values 
          (list ust3 ust1 ust2)
          new-undead-out-3
          (set-union call-undead-set call-undead-set2 call-undead-set3))]
      [`(jump ,trg ,locs ...)
        (values 
          locs
          (set-union (get-undead-set-trg trg) locs)
          '())]))

  ;; (asm-pred-lang-v7/locals? effect) undead-set? -> (values undead-set-tree undead-set call-undead-set)
  ;; References: location is definitely alive
  ;; Definitions: kills a location
  (define (analyse-effect e undead-out) 
    (match e
      [`(set! ,loc ,triv)
         #:when (triv? triv)
         (define new-undead-out (set-union (set-remove undead-out loc) (get-undead-set-triv triv)))
         (values undead-out new-undead-out '())]
      [`(set! ,loc_1 (,binop ,loc_1 ,opand))
        (define new-undead-out (set-union (set-remove undead-out loc_1) (set-union (get-undead-set-opand opand) `(,loc_1))))
        (values undead-out new-undead-out '())]
      [`(begin ,effects ...)      
        (define-values (ust new-undead-out call-undead-set)
          (analyse-effects effects undead-out))
        (values ust new-undead-out call-undead-set)]
      [`(if ,pred ,effect1 ,effect2)
        (define-values (ust1 new-undead-out-1 call-undead-set)
          (analyse-effect effect1 undead-out))
        (define-values (ust2 new-undead-out-2 call-undead-set2)
          (analyse-effect effect2 undead-out))
        (define-values (ust3 new-undead-out-3 call-undead-set3)
          (analyse-pred pred (set-union new-undead-out-1 new-undead-out-2)))
        (values 
          (list ust3 ust1 ust2)
          new-undead-out-3
          (set-union call-undead-set call-undead-set2 call-undead-set3))]
      [`(return-point ,label ,tail)
        (define-values (ust new-undead-out call-undead-set) (analyse-tail tail undead-out))
        ;; The call-undead field stores every abstract location or frame 
        ;; variable that is in the undead-out set of a return-point
        (define new-call-undead-set
          (filter (λ (x) (or (fvar? x) (aloc? x))) (set-union undead-out new-undead-out)))
        ;; return value register needs to be removed from undead-set after call.
        (define new-undead-out-2
          (set-remove 
            (set-union undead-out new-undead-out)
            (current-return-value-register)))
        (values 
          (list undead-out ust)
          new-undead-out-2
          (set-union call-undead-set new-call-undead-set))]))

  ;; (asm-pred-lang-v7/locals? effects) undead-set? -> (values undead-set-tree undead-set call-undead-set)
  (define (analyse-effects effects undead-out)
    (for/foldr ([ust '()] ;acc
                [new-undead-out undead-out]
                [call-undead-set '()]) ;acc
                ([new-effect effects])
      (define-values (new-ust undead-in new-call-undead-set)
        (analyse-effect new-effect new-undead-out))
      (values 
        (cons new-ust ust) 
        undead-in 
        (set-union call-undead-set new-call-undead-set))))

  ;; (asm-pred-lang-v7/locals? pred) undead-set? -> (values undead-set-tree undead-set call-undead-set)
  (define (analyse-pred pred undead-out)
    (match pred
      [`(begin ,effects ... ,pred)
        (define-values (ust1 new-undead-out call-undead-set)
          (analyse-pred pred undead-out))
        (if (empty? effects)
          (let ()
            (values 
              (list ust1)
              new-undead-out
              call-undead-set))
          (let ()
            (define-values (ust2 new-undead-out-2 call-undead-set2)
              (analyse-effects effects new-undead-out))
            (values 
              `(,@ust2 ,ust1)
              new-undead-out-2
              (set-union call-undead-set call-undead-set2))))]
      [`(,relop ,loc ,triv)
        (define new-undead-out (set-union (set-add undead-out loc) (get-undead-set-triv triv)))
        (values undead-out new-undead-out '())]
      ['(true)
        (values undead-out undead-out '())]
      ['(false)
        (values undead-out undead-out '())]
      [`(not ,pred)
        (analyse-pred pred undead-out)]
      [`(if ,pred ,pred2 ,pred3)
        (define-values (ust2 new-undead-out-2 call-undead-set2)
          (analyse-pred pred2 undead-out))
        (define-values (ust3 new-undead-out-3 call-undead-set3)
          (analyse-pred pred3 undead-out))
        (define-values (ust1 new-undead-out call-undead-set1)
          (analyse-pred pred (set-union new-undead-out-2 new-undead-out-3)))
        (values 
          (list ust1 ust2 ust3)
          new-undead-out
          (set-union call-undead-set1 call-undead-set2 call-undead-set3))]))

  ;; block -> block-result
  (define (undead-block b)
    (match b
      [`(define ,label ,info ,tail)
        (define-values (ust undead-out call-undead-set)
          (analyse-tail tail '()))
        (define new-info 
          (append info `((call-undead ,call-undead-set) (undead-out ,ust))))
        `(define ,label ,new-info ,tail)]))

  ;; (asm-pred-lang-v7/locals? opand) -> undead-set
  (define (get-undead-set-opand opand)
    (match opand
      [int64 #:when (int64? int64)
        '()]
      [loc #:when (loc? loc)
        `(,loc)]))

  ;; (asm-pred-lang-v7/locals? trg) -> undead-set
  (define (get-undead-set-trg trg)
    (match trg
      [label #:when (label? trg)
        '()]
      [loc #:when (loc? loc)
        `(,loc)]))

  ;; triv -> undead-set
  (define (get-undead-set-triv triv)
    (match triv
      [label #:when (label? triv)
        '()]
      [opand #:when (opand? opand)
        (get-undead-set-opand opand)]))

  (define (loc? l)
    (or (aloc? l) (rloc? l)))

  (define (rloc? r)
    (or (register? r) (fvar? r)))

  (define (opand? r)
    (or (int64? r) (loc? r)))

  (define (triv? t)
    (or (opand? t) (label? t)))
   
  (match p
    [`(module ,info ,blocks ... ,tail)
      (define-values (ust undead-out call-undead-set)
        (analyse-tail tail '()))
      (define blocks-result 
        (for/list ([block blocks])
          (undead-block block)))
      `(module 
        (,@info (call-undead ,call-undead-set) (undead-out ,ust))
        ,@blocks-result
        ,tail)]))

;; asm-pred-lang-v7/pre-framed? -> asm-pred-lang-v7/framed?
;; Compiles Asm-pred-lang-v7/pre-framed to Asm-pred-lang-v7/framed
;; by allocating frames for each non-tail call, and assigning all 
;; new-frame variables to frame variables in the new frame.
(define (allocate-frames p)

  ;; (asm-pred-lang-v7/pre-framed? pred) nb -> (asm-pred-lang-v7/framed? pred)
  (define (allocate-pred pred nb)
    (match pred
      [`(true) 
        `(true)]
      [`(false) 
        `(false)]
      [`(not ,pred1)
        `(not ,(allocate-pred pred1 nb))]
      [`(begin ,efx ... ,pred1)
        (define efx-result
          (for/list ([ef efx])
            (allocate-effect ef nb)))
        `(begin ,@efx-result ,(allocate-pred pred1 nb))]
      [`(if ,pred1 ,pred2 ,pred3)
          (define pred-result1 (allocate-pred pred1 nb))
          (define pred-result2 (allocate-pred pred2 nb))
          (define pred-result3 (allocate-pred pred3 nb))
          `(if ,pred-result1 ,pred-result2 ,pred-result3)]
      [`(,relop ,loc ,opand)
        pred]))
    
   ;; (asm-pred-lang-v7/pre-framed? tail) nb -> (asm-pred-lang-v7/framed? tail)
  (define (allocate-tail t nb)
    (match t
      [`(jump ,trg ,locs ...)
        t]
      [`(begin ,efx ... ,tail)
        (define efx-result
          (for/list ([ef efx])
            (allocate-effect ef nb)))
        `(begin ,@efx-result ,(allocate-tail tail nb))]
      [`(if ,pred ,tail1 ,tail2)
        (define pred-result (allocate-pred pred nb))
        (define tail-result1 (allocate-tail tail1 nb))
        (define tail-result2 (allocate-tail tail2 nb))
        `(if ,pred-result ,tail-result1 ,tail-result2)]))
    
  ;; (asm-pred-lang-v7/pre-framed? effect) nb -> (asm-pred-lang-v7/framed? effect)
  (define (allocate-effect e nb)
    (match e
      [`(set! ,loc (,binop ,loc ,opand))
        e]
      [`(set! ,loc ,triv)
        e]
      [`(begin ,efx ... ,effect)
        (define efx-result
          (for/list ([ef efx])
              (allocate-effect ef nb)))
        `(begin ,@efx-result ,(allocate-effect effect nb)) ]
      [`(if ,pred ,effect1 ,effect2)
        (define pred-result (allocate-pred pred nb))
        (define effect-result1 (allocate-effect effect1 nb))
        (define effect-result2 (allocate-effect effect2 nb))
        `(if ,pred-result ,effect-result1 ,effect-result2)]
      [`(return-point ,label ,tail)
        `(begin 
          (set! ,(current-frame-base-pointer-register) (- ,(current-frame-base-pointer-register) ,nb))
          (return-point ,label ,(allocate-tail tail nb))
          (set! ,(current-frame-base-pointer-register) (+ ,(current-frame-base-pointer-register) ,nb)))]))

  ;; (asm-pred-lang-v7/pre-framed? info) (asm-pred-lang-v7/pre-framed? tail) -> (values (asm-pred-lang-v7/framed? tail) info)
  (define (allocate-info-tail info tail)
    ;; compute n and nb
    (define n (compute-n (info-ref info 'call-undead) (info-ref info 'conflicts)))
    (define nb (* n (current-word-size-bytes)))
    ;; remove new-frames from locals
    (define locals (info-ref info 'locals))
    (for ([f (info-ref info 'new-frames)])
      (for ([aloc f])
        (set! locals (set-remove locals aloc))))
    (set! locals (reverse locals))
    ;; get new assignments
    (define new-assignments
      (for/foldr ([assignments '()])
                 ([this-frame (info-ref info 'new-frames)])
        (define-values (new-assignments-inner _)
          (for/foldr ([assignments-inner '()] ;;acc
                      [i n]) ;;acc
                      ([aloc (reverse this-frame)])
            (values (set-add assignments-inner `(,aloc ,(make-fvar i))) (add1 i))))
        (set-union assignments new-assignments-inner)))
    (define new-info (info-set (info-set (info-remove (info-remove (info-remove info 'undead-out) 'call-undead) 'new-frames) 'assignment (set-union (info-ref info 'assignment) new-assignments)) 'locals locals)) 
    (values (allocate-tail tail nb) new-info))
    
  ;; (asm-pred-lang-v7/pre-framed? block) -> (asm-pred-lang-v7/framed? block)
  (define (allocate-block b)
    (match b
      [`(define ,label ,info ,tail)
        (define-values (tail-result new-info) (allocate-info-tail info tail))
        `(define ,label ,new-info ,tail-result)]))

  ;; call-undead conflicts -> n
  (define (compute-n call-undead conflicts)
    (define largest-fvar-index 0) 
    ;; Find the largest fvar index
    (for ([loc call-undead])
      (if (fvar? loc)
        (set! largest-fvar-index (max largest-fvar-index (fvar->index loc)))
        (begin
          (let ([neighbours (get-neighbors conflicts loc)])  ;; find largest fvar in conflicts
            (for ([neighbour neighbours])
              (when (fvar? neighbour)
                (set! largest-fvar-index (max largest-fvar-index (fvar->index neighbour)))))))))
    ;; n is intuitively the length of the call undead-set,
    ;; however, we should extend to at least cover the largest frame variable
    (max (+ largest-fvar-index 2) (length call-undead)))

  (match p
    [`(module ,info ,blocks ... ,tail)
      (define blocks-result 
        (for/list ([block blocks])
          (allocate-block block)))
      (define-values (tail-result new-info) (allocate-info-tail info tail))
      `(module ,new-info ,@blocks-result ,tail-result)]))

;; asm-pred-lang-v7/undead? -> asm-lang-pred-lang-v7/conflicts?
;; Decorates a program with its conflict graph.
(define (conflict-analysis p)

  ;; graph? aloc? undead-set-tree? -> graph?
  ;; Returns the graph updated with any conflicts found between v
  ;; and the undead-out-set
  (define (analyse g v undead-out-set)
    (define new-g
         (if (not (graph-contains-v g v))
             (add-vertex g v)
             g))
       (for/fold ([new-g new-g])
                 ([undead-aloc undead-out-set])
         (if (not (eq? v undead-aloc))
             (add-edge new-g v undead-aloc)
             new-g)))

  ;; graph? aloc? -> boolean?
  ;; Returns true iff the graph contains the vertex
  (define (graph-contains-v g v)
      (for/fold ([acc #f])
                ([vertex-edges g])
        (or (equal? (list-ref vertex-edges 0) v) acc)))
  
  ;; (asm-pred-lang-v7/undead? tail) undead-set-tree? graph? -> graph?
  ;; Returns the graph updated with the conflicts found in tail
  (define (ca-tail tail ust g)
    (match (cons tail ust)
      [(cons `(begin ,effects ... ,tail) `(,usts ... ,tail-ust))
       (define effect-g
         (for/fold ([g g])
                   ([next-effect effects]
                    [next-ust usts])
           (ca-effect next-effect next-ust g)))
       (ca-tail tail tail-ust effect-g)]
      [`((if ,pred ,tail1 ,tail2) ,ust-pred ,ust-tail1 ,ust-tail2)
       (define pred-g (ca-pred pred ust-pred g))
       (define tail1-g (ca-tail tail1 ust-tail1 pred-g))
       (define tail2-g (ca-tail tail2 ust-tail2 tail1-g))
       tail2-g]
      [(cons `(jump ,trg ,loc ...) undead-out-set) ;; not a "move", add edges from aloc1 to every variable in undead-out-set except itself
       #:when (aloc? trg)
       (analyse g trg undead-out-set)]
      [_ g]))
  
  ;; (asm-pred-lang-v7/undead? effect) undead-set-tree? graph? -> graph?
  ;; Returns the graph updated with the conflicts found in effect
  (define (ca-effect effect ust g)
    (match (cons effect ust)
      [(cons `(set! ,aloc1 (,binop ,aloc1 ,triv)) ;; not a "move", add edges from aloc1 to every variable in undead-out-set except itself
             undead-out-set)
       (analyse g aloc1 undead-out-set)]
      [(cons `(set! ,aloc ,triv) ;; "move"
             undead-out-set)
       (analyse g aloc undead-out-set)]
      [(cons `(begin ,effects ...)
             `(,usts ...))
       (define new-g
         (for/fold ([g g])
                   ([next-effect effects]
                    [next-ust usts])
           (ca-effect next-effect next-ust g)))
       new-g]
      [(cons `(if ,pred ,effect1 ,effect2) `(,ust-pred ,ust-effect1 ,ust-effect2))
       (define pred-g (ca-pred pred ust-pred g))
       (define effect1-g (ca-effect effect1 ust-effect1 pred-g))
       (define effect2-g (ca-effect effect2 ust-effect2 effect1-g))
       effect2-g]
      [(cons `(return-point ,label ,tail) `(,undead-out-set ,tail-ust))
       (ca-tail tail tail-ust g)]))

  ;; (asm-pred-lang-v7/undead? pred) undead-set-tree? graph? -> graph?
  ;; Returns the graph updated with the conflicts found in pred
  (define (ca-pred pred ust g)
    (match (cons pred ust)
      [(cons `(true) undead-out-set) g]
      [(cons `(false) undead-out-set) g]
      [(cons `(not ,pred) ust)
       (ca-pred pred ust g)]
      [(cons `(begin ,effects ... ,pred)
             `(,usts ... ,pred-ust))
       (define new-g
         (for/fold ([g g])
                   ([next-effect effects]
                    [next-ust usts])
           (ca-effect next-effect next-ust g)))
       (ca-pred pred pred-ust new-g)]
      [(cons `(if ,pred1 ,pred2 ,pred3) `(,ust1 ,ust2 ,ust3))
       (define pred1-g (ca-pred pred1 ust1 g)) 
       (define pred2-g (ca-pred pred2 ust2 pred1-g))
       (define pred3-g (ca-pred pred3 ust3 pred2-g))
       pred3-g]
      [(cons `(,relop ,aloc ,triv)
              undead-out-set)
       (analyse g aloc undead-out-set)]))

  ;; definition? -> definition?
  ;; Where definition?:: `(define ,label ,info ,tail)
  ;; Returns the definition with the calculated conflicts in the block
  (define (ca-def def)
    (match def
      [`(define ,label ,info ,tail)
       `(define ,label ,(info-set info 'conflicts (ca-tail tail (info-ref info 'undead-out) '())) ,tail)]))

  (match p
    [`(module ,info ,defs ... ,tail)
     (define ca-defs
       (for/list ([def defs])
         (ca-def def)))
     `(module ,(info-set info 'conflicts (ca-tail tail (info-ref info 'undead-out) '()))
        ,@ca-defs
        ,tail)]))

; proc-imp-cmf-lang-v7? -> imp-cmf-lang-v7?
; Compiles Proc-imp-cmf-lang v7 to Imp-cmf-lang v7
; by imposing calling conventions on all calls (both tail and non-tail calls),
; and entry points. The registers used to passing parameters are defined by 
; current-parameter-registers, and the registers used for returning are defined 
; by current-return-address-register and current-return-value-register.
;
; Compared to the source, we remove the call form and replace
; it by the jump form. As described in Designing the Calling 
; Convention Translation, all calls are compiled to a sequence
; of set!s moving the arguments followed by a jump, and all 
; procedure definitions are compiled to a block that assigns
; the parameters, as directed by the calling convention.
(define (impose-calling-conventions p)

  (define fvar-i 0)

  ; (proc-imp-cmf-lang-v7 entry) return-address-register -> (imp-cmf-lang-v7 entry) new-frames
  (define (impose-entry e ra)
    ;; Note that init of return label is done at the block helper
    (match e
      [tail (impose-tail tail ra)]))
  
  ; (proc-imp-cmf-lang-v7 pred) -> (imp-cmf-lang-v7 pred) new-frames
  (define (impose-pred pr)
    (match pr
      [`(true)
        (values pr '())]
      [`(false)
        (values pr '())]
      [`(not ,pred)
        (define-values (impose-pred-result new-frames) (impose-pred pred))
        (values
          `(not ,impose-pred-result)
          new-frames)]
      [`(begin ,efx ... ,pred)
        (define-values (efx-result new-frames1) (impose-effects efx))
        (define-values (pred-result new-frames2) (impose-pred pred))
        (values
          `(begin ,@efx-result ,pred-result)
          (append new-frames1 new-frames2))]
      [`(if ,pred1 ,pred2 ,pred3)
        (define-values (impose-pred-result1 new-frames1) (impose-pred pred1))
        (define-values (impose-pred-result2 new-frames2) (impose-pred pred2))
        (define-values (impose-pred-result3 new-frames3) (impose-pred pred3))
        (values
          `(if ,impose-pred-result1 ,impose-pred-result2 ,impose-pred-result3)
          (append new-frames1 new-frames2 new-frames3))]
      [`(,relop ,opand1 ,opand2)
        (values pr '())]))

  (define (get-new-fvar)
    (begin
      (define fvar (make-fvar fvar-i))
      (set! fvar-i (+ 1 fvar-i))
      fvar))

  ; (proc-imp-cmf-lang-v7 tail) return-address-register -> (imp-cmf-lang-v7 tail) new-frames
  (define (impose-tail t ra)
    (match t
      [`(call ,triv ,opands ...)
        ; in case there isn't enough registers for all parameters, we need to create fvars
        (set! fvar-i 0)
        (define parameter-registers '())
        (for ([i (in-range (length opands))])
          (if (< i (length (current-parameter-registers)))
            (set! parameter-registers (append parameter-registers (list (list-ref (current-parameter-registers) i))))
            (set! parameter-registers (append parameter-registers (list (get-new-fvar))))))
        (values (create-jump triv opands ra parameter-registers) '())]
      [`(begin ,effects ... ,tail)
        (define-values (impose-tail-result new-frames1) (impose-tail tail ra))
        (define-values (impose-effects-result new-frames2) (impose-effects effects))
        (values
          `(begin ,@impose-effects-result ,impose-tail-result)
          (append new-frames2 new-frames1))]
      [`(if ,pred ,tail1 ,tail2)
        (define-values (impose-tail-result1 new-frames1) (impose-tail tail1 ra))
        (define-values (impose-tail-result2 new-frames2) (impose-tail tail2 ra))
        (define-values (impose-pred-result new-frames3) (impose-pred pred))
        (values
          `(if ,impose-pred-result
            ,impose-tail-result1
            ,impose-tail-result2)
          (append new-frames1 new-frames2 new-frames3))]
      [value
        (values 
          ;; We transform a value in tail position by moving it into the current-return-value-register,
          ;; and jumping to the return address stored in tmp-ra.
          `(begin (set! ,(current-return-value-register) ,value)
            (jump ,ra ,(current-frame-base-pointer-register) ,(current-return-value-register)))
          '())]))

  ; (proc-imp-cmf-lang-v7 value) -> (list of (imp-cmf-lang-v7 effect)) (imp-cmf-lang-v7 value) new-frames
  (define (impose-value v)
    (match v
      [`(call ,triv ,opands ...)
        ;; When we have non-tail calls, we create return-point.
        (define return-point-label (fresh-label))
        ; in case there isn't enough registers for all parameters, we need to create nfvs
        (define-values (parameter-registers new-frames)
          (for/fold ([regis '()] ;acc
                      [frames '()]) ;acc
                     ([i (in-range (length opands))])
            (if (< i (length (current-parameter-registers)))
              (values 
                (append regis (list (list-ref (current-parameter-registers) i))) 
                frames)
              (begin
                (let ((nfv (fresh 'nfv))) 
                  (values 
                    (append regis (list nfv))
                    (append frames (list nfv))))))))
        (define create-jump-result (create-jump triv opands return-point-label parameter-registers))
        (values `((return-point ,return-point-label ,create-jump-result)) (current-return-value-register) (list new-frames))]
      [`(,binop ,opand ,opand)
        (values '() v '())]
      [triv 
        (values '() v '())]))

  ; (proc-imp-cmf-lang-v7 (list of effect)) -> (imp-cmf-lang-v7 (list of effect)) new-frames
  (define (impose-effects efx)
    (for/fold ([effects-acc '()]
               [new-frames-acc '()])
              ([e efx])
      (define-values (impose-effect-result new-frames) (impose-effect e))
      (values `(,@effects-acc ,impose-effect-result) (append new-frames new-frames-acc))))

  ; (proc-imp-cmf-lang-v7 effect) -> (imp-cmf-lang-v7 effect) new-frames
  (define (impose-effect e)
    (match e
      [`(set! ,aloc ,value) 
        (define-values (effects value2 new-frames) (impose-value value))
        (if (> (length effects) 0)
          (values `(begin ,@effects (set! ,aloc ,value2)) new-frames)
          (values `(set! ,aloc ,value2) new-frames))]
      [`(begin ,efx ... ,effect)
        (define-values (impose-effects-result new-frames1) (impose-effects efx))
        (define-values (impose-effect-result new-frames2) (impose-effect effect))
        (values 
          `(begin ,@impose-effects-result ,impose-effect-result) 
          (append new-frames1 new-frames2))]
      [`(if ,pred ,effect1 ,effect2)
        (define-values (impose-effect-result1 new-frames1) (impose-effect effect1))
        (define-values (impose-effect-result2 new-frames2) (impose-effect effect2))
        (define-values (impose-pred-result new-frames3) (impose-pred pred))
        (values 
          `(if ,impose-pred-result ,impose-effect-result1 ,impose-effect-result2)
          (append new-frames1 new-frames2 new-frames3))]))
  
  ; (proc-imp-cmf-lang-v7 block) -> (imp-cmf-lang-v7 block)
  (define (impose-block d)
    (match d
      [`(define ,label (lambda (,alocs ...) ,entry))
        ; in case there isn't enough registers for all parameters,
        ; we need to use fvars
        (set! fvar-i 0)
        (define registers 
          (for/fold ([regis (current-parameter-registers)])
                    ([i (in-range (- (length alocs) (length (current-parameter-registers))))])
            (append regis (list (get-new-fvar)))))
        (define tmp-ra (fresh 'tmp-ra))
        (define register-sets 
          (for/list ([aloc alocs]
                     [reg registers])
            `(set! ,aloc ,reg)))
        (define-values (impose-entry-result new-frames) (impose-entry entry tmp-ra))
        `(define ,label ((new-frames ,new-frames))
          (begin (set! ,tmp-ra ,(current-return-address-register)) (begin ,@register-sets ,impose-entry-result)))]))

  ; (proc-imp-cmf-lang-v7 triv) (list of (proc-imp-cmf-lang-v7 opands)) return-address-register -> (imp-cmf-lang-v7 tail)
  (define (create-jump triv opands ra parameter-registers)

    (define-values (used-registers register-sets)
      (for/foldr ([used '()]
                  [sets '()])
                  ([op opands]
                   [reg parameter-registers])
        (values
          (set-add used reg)
          (set-add sets `(set! ,reg ,op)))))

    `(begin 
      ,@(reverse register-sets) 
      (set! ,(current-return-address-register) ,ra)
      (jump ,triv 
        ,(current-frame-base-pointer-register)
        ,(current-return-address-register)
        ,@used-registers)))

  (match p
    [`(module ,blocks ... ,entry)
      (define blocks-result 
        (for/list ([block blocks])
          (impose-block block)))
      (define tmp-ra (fresh 'tmp-ra))
      (define-values (impose-entry-result new-frames) (impose-entry entry tmp-ra))
      `(module ((new-frames ,new-frames)) ,@blocks-result (begin (set! ,tmp-ra ,(current-return-address-register)) ,impose-entry-result))]))

;; asm-lang-v7/conflicts? -> asm-pred-lang-v7/pre-framed?
;; Compiles Asm-pred-lang-v7/conflicts to Asm-pred-lang-v7/pre-framed
;; by pre-assigning all variables in the call-undead sets to frame variables.
(define (assign-call-undead-variables p)

  ;; number (Listof fvar?) -> number
  ;; Returns the lowest available fvar index
  (define (get-avail-fvar-i fvar-i taken-fvars)
    (if (not (member (make-fvar fvar-i) taken-fvars))
        fvar-i
        (get-avail-fvar-i (add1 fvar-i) taken-fvars)))
    
;; (Listof loc) graph? -> (Listof (Pair aloc? rloc?))
;; Takes in a list of locs (call undead variables) to be assigned,
;; the current conflict graph and returns the assignments list to fvars
  (define (acuv locs conflict-g)
    (match locs
      ['() '()]
      [(cons loc locs)  
       (define selected-loc loc)
       (define rest-locs locs)
       (define new-graph
         (remove-vertex conflict-g selected-loc))
       (define assignment (acuv rest-locs new-graph))
       ;; find the set of frame variables to which x cannot be assigned
       ;; conflicting fvs in neighbors + assigned fvs of neighbors
       (define neighbors (get-neighbors conflict-g selected-loc))
       (define conf-fvs (filter fvar? neighbors))
       ;; conf-assign-fvs first filters the assignment pairs such that it only contains those that are direct neighbors of the
       ;;   aloc we're currently looking at. It then creates a single list out of the filtered result, and filters it again to only
       ;;   to only include the fvars. The resulting variable contains any assigned fvars of the direct neighbors of the current aloc
       (define conf-assign-fvs (filter fvar? (apply append (filter (λ (pair) (member (first pair) neighbors)) assignment))))
       (define unavailable-fvs (append conf-fvs conf-assign-fvs))
       (define fvar-i (get-avail-fvar-i 0 unavailable-fvs))
       (define result `(,selected-loc ,(make-fvar fvar-i)))
       (cons result assignment)]))

  ;; definition? -> definition? with assignment in info
  (define (acuv-definition def)
    (match def
      [`(define ,label ,info ,tail)
       (define call-undead-vars (info-ref info 'call-undead))
       (define conflict-g (info-ref info 'conflicts))
       (define result (acuv call-undead-vars conflict-g))
       (define locals (info-ref info 'locals))
       (define new-locals (filter (λ (l) (not (member l call-undead-vars))) locals))
       `(define ,label ,(info-set (info-set info 'assignment result) 'locals new-locals) ,tail)]))

  (match p
    [`(module ,info ,definitions ... ,tail)
     (define acuv-defs
       (for/list ([def definitions])
         (acuv-definition def)))
     (define call-undead-vars (info-ref info 'call-undead))
     (define conflict-g (info-ref info 'conflicts))
     (define result (acuv call-undead-vars conflict-g))
     (define locals (info-ref info 'locals))
     (define new-locals (filter (λ (l) (not (member l call-undead-vars))) locals))
     `(module ,(info-set (info-set info 'assignment result) 'locals new-locals) ,@acuv-defs ,tail)]))

;; imp-cmf-lang-v7? -> asm-pred-lang-v7?
;; Compiles Imp-cmf-lang v7 to Asm-pred-lang v7, 
;; selecting appropriate sequences of abstract assembly
;; instructions to implement the operations of the source language.
(define (select-instructions p)

  ; (imp-cmf-lang-v7 value) -> (List-of (asm-pred-lang-v7 effect)) and (asm-pred-lang-v7 aloc)
  ; Assigns the value v to a fresh temporary, returning two values: the list of
  ; statements that implement the assignment in Loc-lang, and the aloc that the
  ; value is stored in.
  (define (assign-tmp v)
    (match v
      [`(,binop ,triv1 ,triv2)
       (define tmp (fresh))
       (define efx (list `(set! ,tmp ,triv1) `(set! ,tmp (,binop ,tmp ,triv2))))
       (values efx tmp)]
      [triv
        (define tmp (fresh))
        (define efx (list `(set! ,tmp ,triv)))
        (values efx tmp)]))

  ; (imp-cmf-lang-v7 tail) -> (asm-pred-lang-v7 tail)
  (define (select-tail t)
    (match t
      [`(begin ,efx ... ,tail)
       (define sel-efx
         (foldr append `() (map select-effect efx)))
       (make-begin-effect `(,@sel-efx ,(select-tail tail)))]
      [`(if ,pred ,tail1 ,tail2)
        `(if ,(select-pred pred) ,(select-tail tail1) ,(select-tail tail2))]
      [`(jump ,trg ,loc ...)
        t]))

  ; (imp-cmf-lang-v7 loc? value) -> Listof(asm-pred-lang-v7 effect) 
  (define (select-value l v)
    (match v
      [`(,binop ,opand1 ,opand2)
        (cond
          [(aloc? opand1) 
            (cond
              [(eq? opand1 l) (list `(set! ,l (,binop ,opand1 ,opand2)))]
              [else (list `(set! ,l ,opand1) `(set! ,l (,binop ,l ,opand2)))])]          
          [else  (list `(set! ,l ,opand1) `(set! ,l (,binop ,l ,opand2)))])]
      [triv (list `(set! ,l ,triv))]))

  ; (imp-cmf-lang-v7 effect) -> Listof(asm-pred-lang-v7 effect) 
  (define (select-effect e)
    (match e
      [`(set! ,loc ,value)
        (select-value loc value)]
      [`(begin ,efx ... ,ef)
        (define sel-efx
          (foldr append `() (map select-effect efx)))
        (list `(begin ,@sel-efx ,@(select-effect ef)))]
      [`(if ,pred ,effect1 ,effect2)
        (list `(if ,(select-pred pred) ,@(select-effect effect1) ,@(select-effect effect2)))]
      [`(return-point ,label ,tail)
        (list `(return-point ,label ,(select-tail tail)))]))

  ; (imp-cmf-lang-v7 pred) -> (asm-pred-lang-v7 pred)
  (define (select-pred p) 
    (match p
      [`(begin ,efx ... ,pred)
        (define sel-efx
          (foldr append `() (map select-effect efx)))
        `(begin ,@sel-efx ,(select-pred pred))]
      [`(,relop ,opand1 ,opand2)
        (cond 
          [(int64? opand1)
            (begin
              (define-values (efx tmp) (assign-tmp opand1))
              (make-begin-effect `(,@efx (,relop ,tmp ,opand2))))]
          [else p])]
      [`(true)
        p]
      [`(false)
        p]
      [`(not ,pred)
        `(not ,(select-pred pred))]
      [`(if ,pred1 ,pred2 ,pred3)
        `(if ,(select-pred pred1) ,(select-pred pred2) ,(select-pred pred3))]))

  ; (Imp-cmf-lang-v7 block) -> (asm-pred-lang-v7 block)
  (define (select-block b)
    (match b
      [`(define ,label ,info ,tail)
        `(define ,label ,info ,(select-tail tail))]))
  (match p
    [`(module ,info ,blocks ... ,tail)
      (define blocks-result 
        (for/list ([block blocks])
          (select-block block)))
      `(module ,info ,@blocks-result ,(select-tail tail))]))            

;; asm-pred-lang-v7? ->  asm-pred-lang-v7/locals?
;; Compiles Asm-pred-lang v7 to Asm-pred-lang v7/locals, 
;; analysing which abstract locations are used in each block,
;; and updating each block and the module with the set of variables in an info? fields.
(define (uncover-locals p)

  ;; (asm-pred-lang-v7 tail) -> (asm-pred-lang-v7/locals (list of aloc))
  (define (ul-tail t)
    (match t
      [`(begin ,efx ... ,tail)
      (define ul-effects-result
        (for/fold ([acc '()])
                  ([e efx])
          (set-union acc (ul-effect e))))
      (set-union ul-effects-result (ul-tail tail))]
      [`(if ,pred ,tail1 ,tail2)
        (set-union (ul-pred pred) (ul-tail tail1) (ul-tail tail2))]
      [`(jump ,trg ,loc ...)
        ;; loc is only metadata, don't need to put it into locals.
        (ul-trg trg)]))

  ;; (asm-pred-lang-v7 effect) -> (asm-pred-lang-v7/locals (list of aloc))
  (define (ul-effect e)
    (match e
      [`(set! ,loc1 (,binop ,loc1 ,opand))
       (set-union (ul-loc loc1) (ul-opand opand))]
      [`(set! ,loc ,triv)
       (set-union (ul-loc loc) (ul-triv triv))]
      [`(begin ,efx ... ,ef)
       (define ul-effects-result
        (for/fold ([acc '()])
                  ([e efx])
          (set-union acc (ul-effect e))))
       (set-union ul-effects-result (ul-effect ef))]
      [`(if ,pred ,effect1 ,effect2)
        (set-union (ul-pred pred) (ul-effect effect1) (ul-effect effect2))]
      [`(return-point ,label ,tail)
        (ul-tail tail)]))

  ;; (asm-pred-lang-v7 opand) -> (asm-pred-lang-v7/locals (list of aloc))
  (define (ul-opand o)
    (match o
      [int64 #:when (int64? o)
        '()]
      [loc #:when (loc? o)
        (ul-loc loc)]))

  ;; (asm-pred-lang-v7 trg) -> (asm-pred-lang-v7/locals (list of aloc))
  (define (ul-trg t)
    (match t
      [loc #:when (loc? t)
        (ul-loc loc)]
      [label 
        '()]))

  ;; (asm-pred-lang-v7 loc) -> (asm-pred-lang-v7/locals (list of aloc))
  (define (ul-loc l)
    (match l
      [aloc #:when (aloc? aloc)
        (list aloc)]
      [rloc #:when (rloc? rloc)
        '()]))

  ;; (asm-pred-lang-v7 triv) -> (asm-pred-lang-v7/locals (list of aloc))
  (define (ul-triv t)
    (match t
      [opand #:when (opand? opand) 
        (ul-opand opand)]
      [label #:when (label? label) 
        '()]))

  ;; (asm-pred-lang-v7 pred) -> (asm-pred-lang-v7/locals (list of aloc))
  (define (ul-pred p)
    (match p
      [`(begin ,efx ... ,pred)
        (define ul-effects-result
          (for/fold ([acc '()])
                    ([e efx])
            (set-union acc (ul-effect e))))
       (set-union ul-effects-result (ul-pred pred))]
      [`(,relop ,loc ,opand)
        (set-union (ul-loc loc) (ul-opand opand))]
      [`(true)
        '()]
      [`(false)
        '()]
      [`(not ,pred)
        (ul-pred pred)]
      [`(if ,pred1 ,pred2 ,pred3)
        (set-union (ul-pred pred1) (ul-pred pred2) (ul-pred pred3))]))

  ;; (asm-pred-lang-v7 (define label info tail)) -> (asm-pred-lang-v7/locals (list of aloc))
  (define (ul-block b)
    (match b
      [`(define ,label ,info ,tail)
        (define ul-tail-result
          (ul-tail tail))
        (define new-info (append info `((locals ,(set->list ul-tail-result)))))
        `(define ,label ,new-info ,tail)]))

  (define (loc? l)
    (or (aloc? l) (rloc? l)))

  (define (rloc? r)
    (or (register? r) (fvar? r)))

  (define (opand? r)
    (or (int64? r) (loc? r)))

  (match p
    [`(module ,info ,blocks ... ,tail)
      (define blocks-result 
        (for/list ([block blocks])
          (ul-block block)))
      (define ul-tail-result
        (ul-tail tail))
      (define new-info (append info `((locals ,(set->list ul-tail-result)))))
      `(module ,new-info ,@blocks-result ,tail)]))

;; nested-asm-lang-fvars-v7? -> nested-asm-lang-v7?
;; Reifies fvars into displacement mode operands.
(define (implement-fvars p)
  
  (define fbp (current-frame-base-pointer-register))

  ;; (nested-asm-lang-fvars-v7? fvar?) number? -> (nested-asm-lang-v7? addr)
  ;; Concretizes fvar into an address
  (define (reify-fvar fv offset)
    `(,fbp - ,(+ (* (fvar->index fv) (current-word-size-bytes)) offset)))

  ;; (nested-asm-lang-fvars-v7? tail) number? -> (nested-asm-lang-v7? tail)
  ;; env captures the interpreted value for locs
  (define (implement-fvars-tail t offset)
    (match t
      [`(jump ,trg)
       (define new-trg (implement-fvars-trg trg offset))
       `(jump ,new-trg)]
      [`(begin ,effects ... ,tail)
       (define-values (new-effects new-offset)
         (for/fold ([ef-results '()]
                    [offset offset])
                   ([ef effects])
           (define-values (new-effect new-offset) (implement-fvars-effect ef offset))
           (values (append ef-results (list new-effect)) new-offset)))
       (make-begin new-effects (implement-fvars-tail tail new-offset))]
      [`(if ,pred ,tail1 ,tail2)
       (define-values (new-pred new-offset) (implement-fvars-pred pred offset))
       (define new-tail1 (implement-fvars-tail tail1 new-offset))
       (define new-tail2 (implement-fvars-tail tail2 new-offset))
       `(if ,new-pred ,new-tail1 ,new-tail2)]))

  ;; (nested-asm-lang-fvars-v7? pred) number? -> (nested-asm-lang-v7? pred) number?
  (define (implement-fvars-pred p offset)
    (match p
      [`(true) (values p offset)]
      [`(false) (values p offset)]
      [`(not ,pred) 
      (define-values (new-pred new-offset) (implement-fvars-pred pred offset))
      (values `(not ,new-pred) new-offset)]
      [`(begin ,effects ... ,pred)
       (define-values (new-effects new-offset)
         (for/fold ([effects-list '()]
                    [offset offset])
                   ([effect effects])
           (define-values (new-effect new-offset) (implement-fvars-effect effect offset))
           (values (append effects-list (list new-effect)) new-offset)))
       (define-values (new-pred new-offset2) (implement-fvars-pred pred new-offset))
       (values `(begin ,@new-effects ,new-pred) new-offset2)]
      [`(if ,pred1 ,pred2 ,pred3)
       (define-values (new-pred1 offset1) (implement-fvars-pred pred1 offset))
       (define-values (new-pred2 _1) (implement-fvars-pred pred2 offset1))
       (define-values (new-pred3 _2) (implement-fvars-pred pred3 offset1))
       (values `(if ,new-pred1 ,new-pred2 ,new-pred3) offset1)]
      [`(,relop ,loc ,opand)
       (define new-loc (implement-fvars-loc loc offset))
       (define new-opand (implement-fvars-opand opand offset))
       (values `(,relop ,new-loc ,new-opand) offset)]))

  (define (not-equal a b)
    (not (= a b)))

  (define op-dict
    `((* . ,*)
      (+ . ,+)
      (- . ,-)
      (< . ,<)
      (<= . ,<=)
      (= . ,=)
      (>= . ,>=)
      (> . ,>)
      (!= . ,not-equal)))
  
  ;; (nested-asm-lang-fvars-v7? effect) number? -> (nested-asm-lang-v7? effect) number?
  (define (implement-fvars-effect e offset)
    (match e
      [`(set! ,loc1 (,binop ,loc1 ,opand))
       (if (equal? loc1 fbp)
           (let ()
             (define new-offset ((dict-ref op-dict binop) offset opand))
             (values e new-offset))
           (let ()
             (define new-loc (implement-fvars-loc loc1 offset))
             (define new-opand (implement-fvars-opand opand offset))
             (values `(set! ,new-loc (,binop ,new-loc ,new-opand)) offset)))]
      [`(set! ,loc ,triv)
       (define new-loc (implement-fvars-loc loc offset))
       (define new-triv (implement-fvars-triv triv offset))
       (values `(set! ,new-loc ,new-triv) offset)]
      [`(begin ,effects ... ,effect)
       (define-values (new-effects new-offset)
         (for/fold ([effects-list '()]
                    [offset offset])
                   ([effect effects])
           (define-values (new-effect new-offset) (implement-fvars-effect effect offset))
           (values (append effects-list (list new-effect)) new-offset)))
       (define-values (new-effect new-offset2) (implement-fvars-effect effect new-offset))
       (values `(begin ,@new-effects ,new-effect) new-offset2)]
      [`(if ,pred ,effect1 ,effect2)
       (define-values (new-pred new-offset) (implement-fvars-pred pred offset))
       (define-values (new-effect1 _1) (implement-fvars-effect effect1 new-offset)) ;; assume that changes to offset in either effect position
       (define-values (new-effect2 _2) (implement-fvars-effect effect2 new-offset)) ;; is not a valid program
       (values `(if ,new-pred ,new-effect1 ,new-effect2) new-offset)] 
      [`(return-point ,label ,tail)
       (define new-tail (implement-fvars-tail tail offset))
       (values `(return-point ,label ,new-tail) offset)]))

   ;; (nested-asm-lang-fvars-v7? trg) number -> (nested-asm-lang-v7? trg)
  ;; if trg is an fvar, concretizes it. Otherwise return it unchanged
  (define (implement-fvars-trg trg offset)
    (match trg
      [label #:when (label? label) label]
      [loc (implement-fvars-loc loc offset)]))
  
  ;; (nested-asm-lang-fvars-v7? triv) number -> (nested-asm-lang-v7? triv)
  ;; if triv is an fvar, concretizes it. Otherwise return it unchanged
  (define (implement-fvars-triv triv offset)
    (match triv
      [label #:when (label? label) label]
      [opand (implement-fvars-opand opand offset)]))

  ;; (nested-asm-lang-fvars-v7? opand) number -> (nested-asm-lang-v7? opand)
  ;; if opand is an fvar, concretizes it. Otherwise return it unchanged
  (define (implement-fvars-opand opand offset)
    (match opand
      [int64 #:when (int64? int64) int64]
      [loc #:when (or (fvar? loc) (register? loc))
           (implement-fvars-loc loc offset)]))

  ;; (nested-asm-lang-fvars-v7? loc) number? -> (nested-asm-lang-v7? loc)
  ;; If loc is an fvar, concretizes it. Otherwise return it unchanged
  (define (implement-fvars-loc l offset)
    (match l
      [reg #:when (register? reg) l]
      [fvar #:when (fvar? fvar) (reify-fvar l offset)]))

  ;; definition? -> definition?
  (define (implement-fvars-definition def)
    (match def
      [`(define ,label ,tail)
       `(define ,label ,(implement-fvars-tail tail 0))]))

  (match p
    [`(module ,definitions ... ,tail)
     (define defs-result 
        (for/list ([def definitions])
          (implement-fvars-definition def)))
     (define new-tail (implement-fvars-tail tail 0))
     `(module ,@defs-result ,new-tail)]))


;; nested-asm-lang-fvars-v7? -> nested-asm-lang-fvars-v7?
;; Optimize nested-asm-lang-fvars-v7 programs by analyzing and simplifying predicates.
(define (optimize-predicates p)

  ;; (nested-asm-lang-fvars-v7? tail) env -> (nested-asm-lang-fvars-v7? tail)
  (define (optimize-predicates-tail t env)
    (match t
      [`(begin ,effects ... ,tail)
      (define-values (new-env-result new-effects)
          (for/fold ([env env]
                     [ef-results '()])
                    ([ef effects])
            (define-values (new-effect new-env) (optimize-predicates-effect ef env))
            (values new-env (append ef-results `(,new-effect)))))
        (define new-tail (optimize-predicates-tail tail new-env-result))
        (append `(begin) new-effects `(,new-tail))]
      [`(if ,pred ,tail1 ,tail2) 
       (define-values (optimize-pred1-result new-env) (optimize-predicates-pred pred env))
        (match optimize-pred1-result
          [`(true) (optimize-predicates-tail tail1 new-env)]
          [`(false) (optimize-predicates-tail tail2 new-env)]
          [_ `(if ,pred ,(optimize-predicates-tail tail1 new-env) ,(optimize-predicates-tail tail2 new-env))])]
      [`(jump ,trg) t]))

  ;; (nested-asm-lang-fvars-v7? pred) env -> (Pair (nested-asm-lang-fvars-v7? pred) env)
  (define (optimize-predicates-pred p env)
    (match p
      [`(begin ,effects ... ,pred)
        (define-values (new-env-result new-effects)
          (for/fold ([env env]
                     [ef-results '()])
                    ([ef effects])
            (define-values (new-effect new-env) (optimize-predicates-effect ef env))
            (values new-env (append ef-results `(,new-effect)))))
        (define-values (new-pred newest-env) (optimize-predicates-pred pred new-env-result))
        (values (append `(begin) new-effects `(,new-pred)) newest-env)] 
      [`(if ,pred1 ,pred2 ,pred3)
        (define-values (optimize-pred1-result new-env) (optimize-predicates-pred pred1 env))
        (match optimize-pred1-result
          [`(true) (optimize-predicates-pred pred2 new-env)]
          [`(false) (optimize-predicates-pred pred3 new-env)]
          [_ 
            (define-values (optimize-pred2-result env-2) (optimize-predicates-pred pred2 new-env))
            (define-values (optimize-pred3-result env-3) (optimize-predicates-pred pred3 env-2))
          (values `(if ,optimize-pred1-result ,optimize-pred2-result ,optimize-pred3-result) env-3)])]
      [`(,relop ,loc ,triv) (values (optimize-predicates-op p env) env)]
      [`(not ,pred) 
        (define-values (optimize-pred-result new-env) (optimize-predicates-pred pred env))
        (match optimize-pred-result
          [`(true) (values `(false) new-env)]
          [`(false) (values `(true) new-env)]
          [_ (values `(not ,optimize-pred-result) new-env)])]
      [`(false) (values p env)]
      [`(true) (values p env)]))

  ;; (nested-asm-lang-fvars-v7? effect) env -> (Pair (nested-asm-lang-fvars-v7? effect) env)
  (define (optimize-predicates-effect e env)
    (match e
      [`(begin ,effects ... ,ef) 
        (define-values (new-env-result new-effects)
          (for/fold ([env env]
                     [ef-results '()])
                    ([ef effects])
            (define-values (new-effect new-env) (optimize-predicates-effect ef env))
            (values new-env (append ef-results `(,new-effect)))))
        (define-values (new-ef _) (optimize-predicates-effect ef new-env-result))
        (values (append `(begin) new-effects `(,new-ef)) new-env-result)]
      [`(set! ,loc ,triv) #:when (triv? triv)
        (define new-triv (optimize-predicates-triv triv env))
        (values `(set! ,loc ,triv) (dict-set env loc new-triv))]
      [`(set! ,loc_1 ,binop )
        (define new-binop (optimize-predicates-op binop env))
        (if (number? new-binop)
          (values e (dict-set env loc_1 new-binop))
          (values e env))]     
      [`(if ,pred1 ,effect1 ,effect2) 
        (define-values (optimize-pred1-result new-env) (optimize-predicates-pred pred1 env))
        (match optimize-pred1-result
          [`(true) (optimize-predicates-effect effect1 new-env)]
          [`(false) (optimize-predicates-effect effect2 new-env)]
          [_ 
            (define-values (optimize-effect1-result env-1) (optimize-predicates-effect effect1 new-env))
            (define-values (optimize-effect2-result env-2) (optimize-predicates-effect effect2 env-1))
          (values `(if ,optimize-pred1-result ,optimize-effect1-result ,optimize-effect2-result) env-2)])]
      [`(return-point ,label ,tail) 
        (values `(return-point ,label ,(optimize-predicates-tail tail env)) env)]))

  ;; (nested-asm-lang-fvars-v7? triv) env -> (nested-asm-lang-fvars-v7? triv)
  (define (optimize-predicates-triv t env)
    (match t
      [label #:when (label? label) label]
      [opand (optimize-predicates-opand opand env)]))

  ;; (nested-asm-lang-fvars-v7? opand) env -> (nested-asm-lang-fvars-v7? opand)
  (define (optimize-predicates-opand o env)
    (match o
      [int64 #:when (number? int64) int64]
      [loc (optimize-predicates-loc loc env)]))

  (define (not-equal a b)
    (not (= a b)))

  (define op-dict
    `((* . ,*)
      (+ . ,+)
      (- . ,-)
      (< . ,<)
      (<= . ,<=)
      (= . ,=)
      (>= . ,>=)
      (> . ,>)
      (!= . ,not-equal)
      (bitwise-and . ,bitwise-and)
      (bitwise-ior . ,bitwise-ior)
      (bitwise-xor . ,bitwise-xor)
      (arithmetic-shift-right . ,arithmetic-shift)))

  (define (triv? t)
    (or (opand? t) (label? t)))

  (define (opand? o)
    (or (int64? o) (loc? o)))

  (define (loc? l)
    (or (register? l) (fvar? l)))

  ;; (nested-asm-lang-fvars-v7? op) env -> (nested-asm-lang-fvars-v7? op)
  (define (optimize-predicates-op op env)
    (match op
      [`(,o ,loc ,triv) #:when (and (number? (optimize-predicates-loc loc env)) (number? (optimize-predicates-triv triv env)))
        (define result ((dict-ref op-dict o) (optimize-predicates-loc loc env) (optimize-predicates-triv triv env)))
        (if (number? result)
            result
            (match result
              [#t '(true)]
              [#f '(false)]))]
      [`(,o ,loc ,triv)
       `(,o ,(optimize-predicates-loc loc env) ,(optimize-predicates-triv triv env))]))

  
  ;; (nested-asm-lang-fvars-v7? loc) env -> (nested-asm-lang-fvars-v7? loc)
  (define (optimize-predicates-loc l env)
    (if (dict-has-key? env l) (dict-ref env l) l))

  ;; (nested-asm-lang-fvars-v7? def) env -> (nested-asm-lang-fvars-v7? def)
  (define (optimize-predicates-def d env)
    (match d
      [`(define ,label ,tail)
       `(define ,label ,(optimize-predicates-tail tail env))]))

  (match p
    [`(module ,definitions ... ,tail)
      (define new-defs
        (for/fold ([def-results '()])
                  ([def definitions])
          (define new-def (optimize-predicates-def def '()))
          (append def-results `(,new-def))))
      (append `(module) new-defs `(,(optimize-predicates-tail tail '())))]
    [`(module ,tail)
      `(module ,(optimize-predicates-tail tail '()))]))

;; nested-asm-lang-v7? -> block-pred-lang-v7?
;; Compile the Nested-asm-lang-v7 to Block-pred-lang-v7,
;; eliminating all nested expressions by generating fresh basic blocks and jumps.
(define (expose-basic-blocks p)

  ;; label? (Block-pred-lang-v7? tail) -> block
  ;; Creates a block with the given label and tail
  (define (make-block label tail)
    `(define ,label ,tail))

  ;; (Nested-asm-lang-v7? tail) -> (values (Block-pred-lang-v7? tail) (Listof block))
  ;; Compiles a single tail and returns said tail and any newly exposed blocks
  (define (expose-basic-blocks-tail t)
    (match t
      [`(halt ,triv) (values t '())]
      [`(begin ,effects ... ,tail)
       (define-values (new-tail new-blocks) (expose-basic-blocks-tail tail))
       (define-values (effects-tail effects-blocks) (expose-basic-blocks-effects effects new-tail))
       (values effects-tail (append new-blocks effects-blocks))]
      [`(if ,pred ,tail1 ,tail2)
       (define-values (new-tail1 new-tail-blocks1) (expose-basic-blocks-tail tail1))
       (define-values (new-tail2 new-tail-blocks2) (expose-basic-blocks-tail tail2))
       (define true-label (fresh-label '__nested))
       (define false-label (fresh-label '__nested))
       (define new-block1 (make-block true-label new-tail1))
       (define new-block2 (make-block false-label new-tail2))
       (define-values (pred-tail pred-blocks) (expose-basic-blocks-pred pred true-label false-label))
       (values pred-tail (append new-tail-blocks1 new-tail-blocks2 pred-blocks (list new-block1 new-block2)))]
      [`(jump ,trg) (values t '())]))

  ;; (Nested-asm-lang-v7? (List effect)) (Block-pred-lang-v7? tail) -> (Block-pred-lang-v7? tail and (List block))
  ;; Notes: will return a tail of `(begin ,effects ... ,tail)
  (define (expose-basic-blocks-effects es t)
    (match es
      ['() (values t '())]
      [(cons effect effects)
       ;; traverse the list backwards
       ;; then we know that tail is the rest of the computation. If effect is not an if branch, can append
       ;; effect onto the top of the begin
       (for/foldr ([total-tail t]
                   [total-blocks '()])
                  ([effect es])
         (define-values (new-tail new-blocks) (expose-basic-blocks-effect effect total-tail))
         (values new-tail (append total-blocks new-blocks)))]))

  ;; (Nested-asm-lang-v7? effect) (Block-pred-lang-v7? tail) -> (Block-pred-lang-v7? tail and Listof block)
  (define (expose-basic-blocks-effect e tail)
    (match e
      [`(set! ,loc ,triv) (values (make-begin (list e) tail) '())]
      [`(set! ,loc1 (,binop ,loc1 ,opand)) (values (make-begin (list e) tail) '())]
      [`(begin ,effects ...)
       (expose-basic-blocks-effects effects tail)] 
      [`(if ,pred ,effect1 ,effect2)
       (define join-label (fresh-label '__join))
       (define join-block (make-block join-label tail))
       (define true-label (fresh-label '__nested))
       (define-values (new-tail1 new-tail1-blocks)
         (expose-basic-blocks-effect effect1 `(jump ,join-label)))
       (define true-block (make-block true-label new-tail1))
       (define false-label (fresh-label '__nested))
       (define-values (new-tail2 new-tail2-blocks)
         (expose-basic-blocks-effect effect2 `(jump ,join-label)))
       (define false-block (make-block false-label new-tail2))
       (define-values (pred-tail pred-blocks)
         (expose-basic-blocks-pred pred true-label false-label))
       (values pred-tail (append pred-blocks new-tail1-blocks new-tail2-blocks (list true-block false-block join-block)))]
      [`(return-point ,label ,rp-tail)
       (define rp-block (make-block label tail))
       (define-values (new-rp-tail new-rp-tail-blocks) (expose-basic-blocks-tail rp-tail))
       (values new-rp-tail (append (list rp-block) new-rp-tail-blocks))]))

  ;; (Nested-asm-lang-v7? pred label? label?) -> (Block-pred-lang-v7? tail and Listof block)
  (define (expose-basic-blocks-pred p k-true k-false)
    (match p
      [`(begin ,effects ... ,pred)
       (define-values (pred-tail pred-blocks)
         (expose-basic-blocks-pred pred k-true k-false))
       (define-values (new-tail new-blocks)
         (expose-basic-blocks-effects effects pred-tail))
       (values new-tail (append pred-blocks new-blocks))]
      [`(,relop ,loc ,opand)
       (values `(if ,p (jump ,k-true) (jump ,k-false)) '())]
      [`(true)
       (values `(if ,p (jump ,k-true) (jump ,k-false)) '())]
      [`(false)
       (values `(if ,p (jump ,k-true) (jump ,k-false)) `())]
      [`(not ,pred)
       (expose-basic-blocks-pred pred k-false k-true)]
      [`(if ,pred ,pred1 ,pred2)
       (define-values (tail1 tail1-blocks)
         (expose-basic-blocks-pred pred1 k-true k-false))
       (define tail1-label (fresh-label 'tmp))
       (define tail1-block (make-block tail1-label tail1))
       (define-values (tail2 tail2-blocks)
         (expose-basic-blocks-pred pred2 k-true k-false))
       (define tail2-label (fresh-label 'tmp))
       (define tail2-block (make-block tail2-label tail2))
       (define-values (pred-tail pred-blocks)
         (expose-basic-blocks-pred pred tail1-label tail2-label))
       (values pred-tail (append pred-blocks tail1-blocks tail2-blocks (list tail1-block tail2-block)))]))

  ;; definition? -> Pair(definition? Listof(block))
  (define (expose-basic-blocks-def def)
    (match def
      [`(define ,label ,tail)
       (define-values (new-tail new-blocks) (expose-basic-blocks-tail tail))
       (values `(define ,label ,new-tail) new-blocks)]))
  
  (match p
    [`(module ,definitions ... ,tail)
     (define-values (new-defs new-def-blocks)
       (for/fold ([new-defs '()]
                  [new-block-list '()])
                 ([def definitions])
       (define-values (new-def new-blocks) (expose-basic-blocks-def def))
       (values (cons new-def new-defs) (append new-block-list new-blocks))))
     (define reverse-new-defs (reverse new-defs))
     (define-values (new-tail new-blocks) (expose-basic-blocks-tail tail))
     `(module (define ,(fresh-label '__main) ,new-tail) ,@reverse-new-defs ,@(append new-blocks new-def-blocks))]))

;; asm-pred-lang-v7/framed? -> asm-pred-lang-v7/spilled?
;; Performs graph-colouring register allocation, compiling 
;; Asm-pred-lang v7/framed to Asm-pred-lang v7/spilled by 
;; decorating programs with their register assignments.
(define (assign-registers p)

  ;; graph? aloc? (Listof (Pair aloc? rloc?)) rloc? -> rloc?
  ;; Given a conflict graph, an aloc we wish to choose a register for,
  ;; the existing assignments list, and a default rloc, return
  ;; a loc that already exists in the assignments list if not in conflict
  ;; with any of the assignments,
  ;; else, return the default loc
  (define (choose-location g v assign default-loc)
    (define conflicting-neighbors (get-neighbors g v))
    (define used-locs (map (λ (p) (second p)) assign))
    (define conflicting-locations
      (for/fold ([acc '()])
                ([p assign])
        (if (member (first p) conflicting-neighbors)
            (cons (second p) acc)
            acc)))
    ;; define not in conflict (used-locs - conflicting-locations)
    (define result
      (filter (λ (loc) (not (member loc conflicting-locations))) used-locs))
    (if (not (empty? result))
        (first result)
        default-loc))

  ;; (Listof (Pair aloc? rloc?)) -> (Listof reg?)
  ;; Returns the list of registers that are definitely available
  (define (get-free-reg assignment)
    (define used-locs (map (λ (p) (second p)) assignment))
    (define result
      (filter (λ (loc) (not (member loc used-locs))) (current-assignable-registers)))
    result)

;; (Listof aloc) graph? -> (Listof (Pair aloc? rloc?)) (Listof aloc?)
;; Takes in a list of alocs to be assigned, the current conflict graph,
;; and returns the assignments list AND the list of variables to be spilled
  (define (ar-conflicts alocs conflict-g)
    (match alocs
      ['() (values '() '())]
      [(cons aloc alocs)  
       (define selected-aloc aloc)
       (define rest-alocs alocs)
       (define new-graph
         (remove-vertex conflict-g selected-aloc))
       (define-values (assignment spilled-res) (ar-conflicts rest-alocs new-graph))
       ;; define absolutely free registers based on assignment
       ;; try to use an already used register or fvar based on conflict graph, otherwise use an absolutely
       ;; free register, or leave the aloc to be spilled later
       (define neighbors (get-neighbors conflict-g selected-aloc))
       (define registers-not-in-assignment (reverse (get-free-reg assignment)))
       (define absolutely-free (filter (λ (reg) (not (member reg neighbors))) registers-not-in-assignment))
       (if (empty? absolutely-free)
           (let ()
             (define chosen-loc (choose-location conflict-g selected-aloc assignment 0)) ;; default-loc is a dummy value
             (if (equal? chosen-loc 0)
                 (values assignment (cons selected-aloc spilled-res))
                 (let ()
                   (define result `(,selected-aloc ,chosen-loc))
                   (values (cons result assignment) spilled-res))))
           (let ()
             (define chosen-loc (choose-location conflict-g selected-aloc assignment (first absolutely-free)))
             (define result `(,selected-aloc ,chosen-loc))
             (values (cons result assignment) spilled-res)))]))

  ;; definition? -> definition? with assignment in info
  (define (ar-definition def)
    (match def
      [`(define ,label ,info ,tail)
       (define alocs (info-ref info 'locals))
       (define graph (info-ref info 'conflicts))
       (define assign (info-ref info 'assignment))
       (define sorted-conflicts
          (sort graph (lambda (x y) (< (length (list-ref x 1)) (length (list-ref y 1))))))
       ;; set alocs to be those in sorted-conflicts (filtering out registers and those not in the original alocs list)
       (define all-alocs  (map (λ (c) (list-ref c 0)) sorted-conflicts))
       (define new-alocs (filter (λ (aloc) (and (not (register? aloc)) (member aloc alocs))) all-alocs))
       (define-values (result spilled-vars) (ar-conflicts new-alocs sorted-conflicts))
       (define new-info (info-set (info-set info 'assignment (append assign result)) 'locals spilled-vars))
       `(define ,label ,new-info ,tail)]))

  (match p
    [`(module ,info ,definitions ... ,tail)
     (define ar-defs
       (for/list ([def definitions])
         (ar-definition def)))
     (define alocs (info-ref info 'locals))
     (define graph (info-ref info 'conflicts))
     (define assign (info-ref info 'assignment))
     (define sorted-conflicts
          (sort graph (lambda (x y) (< (length (list-ref x 1)) (length (list-ref y 1))))))
     ;; set alocs to be those in sorted-conflicts (filtering out registers and those not in the original alocs list)
     (define all-alocs  (map (λ (c) (list-ref c 0)) sorted-conflicts))
     (define new-alocs (filter (λ (aloc) (and (not (register? aloc)) (member aloc alocs))) all-alocs))
     (define-values (result spilled-vars) (ar-conflicts new-alocs sorted-conflicts))
     (define new-info (info-set (info-set info 'assignment (append assign result)) 'locals spilled-vars))
     `(module ,new-info ,@ar-defs ,tail)]))

;; asm-pred-lang-v7/assignments?? -> nested-asm-lang-fvars-v7?
;; Compiles Asm-pred-lang v7/assignments to Nested-asm-lang-fvars-v7 by replacing all
;; abstract location with physical locations using the assignments described in the assignment info field.
(define (replace-locations p)
  (define (rl-tail t ctx)
    (match t
      [`(begin ,efx ... ,tail)
       (define rl-efx
         (map (lambda (ef) (rl-effect ef ctx)) efx))
       `(begin ,@rl-efx ,(rl-tail tail ctx))]
      [`(if ,pred ,tail1 ,tail2)
        `(if ,(rl-pred pred ctx) ,(rl-tail tail1 ctx) ,(rl-tail tail2 ctx))]
      [`(jump ,trg ,locs ...)
       (define trg-result
         (if (not (label? trg))
             (rl-loc trg ctx)
             trg))
       `(jump ,trg-result)]))
  
  ;; opand? -> opand?
  (define (rl-opand o ctx)
    (match o
      [int64 #:when (int64? int64) int64]
      [loc (rl-loc loc ctx)]))

  ;; loc? -> rloc?
  (define (rl-loc l ctx)
    (match l
      [aloc #:when (aloc? aloc) (first (dict-ref ctx aloc))]
      [rloc #:when (or (register? rloc) (fvar? rloc)) rloc]))

  ;; triv? -> triv?
  (define (rl-triv t ctx)
    (match t
      [label #:when (label? label) label]
      [opand (rl-opand opand ctx)]))

  ;; effect? -> effect?
  (define (rl-effect e ctx)
    (match e
      [`(set! ,loc (,binop ,loc ,opand))
       `(set! ,(rl-loc loc ctx) (,binop ,(rl-loc loc ctx) ,(rl-opand opand ctx)))]
      [`(set! ,loc ,triv)
       `(set! ,(rl-loc loc ctx) ,(rl-triv triv ctx))]
      [`(begin ,efx ... ,ef)
       (define rl-efx
         (map (lambda (ef) (rl-effect ef ctx)) efx))
       `(begin ,@rl-efx ,(rl-effect ef ctx))]
      [`(if ,pred ,effect1 ,effect2)
        `(if ,(rl-pred pred ctx) ,(rl-effect effect1 ctx) ,(rl-effect effect2 ctx))]
      [`(return-point ,label ,tail)
        `(return-point ,label ,(rl-tail tail ctx))]))

  ;; pred? -> pred?
  (define (rl-pred e ctx)
    (match e 
      ['(true)
        e]
      ['(false)
        e]
      [`(not ,pred)
        `(not ,(rl-pred pred ctx))]
      [`(begin ,efx ... ,pred)
        (define rl-efx
         (map (lambda (ef) (rl-effect ef ctx)) efx))
         `(begin ,@rl-efx ,(rl-pred pred ctx))]
      [`(if ,pred1 ,pred2 ,pred3)
        `(if ,(rl-pred pred1 ctx) ,(rl-pred pred2 ctx) ,(rl-pred pred3 ctx))]
      [`(,relop ,loc ,opand)
        `(,relop ,(rl-loc loc ctx) ,(rl-opand opand ctx))]))

  ;; definition? -> definition?
  ;; Where definition?:: `(define ,label ,info ,tail)
  (define (rl-definition d)
    (match d
      [`(define ,label ,info ,tail)
       (define asmts (info-ref info 'assignment))
       `(define ,label ,(rl-tail tail asmts))]))
  
  (match p
    [`(module ,info ,definitions ... ,tail)
     (define asmts (info-ref info 'assignment))
     (define defs-result
       (for/list ([def definitions])
         (rl-definition def)))
      `(module ,@defs-result ,(rl-tail tail asmts))]))

; paren-x64-v7? -> (and/c string? x64-instructions?)
; Compile the paren-x64-v6 program into a valid sequence of x64 instructions, represented as a string.
(define (generate-x64 p)
  (define fbp (current-frame-base-pointer-register))
  (define (program->x64 p)
    (match p
      [`(begin ,s ...)
       (foldr string-append "" (map statement->x64 s))]))

  ; (paren-x64-v7? s) -> (and/c string? x64-instructions?)
  (define (statement->x64 s)
    (match s
      [`(set! ,addr ,int32) #:when (and (addr? addr) (int32? int32))
        (string-append "mov " (addr->x64 addr) ", " (~a int32) "\n")]
      [`(set! ,addr ,trg) #:when (and (addr? addr) (trg? trg))
        (string-append "mov " (addr->x64 addr) ", " (trg->x64 trg) "\n")]
      [`(set! ,reg1 ,loc) #:when (and (register? reg1) (loc? loc))
        (string-append "mov " (~a reg1) ", " (loc->x64 loc) "\n")]
      [`(set! ,reg1 ,triv) #:when (and (register? reg1) (triv? triv))
        (string-append "mov " (~a reg1) ", " (triv->x64 triv) "\n")]
      [`(set! ,reg1 (,binop ,reg1 ,int32)) #:when (and (register? reg1) (int32? int32))
        (string-append (binop->ins binop) (~a reg1) ", " (~a int32) "\n")]
      [`(set! ,reg1 (,binop ,reg1 ,loc)) #:when (and (register? reg1) (loc? loc))
        (string-append (binop->ins binop) (~a reg1) ", " (loc->x64 loc) "\n")]
      [`(with-label ,label ,statement)
        (string-append (~a (sanitize-label label)) ":" "\n" 
          (statement->x64 statement))]
      [`(jump ,trg)
        (string-append "jmp " (trg->x64 trg) "\n")]
      [`(compare ,reg ,opand)
        (string-append "cmp " (~a reg) ", " (~a opand) "\n")]
      [`(jump-if ,relop ,label)
        (string-append (relop->ins relop) (~a (sanitize-label label)) "\n")]))

  (define (addr? addr)
    (match addr
      [`(,reg - ,i)
        #:when (equal? reg fbp)
        true]
      [_ false]))

  (define (triv? triv)
    (or (trg? triv) (int64? triv)))

  (define (loc? loc)
    (or (register? loc) (addr? loc)))

  (define (trg? trg)
    (or (register? trg) (label? trg)))

;; (paren-x64-v7 triv) -> (and/c string? x64-instructions?)
  (define (triv->x64 triv)
    (match triv
      [`,int64 #:when (int64? int64)
        (~a int64)]
      [`,trg #:when (trg? trg)
        (trg->x64 trg)]))

;; (paren-x64-v7 trg) -> (and/c string? x64-instructions?)
  (define (trg->x64 trg)
    (match trg
      [`,reg #:when (register? reg)
        (~a reg)]
      [`,label #:when (label? label)
        (~a (sanitize-label label))]))

  ;; (paren-x64-v7 loc) -> (and/c string? x64-instructions?)
  (define (loc->x64 loc)
    (match loc
      [`,reg #:when (register? reg)
        (~a reg)]
      [`,addr #:when (addr? addr)
        (addr->x64 addr)]))

  ;; (paren-x64-v7 addr) -> (and/c string? x64-instructions?)
  (define (addr->x64 addr)
     (match addr
       [`(,reg - ,i) 
        (string-append "QWORD [" (~a fbp) " - " (~a i) "]")]))

  ;; (paren-x64-v7 binop) -> (and/c string? x64-instructions?)
  (define (binop->ins binop)
    (match binop
       ['* "imul "]
       ['+ "add "]
       ['- "sub "]
       ['bitwise-and "and "]
       ['bitwise-ior "or "]
       ['bitwise-xor "xor "]
       ['arithmetic-shift-right "sar "]))

  (define (relop->ins relop)
     (match relop
       ['< "jl "]
       ['<= "jle "]
       ['= "je "]
       ['>= "jge "]
       ['> "jg "]
       ['!= "jne "]))

  (program->x64 p))

;; asm-pred-lang-v7/spilled? -> asm-pred-lang-v7/assignments?
;; Compiles Asm-pred-lang-v7/spilled to Asm-pred-lang-v7/assignments by allocating
;; all abstract locations in the locals set to free frame variables.
(define (assign-frame-variables p)

  ;; (asm-pred-lang-v7/spilled? assignment) conflicts of a local -> (fvar? ...)
  ;; Returns fvars that are in conflicts or assigned to conflicts
  (define (afv-conflicting-fvars assignments conflicts)
    (filter fvar? 
      (for/list ([conflict conflicts])
        (define assignment (dict-ref assignments conflict #f))  
        (if (fvar? conflict)
          conflict
          (cond 
            [assignment (list-ref assignment 0)])))))

  ;; (fvar? ...) -> fvar?
  ;; Returns valid fvar to assign to
  (define (afv-find-fvar conflicting-fvars)
    (define conflict-indexes (map (lambda (conflict) (fvar->index conflict)) conflicting-fvars))
    (define max-conflict-index (car (sort conflict-indexes >)))
    (define range-fvar
      (for/first ([i (range (add1 max-conflict-index))]
      #:when (not(member i conflict-indexes)))
      i))
    (if range-fvar
      (make-fvar range-fvar)
      (make-fvar (add1 max-conflict-index))))

  ;; (asm-pred-lang-v7/spilled? info) -> (asm-pred-lang-v7/assignments? info)
  (define (afv-info i)
    (match i
      [`((locals (,locals ...)) (conflicts (,conflicts ...)) (assignment (,assignments ...)))
        (cond 
        [(empty? locals) i]
        [else 
          (define final-assignments (for/fold ([new-assignments assignments]) 
                    ([local (reverse locals)])
            (define conflicting-fvars (afv-conflicting-fvars new-assignments (list-ref (dict-ref conflicts local `(())) 0)))
            (dict-set new-assignments local `(,(afv-find-fvar conflicting-fvars)))
          ))
          `((locals ,locals) (conflicts ,conflicts) (assignment ,final-assignments))])])) 

  ;; (asm-pred-lang-v7/spilled? def) -> (asm-pred-lang-v7/assignments? def)
  (define (afv-def d)
    (match d
      [`(define ,label ,info ,tail)
       `(define ,label ,(afv-info info) ,tail)]))

  (match p
    [`(module ,info ,tail) `(module ,(afv-info info) ,tail)]
    [`(module ,info ,definitions ... ,tail)
      (define afv-definitions
        (for/fold ([res '()])
                  ([definition definitions])
          (append res (list (afv-def definition)))))
    `(module ,(afv-info info) ,@afv-definitions ,tail)])
)

;; exprs-unique-lang-v7? -> exprs-unsafe-data-lang-v7?
;; Implement safe primitive operations by inserting procedure definitions for
;; each primitive operation which perform dynamic tag checking, to ensure type safety.
;;
;; error codes: 
;; 1: error in first argument of *
;; 2: error in second argument of *
;; 3: error in first argument of +
;; 4: error in second argument of +
;; 5: error in first argument of -
;; 6: error in second argument of -
;; 7: error in first argument of <
;; 8: error in second argument of <
;; 9: error in first argument of <=
;; 10: error in second argument of <=
;; 11: error in first argument of >
;; 12: error in second argument of >
;; 13: error in first argument of >=
;; 14: error in second argument of >=
(define (implement-safe-primops p)

  ;; Dictionary of already defined ops to its labels
  ;; key: op (primop or binop)
  ;; value: label
  (define ops-dict (make-hash))

  ;; Operations mapped to error codes x
  ;; Error will be x if error is in first argument
  ;; Error will be x+1 if error is in second argument
  (define err-dict
    `((* . 1)
      (+ . 3)
      (- . 5)
      (< . 7)
      (<= . 9)
      (> . 11)
      (>= . 13)))

  ;; (exprs-unique-lang-v7 value) -> (values (exprs-unsafe-data-lang-v7 value) (list definitions))
  (define (implement-value v)
    (match v
      [`(call ,value1 ,vals ...)
        (define-values (implement-value1-result-v implement-value1-result-defs)
          (implement-value value1))
        (define-values (implement-vals-result-vs implement-vals-result-defs)
          (for/fold ([implement-vals-result-vs-acc '()] [implement-vals-result-defs-acc '()])
                    ([v vals])
            (begin
              (define-values (implement-v-result-v implement-v-result-defs)
                (implement-value v))
              (values 
                (append implement-vals-result-vs-acc (list implement-v-result-v))
                (append implement-vals-result-defs-acc implement-v-result-defs)))))
        (values
          `(call ,implement-value1-result-v ,@implement-vals-result-vs)
          (append implement-value1-result-defs implement-vals-result-defs))]
      [`(let ([,alocs ,vals] ...) ,value1)
        (define-values (implement-value1-result-v implement-value1-result-defs)
          (implement-value value1))
        (define-values (implement-alocs-vals-results implement-alocs-vals-results-defs)
          (for/fold ([alocs-vals-result-acc '()] [aloc-vals-result-defs-acc '()])
                    ([aloc alocs] [v vals])
            (begin
              (define-values (implement-v-result-v implement-v-result-defs)
                (implement-value v))
              (values 
                (append alocs-vals-result-acc (list `(,aloc ,implement-v-result-v)))
                (append aloc-vals-result-defs-acc implement-v-result-defs)))))
        (values
          `(let ,implement-alocs-vals-results ,implement-value1-result-v)
           (append implement-value1-result-defs implement-alocs-vals-results-defs))]
      [`(if ,value1 ,value2 ,value3)
        (define-values (implement-value1-result-v implement-value1-result-defs)
          (implement-value value1))
        (define-values (implement-value2-result-v implement-value2-result-defs)
          (implement-value value2))
        (define-values (implement-value3-result-v implement-value3-result-defs)
          (implement-value value3))
        (values 
          `(if ,implement-value1-result-v ,implement-value2-result-v ,implement-value3-result-v)
          (append implement-value1-result-defs implement-value2-result-defs implement-value3-result-defs))]
      [triv
        (implement-triv triv)]))

  ;; (exprs-unique-lang-v7 triv) -> 
  ;;    (values 
  ;;        (exprs-unsafe-data-lang-v7 triv) 
  ;;        (list '(define label (lambda (aloc ...) value)))))
  (define (implement-triv t)
    (match t
      [label #:when (label? label)
        (values label '())]
      [aloc #:when (aloc? aloc)
        (values aloc '())]
      [prim-f #:when (prim-f? prim-f)
        (implement-prim-f prim-f)]
      [fixnum #:when (int61? fixnum)
        (values fixnum '())]
      ['#t 
        (values #t '())]
      ['#f 
        (values #f '())]
      [`empty
        (values `empty '())]
      [`(void)
        (values '(void) '())]
      [`(error ,uint8)
        (values `(error ,uint8) '())]
      [ascii-char-literal #:when (ascii-char-literal? ascii-char-literal)
        (values ascii-char-literal '())]))
    
  ;; (exprs-unique-lang-v7 prim-f) -> 
  ;;      (values 
  ;;        (exprs-unsafe-data-lang-v7 label) 
  ;;        (exprs-unsafe-data-lang-v7 (list '(define label (lambda (aloc ...) value)))))
  (define (implement-prim-f p)
    (match p
      [binop #:when (binop? binop)
        (implement-binop binop)]
      [unop #:when (unop? unop)
        (implement-unop unop)]))

  ;; (exprs-unique-lang-v7 binop) -> 
  ;;      (values 
  ;;        (exprs-unsafe-data-lang-v7 label) 
  ;;        (exprs-unsafe-data-lang-v7 (list '(define label (lambda (aloc ...) value)))))
  (define (implement-binop b)
    (if (dict-has-key? ops-dict b)
      (values (dict-ref ops-dict b) '())
      (let ()
        (define tmp-1 (fresh))
        (define tmp-2 (fresh))
        (define new-label (fresh-label b))
        (dict-set! ops-dict b new-label)
        (match b
          ['eq? ;;eq is a special case because it does not have to take in a fixnum for its arguments
            (define new-def `(define ,new-label (lambda (,tmp-1 ,tmp-2) (eq? ,tmp-1 ,tmp-2))))
            (values
              new-label
              (list new-def))]
          [else
            (define unsafe-fx (string->symbol (string-append "unsafe-fx" (symbol->string b))))
            (define new-def 
              `(define ,new-label 
                (lambda (,tmp-1 ,tmp-2)
                  (if (fixnum? ,tmp-2)
                    (if (fixnum? ,tmp-1) 
                      (,unsafe-fx ,tmp-1 ,tmp-2) 
                      (error ,(dict-ref err-dict b)))
                    (error ,(add1 (dict-ref err-dict b)))))))
            (values new-label (list new-def))]))))

  ;; (exprs-unique-lang-v7 unop) -> s
  ;;      (values 
  ;;        (exprs-unsafe-data-lang-v7 label) 
  ;;        (exprs-unsafe-data-lang-v7 '(define label (lambda (aloc ...) value))))
  (define (implement-unop u)
    (if (dict-has-key? ops-dict u)
      (values (dict-ref ops-dict u) '())
      (let ()
        (define tmp (fresh))
        (define new-label (fresh-label u))
        (dict-set! ops-dict u new-label)
        (define new-def `(define ,new-label (lambda (,tmp) (,u ,tmp))))
        (values new-label (list new-def)))))

  ;; (exprs-unique-lang-v7 block) -> 
  ;;    (values 
  ;;       (exprs-unsafe-data-lang-v7 block))
  ;;       (exprs-unsafe-data-lang-v7 (list '(define label (lambda (aloc ...) value)))))
  (define (implement-block b)
    (match b
      [`(define ,label (lambda (,alocs ...) ,value))
        (define-values (implement-value-result-value implement-value-result-defs)
          (implement-value value))
        (values
          `(define ,label (lambda (,@alocs) ,implement-value-result-value))
          implement-value-result-defs)]))

  (define (prim-f? p)
    (or (binop? p) (unop? p)))

  (define (binop? b)
    (set-member? (set '* '+ '- '< 'eq? '<= '> '>=) b))

  (define (unop? u)
    (set-member? (set 'fixnum? 'boolean? 'empty? 'void? 'ascii-char? 'error? 'not) u))

  (match p
    [`(module ,blocks ... ,value)
      (define-values (blocks-result blocks-result-defs)
        (for/fold ([blocks-result-acc '()] [blocks-result-defs-acc '()])
                  ([b blocks])
          (define-values (block-result block-result-defs) 
            (implement-block b))
          (values
            (append blocks-result-acc (list block-result))
            (append block-result-defs blocks-result-defs-acc))))
      (define-values (implement-value-result-value implement-value-result-defs)
          (implement-value value))
      `(module ,@blocks-result-defs ,@implement-value-result-defs ,@blocks-result ,implement-value-result-value)]))

;; exprs-unsafe-data-lang-v7? -> exprs-bits-lang-v7?
;; Compiles immediate data and primitive operations into their
;; implementations as ptrs and primitive bitwise operations on ptrs.
(define (specify-representation p)

  ;; List A and List B -> List ((a1 b1) (a2 b2) ...)
  ;; Helper function to zip two lists into a list of pairs
  (define (zip a b)
    (apply map list (list a b)))

  ;; (exprs-unsafe-data-lang-v7? triv) -> (exprs-bits-lang-v7? triv)
  ;; Compiles trivs into implementations as ptrs and primitive bitwise ops on ptrs
  (define (specify-rep-triv t)
    (match t
      [label #:when (label? label) label]
      [aloc #:when (aloc? aloc) aloc]
      [fixnum #:when (int61? fixnum)
              (bitwise-ior (arithmetic-shift fixnum (current-fixnum-shift)) (current-fixnum-tag))]
      [`(error ,uint8) (bitwise-ior (arithmetic-shift uint8 (current-error-shift)) (current-error-tag))]
      [#t (current-true-ptr)]
      [#f (current-false-ptr)]
      [`empty (current-empty-ptr)]
      [`(void) (current-void-ptr)]
      [char #:when (ascii-char-literal? char)
           (bitwise-ior (arithmetic-shift (char->integer char) (current-ascii-char-shift)) (current-ascii-char-tag))]))

  ;; (exprs-unsafe-data-lang-v7? value) -> (exprs-bits-lang-v7? value)
  ;; Compiles data in value as implementations as ptrs and primitive bitwise ops on ptrs
  (define (specify-rep-value v)
    (match v
      [`(call ,value1 ,values ...)
       (define new-value1 (specify-rep-value value1))
       (define new-values
         (for/list ([value values])
           (specify-rep-value value)))
       `(call ,new-value1 ,@new-values)]
      [`(let ([,als ,vs] ...) ,value)
       (define new-vs
         (for/list ([v vs])
           (specify-rep-value v)))
       (define new-pairs (zip als new-vs))
       (define new-value (specify-rep-value value))
       `(let ,new-pairs ,new-value)
       ]
      [`(if ,value1 ,value2 ,value3)
       (define new-value1 (specify-rep-value value1))
       (define new-value2 (specify-rep-value value2))
       (define new-value3 (specify-rep-value value3))
       `(if (!= ,new-value1 ,(current-false-ptr)) ,new-value2 ,new-value3)]
      [`(,unop ,value) #:when (not (equal? unop 'error)) (specify-rep-unop unop value)]
      [`(,binop ,value1 ,value2) (specify-rep-binop binop value1 value2)]
      [triv (specify-rep-triv triv)]))

  ;; (exprs-unsafe-data-lang-v7? unop) (exprs-unsafe-data-lang-v7? value) -> (exprs-bits-lang-v7? value)
  ;; Compiles unops into their representation using ptrs
  (define (specify-rep-unop unop value)
     (define new-value (specify-rep-value value))
    (match unop
      [`fixnum?
       `(if (= (bitwise-and ,new-value ,(current-fixnum-mask)) ,(current-fixnum-tag)) ,(current-true-ptr) ,(current-false-ptr))]
      [`boolean?
       `(if (= (bitwise-and ,new-value ,(current-boolean-mask)) ,(current-boolean-tag)) ,(current-true-ptr) ,(current-false-ptr))]
      [`empty?
       `(if (= (bitwise-and ,new-value ,(current-empty-mask)) ,(current-empty-tag)) ,(current-true-ptr) ,(current-false-ptr))]
      [`void?
       `(if (= (bitwise-and ,new-value ,(current-void-mask)) ,(current-void-tag)) ,(current-true-ptr) ,(current-false-ptr))]
      [`ascii-char?
       `(if (= (bitwise-and ,new-value ,(current-ascii-char-mask)) ,(current-ascii-char-tag)) ,(current-true-ptr) ,(current-false-ptr))]
      [`error?
       `(if (= (bitwise-and ,new-value ,(current-error-mask)) ,(current-error-tag)) ,(current-true-ptr) ,(current-false-ptr))]
      [`not
       `(if (!= ,new-value ,(current-false-ptr)) ,(current-false-ptr) ,(current-true-ptr))]))

  ;; (exprs-unsafe-data-lang-v7? binop) (exprs-unsafe-data-lang-v7? value) (exprs-unsafe-data-lang-v7? value) -> (exprs-bits-lang-v7? value)
  ;; Compiles binops into their representation using ptrs
  (define (specify-rep-binop binop value1 value2)
    (define new-value1 (specify-rep-value value1))
    (define new-value2 (specify-rep-value value2))
    (match binop
      [`unsafe-fx*
       `(* ,new-value1 (arithmetic-shift-right ,new-value2 ,(current-fixnum-shift)))]
      [`unsafe-fx+
       `(+ ,new-value1 ,new-value2)]
      [`unsafe-fx-
       `(- ,new-value1 ,new-value2)]
      [`unsafe-fx<
       `(if (< ,new-value1 ,new-value2) ,(current-true-ptr) ,(current-false-ptr))]
      [`eq?
       `(if (= ,new-value1 ,new-value2) ,(current-true-ptr) ,(current-false-ptr))]
      [`unsafe-fx<=
       `(if (<= ,new-value1 ,new-value2) ,(current-true-ptr) ,(current-false-ptr))]
      [`unsafe-fx>
       `(if (> ,new-value1 ,new-value2) ,(current-true-ptr) ,(current-false-ptr))]
      [`unsafe-fx>=
       `(if (>= ,new-value1 ,new-value2) ,(current-true-ptr) ,(current-false-ptr))]))

  ;; (exprs-unsafe-data-lang-v7? definition) -> (exprs-bits-lang-v7? definition)
  ;; Compiles the definition by implementing ptrs in value
  (define (specify-rep-def def)
    (match def
      [`(define ,label (lambda (,aloc ...) ,value))
       `(define ,label (lambda ,aloc ,(specify-rep-value value)))]))
  
  (match p
    [`(module ,definitions ... ,value)
     (define new-defs
       (for/list ([def definitions])
       (specify-rep-def def)))
     `(module ,@new-defs ,(specify-rep-value value))]))

;; exprs-lang-v7? -> exprs-unique-lang-v7?
;; Compiles exprs-lang v7 to exprs-unique-lang v7 by resolving lexical identifiers to unique abstract locations.
(define (uniquify p)

;; Helper function to zip two lists into a list of pairs
;; List A and List B -> List ((a1 b1) (a2 b2) ...)
  (define (zip a b)
    (apply map list (list a b)))

  ;; (exprs-lang-v7? value) env -> (exprs-unique-lang-v7? value)
  (define (uniquify-value v acc)
    (match v
      [`(let ([,xs ,vs] ...) ,value)
       (define new-acc
         (for/fold ([acc acc])
                   ([x xs])
           (dict-set acc x (fresh x))))
       (define uxs
         (map (λ (x)
                (dict-ref new-acc x)) xs))
       (define uvals
         (for/list ([v vs])
           (uniquify-value v acc)))
       (define bindings
         (zip uxs uvals))
       `(let ,bindings ,(uniquify-value value new-acc))]
      [`(if ,value ,value1 ,value2)
       `(if ,(uniquify-value value acc) ,(uniquify-value value1 acc) ,(uniquify-value value2 acc))]
      [`(call ,value ,values ...)
       (define uniquify-values
         (for/list ([val values])
           (uniquify-value val acc)))
       `(call ,(uniquify-value value acc) ,@uniquify-values)]
      [triv (uniquify-triv triv acc)]))

  ;; (exprs-lang-v7? triv) env -> (exprs-unique-lang-v7? triv)
  (define (uniquify-triv t acc)
    (match t
      [fixnum #:when (int61? fixnum) fixnum]
      [#t t]
      [#f t]
      [`empty t]
      [`(void) t]
      [`(error ,uint8) t]
      [ascii-char-literal #:when (ascii-char-literal? ascii-char-literal) ascii-char-literal]
      [x (dict-ref acc x (λ () "Not well scoped, variable not defined: " x))]))

  ;; definition? env -> definition?
  (define (uniquify-def def acc)
    (match def
      ;; given a list of xs, uniquify each and pass the new accumulator into uniquify-tail
      [`(define ,x (lambda (,xs ...) ,value))
       (define new-acc
         (for/fold ([acc '()])
                   ([x xs])
           (dict-set acc x (fresh x))))
       (define new-value
         (uniquify-value value (append acc new-acc)))
       `(define ,(dict-ref acc x) (lambda (,@(dict-values new-acc)) ,new-value))]))
  
  (match p
    [`(module ,definitions ... ,value)
     ;; go through each definition and map x to (fresh-label x)
     (define labels-acc
       (for/fold ([acc '()])
                 ([def definitions])
       (match def
         [`(define ,x (lambda (,xs ...) ,value))
          (dict-set acc x (fresh-label x))])))
     ;; go through each definition and uniquify it given above mapping
     (define uniquify-defs
       (for/fold ([uniquify-defs '()])
                 ([def definitions])
       (define new-def (uniquify-def def labels-acc))
       (cons new-def uniquify-defs)))
     (set! uniquify-defs (reverse uniquify-defs))
     (define new-value (uniquify-value value labels-acc))
     `(module ,@uniquify-defs ,new-value)]))

;; para-asm-lang-v7? -> paren-x64-v7?
;; Compile the Para-asm-lang v7 to Paren-x64 v7
;; by patching instructions that have no x64 analogue
;; into to a sequence of instructions and an auxiliary
;; register from current-patch-instructions-registers.
(define (patch-instructions p)

  (define areg1 (set-first (current-auxiliary-registers)))
  (define areg2 (set-first (set-rest (current-auxiliary-registers))))

  ;; relop -> relop
  ;; Returns the negation of the input relop
  (define (negate-relop r)
    (match r
      [`< `>=]
      [`<= `>]
      [`= `!=]
      [`>= `<]
      [`> `<=]
      [`!= `=]))

  ;; any? -> Boolean
  ;; Returns true if the input is an address
  (define (addr? a)
    (match a
      [`(,fbp - ,offset) #t]
      [_ #f]))

  ;; (para-asm-lang-v7? s) -> List (paren-x64-v7? s)
  ;; Compiles a single s instruction to a list of new instructions
  (define (patch-instructions-s s)
    (match s
      [`(set! ,loc1 (,binop ,loc1 ,opand))
       (match loc1
         [addr #:when (addr? addr)
             (list `(set! ,areg1 ,addr)
                   `(set! ,areg1 (,binop ,areg1 ,opand))
                   `(set! ,addr ,areg1))]
         [reg #:when (register? reg)
              (match opand
               [int64 #:when (and (int64? int64) (not (int32? int64)))
                      (list `(set! ,areg2 ,int64)
                            `(set! ,reg (,binop ,reg ,areg2)))]
               [else (list s)])])]
       [`(set! ,loc ,triv)
       (match loc
         [addr #:when (addr? addr)
               (match triv
                 [addr2 #:when (addr? addr2)
                        (list `(set! ,areg1 ,addr2)
                              `(set! ,addr ,areg1))]
                 [int64 #:when (and (int64? int64) (not (int32? int64)))
                        (list `(set! ,areg1 ,int64)
                              `(set! ,loc ,areg1))]
                 [int32 #:when (int32? int32) (list s)]
                 [reg   #:when (register? reg) (list s)]
                 [label #:when (label? label) (list s)])]
         [reg #:when (register? reg)
              (list s)])]
      [`(jump ,trg)
       (match trg
         [addr #:when (addr? addr) 
               (list `(set! ,areg1 ,trg)
                     `(jump ,areg1))]
         [else (list s)])]
      [`(with-label ,label ,s1)
       (define sub-instructions (patch-instructions-s s1))
       (cons `(with-label ,label ,(first sub-instructions)) (rest sub-instructions))]
      [`(compare ,loc ,opand)
       (match loc
         [reg #:when (register? reg)
              (match opand
                [addr #:when (addr? addr)
                       (list `(set! ,areg1 ,addr)
                             `(compare ,reg ,areg1))]
                [int64 #:when (and (int64? int64) (not (int32? int64)))
                       (list `(set! ,areg1 ,int64)
                             `(compare ,reg ,areg1))]
                [_ (list s)])]
         [addr #:when (addr? addr)
               (match opand
                [addr2 #:when (addr? addr2)
                       (list `(set! ,areg2 ,addr2)
                             `(set! ,areg1 ,addr)
                             `(compare ,areg1 ,areg2))]
                [int64 #:when (int64? int64)
                       (list `(set! ,areg1 ,loc)
                             `(compare ,areg1 ,int64))]
                [reg   #:when (register? reg)
                       (list `(set! ,areg1 ,loc)
                             `(compare ,areg1 ,reg))])])]
      [`(jump-if ,relop ,trg)
       (match trg
         [addr #:when (addr? addr)  
                (define tmp-label (fresh-label))
                (list `(set! ,areg1 ,addr)
                      `(jump-if ,(negate-relop relop) ,tmp-label)
                      `(jump ,areg1)
                      `(with-label ,tmp-label (set! ,areg1 ,areg1)))]
         [reg   #:when (register? reg)
                (define tmp-label (fresh-label))
                (list `(jump-if ,(negate-relop relop) ,tmp-label)
                      `(jump ,reg)
                      `(with-label ,tmp-label (set! ,areg1 ,areg1)))]
         [label #:when (label? label)
                (list s)])]))

  (match p
    [`(begin ,ss ...)
     `(begin ,@(apply append (map patch-instructions-s ss)))]))

;; exprs-bits-lang-v7? -> values-bits-lang-v7?
;; Performs the monadic form transformation, unnesting all non-trivial operators and operands 
;; to binops, calls, and relops, making data flow explicit and and simple to implement imperatively.
(define (remove-complex-opera* p)

  ;; (exprs-bits-lang-v7? pred) -> (values-bits-lang-v7? pred)
  (define (rco-pred p)
    (match p
      [`(let ([,alocs ,values] ...) ,pred)
        (define let-vals 
          (for/fold ([res '()])
                    ([aloc alocs]
                     [value values])
                     (append res (list `(,aloc ,(rco-value value))))))
        `(let (,@let-vals) ,(rco-pred pred))]
      [`(if ,pred1 ,pred2, pred3) `(if ,(rco-pred pred1) ,(rco-pred pred2) ,(rco-pred pred3))]
      [`(not ,pred) `(not ,(rco-pred pred))]
      [`(true) p]
      [`(false) p]
      [`(,relop ,val1 ,val2) (rco-op p)]))

  ;; (exprs-bits-lang-v7? (call ,value ,vals ...)) alocs -> (values-bits-lang-v7? value)
  (define (rco-value-call v alocs)
    (match v
      [`(call ,value ,vals ...)
        (if (empty? vals)
          (if (triv? value)
            `(call ,@alocs ,value)
            (let ()
              (define tmp (fresh))
              `(let ((,tmp ,(rco-value value))) (call ,@alocs ,tmp))))
          (if (triv? value)
            (rco-value-call `(call ,@vals) (append alocs (list value)))
            (let ()
              (define tmp (fresh))
              `(let ((,tmp ,(rco-value value))) ,(rco-value-call `(call ,@vals) (append alocs (list tmp)))))))]))

  ;; (exprs-bits-lang-v7? value) -> (values-bits-lang-v7? value)
  (define (rco-value v)
    (match v
      [`(call ,value ,vals ...)
        (rco-value-call v '())]
      [`(let ([,alocs ,values] ...) ,value)
        (define let-vals 
          (for/fold ([res '()])
                    ([aloc alocs]
                     [value values])
                     (append res (list `(,aloc ,(rco-value value))))))
        `(let (,@let-vals) ,(rco-value value))]
      [`(if ,pred ,val1 ,val2) `(if ,(rco-pred pred) ,(rco-value val1) ,(rco-value val2))]
      [`(,binop ,val1 ,val2) (rco-op v)]
      [triv v]))

  (define (opand? o)
    (or (int64? o) (aloc? o)))

  (define (triv? t)
    (or (opand? t) (label? t)))

  ;; (exprs-bits-lang-v7? op) -> (values-bits-lang-v7? op)
  (define (rco-op o)
    (match o
      [`(,op ,val1 ,val2)
        (cond
          [(not (or (triv? val1) (triv? val2)))
            (define-values (tmp-1 tmp-2) (values (fresh) (fresh))) 
            `(let ((,tmp-1 ,(rco-value val1))) (let ((,tmp-2 ,(rco-value val2))) (,op ,tmp-1 ,tmp-2)))]
          [(not (triv? val1))
            (define tmp-1 (fresh))
            `(let ((,tmp-1 ,(rco-value val1))) (,op ,tmp-1 ,val2))]
          [(not (triv? val2))
            (define tmp-1 (fresh))
            `(let ((,tmp-1 ,(rco-value val2))) (,op ,val1 ,tmp-1))]
          [else o])]))

  ;; (exprs-bits-lang-v7? def) -> (values-bits-lang-v7? def)
  (define (rco-def d)
    (match d
      [`(define ,label (lambda (,aloc ...) ,value))
        `(define ,label (lambda ,aloc ,(rco-value value)))]))

  (match p
    [`(module ,definitions ... ,value)
      (define rco-definitions
        (for/fold ([res '()])
                  ([definition definitions])
          (append res (list (rco-def definition)))))
      `(module ,@rco-definitions ,(rco-value value))]))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                             TESTS                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(module+ test
  (require
   rackunit
   rackunit/text-ui
   cpsc411/langs/v7
   cpsc411/test-suite/public/v7)

  ;; You can modify this pass list, e.g., by adding other
  ;; optimization, debugging, or validation passes.
  ;; Doing this may provide additional debugging info when running the rest
  ;; suite.
  (define pass-map
    (list
     #;(cons check-exprs-lang #f)
     (cons uniquify interp-exprs-lang-v7)
     (cons implement-safe-primops interp-exprs-unique-lang-v7)
     (cons specify-representation interp-exprs-unsafe-data-lang-v7)
     (cons remove-complex-opera* interp-exprs-bits-lang-v7)
     (cons sequentialize-let interp-values-bits-lang-v7)
     (cons normalize-bind interp-imp-mf-lang-v7)
     (cons impose-calling-conventions interp-proc-imp-cmf-lang-v7)
     (cons select-instructions interp-imp-cmf-lang-v7)
     (cons uncover-locals interp-asm-pred-lang-v7)
     (cons undead-analysis interp-asm-pred-lang-v7/locals)
     (cons conflict-analysis interp-asm-pred-lang-v7/undead)
     (cons assign-call-undead-variables interp-asm-pred-lang-v7/conflicts)
     (cons allocate-frames interp-asm-pred-lang-v7/pre-framed)
     (cons assign-registers interp-asm-pred-lang-v7/framed)
     (cons assign-frame-variables interp-asm-pred-lang-v7/spilled)
     (cons replace-locations interp-asm-pred-lang-v7/assignments)
     (cons optimize-predicates interp-nested-asm-lang-fvars-v7)
     (cons implement-fvars interp-nested-asm-lang-fvars-v7)
     (cons expose-basic-blocks interp-nested-asm-lang-v7)
     (cons resolve-predicates interp-block-pred-lang-v7)
     (cons flatten-program interp-block-asm-lang-v7)
     (cons patch-instructions interp-para-asm-lang-v7)
     (cons generate-x64 interp-paren-x64-v7)
     (cons wrap-x64-boilerplate #f)
     (cons wrap-x64-run-time #f)))

  (current-pass-list
   (map car pass-map))

  (run-tests
   (v7-public-test-suite
    (current-pass-list)
    (map cdr pass-map))))
