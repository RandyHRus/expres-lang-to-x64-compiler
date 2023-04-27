#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    "../compiler.rkt"
    rackunit
    rackunit/text-ui)

(check-equal? (uniquify
                '(module
                    (let ([e #f] [- 2])
                    (call fixnum? (void) -))))
                '(module 
                    (let ((e.2 #f) (|-.1| 2)) 
                    (call fixnum? (void) |-.1|))))

(check-equal? (uniquify 
                '(module
                    (let ([* 1] [- 2])
                    (call + * -))))
                `(module 
                    (let ((*.2 1) (|-.1| 2)) 
                    (call + *.2 |-.1|))))             

(check-equal? (uniquify
                `(module 
                    (define abra 
                        (lambda (x) 
                            (if (call eq? x 0) < (call abra (call - x 1) (call * (error 5) x))))) 
                    (call abra (void) 1)))
                `(module
                    (define L.abra.1
                        (lambda (x.1) 
                            (if (call eq? x.1 0) < (call L.abra.1 (call - x.1 1) (call * (error 5) x.1)))))
                    (call L.abra.1 (void) 1)))

(check-equal? (uniquify
                `(module 
                    (define abra 
                        (lambda (x) 
                            (if (call eq? x 0) < (call abra (call - x 1) (call * (error 5) x)))))
                    (define ping 
                        (lambda (a b c) 
                            (if 
                                (let ([a #f] [b (error 2)]) 
                                    (let ([c 3]) (call < 3))) 
                                b 
                                (call ping (call - a 1) 
                                    (if a empty c)))))         
                    (call abra #\a 1)))
                `(module
                    (define L.abra.1
                        (lambda (x.1)
                        (if (call eq? x.1 0)
                            <
                            (call L.abra.1 (call - x.1 1) (call * (error 5) x.1)))))
                    (define L.ping.2
                        (lambda (a.4 b.3 c.2)
                        (if (let ((a.6 #f) (b.5 (error 2))) (let ((c.7 3)) (call < 3)))
                            b.3
                            (call L.ping.2 (call - a.4 1) (if a.4 empty c.2)))))
                    (call L.abra.1 #\a 1))) 