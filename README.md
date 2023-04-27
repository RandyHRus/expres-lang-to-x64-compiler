# Exprs-lang v7 to x64 compiler

Compiles Values-lang v3 to x64 using a series of passes

-   uniquify
-   implement-safe-primops
-   specify-representation
-   remove-complex-opera\*
-   sequentialize-let
-   normalize-bind
-   impose-calling-conventions
-   select-instructions
-   uncover-locals
-   undead-analysis
-   conflict-analysis
-   assign-call-undead-variables
-   allocate-frames
-   assign-registers
-   assign-frame-variables
-   replace-locations
-   implement-fvars
-   expose-basic-blocks
-   resolve-predicates
-   flatten-program
-   patch-instructions
-   generate-x64

Exprs-lang v7 language definition:  
p ::= (module (define x (lambda (x ...) value)) ... value)
value ::= triv
  | (let ([x value] ...) value)
  | (if value value value)
  | (call value value ...)
triv ::= x
  | fixnum
  | #t
  | #f
  | empty
  | (void)
  | (error uint8)
  | ascii-char-literal
x ::= name?
  | prim-f
prim-f ::= binop
  | unop
binop ::= \*
  | +
  | -
  | eq?
  | <
  | <=
  | >
  | >=
unop ::= fixnum?
  | boolean?
  | empty?
  | void?
  | ascii-char?
  | error?
  | not
uint8 ::= uint8?
ascii-char-literal ::= ascii-char-literal?
fixnum ::= int61?

## Example

```
//Exprs-lang v7
'(module
    (define swap
        (lambda (x y)
            (if (call < y x)
                x
                (call swap y x))))
    (call swap 1 2))

//x64 result
L.__main.18:
mov r15, r15
mov rsi, 16
mov rdi, 8
mov r15, r15
jmp L.swap.1
L.$3c$.2:
mov r15, r15
mov r14, rdi
mov r13, rsi
mov r9, r13
and r9, 7
cmp r9, 0
je L.__nested.14
jmp L.__nested.15
L.swap.1:
mov QWORD [rbp - 16], r15
mov QWORD [rbp - 8], rdi
mov QWORD [rbp - 0], rsi
sub rbp, 24
mov rsi, QWORD [rbp - -16]
mov rdi, QWORD [rbp - -24]
mov r15, L.tmp.3
jmp L.$3c$.2
L.__nested.4:
mov rax, 14
jmp r15
L.__nested.5:
mov rax, 6
jmp r15
L.__nested.9:
mov r9, 14
jmp L.__join.8
L.__nested.10:
mov r9, 6
jmp L.__join.8
L.__join.8:
cmp r9, 6
jne L.__nested.6
jmp L.__nested.7
L.__nested.6:
cmp r14, r13
jl L.__nested.4
jmp L.__nested.5
L.__nested.7:
mov rax, 1854
jmp r15
L.__nested.14:
mov r9, 14
jmp L.__join.13
L.__nested.15:
mov r9, 6
jmp L.__join.13
L.__join.13:
cmp r9, 6
jne L.__nested.11
jmp L.__nested.12
L.__nested.11:
mov r9, r14
and r9, 7
cmp r9, 0
je L.__nested.9
jmp L.__nested.10
L.__nested.12:
mov rax, 2110
jmp r15
L.tmp.3:
add rbp, 24
mov r15, rax
cmp r15, 6
jne L.__nested.16
jmp L.__nested.17
L.__nested.16:
mov rax, QWORD [rbp - 8]
mov r10, QWORD [rbp - 16]
jmp r10
L.__nested.17:
mov rsi, QWORD [rbp - 8]
mov rdi, QWORD [rbp - 0]
mov r15, QWORD [rbp - 16]
jmp L.swap.1
```

## Notes

This project was built for CPSC411 course at the University of British Columbia

Team members:  
Randy Russell  
Mary Cheung  
Anthony Baek
