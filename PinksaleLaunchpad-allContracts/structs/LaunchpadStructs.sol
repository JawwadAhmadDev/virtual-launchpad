// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

library LaunchpadStructs {
    struct LaunchpadInfo {
        address icoToken; // token address for which presale is created
        address feeToken; // against which token presale is created
        uint256 softCap; // min amount this project wants to collect
        uint256 hardCap; // max amount this project wants to collect
        uint256 presaleRate; // how much ico tokens equal to 1 feeToken
        uint256 minInvest; // minimum limit of a user investment
        uint256 maxInvest; // maximum limit of a user against all the investments
        uint256 startTime; // from which time launchpad will start 
        uint256 endTime; //  at which time launchpad will end
        uint256 whitelistPool; //0 public, 1 whitelist, 2 public anti bot 
                    // Anti-Bot System: With this option you can control who can contribute to the pool. 
                    // Only Users who hold a minimum amount of token you suggest would be able to contribute
        uint256 poolType; //0 burn, 1 refund
    }

    struct ClaimInfo {
        uint256 cliffVesting; //First gap release after listing (minutes)
        uint256 lockAfterCliffVesting; //second gap release after cliff (minutes)
        uint256 firstReleasePercent; // percent of tokens to be released after cliffVesting.
        uint256 vestingPeriodEachCycle; // time of each cycle after first release
        uint256 tokenReleaseEachCycle; // percentage of tokens to be released on completion of each cycle.
    }


    struct DexInfo {
        bool manualListing; // true -> manualListing(after end of launchpad owner can claim all the collected amount and can manually list on any dex)
                            // false -> autoListing (after end of launchpad liquidity will be added automatically at the time of finalizing the launchpad.)
        address routerAddress; // router address of DEX in case of auto listing
        address factoryAddress; // factory address in case of auto listing
        uint256 listingPrice; // how much tokens will be added for liquidity against one feeToken in case of auto listing
        uint256 listingPercent;// 1=> 10000 (how much percentage of raised feeTokens will be added for liquidity in case of auto listing)
        uint256 lpLockTime; // how much time liquidity will be locked. time will be taken in the form of days.
    }


    struct LaunchpadReturnInfo {
        uint256 softCap; 
        uint256 hardCap;
        uint256 startTime;
        uint256 endTime;
        uint256 state; // state of Launchpad. whether it is actived / finalized / cancelled (1 / 2 / 3 respectively)
        uint256 raisedAmount; // total amount raised yet.
        uint256 balance; // how much tokens are in the account of launchpad smart contract
        address feeToken; 
        uint256 listingTime; // time on which user can claim tokens or time on which liquidity is added.
        uint256 whitelistPool; // status of pool. whether it is public / whitelisted / public anti bot (0 public, 1 whitelist, 2 public anti bot)
        address holdingToken; // this will be used in case of anti bot mechanism
        uint256 holdingTokenAmount; // this address will also be used in anti-bot mechanism.
                                // for further detail of anti-bot mechanism see the comments of launchpadInfo structure.
    }

    struct OwnerZoneInfo { // this structure is designed to show owner's informations
        bool isOwner; // caller is owner or not
        uint256 whitelistPool; // whether pool is public / whitelisted / anti-bot (0 / 1 / 2 respectively)
        bool canFinalize; // owner can finalized the launchpad or not at this stage.
        bool canCancel; // owner can cancel the launchpad at this stage or not.
                        // NOTE: for further details see getOwnerZoneInfo() function implemented in Launchpad contract
    }

    struct FeeSystem {
        uint256 initFee; // initial fee to create a launchpad. this fee will be transferred to the owner's account at each launchpad creation.
        uint256 raisedFeePercent; // how much percent of collected BNB will be transferred to to the fee collector A/C at the time of finalizing launchpad.
        uint256 raisedTokenFeePercent; // how much percent of collected feeToken will be transferred to the fee collector address at the time of finalizing launchpad.
        uint256 penaltyFee; // how much fee will be dedected on emergency withdrawl in case of both scenarios i.e. BNB / feeToken
    }

    struct SettingAccount {
        address deployer;
        address signer;
        address superAccount; //BNB With Raised Amount
        address payable fundAddress; // address which will receive all kind of collected BNB or tokens.
        address gsLock; // contract address implementing lock mechanism
    }

    struct TeamVestingInfo {
        uint256 teamTotalVestingTokens;
        uint256 teamCliffVesting; //First token release after listing (minutes)
        uint256 teamFirstReleasePercent;
        uint256 teamVestingPeriodEachCycle;
        uint256 teamTokenReleaseEachCycle;
    }

    struct CalculateTokenInput {
        address feeToken; // against which token presale is created. i.e. against BNB or BUSD or any other ERC20 token.
        uint256 presaleRate; // how much icotokens will be equal to 1 fee Token. i.e. 1 BNB = 100 BL Tokens
        uint256 hardCap; // maximum how much BNB or Fee tokens we want from presale.
        uint256 raisedTokenFeePercent; // in case of feetoken is BUSD or any other ERC20token, how much fee will be deducted from raised BUSD or other ERC20Token 
        uint256 raisedFeePercent; // in case of feeToken is BNB, how much percent will be deducted from raised BNBs and will be transfered to the system. 
        uint256 listingPercent; // in case of autolisting, how much liquidity of raised BNB or Fee tokens will be added.
        uint256 listingPrice; // how much ico tokens will be equal to 1 fee token at the time of liqudity. 
                              // in other words, how much liquidity of icoTokens will be added against 1 feeToken. i.e. 1 BNB = 50 Bl Tokens

    }
}



