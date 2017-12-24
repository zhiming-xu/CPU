```assembly
注：最后写相对地址没有确定的jmp类指令
#0 register: eax
#1 register: ebx
#2 register: ebp
#3 register: esp
#4 register: temp1
#5 register: temp2

080483db <fib>:
 80483db:	55                   	push   %ebp				10101_010_00000000
 80483dc:	89 e5                	mov    %esp,%ebp		01110_011_010_00000
 80483de:	53                   	push   %ebx				10101_001_00000000
 80483df:	83 ec 04             	sub    $0x4,%esp		00001_011_00000100
 #80483e2:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)	
 									load   %temp1,%ebp		10011_100_010_00000
 									adc	   0x8,%temp1		00000_100_00001000
 									xor	   %temp2,%temp2	01001_101_101_00000
 									cmp	   %temp1,%temp2	00101_100_101_00000
 #80483e6:	75 07                	jne    80483ef <fib+0x14> 
 									jrnz   +x				11011_xxx_xxx_xxxxx
 #80483e8:	b8 00 00 00 00       	mov    $0x0,%eax		
 									xor	   %eax,%eax		01001_000_000_00000
 80483ed:	eb 35                	jmp    8048424 <fib+0x49> 10111_xxx_xxx_xxxxx
 #80483ef:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
 									load   %temp1,%ebp		10011_100_010_00000
 									adc	   0x8,%temp1		00000_100_00001000
 									xor	   %temp2,%temp2	01001_101_101_00000
 									adc	   0x1,%temp2		00000_101_00000001
 									cmp	   %temp1,%temp2	00101_100_101_00000
 #80483f3:	75 07                	jne    80483fc <fib+0x21>
 									jrnz   +x				11011_xxx_xxx_xxxxx
 #80483f5:	b8 01 00 00 00       	mov    $0x1,%eax
 									movil  %eax,$0x1		01111_000_00000001
 									movih  %eax,$0x0		10000_000_00000000
 80483fa:	eb 28                	jmp    8048424 <fib+0x49> 10111_xxx_xxx_xxxxx
 #80483fc:	8b 45 08             	mov    0x8(%ebp),%eax
 									load   %temp1,%ebp		10011_100_010_00000
 									adc	   0x8,%temp1		00000_100_00001000
 									store  %temp1,%eax		10100_100_000_00000
 80483ff:	83 e8 01             	sub    $0x1,%eax		00001_000_00000001
 8048402:	83 ec 0c             	sub    $0xc,%esp		00001_011_00001100
 8048405:	50                   	push   %eax				10101_000_00000000
 #8048406:	e8 d0 ff ff ff       	call   80483db <fib>
 									push next_eip but how?
 									jr	   +x				10111_xxx_xxx_xxxxx
 804840b:	83 c4 10             	add    $0x10,%esp
 804840e:	89 c3                	mov    %eax,%ebx
 8048410:	8b 45 08             	mov    0x8(%ebp),%eax
 8048413:	83 e8 02             	sub    $0x2,%eax
 8048416:	83 ec 0c             	sub    $0xc,%esp
 8048419:	50                   	push   %eax
 804841a:	e8 bc ff ff ff       	call   80483db <fib>
 804841f:	83 c4 10             	add    $0x10,%esp
 8048422:	01 d8                	add    %ebx,%eax
 8048424:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 8048427:	c9                   	leave  
 8048428:	c3                   	ret    

08048429 <main>:
 #8048429:	8d 4c 24 04          	lea    0x4(%esp),%ecx
 #804842d:	83 e4 f0             	and    $0xfffffff0,%esp
 #8048430:	ff 71 fc             	pushl  -0x4(%ecx)
 #8048433:	55                   	push   %ebp
 #8048434:	89 e5                	mov    %esp,%ebp
 #8048436:	51                   	push   %ecx
 #8048437:	83 ec 14             	sub    $0x14,%esp
 #804843a:	83 ec 0c             	sub    $0xc,%esp
 804843d:	6a 05                	push   $0x5
 804843f:	e8 97 ff ff ff       	call   80483db <fib>
 8048444:	83 c4 10             	add    $0x10,%esp
 
 halt & see %eax
 #8048447:	89 45 f4             	mov    %eax,-0xc(%ebp)
 #804844a:	b8 00 00 00 00       	mov    $0x0,%eax
 #804844f:	8b 4d fc             	mov    -0x4(%ebp),%ecx
 #8048452:	c9                   	leave  
 #8048453:	8d 61 fc             	lea    -0x4(%ecx),%esp
 #8048456:	c3                   	ret    
```





##### REF

push

```c
rtl_push(&(id_dest->val));

cpu.esp -= 4;
vaddr_write(cpu.esp, 4, *src1);
```

pop

```c
rtl_pop(&id_src->val);
operand_write(id_dest, &id_src->val);

*dest = vaddr_read(cpu.esp, 4);
cpu.esp += 4;
```

call = jmp + push(eip+1)

```c
decoding.jmp_eip = *eip + id_dest->val;
decoding.is_jmp = 1;
rtl_push(&decoding.seq_eip);
```

leave = mov(esp <- ebp) + pop(ebp)

```c
cpu.esp = cpu.ebp;
rtl_pop(&cpu.ebp);
```

ret = pop() + jmp

```c
rtl_pop(&decoding.jmp_eip);
decoding.is_jmp = 1;
```

