/******************************************************************************
 * Project  ELE8304 : Circuits intégrés à très grande échelle
 ******************************************************************************
 * File     riscv_basic.S
 * Author   Mickael Fiorentino  <mickael.fiorentino@polymtl.ca>
 * Lab      GRM - Polytechnique Montreal
 * Date     <2019-12-02 Mon>
 ******************************************************************************
 * Brief    Programme de test simple pour le mini-riscv
 ******************************************************************************/
#define BRANCH_SUCCESS  -1
#define BRANCH_FAILURE   1
#define TMP 0xFFF

/******************************************************************************
 * Début
 ******************************************************************************/
.global start
start:
    and s1, zero, zero                 // x9 = 0

/******************************************************************************
 * Opérations arithmétiques et logiques sans dépendances de données
 ******************************************************************************/
arith:
    lui   t0, 0xFFFFF                 // x5  = 0xFFFFF000
    ori   t1, zero, 0x7FF             // x6  = 0x000007FF
    addi  t2, zero, -1                // x7  = 0xFFFFFFFF
    xori  t3, zero, 2                 // x28 = 0x00000002
    andi  t4, t1, 1                   // x29 = 0x00000001

    slli  a0, t1, 4                   // x10 = 0x00007FF0
    srli  a1, t0, 4                   // x11 = 0x0FFFFF00
    srai  a2, t0, 4                   // x12 = 0xFFFFFF00

    sll  t4, t0, t3                   // x29 = 0xFFFFC000
    srl  t5, t0, t3                   // x30 = 0x3FFFFC00
    sra  t6, t0, t3                   // x31 = 0xFFFFFC00

    xor   a0, a0, a1                  // x10 = 0x0FFF80F0
    and   a1, t1, t3                  // x11 = 0x00000002
    or    a2, t0, t3                  // x12 = 0xFFFFF002

    add   s2, t1, t0                  // x18 = 0xFFFFF7FF
    sub   s3, t1, t0                  // x19 = 0x000017FF

    sltu  s4, t1, t0                  // x20 = 0x00000001
    slt   s5, t0, t1                  // x21 = 0x00000001
    sltiu s4, t6, 1                   // x20 = 0x00000000
    slti  s5, t3, 1                   // x21 = 0x00000000

    nop
    nop
    nop
    nop

/******************************************************************************
 * Load / Store + dépendance de donnée dans le RF
 ******************************************************************************/
mem:
    la  sp, _STACK                    // x2  = 0x000007FC
    la  gp, _HEAP                     // x3  = 0x000003FC
    la  tp, _HEAP                     // x4  = 0x000003FC
    sw  a0, -4(sp)                    // DMEM[7F8] = 0x0FFF80F0
    lw  a1, -4(sp)                    // x11 = 0x0FFF80F0

    nop
    nop
    nop
    nop

/******************************************************************************
 * Branchements: x8 = BRANCH_SUCCESS si succès, BRANCH_FAILURE (ou 0) sinon
 ******************************************************************************/
branch:
    beq a0, a1, branch_ok
    li  s0, BRANCH_FAILURE
    jal zero, next

branch_ok:
    jal ra, success
    jal zero, next

success:
    li s0, BRANCH_SUCCESS
    jalr zero, ra, 0

next:
    nop
    nop
    nop
    nop

/******************************************************************************
 * Dépendances de données
 ******************************************************************************/
fwd:
    addi sp, sp, -8                 // x2  = 0x000007F4
    sw   sp, 0(sp)                  // DMEM[7F4] = 0x000007F4
    lw   a0, 0(sp)                  // x10 = 0x000007F4
    lw   a1, 0(a0)                  // x11 = 0x000007F4

    nop
    nop
    nop
    nop

/******************************************************************************
 * Instruction spécialisée
 ******************************************************************************/
spec:
    addi  t0, t0, 0x5D6
    eswp  t1, zero, 0xFFFFFBA2
    eswp  t2, t0, 0
    eswp  t3, t2, 0

    nop
    nop
    nop
    nop

/******************************************************************************
 * Fin
 ******************************************************************************/
end:
    beqz s1, end
