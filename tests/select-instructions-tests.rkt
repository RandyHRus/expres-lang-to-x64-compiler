#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    "../compiler.rkt"
    rackunit
    rackunit/text-ui)



(check-equal? (select-instructions '(module
  ((new-frames ()))
  (define L.start.1
    ((new-frames (())))
    (begin
      (set! tmp-ra.1 r15)
      (begin
        (set! x.1 rdi)
        (set! x.2 rsi)
        (set! y.3 rdx)
        (set! z.4 rcx)
        (begin
          (begin
            (return-point
             L.rp.1
             (begin (set! rdi y.2) (set! r15 L.rp.1) (jump x.1 rbp r15 rdi)))
            (set! x.1 rax))
          (if (true)
            (begin (set! rax 1) (jump tmp-ra.1 rbp rax))
            (begin (set! rax 2) (jump tmp-ra.1 rbp rax)))))))
  (begin (set! tmp-ra.2 r15) (begin (set! rax 2) (jump tmp-ra.2 rbp rax)))))
              '(module
  ((new-frames ()))
  (define L.start.1
    ((new-frames (())))
    (begin
      (set! tmp-ra.1 r15)
      (set! x.1 rdi)
      (set! x.2 rsi)
      (set! y.3 rdx)
      (set! z.4 rcx)
      (return-point
       L.rp.1
       (begin (set! rdi y.2) (set! r15 L.rp.1) (jump x.1 rbp r15 rdi)))
      (set! x.1 rax)
      (if (true)
        (begin (set! rax 1) (jump tmp-ra.1 rbp rax))
        (begin (set! rax 2) (jump tmp-ra.1 rbp rax)))))
  (begin (set! tmp-ra.2 r15) (set! rax 2) (jump tmp-ra.2 rbp rax))))

(check-equal? (select-instructions '(module
  ((new-frames ()))
  (define L.start.1
    ((new-frames (() ())))
    (begin
      (set! tmp-ra.1 r15)
      (begin
        (set! x.1 rdi)
        (set! x.2 rsi)
        (set! y.3 rdx)
        (set! z.4 rcx)
        (begin
          (set! x.2 1)
          (begin
            (return-point
             L.rp.1
             (begin (set! rdi y.2) (set! r15 L.rp.1) (jump x.1 rbp r15 rdi)))
            (set! x.1 rax))
          (if (true)
            (begin
              (begin
                (return-point
                 L.rp.2
                 (begin
                   (set! rsi z.4)
                   (set! rdi y.3)
                   (set! r15 L.rp.2)
                   (jump x.1 rbp r15 rdi rsi)))
                (set! y.3 rax))
              (begin (set! rax 1) (jump tmp-ra.1 rbp rax)))
            (begin (set! rax 2) (jump tmp-ra.1 rbp rax)))))))
  (begin (set! tmp-ra.2 r15) (begin (set! rax 2) (jump tmp-ra.2 rbp rax)))))
              '(module
  ((new-frames ()))
  (define L.start.1
    ((new-frames (() ())))
    (begin
      (set! tmp-ra.1 r15)
      (set! x.1 rdi)
      (set! x.2 rsi)
      (set! y.3 rdx)
      (set! z.4 rcx)
      (set! x.2 1)
      (return-point
       L.rp.1
       (begin (set! rdi y.2) (set! r15 L.rp.1) (jump x.1 rbp r15 rdi)))
      (set! x.1 rax)
      (if (true)
        (begin
          (return-point
           L.rp.2
           (begin
             (set! rsi z.4)
             (set! rdi y.3)
             (set! r15 L.rp.2)
             (jump x.1 rbp r15 rdi rsi)))
          (set! y.3 rax)
          (set! rax 1)
          (jump tmp-ra.1 rbp rax))
        (begin (set! rax 2) (jump tmp-ra.1 rbp rax)))))
  (begin (set! tmp-ra.2 r15) (set! rax 2) (jump tmp-ra.2 rbp rax))))

(check-equal? (select-instructions '(module
  ((new-frames ()))
  (define L.start.1
    ((new-frames (() ())))
    (begin
      (set! tmp-ra.1 r15)
      (begin
        (set! x.1 rdi)
        (set! x.2 rsi)
        (set! y.3 rdx)
        (set! z.4 rcx)
        (begin
          (set! x.2 1)
          (begin
            (return-point
             L.rp.1
             (begin (set! rdi y.2) (set! r15 L.rp.1) (jump x.1 rbp r15 rdi)))
            (set! x.1 rax))
          (if (true)
            (begin
              (begin
                (return-point
                 L.rp.2
                 (begin
                   (set! z.4 (+ 2 2))
                   (set! rsi z.4)
                   (set! rdi y.3)
                   (set! r15 L.rp.2)
                   (jump x.1 rbp r15 rdi rsi)))
                (set! y.3 rax))
              (begin (set! rax 1) (jump tmp-ra.1 rbp rax)))
            (begin (set! rax 2) (jump tmp-ra.1 rbp rax)))))))
  (begin (set! tmp-ra.2 r15) (begin (set! rax 2) (jump tmp-ra.2 rbp rax)))))
    '(module
  ((new-frames ()))
  (define L.start.1
    ((new-frames (() ())))
    (begin
      (set! tmp-ra.1 r15)
      (set! x.1 rdi)
      (set! x.2 rsi)
      (set! y.3 rdx)
      (set! z.4 rcx)
      (set! x.2 1)
      (return-point
       L.rp.1
       (begin (set! rdi y.2) (set! r15 L.rp.1) (jump x.1 rbp r15 rdi)))
      (set! x.1 rax)
      (if (true)
        (begin
          (return-point
           L.rp.2
           (begin
             (set! z.4 2)
             (set! z.4 (+ z.4 2))
             (set! rsi z.4)
             (set! rdi y.3)
             (set! r15 L.rp.2)
             (jump x.1 rbp r15 rdi rsi)))
          (set! y.3 rax)
          (set! rax 1)
          (jump tmp-ra.1 rbp rax))
        (begin (set! rax 2) (jump tmp-ra.1 rbp rax)))))
  (begin (set! tmp-ra.2 r15) (set! rax 2) (jump tmp-ra.2 rbp rax))))
