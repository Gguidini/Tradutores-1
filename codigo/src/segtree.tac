___min:
mov $0, #0
mov $1, #1
mov $2, $0
mov $3, $1
slt $4, $2, $3
brz ___0, $4
mov $4, $0
return $4
___0:
___end0:
mov $4, $1
return $4
return 0
___max:
mov $0, #0
mov $1, #1
mov $2, $0
mov $3, $1
slt $4, $3, $2
brz ___1, $4
mov $4, $0
return $4
___1:
___end1:
mov $4, $1
return $4
return 0
___prop:
mov $0, #0
mov $1, #1
mov $2, #2
mov $3, #3
mov $4, #4
mov $5, #5
mov $6, #6
mov $7, $4
mov $8, $3[$7]
brz ___2, $8
mov $8, $4
mov $9, $4
mov $10, $3[$9]
mov $11, $6
mov $12, $5
sub $13, $11, $12
mov $12, 1
add $11, $13, $12
mul $12, $10, $11
mov $11, $0[$8]
add $11, $11, $12
mov $0[$8], $11
mov $11, $4
mov $12, $4
mov $10, $3[$12]
mov $13, $1[$11]
add $13, $13, $10
mov $1[$11], $13
mov $13, $4
mov $10, $4
mov $14, $3[$10]
mov $15, $2[$13]
add $15, $15, $14
mov $2[$13], $15
mov $15, $5
mov $14, $6
seq $16, $15, $14
bxor $16, $16, 1
brz ___3, $16
mov $16, 2
mov $14, $4
mul $15, $16, $14
mov $14, $4
mov $16, $3[$14]
mov $17, $3[$15]
add $17, $17, $16
mov $3[$15], $17
mov $17, 2
mov $16, $4
mul $18, $17, $16
mov $16, 1
add $17, $18, $16
mov $16, $4
mov $18, $3[$16]
mov $19, $3[$17]
add $19, $19, $18
mov $3[$17], $19
___3:
___end3:
mov $19, $4
mov $18, 0
mov $3[$19], $18
___2:
___end2:
return 0
___querysum:
mov $0, #0
mov $1, #1
mov $2, #2
mov $3, #3
mov $4, #4
mov $5, #5
mov $6, #6
mov $7, #7
mov $8, #8
mov $9, $0
mov $10, $1
mov $11, $2
mov $12, $3
mov $13, $4
mov $14, $5
mov $15, $6
param $9
param $10
param $11
param $12
param $13
param $14
param $15
call ___prop, 7
pop $15
mov $15, $5
mov $14, $7
sleq $13, $14, $15
mov $14, $6
mov $15, $8
sleq $12, $14, $15
and $15, $13, $12
brz ___4, $15
mov $15, $4
mov $12, $0[$15]
return $12
___4:
___end4:
mov $12, $7
mov $13, $6
sleq $14, $12, $13
mov $13, $8
mov $12, $5
sleq $11, $12, $13
and $12, $14, $11
brz ___5, $12
mov $11, $5
mov $14, $6
add $13, $11, $14
mov $14, 2
div $11, $13, $14
mov $12, $11
mov $11, $0
mov $14, $1
mov $13, $2
mov $10, $3
mov $9, 2
mov $16, $4
mul $17, $9, $16
mov $16, $5
mov $9, $12
mov $18, $7
mov $19, $8
param $11
param $14
param $13
param $10
param $17
param $16
param $9
param $18
param $19
call ___querysum, 9
pop $19
mov $18, $0
mov $9, $1
mov $16, $2
mov $17, $3
mov $10, 2
mov $13, $4
mul $14, $10, $13
mov $13, 1
add $10, $14, $13
mov $13, $12
mov $14, 1
add $11, $13, $14
mov $14, $6
mov $13, $7
mov $20, $8
param $18
param $9
param $16
param $17
param $10
param $11
param $14
param $13
param $20
call ___querysum, 9
pop $20
add $13, $19, $20
return $13
___5:
___end5:
return 0
___querymin:
mov $0, #0
mov $1, #1
mov $2, #2
mov $3, #3
mov $4, #4
mov $5, #5
mov $6, #6
mov $7, #7
mov $8, #8
mov $9, $0
mov $10, $1
mov $11, $2
mov $12, $3
mov $13, $4
mov $14, $5
mov $15, $6
param $9
param $10
param $11
param $12
param $13
param $14
param $15
call ___prop, 7
pop $15
mov $15, $5
mov $14, $7
sleq $13, $14, $15
mov $14, $6
mov $15, $8
sleq $12, $14, $15
and $15, $13, $12
brz ___6, $15
mov $15, $4
mov $12, $1[$15]
return $12
___6:
___end6:
mov $12, $7
mov $13, $6
sleq $14, $12, $13
mov $13, $8
mov $12, $5
sleq $11, $12, $13
and $12, $14, $11
brz ___7, $12
mov $11, $5
mov $14, $6
add $13, $11, $14
mov $14, 2
div $11, $13, $14
mov $12, $11
mov $11, $0
mov $14, $1
mov $13, $2
mov $10, $3
mov $9, 2
mov $16, $4
mul $17, $9, $16
mov $16, $5
mov $9, $12
mov $18, $7
mov $19, $8
param $11
param $14
param $13
param $10
param $17
param $16
param $9
param $18
param $19
call ___querymin, 9
pop $19
mov $18, $0
mov $9, $1
mov $16, $2
mov $17, $3
mov $10, 2
mov $13, $4
mul $14, $10, $13
mov $13, 1
add $10, $14, $13
mov $13, $12
mov $14, 1
add $11, $13, $14
mov $14, $6
mov $13, $7
mov $20, $8
param $18
param $9
param $16
param $17
param $10
param $11
param $14
param $13
param $20
call ___querymin, 9
pop $20
param $19
param $20
call ___min, 2
pop $20
return $20
___7:
___end7:
mov $20, 2147483647
return $20
return 0
___querymax:
mov $0, #0
mov $1, #1
mov $2, #2
mov $3, #3
mov $4, #4
mov $5, #5
mov $6, #6
mov $7, #7
mov $8, #8
mov $9, $0
mov $10, $1
mov $11, $2
mov $12, $3
mov $13, $4
mov $14, $5
mov $15, $6
param $9
param $10
param $11
param $12
param $13
param $14
param $15
call ___prop, 7
pop $15
mov $15, $5
mov $14, $7
sleq $13, $14, $15
mov $14, $6
mov $15, $8
sleq $12, $14, $15
and $15, $13, $12
brz ___8, $15
mov $15, $4
mov $12, $2[$15]
return $12
___8:
___end8:
mov $12, $7
mov $13, $6
sleq $14, $12, $13
mov $13, $8
mov $12, $5
sleq $11, $12, $13
and $12, $14, $11
brz ___9, $12
mov $11, $5
mov $14, $6
add $13, $11, $14
mov $14, 2
div $11, $13, $14
mov $12, $11
mov $11, $0
mov $14, $1
mov $13, $2
mov $10, $3
mov $9, 2
mov $16, $4
mul $17, $9, $16
mov $16, $5
mov $9, $12
mov $18, $7
mov $19, $8
param $11
param $14
param $13
param $10
param $17
param $16
param $9
param $18
param $19
call ___querymax, 9
pop $19
mov $18, $0
mov $9, $1
mov $16, $2
mov $17, $3
mov $10, 2
mov $13, $4
mul $14, $10, $13
mov $13, 1
add $10, $14, $13
mov $13, $12
mov $14, 1
add $11, $13, $14
mov $14, $6
mov $13, $7
mov $20, $8
param $18
param $9
param $16
param $17
param $10
param $11
param $14
param $13
param $20
call ___querymax, 9
pop $20
param $19
param $20
call ___max, 2
pop $20
return $20
___9:
___end9:
mov $20, 0
mov $19, 2147483648
sub $13, $20, $19
return $13
return 0
___upd:
mov $0, #0
mov $1, #1
mov $2, #2
mov $3, #3
mov $4, #4
mov $5, #5
mov $6, #6
mov $7, #7
mov $8, #8
mov $9, #9
mov $10, $0
mov $11, $1
mov $12, $2
mov $13, $3
mov $14, $4
mov $15, $5
mov $16, $6
param $10
param $11
param $12
param $13
param $14
param $15
param $16
call ___prop, 7
pop $16
mov $16, $7
mov $15, $6
slt $14, $15, $16
mov $15, $8
mov $16, $5
slt $13, $15, $16
or $16, $14, $13
brz ___10, $16
mov $16, 0
return $16
___10:
___end10:
mov $16, $5
mov $13, $7
sleq $14, $13, $16
mov $13, $6
mov $16, $8
sleq $15, $13, $16
and $16, $14, $15
brz ___11, $16
mov $16, $4
mov $15, $9
mov $3[$16], $15
mov $15, $0
mov $13, $1
mov $12, $2
mov $11, $3
mov $10, $4
mov $17, $5
mov $18, $6
param $15
param $13
param $12
param $11
param $10
param $17
param $18
call ___prop, 7
pop $18
mov $18, 1
return $18
___11:
___end11:
mov $17, $5
mov $10, $6
add $11, $17, $10
mov $10, 2
div $17, $11, $10
mov $18, $17
mov $17, $0
mov $10, $1
mov $11, $2
mov $12, $3
mov $13, 2
mov $15, $4
mul $19, $13, $15
mov $15, $5
mov $13, $18
mov $20, $7
mov $21, $8
mov $22, $9
param $17
param $10
param $11
param $12
param $19
param $15
param $13
param $20
param $21
param $22
call ___upd, 10
pop $22
mov $22, $0
mov $21, $1
mov $20, $2
mov $13, $3
mov $15, 2
mov $19, $4
mul $12, $15, $19
mov $19, 1
add $15, $12, $19
mov $19, $18
mov $12, 1
add $11, $19, $12
mov $12, $6
mov $19, $7
mov $10, $8
mov $17, $9
param $22
param $21
param $20
param $13
param $15
param $11
param $12
param $19
param $10
param $17
call ___upd, 10
pop $17
mov $17, $4
mov $10, 2
mov $19, $4
mul $12, $10, $19
mov $19, $0[$12]
mov $10, 2
mov $11, $4
mul $15, $10, $11
mov $11, 1
add $10, $15, $11
mov $11, $0[$10]
add $15, $19, $11
mov $0[$17], $15
mov $15, $4
mov $19, 2
mov $13, $4
mul $20, $19, $13
mov $13, $2[$20]
mov $19, 2
mov $21, $4
mul $22, $19, $21
mov $21, 1
add $19, $22, $21
mov $21, $2[$19]
param $13
param $21
call ___max, 2
pop $21
mov $2[$15], $21
mov $21, $4
mov $22, 2
mov $23, $4
mul $24, $22, $23
mov $23, $1[$24]
mov $22, 2
mov $25, $4
mul $26, $22, $25
mov $25, 1
add $22, $26, $25
mov $25, $1[$22]
param $23
param $25
call ___min, 2
pop $25
mov $1[$21], $25
return 0
main:
mema $0, 4000
mema $1, 4000
mema $2, 4000
mema $3, 4000
mov $4, $3
mov $5, $2
mov $6, $1
mov $7, $0
mov $8, 1
mov $9, 0
mov $10, 10
mov $11, 1
mov $12, 1
mov $13, 100
param $4
param $5
param $6
param $7
param $8
param $9
param $10
param $11
param $12
param $13
call ___upd, 10
pop $13
nop
