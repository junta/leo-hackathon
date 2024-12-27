import token.aleo;

program blind_staking.aleo {
    const program_address: address = aleo104ur4csap6qp3fguddw3mn7f6ddpfkn4clqzzkyjhxmw5j46xsrse6vt5f;
    const owner_address: address = aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg;

    // suppose 5 seconds per block
    const blocks_per_week: u64 = 120960u64;

    // round # -> end of block number
    mapping round_end_block: u8 => u64;

    // round -> deposit amount
    mapping total_deposits: u8 => u64;

    // round -> a number of deposit
    mapping num_deposits: u8 => u64;

    // round -> winner hash address
    mapping current_winner: u8 => field;

    record Deposit {
        owner: address,
        round: u8,
        user: address,
        amount: u64,
        is_winner: bool
    }

    async transition set_next_round (previous_round: u8) -> Future {
        assert_eq(self.caller, owner_address);
        return set_round_block(previous_round);
    }

    async function set_round_block(previous_round: u8) {
        let previous_round_end_block: u64 = Mapping::get_or_use(round_end_block, previous_round, 0u64);
        Mapping::set(round_end_block, previous_round + 1u8, previous_round_end_block + blocks_per_week);
    }

    async transition deposit(round: u8, amount: u64) -> (Deposit, Future) {
        let hash: field = BHP256::hash_to_field(self.caller);

        let transfer: Future = token.aleo/transfer_public(program_address, amount);

        let user_deposit: Deposit = Deposit {
            round: 0u8,
            owner: owner_address,
            user: self.caller,
            amount: amount,
            is_winner: false
        };

        return (user_deposit, finalize_deposit(transfer, hash, amount, round));
    }

    async function finalize_deposit(public transfer: Future, hash: field, amount: u64, round: u8) {
        let current_round_end_block: u64 = Mapping::get(round_end_block, round);
        assert(round as u64 < current_round_end_block);

        let previous_round_end_block: u64 = Mapping::get(round_end_block, round - 1u8);
        assert(round as u64 > previous_round_end_block);

        transfer.await();
        let current_round: u8 = 0u8;
        let existing_amount: u64 = Mapping::get_or_use(total_deposits, current_round, 0u64);

        Mapping::set(total_deposits, current_round, existing_amount + amount);    

        let current_num_deposits: u64 = Mapping::get_or_use(num_deposits, current_round, 0u64);
        Mapping::set(total_deposits, current_round, current_num_deposits + 1u64);    
    }

    async transition withdraw(round: u8, amount: u64) -> Future {
        let transfer: Future = token.aleo/transfer_public(self.caller, amount);

        return finalize_withdraw(transfer, round);
    }

    async function finalize_withdraw(public transfer: Future, round: u8) {
        // check the round is ended.
        let fetched_round_end_block: u64 = Mapping::get(round_end_block, round);
        assert(fetched_round_end_block < block.height as u64);
        transfer.await();     
    }

    transition resolve(first: Deposit, second: Deposit) -> Deposit {
        // Ensure the caller is the owner.
        assert_eq(self.caller, owner_address);
        // Resolve the winner of the round.
        if (first.amount >= second.amount) {
            return first;
        } else {
            return second;
        }
    }

    transition finishRound(winner_deposit: Deposit) -> Deposit {
        assert_eq(self.caller, owner_address);
        return Deposit {
            owner: owner_address,
            round: winner_deposit.round,
            user: winner_deposit.user,
            amount: winner_deposit.amount,
            is_winner: true
        };
    }

    async transition claim_reward(winner_deposit: Deposit) -> Future {
        assert_eq(winner_deposit.is_winner, true);
        let f0: Future = token.aleo/transfer_public(self.caller, winner_deposit.amount);

        return finalize_claim_reward(f0);
    }

    async function finalize_claim_reward(f0: Future) {
        f0.await();    
    }
}

