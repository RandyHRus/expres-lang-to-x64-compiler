#lang racket
(require
    cpsc411/compiler-lib
    cpsc411/langs/v2
    cpsc411/langs/v2-reg-alloc
    "../compiler.rkt"
    rackunit
    rackunit/text-ui)

(check-equal?
    (generate-x64
   '(begin
      (set! rax 0)
      (set! rax (- rax 42))))
    "mov rax, 0\nsub rax, 42\n")

(check-equal?
    (generate-x64
    '(begin
       (set! rax 170679)
       (set! rdi rax)
       (set! rdi (+ rdi rdi))
       (set! rsp rdi)
       (set! rsp (- rsp rsp))
       (set! rbx 8991)))
    "mov rax, 170679\nmov rdi, rax\nadd rdi, rdi\nmov rsp, rdi\nsub rsp, rsp\nmov rbx, 8991\n")

(check-equal?
    (generate-x64
        '(begin
            (set! rax 170679)
            (jump rax)
            (jump L.start.1)))
    "mov rax, 170679\njmp rax\njmp L.start.1\n")

(check-equal?
    (generate-x64
        '(begin
            (with-label L.start.1
                (set! rax 1))
            (jump rax)
            (with-label L.test.2
                (set! rax 1))))
    "L.start.1:\nmov rax, 1\njmp rax\nL.test.2:\nmov rax, 1\n")

(check-equal?
    (generate-x64
        '(begin
            (compare rax 61)
            (jump-if < L.start.1)
            (compare rdi rax)
            (jump-if != L.start.1)
            (compare rdi rax)
            (jump-if = L.start.1)
            (compare rdi rax)
            (jump-if <= L.start.1)
            (compare rdi rax)
            (jump-if >= L.start.1)
            (compare rdi rax)
            (jump-if > L.start.1)))
    "cmp rax, 61\njl L.start.1\ncmp rdi, rax\njne L.start.1\ncmp rdi, rax\nje L.start.1\ncmp rdi, rax\njle L.start.1\ncmp rdi, rax\njge L.start.1\ncmp rdi, rax\njg L.start.1\n")

(check-equal?
    (generate-x64
    '(begin
       (set! rsp (bitwise-and rsp rsp))
       (set! rsp (bitwise-ior rsp rsp))
       (set! rsp (bitwise-xor rsp rsp))
       (set! rsp (arithmetic-shift-right rsp rsp))))
    "and rsp, rsp\nor rsp, rsp\nxor rsp, rsp\nsar rsp, rsp\n")

(check-equal?
    (generate-x64
    '(begin
       (set! rsp (bitwise-and rsp 1))
       (set! rsp (bitwise-ior rsp 2))
       (set! rsp (bitwise-xor rsp 3))
       (set! rsp (arithmetic-shift-right rsp 4))))
    "and rsp, 1\nor rsp, 2\nxor rsp, 3\nsar rsp, 4\n")