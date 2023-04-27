#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    "../compiler.rkt"
    rackunit
    rackunit/text-ui)


(check-equal? 
  (implement-fvars 
    '(module (begin (set! r15 (bitwise-and r15 r15)) (jump r15))))
  '(module (begin (set! r15 (bitwise-and r15 r15)) (jump r15))))

(check-equal? (implement-fvars '(module (begin (set! r14 r15) (set! r13 20) (set! r15 21) (if (not (> r13 12)) (if (if (begin (set! r13 r13) (< r15 r13)) (true) (false)) (begin (set! rax 10) (jump r14)) (begin (set! rax 12) (jump r14))) (begin (set! rax r13) (set! rax (+ rax r15)) (jump r14))))))
              '(module
  (begin
    (set! r14 r15)
    (set! r13 20)
    (set! r15 21)
    (if (not (> r13 12))
      (if (if (begin (set! r13 r13) (< r15 r13)) (true) (false))
        (begin (set! rax 10) (jump r14))
        (begin (set! rax 12) (jump r14)))
      (begin (set! rax r13) (set! rax (+ rax r15)) (jump r14))))))

(check-equal? (implement-fvars '(module (define L.identity.6 (begin (set! fv0 r15) (set! r15 rdi) (if (= r15 0) (begin (set! rax 0) (jump fv0)) (begin (set! fv1 r15) (set! fv1 (- fv1 1)) (begin (set! rbp (- rbp 16)) (return-point L.tmp.14 (begin (set! rdi fv1) (set! r15 L.tmp.14) (jump L.identity.6))) (set! rbp (+ rbp 16))) (set! r15 rax) (set! rax 1) (set! rax (+ rax r15)) (jump fv0))))) (define L.fact.7 (begin (set! fv0 r15) (set! fv1 rdi) (begin (set! rbp (- rbp 32)) (return-point L.tmp.18 (begin (set! rdi fv1) (set! r15 L.tmp.18) (jump L.identity.6))) (set! rbp (+ rbp 32))) (set! fv1 rax) (begin (set! rbp (- rbp 32)) (return-point L.tmp.19 (begin (set! rdi 0) (set! r15 L.tmp.19) (jump L.identity.6))) (set! rbp (+ rbp 32))) (set! r15 rax) (if (= fv1 r15) (begin (begin (set! rbp (- rbp 32)) (return-point L.tmp.15 (begin (set! rdi 1) (set! r15 L.tmp.15) (jump L.identity.6))) (set! rbp (+ rbp 32))) (set! r15 rax) (set! rax r15) (jump fv0)) (begin (begin (set! rbp (- rbp 32)) (return-point L.tmp.17 (begin (set! rdi 1) (set! r15 L.tmp.17) (jump L.identity.6))) (set! rbp (+ rbp 32))) (set! r15 rax) (set! fv2 fv1) (set! fv2 (- fv2 r15)) (begin (set! rbp (- rbp 32)) (return-point L.tmp.16 (begin (set! rdi fv2) (set! r15 L.tmp.16) (jump L.fact.7))) (set! rbp (+ rbp 32))) (set! r15 rax) (set! rax fv1) (set! rax (* rax r15)) (jump fv0))))) (begin (set! r15 r15) (set! rdi 5) (set! r15 r15) (jump L.fact.7)))
) '(module
  (define L.identity.6
    (begin
      (set! (rbp - 0) r15)
      (set! r15 rdi)
      (if (= r15 0)
        (begin (set! rax 0) (jump (rbp - 0)))
        (begin
          (set! (rbp - 8) r15)
          (set! (rbp - 8) (- (rbp - 8) 1))
          (begin
            (set! rbp (- rbp 16))
            (return-point
             L.tmp.14
             (begin
               (set! rdi (rbp - -8))
               (set! r15 L.tmp.14)
               (jump L.identity.6)))
            (set! rbp (+ rbp 16)))
          (set! r15 rax)
          (set! rax 1)
          (set! rax (+ rax r15))
          (jump (rbp - 0))))))
  (define L.fact.7
    (begin
      (set! (rbp - 0) r15)
      (set! (rbp - 8) rdi)
      (begin
        (set! rbp (- rbp 32))
        (return-point
         L.tmp.18
         (begin
           (set! rdi (rbp - -24))
           (set! r15 L.tmp.18)
           (jump L.identity.6)))
        (set! rbp (+ rbp 32)))
      (set! (rbp - 8) rax)
      (begin
        (set! rbp (- rbp 32))
        (return-point
         L.tmp.19
         (begin (set! rdi 0) (set! r15 L.tmp.19) (jump L.identity.6)))
        (set! rbp (+ rbp 32)))
      (set! r15 rax)
      (if (= (rbp - 8) r15)
        (begin
          (begin
            (set! rbp (- rbp 32))
            (return-point
             L.tmp.15
             (begin (set! rdi 1) (set! r15 L.tmp.15) (jump L.identity.6)))
            (set! rbp (+ rbp 32)))
          (set! r15 rax)
          (set! rax r15)
          (jump (rbp - 0)))
        (begin
          (begin
            (set! rbp (- rbp 32))
            (return-point
             L.tmp.17
             (begin (set! rdi 1) (set! r15 L.tmp.17) (jump L.identity.6)))
            (set! rbp (+ rbp 32)))
          (set! r15 rax)
          (set! (rbp - 16) (rbp - 8))
          (set! (rbp - 16) (- (rbp - 16) r15))
          (begin
            (set! rbp (- rbp 32))
            (return-point
             L.tmp.16
             (begin
               (set! rdi (rbp - -16))
               (set! r15 L.tmp.16)
               (jump L.fact.7)))
            (set! rbp (+ rbp 32)))
          (set! r15 rax)
          (set! rax (rbp - 8))
          (set! rax (* rax r15))
          (jump (rbp - 0))))))
  (begin (set! r15 r15) (set! rdi 5) (set! r15 r15) (jump L.fact.7))))