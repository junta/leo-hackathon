program auction.aleo;

mapping deposits:
    key as field.public;
    value as u64.public;

mapping reward_pool:
    key as u64.public;
    value as u64.public;

function deposit:
    input r0 as u64.private;
    hash.bhp256 self.caller into r1 as field;
    async deposit r1 r0 into r2;
    output r2 as auction.aleo/deposit.future;

finalize deposit:
    input r0 as field.public;
    input r1 as u64.public;
    get.or_use deposits[r0] 0u64 into r2;
    add r2 r1 into r3;
    set r3 into deposits[r0];
