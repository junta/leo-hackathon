import token.aleo;
program blind_staking.aleo;

record Deposit:
    owner as address.private;
    round as u8.private;
    user as address.private;
    amount as u64.private;
    is_winner as boolean.private;

mapping round_end_block:
    key as u8.public;
    value as u64.public;

mapping total_deposits:
    key as u8.public;
    value as u64.public;

mapping num_deposits:
    key as u8.public;
    value as u64.public;

mapping current_winner:
    key as u8.public;
    value as field.public;

function set_next_round:
    input r0 as u8.private;
    assert.eq self.caller aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg;
    async set_next_round r0 into r1;
    output r1 as blind_staking.aleo/set_next_round.future;

finalize set_next_round:
    input r0 as u8.public;
    get.or_use round_end_block[r0] 0u64 into r1;
    add r0 1u8 into r2;
    add r1 120960u64 into r3;
    set r3 into round_end_block[r2];

function deposit:
    input r0 as u8.private;
    input r1 as u64.private;
    hash.bhp256 self.caller into r2 as field;
    call token.aleo/transfer_public aleo104ur4csap6qp3fguddw3mn7f6ddpfkn4clqzzkyjhxmw5j46xsrse6vt5f r1 into r3;
    cast aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg 0u8 self.caller r1 false into r4 as Deposit.record;
    async deposit r3 r2 r1 r0 into r5;
    output r4 as Deposit.record;
    output r5 as blind_staking.aleo/deposit.future;

finalize deposit:
    input r0 as token.aleo/transfer_public.future;
    input r1 as field.public;
    input r2 as u64.public;
    input r3 as u8.public;
    get round_end_block[r3] into r4;
    cast r3 into r5 as u64;
    lt r5 r4 into r6;
    assert.eq r6 true;
    sub r3 1u8 into r7;
    get round_end_block[r7] into r8;
    cast r3 into r9 as u64;
    gt r9 r8 into r10;
    assert.eq r10 true;
    await r0;
    get.or_use total_deposits[0u8] 0u64 into r11;
    add r11 r2 into r12;
    set r12 into total_deposits[0u8];
    get.or_use num_deposits[0u8] 0u64 into r13;
    add r13 1u64 into r14;
    set r14 into total_deposits[0u8];

function withdraw:
    input r0 as u8.private;
    input r1 as u64.private;
    call token.aleo/transfer_public self.caller r1 into r2;
    async withdraw r2 r0 into r3;
    output r3 as blind_staking.aleo/withdraw.future;

finalize withdraw:
    input r0 as token.aleo/transfer_public.future;
    input r1 as u8.public;
    get round_end_block[r1] into r2;
    cast block.height into r3 as u64;
    lt r2 r3 into r4;
    assert.eq r4 true;
    await r0;

function resolve:
    input r0 as Deposit.record;
    input r1 as Deposit.record;
    assert.eq self.caller aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg;
    gte r0.amount r1.amount into r2;
    not r2 into r3;
    ternary r2 r0.owner r1.owner into r4;
    ternary r2 r0.round r1.round into r5;
    ternary r2 r0.user r1.user into r6;
    ternary r2 r0.amount r1.amount into r7;
    ternary r2 r0.is_winner r1.is_winner into r8;
    cast r4 r5 r6 r7 r8 into r9 as Deposit.record;
    output r9 as Deposit.record;

function finishRound:
    input r0 as Deposit.record;
    assert.eq self.caller aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg;
    cast aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg r0.round r0.user r0.amount true into r1 as Deposit.record;
    output r1 as Deposit.record;

function claim_reward:
    input r0 as Deposit.record;
    assert.eq r0.is_winner true;
    call token.aleo/transfer_public self.caller r0.amount into r1;
    async claim_reward r1 into r2;
    output r2 as blind_staking.aleo/claim_reward.future;

finalize claim_reward:
    input r0 as token.aleo/transfer_public.future;
    await r0;
