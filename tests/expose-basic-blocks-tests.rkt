#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    "../compiler.rkt"
    rackunit
    rackunit/text-ui)

(check-equal? (expose-basic-blocks '(module (halt 6)))
              '(module (define L.__main.1 (halt 6))))


(check-equal? (expose-basic-blocks '(module (if (true) (halt 5) (halt 6))))
              '(module
  (define L.__main.3 (if (true) (jump L.__nested.1) (jump L.__nested.2)))
  (define L.__nested.1 (halt 5))
  (define L.__nested.2 (halt 6))))


(check-equal? (expose-basic-blocks '(module (if (not (true)) (halt 5) (halt 6))))
              '(module
  (define L.__main.3 (if (true) (jump L.__nested.2) (jump L.__nested.1)))
  (define L.__nested.1 (halt 5))
  (define L.__nested.2 (halt 6))))

(check-equal? (expose-basic-blocks '(module (if (if (true) (false) (true)) (halt 5) (halt 6))))
              '(module
  (define L.__main.5 (if (true) (jump L.tmp.3) (jump L.tmp.4)))
  (define L.tmp.3 (if (false) (jump L.__nested.1) (jump L.__nested.2)))
  (define L.tmp.4 (if (true) (jump L.__nested.1) (jump L.__nested.2)))
  (define L.__nested.1 (halt 5))
  (define L.__nested.2 (halt 6))))

(check-equal? (expose-basic-blocks '(module (begin (set! fv0 1) (set! fv1 2) (halt 0))))
              '(module (define L.__main.1 (begin (set! fv0 1) (set! fv1 2) (halt 0)))))


(check-equal? (expose-basic-blocks '(module (begin (begin (set! fv0 1) (set! fv1 2)) (begin (begin (set! fv0 (+ fv0 fv1)))) (halt fv0))))
              '(module
  (define L.__main.1
    (begin (set! fv0 1) (set! fv1 2) (set! fv0 (+ fv0 fv1)) (halt fv0)))))


(check-equal? (expose-basic-blocks '(module (if (begin (set! rax 0) (< rax 1)) (halt 5) (halt 6))))
              '(module
  (define L.__main.3
    (begin
      (set! rax 0)
      (if (< rax 1) (jump L.__nested.1) (jump L.__nested.2))))
  (define L.__nested.1 (halt 5))
  (define L.__nested.2 (halt 6))))

(check-equal? (expose-basic-blocks 
'(module (if
          (begin
            (set! rax 0)
            (if (< rax 0)
                (true)
                (false)))
 (halt 5) (halt 6))))
              '(module
  (define L.__main.5
    (begin (set! rax 0) (if (< rax 0) (jump L.tmp.3) (jump L.tmp.4))))
  (define L.tmp.3 (if (true) (jump L.__nested.1) (jump L.__nested.2)))
  (define L.tmp.4 (if (false) (jump L.__nested.1) (jump L.__nested.2)))
  (define L.__nested.1 (halt 5))
  (define L.__nested.2 (halt 6))))


(check-equal? (expose-basic-blocks '(module (begin (if (true) (set! fv0 1) (set! fv1 2)) (set! fv0 1) (set! fv1 2) (halt 0))))
              '(module
  (define L.__main.4 (if (true) (jump L.tmp.1) (jump L.tmp.2)))
  (define L.tmp.1 (begin (set! fv0 1) (jump L.tmp.3)))
  (define L.tmp.2 (begin (set! fv1 2) (jump L.tmp.3)))
  (define L.tmp.3 (begin (set! fv0 1) (set! fv1 2) (halt 0)))))

(check-equal? (expose-basic-blocks '(module (begin (set! fv0 3) (if (true) (set! fv0 1) (set! fv1 2)) (set! fv0 1) (set! fv1 2) (halt 0))))
              `(module
  (define L.__main.4
    (begin (set! fv0 3) (if (true) (jump L.tmp.1) (jump L.tmp.2))))
  (define L.tmp.1 (begin (set! fv0 1) (jump L.tmp.3)))
  (define L.tmp.2 (begin (set! fv1 2) (jump L.tmp.3)))
  (define L.tmp.3 (begin (set! fv0 1) (set! fv1 2) (halt 0)))))


(check-equal? (expose-basic-blocks '(module (begin (set! r8 12) (set! r9 12) (if (true) (set! r12 15) (set! r13 90)) (halt r8))))
              '(module
  (define L.__main.4
    (begin
      (set! r8 12)
      (set! r9 12)
      (if (true) (jump L.tmp.1) (jump L.tmp.2))))
  (define L.tmp.1 (begin (set! r12 15) (jump L.tmp.3)))
  (define L.tmp.2 (begin (set! r13 90) (jump L.tmp.3)))
  (define L.tmp.3 (halt r8))))

(check-equal? (expose-basic-blocks
               '(module
                    (define L.identity.6
                      (begin (set! (rbp - 0) r15)
                             (set! r15 rdi)
                             (if (= r15 0)
                                 (begin
                                   (set! rax 0)
                                   (jump (rbp - 0)))
                                 (begin
                                   (set! (rbp - 8) r15)
                                   (set! (rbp - 8) (- (rbp - 8) 1))
                                   (set! rbp (- rbp 16))
                                   (return-point L.tmp.14
                                                 (begin
                                                   (set! rdi (rbp - -8))
                                                   (set! r15 L.tmp.14)
                                                   (jump L.identity.6)))
                                   (set! rbp (+ rbp 16))
                                   (set! r15 rax)
                                   (set! rax 1)
                                   (set! rax (+ rax r15))
                                   (jump (rbp - 0))))))
                  (define L.fact.7
                    (begin
                      (set! (rbp - 0) r15)
                      (set! (rbp - 8) rdi)
                      (set! rbp (- rbp 32))
                      (return-point L.tmp.18
                                    (begin
                                      (set! rdi (rbp - -24))
                                      (set! r15 L.tmp.18)
                                      (jump L.identity.6)))
                      (set! rbp (+ rbp 32))
                      (set! (rbp - 8) rax)
                      (set! rbp (- rbp 32))
                      (return-point L.tmp.19
                                    (begin (set! rdi 0)
                                           (set! r15 L.tmp.19)
                                           (jump L.identity.6)))
                      (set! rbp (+ rbp 32)) (set! r15 rax)
                      (if (= (rbp - 8) r15)
                          (begin
                            (set! rbp (- rbp 32))
                            (return-point L.tmp.15
                                          (begin
                                            (set! rdi 1)
                                            (set! r15 L.tmp.15)
                                            (jump L.identity.6)))
                            (set! rbp (+ rbp 32))
                            (set! r15 rax)
                            (set! rax r15)
                            (jump (rbp - 0)))
                          (begin
                            (set! rbp (- rbp 32))
                            (return-point L.tmp.17
                                          (begin
                                            (set! rdi 1)
                                            (set! r15 L.tmp.17)
                                            (jump L.identity.6)))
                            (set! rbp (+ rbp 32))
                            (set! r15 rax)
                            (set! (rbp - 16) (rbp - 8))
                            (set! (rbp - 16) (- (rbp - 16) r15))
                            (set! rbp (- rbp 32))
                            (return-point L.tmp.16
                                          (begin
                                            (set! rdi (rbp - -16))
                                            (set! r15 L.tmp.16)
                                            (jump L.fact.7)))
                            (set! rbp (+ rbp 32))
                            (set! r15 rax)
                            (set! rax (rbp - 8))
                            (set! rax (* rax r15))
                            (jump (rbp - 0))))))
                  (begin
                    (set! r15 r15)
                    (set! rdi 5)
                    (set! r15 r15)
                    (jump L.fact.7))))
'(module
  (define L.__main.1
    (begin (set! r15 r15) (set! rdi 5) (set! r15 r15) (jump L.fact.7)))
  (define L.identity.6
    (begin
      (set! (rbp - 0) r15)
      (set! r15 rdi)
      (if (= r15 0) (jump L.__nested.2) (jump L.__nested.3))))
  (define L.tmp.14
    (begin
      (set! rbp (+ rbp 16))
      (set! r15 rax)
      (set! rax 1)
      (set! rax (+ rax r15))
      (jump (rbp - 0))))
  (define L.__nested.2 (begin (set! rax 0) (jump (rbp - 0))))
  (define L.__nested.3
    (begin
      (set! (rbp - 8) r15)
      (set! (rbp - 8) (- (rbp - 8) 1))
      (set! rbp (- rbp 16))
      (set! rdi (rbp - -8))
      (set! r15 L.tmp.14)
      (jump L.identity.6)))
  (define L.fact.7
    (begin
      (set! (rbp - 0) r15)
      (set! (rbp - 8) rdi)
      (set! rbp (- rbp 32))
      (set! rdi (rbp - -24))
      (set! r15 L.tmp.18)
      (jump L.identity.6)))
  (define L.tmp.15
    (begin
      (set! rbp (+ rbp 32))
      (set! r15 rax)
      (set! rax r15)
      (jump (rbp - 0))))
  (define L.tmp.17
    (begin
      (set! rbp (+ rbp 32))
      (set! r15 rax)
      (set! (rbp - 16) (rbp - 8))
      (set! (rbp - 16) (- (rbp - 16) r15))
      (set! rbp (- rbp 32))
      (set! rdi (rbp - -16))
      (set! r15 L.tmp.16)
      (jump L.fact.7)))
  (define L.tmp.16
    (begin
      (set! rbp (+ rbp 32))
      (set! r15 rax)
      (set! rax (rbp - 8))
      (set! rax (* rax r15))
      (jump (rbp - 0))))
  (define L.__nested.4
    (begin
      (set! rbp (- rbp 32))
      (set! rdi 1)
      (set! r15 L.tmp.15)
      (jump L.identity.6)))
  (define L.__nested.5
    (begin
      (set! rbp (- rbp 32))
      (set! rdi 1)
      (set! r15 L.tmp.17)
      (jump L.identity.6)))
  (define L.tmp.18
    (begin
      (set! rbp (+ rbp 32))
      (set! (rbp - 8) rax)
      (set! rbp (- rbp 32))
      (set! rdi 0)
      (set! r15 L.tmp.19)
      (jump L.identity.6)))
  (define L.tmp.19
    (begin
      (set! rbp (+ rbp 32))
      (set! r15 rax)
      (if (= (rbp - 8) r15) (jump L.__nested.4) (jump L.__nested.5))))))

(check-equal? (expose-basic-blocks '(module (begin (set! (rbp - 0) 8) (set! (rbp - 8) (rbp - 0)) (set! (rbp - 8) (+ (rbp - 8) 8)) (set! (rbp - 16) (rbp - 8)) (set! (rbp - 16) (+ (rbp - 16) 8)) (set! rax (rbp - 16)) (jump r15))))
              '(module
  (define L.__main.1
    (begin
      (set! (rbp - 0) 8)
      (set! (rbp - 8) (rbp - 0))
      (set! (rbp - 8) (+ (rbp - 8) 8))
      (set! (rbp - 16) (rbp - 8))
      (set! (rbp - 16) (+ (rbp - 16) 8))
      (set! rax (rbp - 16))
      (jump r15)))))