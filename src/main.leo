import token.aleo;

program blind_staking.aleo {
    // round -> deposit amount
    mapping total_deposits: u8 => u64;

    mapping num_deposits: u8 => u64;

    // round -> winner hash address
    mapping current_winner: u8 => field;

    record Deposit {
        owner: address,
        round: u8,
        user: address,
        amount: u64,
    }

    // Constructor to initialize the owner
    // transition setup(public initial_reward: u64) {
    //     assert_eq(self.caller, aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg);
        
    //     reward_pool.set(initial_reward); // Initialize reward pool
    // }

    // Function to deposit tokens into the contract
    transition deposit(amount: u64) -> Deposit {
        // let lock_period: u64 = block.height) + 168u64; // Lock for 1 week (1 round)
        // let height: u32 = block.height; // Lock for 1 week (1 round)
        // let lock_period: u32 = height + 168u32;

        let hash: field = BHP256::hash_to_field(self.caller);

        return Deposit {
            round: 0u8,
            owner: aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg,
            user: self.caller,
            amount: amount
        };
    }

    async transition settle_deposit(settle_depost: Deposit) -> Future {
        let hash: field = BHP256::hash_to_field(self.caller);

        return finalize_deposit(hash, settle_depost.amount);
    }

    async function finalize_deposit(hash: field, amount: u64) {
        let current_round: u8 = 0u8;
        let existing_amount: u64 = Mapping::get_or_use(total_deposits, current_round, 0u64);
        Mapping::set(total_deposits, current_round, existing_amount + amount);    

        let current_num_deposits: u64 = Mapping::get_or_use(num_deposits, current_round, 0u64);
        Mapping::set(total_deposits, current_round, current_num_deposits + 1u64);    
    }

    async transition get_total_deposits(round: u8) -> Future {
       return get_total_deposits_from_chain(round);
    }

    async function get_total_deposits_from_chain(round: u8) {
        Mapping::get(total_deposits, round);
    }

    // // Function to withdraw deposit (only after lock period)
    // transition withdraw() {
    //     let current_round = aleo::block_height();
    //     let user_lock_end = mapping::get(lock_end, aleo::program_caller());

    //     // Ensure the lock period has ended
    //     assert(user_lock_end != 0u64 && current_round > user_lock_end, "Lock period has not ended");

    //     // Retrieve and reset the user's deposit
    //     let user_deposit = mapping::get_or_use(deposits, aleo::program_caller(), 0u64);
    //     assert(user_deposit > 0u64, "No deposit to withdraw");
    //     mapping::set(deposits, aleo::program_caller(), 0u64);

    //     // Transfer the deposit back to the user
    //     aleo::transfer(aleo::program_caller(), user_deposit);

    //     // Emit withdrawal event
    //     console.log("Withdrawal successful:", user_deposit);
    // }

    // // Function to claim reward (only the winner can claim reward tokens)
    // transition claim_reward() {
    //     let current_round = aleo::block_height();
    //     let highest_depositor: address = address.none();
    //     let highest_deposit: u64 = 0u64;

    //     // Iterate over all deposits to find the highest depositor
    //     for (user: address, deposit: u64) in mapping::entries(deposits) {
    //         if deposit > highest_deposit {
    //             highest_depositor = user;
    //             highest_deposit = deposit;
    //         }
    //     }

    //     // Ensure the caller is the highest depositor
    //     assert(aleo::program_caller() == highest_depositor, "Only the winner can claim the reward");

    //     // Ensure the reward pool is sufficient
    //     let reward_amount = mapping::get_or_use(reward_pool, 0u64);
    //     assert(reward_amount > 0u64, "No reward available");

    //     // Transfer reward tokens to the winner
    //     mapping::set(reward_pool, 0u64); // Clear the reward pool
    //     aleo::transfer(aleo::program_caller(), reward_amount);

    //     // Emit reward claim event
    //     console.log("Reward claimed by:", aleo::program_caller(), "Amount:", reward_amount);
    // }
}




// program auction.aleo {
//     // A bid in an auction.
//     // - `owner`     : The address of the account that owns the record associated with this bid.
//     //                 This is separate from the address of the account that placed the bid.
//     // - `bidder`    : The address of the account that placed the bid.
//     // - `amount`    : The amount of the bid.
//     // - `is_winner` : Whether the bid is the winning bid.
//     record Bid {
//         owner: address,
//         bidder: address,
//         amount: u64,
//         is_winner: bool,
//     }

//     // Returns a new bid.
//     // - `bidder` : The address of the account that placed the bid.
//     // - `amount` : The amount of the bid.
//     // Requires that `bidder` matches the function caller.
//     // The owner of the record is set to the entity responsible for running the auction (auction runner).
//     // The address of the auction runner is aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg.
//     transition place_bid(bidder: address, amount: u64) -> Bid {
//         // Ensure the caller is the auction bidder.
//         assert_eq(self.caller, bidder);
//         // Return a new 'Bid' record for the auction bidder.
//         return Bid {
//             owner: aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg,
//             bidder: bidder,
//             amount: amount,
//             is_winner: false,
//         };
//     }

//     // Returns the winning bid.
//     // - `first`  : The first bid.
//     // - `second` : The second bid.
//     // Requires that the function caller is the auction runner.
//     // Assumes that the function is invoked only after the bidding period has ended.
//     // In the event of a tie, the first bid is selected.
//     transition resolve(first: Bid, second: Bid) -> Bid {
//         // Ensure the caller is the auctioneer.
//         assert_eq(self.caller, aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg);
//         // Resolve the winner of the auction.
//         if (first.amount >= second.amount) {
//             return first;
//         } else {
//             return second;
//         }
//     }

//     // Returns ownership of the bid to bidder.
//     // - `bid` : The winning bid.
//     // Requires that the function caller is the auction runner.
//     // Assumes that the function is invoked only after all bids have been resolved.
//     transition finish(bid: Bid) -> Bid {
//         // Ensure the caller is the auctioneer.
//         assert_eq(self.caller, aleo1ashyu96tjwe63u0gtnnv8z5lhapdu4l5pjsl2kha7fv7hvz2eqxs5dz0rg);
//         // Return 'is_winner' as 'true' in the winning 'Bid'.
//         return Bid {
//             owner: bid.bidder,
//             bidder: bid.bidder,
//             amount: bid.amount,
//             is_winner: true,
//         };
//     }
// }

