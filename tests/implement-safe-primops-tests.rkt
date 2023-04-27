#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    "../compiler.rkt"
    rackunit
    rackunit/text-ui)

(check-equal?
    (implement-safe-primops 
        '(module (call + 1 2)))
    '(module
        (define L.+.1
            (lambda (tmp.3 tmp.4)
            (if (fixnum? tmp.4)
                (if (fixnum? tmp.3) 
                    (unsafe-fx+ tmp.3 tmp.4) 
                    (error 2))
                (error 2))))
        (call L.+.1 1 2)))

(check-equal?
    (implement-safe-primops 
        '(module (call eq? 1 2)))
    '(module
        (define L.eq?.1 (lambda (tmp.15 tmp.16) (eq? tmp.15 tmp.16)))
        (call L.eq?.1 1 2)))

(check-equal?
    (implement-safe-primops 
        '(module (call + + +)))
    '(module
        (define L.+.1
            (lambda (tmp.3 tmp.4)
            (if (fixnum? tmp.4)
                (if (fixnum? tmp.3) (unsafe-fx+ tmp.3 tmp.4) (error 2))
                (error 2))))
        (call L.+.1 L.+.1 L.+.1)))

(check-equal?
    (implement-safe-primops 
        '(module (call + - 2)))
    '(module
        (define L.-.2
            (lambda (tmp.5 tmp.6)
            (if (fixnum? tmp.6)
                (if (fixnum? tmp.5) (unsafe-fx- tmp.5 tmp.6) (error 3))
                (error 3))))
        (define L.+.1
            (lambda (tmp.3 tmp.4)
            (if (fixnum? tmp.4)
                (if (fixnum? tmp.3) (unsafe-fx+ tmp.3 tmp.4) (error 2))
                (error 2))))
        (call L.-.2 L.+.1 2)))

(check-equal?
    (implement-safe-primops 
        '(module (call - 1 2)))
    '(module
        (define L.-.1
            (lambda (tmp.5 tmp.6)
            (if (fixnum? tmp.6)
                (if (fixnum? tmp.5) (unsafe-fx- tmp.5 tmp.6) (error 3))
                (error 3))))
        (call L.-.1 1 2)))

(check-equal?
    (implement-safe-primops 
        '(module
            (if (call > 2 3)
                (void)
                empty)))
    '(module
        (define L.>.1
            (lambda (tmp.11 tmp.12)
            (if (fixnum? tmp.12)
                (if (fixnum? tmp.11) (unsafe-fx> tmp.11 tmp.12) (error 6))
                (error 6))))
        (if (call L.>.1 2 3) (void) empty)))

(check-equal?
    (implement-safe-primops 
            '(module
                (if (call boolean? 2)
                    (void)
                    empty)))
    '(module
        (define L.boolean?.1 (lambda (tmp.18) (boolean? tmp.18)))
        (if (call L.boolean?.1 2) (void) empty)))

(check-equal?
    (implement-safe-primops 
        '(module
            (define L.test.1 (lambda (x.1 x.2) (call + 1 2)))
            (if (call boolean? 2)
                (void)
                empty)))
    '(module
        (define L.boolean?.2 (lambda (tmp.18) (boolean? tmp.18)))
        (define L.+.1
            (lambda (tmp.3 tmp.4)
            (if (fixnum? tmp.4)
                (if (fixnum? tmp.3) (unsafe-fx+ tmp.3 tmp.4) (error 2))
                (error 2))))
        (define L.test.1 (lambda (x.1 x.2) (call L.+.1 1 2)))
        (if (call L.boolean?.2 2) (void) empty)))

(check-equal?
    (implement-safe-primops 
        '(module
            (define L.test.1 (lambda (x.1 x.2) (call + - 2)))
            (if (call boolean? <=)
                (void)
                empty)))
    '(module
        (define L.boolean?.4 (lambda (tmp.18) (boolean? tmp.18)))
        (define L.<=.3
            (lambda (tmp.9 tmp.10)
            (if (fixnum? tmp.10)
                (if (fixnum? tmp.9) (unsafe-fx<= tmp.9 tmp.10) (error 5))
                (error 5))))
        (define L.+.2
            (lambda (tmp.3 tmp.4)
            (if (fixnum? tmp.4)
                (if (fixnum? tmp.3) (unsafe-fx+ tmp.3 tmp.4) (error 2))
                (error 2))))
        (define L.-.1
            (lambda (tmp.5 tmp.6)
            (if (fixnum? tmp.6)
                (if (fixnum? tmp.5) (unsafe-fx- tmp.5 tmp.6) (error 3))
                (error 3))))
        (define L.test.1 (lambda (x.1 x.2) (call L.+.2 L.-.1 2)))
        (if (call L.boolean?.4 L.<=.3) (void) empty)))

(check-equal?
    (implement-safe-primops 
            '(module
                (let ([x.1 -] [y.2 not])
                    (call - empty?))))
    '(module
        (define L.empty?.3 (lambda (tmp.19) (empty? tmp.19)))
        (define L.not.2 (lambda (tmp.23) (not tmp.23)))
        (define L.-.1
            (lambda (tmp.5 tmp.6)
            (if (fixnum? tmp.6)
                (if (fixnum? tmp.5) (unsafe-fx- tmp.5 tmp.6) (error 3))
                (error 3))))
        (let ((x.1 L.-.1) (y.2 L.not.2)) (call L.-.1 L.empty?.3))))

(check-equal?
    (implement-safe-primops 
            '(module
                (call * + - < eq? <= > >= fixnum? boolean? empty? void? ascii-char? error? not)))
    '(module
  (define L.*.15
    (lambda (tmp.1 tmp.2)
      (if (fixnum? tmp.2)
        (if (fixnum? tmp.1) (unsafe-fx* tmp.1 tmp.2) (error 1))
        (error 1))))
        (define L.not.14 (lambda (tmp.23) (not tmp.23)))
        (define L.error?.13 (lambda (tmp.22) (error? tmp.22)))
        (define L.ascii-char?.12 (lambda (tmp.21) (ascii-char? tmp.21)))
        (define L.void?.11 (lambda (tmp.20) (void? tmp.20)))
        (define L.empty?.10 (lambda (tmp.19) (empty? tmp.19)))
        (define L.boolean?.9 (lambda (tmp.18) (boolean? tmp.18)))
        (define L.fixnum?.8 (lambda (tmp.17) (fixnum? tmp.17)))
        (define L.>=.7
            (lambda (tmp.13 tmp.14)
            (if (fixnum? tmp.14)
                (if (fixnum? tmp.13) (unsafe-fx>= tmp.13 tmp.14) (error 7))
                (error 7))))
        (define L.>.6
            (lambda (tmp.11 tmp.12)
            (if (fixnum? tmp.12)
                (if (fixnum? tmp.11) (unsafe-fx> tmp.11 tmp.12) (error 6))
                (error 6))))
        (define L.<=.5
            (lambda (tmp.9 tmp.10)
            (if (fixnum? tmp.10)
                (if (fixnum? tmp.9) (unsafe-fx<= tmp.9 tmp.10) (error 5))
                (error 5))))
        (define L.eq?.4 (lambda (tmp.15 tmp.16) (eq? tmp.15 tmp.16)))
        (define L.<.3
            (lambda (tmp.7 tmp.8)
            (if (fixnum? tmp.8)
                (if (fixnum? tmp.7) (unsafe-fx< tmp.7 tmp.8) (error 4))
                (error 4))))
        (define L.-.2
            (lambda (tmp.5 tmp.6)
            (if (fixnum? tmp.6)
                (if (fixnum? tmp.5) (unsafe-fx- tmp.5 tmp.6) (error 3))
                (error 3))))
        (define L.+.1
            (lambda (tmp.3 tmp.4)
            (if (fixnum? tmp.4)
                (if (fixnum? tmp.3) (unsafe-fx+ tmp.3 tmp.4) (error 2))
                (error 2))))
        (call
        L.*.15
        L.+.1
        L.-.2
        L.<.3
        L.eq?.4
        L.<=.5
        L.>.6
        L.>=.7
        L.fixnum?.8
        L.boolean?.9
        L.empty?.10
        L.void?.11
        L.ascii-char?.12
        L.error?.13
        L.not.14)))