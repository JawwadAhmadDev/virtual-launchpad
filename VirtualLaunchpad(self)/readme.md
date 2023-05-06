# Contract Deployed Addresses:
### VirtualLaunchpad: [https://testnet.bscscan.com/address/0x8ca4086d0fc4d232f959307f723b4206a200c3e3#code]
### VirtualLock: [https://testnet.bscscan.com/address/0xaa388675726517982b36883f55d2fde1b270862f#code]
### LauchpadFactory: [https://testnet.bscscan.com/address/0xbc986976aabe94c3ab192196a8e8a7e94e11ac12#code]


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
2. Can add any other address to whitelist users. [addWhiteListUsers()] functions will be called.
3. Can remove any address from whitelist users. [removeWhiteListUsers()] functions will be called.
4. Can set whitelist buyers. White list buyers are those who can buy in whitelist mode of launchpad. At that time, no public can transact.[setWhiteListBuyers()] functions will be called.
5. Can remove any address from whitelist buyers. [removeWhiteListBuyers()] functions will be called.
6. Can cancel launchpad at any time. [cancelLaunchpad()] functions will be called.
7. Can set claim time after completion of launchpad. [setClaimTime()] functions will be called.
8. Can finalize launchpad after completion of launchpad. [finalizeLaunchpad()] functions will be called.
9. Can claim cancelled tokens after cancellation of launchpad. [claimCancelledTokens()] functions will be called.
10. Can pause functionality of launchpad at any time. [pause()] functions will be called.
11. Can resume functionality of launchpad at any time. [unPause()] functions will be called.


## Whitelist Buyers:
### These are the accounts which can transact when public access will be denied.
1. They can purchase tokens when whitelist option will be on.


## Launchpad State Value: (at any time)
There are three states of a launchpad.
1. Running | available: state == 1;
2. Finalized: state == 2;
3. Cancelled: state == 3;
#### Note:
1. At creation time state will be set to 1.
2. When cancel launchpad function will be called state will be set to 3.
3. When finalize launchpad function will be called state will be set to 2 and after that no one will be able to take part in the launchpad.



## Penalty Fee:
By default the penalty fee is 10% set in each launchpad.
###: Note: In case of user willing to emergency withdraw his contribution before finalization of launchpad, the penalty fee will be deducted from his contribution and remains amount will be transferred back to the user.

