import token.aleo;
program blind_staking.aleo;

record Deposit:
    owner as address.private;
    round as u8.private;
    user as address.private;
    amount as u64.private;

mapping total_deposits:
    key as u8.public;
    value as u64.public;

mapping num_deposits:
    key as u8.public;
    value as u64.public;

mapping current_winner:
    key as u8.public;
    value as field.public;

function deposit:
    input r0 as u64.private;
    hash.bhp256 self.caller into r1 as field;
    cast aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg 0u8 self.caller r0 into r2 as Deposit.record;
    output r2 as Deposit.record;

function settle_deposit:
    input r0 as Deposit.record;
    hash.bhp256 self.caller into r1 as field;
    async settle_deposit r1 r0.amount into r2;
    output r2 as blind_staking.aleo/settle_deposit.future;

finalize settle_deposit:
    input r0 as field.public;
    input r1 as u64.public;
    get.or_use total_deposits[0u8] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into total_deposits[0u8];
    get.or_use num_deposits[0u8] 0u64 into r4;
    add r4 1u64 into r5;
    set r5 into total_deposits[0u8];

function get_total_deposits:
    input r0 as u8.private;
    async get_total_deposits r0 into r1;
    output r1 as blind_staking.aleo/get_total_deposits.future;

finalize get_total_deposits:
    input r0 as u8.public;
    get total_deposits[r0] into r1;
