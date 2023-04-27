#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    "../compiler.rkt"
    rackunit
    rackunit/text-ui)

(check-equal? (remove-complex-opera* 
  '(module 
    (* (+ x.1 1) 2)))
  '(module
    (let ((tmp.1 (+ x.1 1)))
    (* tmp.1 2))))

(check-equal? (remove-complex-opera* 
  '(module
    (+ 3 (let ([x.1 1]) x.1))))
  '(module 
    (let ((tmp.2 (let ((x.1 1)) x.1))) (+ 3 tmp.2))))   

(check-equal? (remove-complex-opera*
  '(module 
      (* (+ x.1 1) (bitwise-and x.2 2))))
  '(module
    (let ((tmp.3 (+ x.1 1)))
      (let ((tmp.4 (bitwise-and x.2 2))) (* tmp.3 tmp.4)))))
 
(check-equal? (remove-complex-opera* 
  '(module (let ([x.1 1]) (bitwise-xor x.1 2))))
  '(module (let ([x.1 1]) (bitwise-xor x.1 2))))

(check-equal? (remove-complex-opera*
  '(module (let ([x.1 1]) (let ([x.2 2]) (let ([x.3 3]) x.1)))))
  '(module (let ((x.1 1)) (let ((x.2 2)) (let ((x.3 3)) x.1)))))

(check-equal? (remove-complex-opera* 
  '(module (let ([x.1 (* 1 (* 3 4))]) (let ([x.2 2]) (let ([x.3 3]) x.1)))))
  '(module
    (let ((x.1 (let ((tmp.5 (* 3 4))) (* 1 tmp.5))))
      (let ((x.2 2)) (let ((x.3 3)) x.1)))))  

(check-equal? (remove-complex-opera*
  '(module (if (let ([x.1 1]) (let ([x.2 2]) (> 3 2))) 0 1)))
  '(module (if (let ((x.1 1)) (let ((x.2 2)) (> 3 2))) 0 1)))

(check-equal? (remove-complex-opera*
  '(module (if (true) (if (true) (if (false) x.2 x.3) x.1) (let ([x.1 1]) (let ([x.2 2]) (let ([x.3 3]) x.1))))))
  '(module (if (true) (if (true) (if (false) x.2 x.3) x.1) (let ((x.1 1)) (let ((x.2 2)) (let ((x.3 3)) x.1))))))

(check-equal? (remove-complex-opera*
  '(module (if (> 3 (if (< 3 x.4) 3 2)) 3 x.3)))
'(module (if (let ((tmp.6 (if (< 3 x.4) 3 2))) (> 3 tmp.6)) 3 x.3)))

(check-equal? (remove-complex-opera*
  '(module 
    (if (> 3 (if (< 3 x.4) 3 2)) 
      (+ (let ([x.1 1]) x.1) 3) 
      (call x.1 (call x.2 x.3 (call x.4))))))
  '(module
    (if (let ((tmp.7 (if (< 3 x.4) 3 2))) (> 3 tmp.7))
      (let ((tmp.8 (let ((x.1 1)) x.1))) (+ tmp.8 3))
      (let ((tmp.9 (let ((tmp.10 (call x.4))) (call x.2 x.3 tmp.10)))) (call x.1 tmp.9)))))

;;calls
 (check-equal? (remove-complex-opera* 
  '(module (call (* 3 (+ 1 2)))))
  '(module (let ((tmp.11 (let ((tmp.12 (+ 1 2))) (* 3 tmp.12)))) (call tmp.11))))

(check-equal? (remove-complex-opera*
  '(module (call x.1)))
  '(module (call x.1)))

 (check-equal? (remove-complex-opera*
  '(module (call x.1 (+ (let ([x.1 1]) x.1) 3) x.2)))
  '(module
  (let ((tmp.13 (let ((tmp.14 (let ((x.1 1)) x.1))) (+ tmp.14 3))))
    (call x.1 tmp.13 x.2)))) 

(check-equal? (remove-complex-opera*
  '(module 
    (call x.1 (+ (let ([x.1 1]) x.1) 3) (* (+ x.1 1) (bitwise-and x.2 2)))))
  '(module
  (let ((tmp.15 (let ((tmp.16 (let ((x.1 1)) x.1))) (+ tmp.16 3))))
    (let ((tmp.17
           (let ((tmp.18 (+ x.1 1)))
             (let ((tmp.19 (bitwise-and x.2 2))) (* tmp.18 tmp.19)))))
      (call x.1 tmp.15 tmp.17)))))

(check-equal? (remove-complex-opera*
  '(module (call (let ([x.1 2]) x.1) (let ([y.2 3]) y.2) (let ([z.3 4]) z.3))))
  '(module
    (let ((tmp.20 (let ((x.1 2)) x.1)))
        (let ((tmp.21 (let ((y.2 3)) y.2)))
            (let ((tmp.22 (let ((z.3 4)) z.3))) 
                (call tmp.20 tmp.21 tmp.22))))))

(check-equal? (remove-complex-opera*
  '(module 
    (call x.1 (+ (let ([x.1 (+ (let ([x.1 1] [y.2 1]) x.1) 3)]) x.1) 3) (* (+ x.1 1) (bitwise-and x.2 2)))))
  '(module
  (let ((tmp.23
         (let ((tmp.24
                (let ((x.1
                       (let ((tmp.25 (let ((x.1 1) (y.2 1)) x.1)))
                         (+ tmp.25 3))))
                  x.1)))
           (+ tmp.24 3))))
    (let ((tmp.26
           (let ((tmp.27 (+ x.1 1)))
             (let ((tmp.28 (bitwise-and x.2 2))) (* tmp.27 tmp.28)))))
      (call x.1 tmp.23 tmp.26)))))

(check-equal? (remove-complex-opera*
  '(module
  (define L.boolean?.2
    (lambda (tmp.18) (if (= (bitwise-and tmp.18 247) 6) 14 6)))
  (define L.+.1
    (lambda (tmp.3 tmp.4)
      (if (!= (if (= (bitwise-and tmp.4 7) 0) 14 6) 6)
        (if (!= (if (= (bitwise-and tmp.3 7) 0) 14 6) 6) (+ tmp.3 tmp.4) 574)
        574)))
  (define L.test.1 (lambda (x.1 x.2) (call L.+.1 8 16)))
  (if (!= (call L.boolean?.2 16) 6) 30 22)))
  '(module
  (define L.boolean?.2
    (lambda (tmp.18)
      (if (let ((tmp.29 (bitwise-and tmp.18 247))) (= tmp.29 6)) 14 6)))
  (define L.+.1
    (lambda (tmp.3 tmp.4)
      (if (let ((tmp.30
                 (if (let ((tmp.31 (bitwise-and tmp.4 7))) (= tmp.31 0)) 14 6)))
            (!= tmp.30 6))
        (if (let ((tmp.32
                   (if (let ((tmp.33 (bitwise-and tmp.3 7))) (= tmp.33 0))
                     14
                     6)))
              (!= tmp.32 6))
          (+ tmp.3 tmp.4)
          574)
        574)))
  (define L.test.1 (lambda (x.1 x.2) (call L.+.1 8 16)))
  (if (let ((tmp.34 (call L.boolean?.2 16))) (!= tmp.34 6)) 30 22))
)      