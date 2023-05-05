# Powers Description

## SuperAccount: 
### (Super Account has all the rights of whiteList users)
1. Can set Fund address(address which will receive all types of fee) for any launchpad. [setFundAddress()] function will be called.
2. Can set penalty Fee in case of emergency withdraw or cancel the launchpad for any launchpad. [setPenaltyFee()] function will be called.
3. Can change DEX related information such as Factory or Router address for any launchpad. [setDex()] function will be called.
4. Can withdraw any token or BNB from the launchpad contract address any time. [emergencyWithdrawPool()] function will be called.

## WhiteListUsers: 
### (superAccount, launchpadOwner, the address which will be added by the whitelist users)
1. White list users have all the rights of launchpad owner. (super account is also added into the whitelist users at launchpad creations time)
2. 