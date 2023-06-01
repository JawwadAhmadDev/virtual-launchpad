// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

library LaunchpadStructs {
    struct LaunchpadInfo {
        address icoToken; // token address for which presale is created
        address feeToken; // which token will be used for fee. i.e. BUSD, USDT or USDC
        uint256 softCap; // min amount this project wants to collect
        uint256 hardCap; // max amount this project wants to collect
        uint256 presaleRate; // how much ico tokens equal to 1 feeToken
        uint256 minInvest; // minimum limit of a user investment
        uint256 maxInvest; // maximum limit of a user against all the investments
        uint256 startTime; // from which time launchpad will start 
        uint256 endTime; //  at which time launchpad will end
        uint256 poolType; //0 burn, 1 refund
        address[] whiteListBuyers;
    }

    struct ClaimInfo {
        uint256 firstReleasePercent; // percent of tokens to be released first time.
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
        
        // social links
        string logoURL;
        string description;
        string websiteURL;
        string facebookURL;
        string twitterURL;
        string githubURL;
        string telegramURL;
        string instagramURL;
        string discordURL;
        string redditURL;

        address icoToken;
        uint256 firstReleasePercent;
        uint256 listingPercent;
        uint256 listingPrice;
        uint256 lpLockTime;
        uint256 maxInvest;
        uint256 minInvest;
        uint256 maxLiquidity;
        uint256 presaleRate;
        uint256 totalSoldTokens;
        bool manualListing;
    }

    struct OwnerZoneInfo { // this structure is designed to show owner's informations
        bool isOwner; // caller is owner or not
        uint256 whitelistPool; // whether pool is public / whitelisted / anti-bot (0 / 1 / 2 respectively)
        bool canFinalize; // owner can finalized the launchpad or not at this stage.
        bool canCancel; // owner can cancel the launchpad at this stage or not.
                        // NOTE: for further details see getOwnerZoneInfo() function implemented in Launchpad contract
    }

    struct FeeSystem {
        uint256 raisedFeePercent; // how much percent of collected BNB will be transferred to to the fee collector A/C at the time of finalizing launchpad.
        uint256 raisedTokenFeePercent; // how much percent of collected feeToken will be transferred to the fee collector address at the time of finalizing launchpad.
    }

    struct SettingAccount {
        address deployer;
        address superAccount; // address that will be set by the launchpad owner and it will have power on all the launchpads.
        address payable fundAddress; // address which will receive all kind of collected BNB or tokens.
        address virtualLock; // contract address implementing lock mechanism
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


    struct SocialLinks {
        string logoURL;
        string description;
        string websiteURL;
        string facebookURL;
        string twitterURL;
        string githubURL;
        string telegramURL;
        string instagramURL;
        string discordURL;
        string redditURL;
    }
}



