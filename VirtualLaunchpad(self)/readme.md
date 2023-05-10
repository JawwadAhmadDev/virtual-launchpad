# Contract Deployment Details:
## Note: Each percent value will be passed after multiplying with 100. for example, 100% will be passed as 100 * 100 = 10000
info: ["0x86BdF6871374B0Be8C4E57B519181036f79dEE57","0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee","2000000000000000000","4000000000000000000",1000,"1000000000000000000","2000000000000000000",1683263004,1684472604,0,0]
claimInfo: [1800,0,0,0,0]
teamVesting: [0,0,0,0,0]
dexInfo: [false,"0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3","0xB7926C0430Afb07AA7DEfDE6DA862aE0Bde767bc","100000000000000000000",50,1800]
feeInfo: [2,2,1]
SettingAccount: ["0xcb06C621e1DCf9D5BB67Af79BEa90Ac626e4Ff38","0xcb06C621e1DCf9D5BB67Af79BEa90Ac626e4Ff38","0xcb06C621e1DCf9D5BB67Af79BEa90Ac626e4Ff38","0xB764Af9108c982dBebeaA1306490a908768D20c4"]
SocialLinks: ["", "", "", "", "", "", "", "", "", ""]
maxLP: 50000000000000000000
    
Parameters for calculate tokens: ["0x0000000000000000000000000000000000000000", "100000000000000000000" , "4000000000000000000", 0, 500, 6000, "50000000000000000000"]
                                 [FeeToken,presaleRate,hardcap,feeTokenRaisedPercent,raisedFeePercent,ListingPercent,ListingRate]

VirtualLaunchpad: [https://testnet.bscscan.com/address/0x007e44dc895ce1df1d85ea62a3e3243d9e25c546#code]
VirtualLock: [https://testnet.bscscan.com/address/0xaa388675726517982b36883f55d2fde1b270862f#code]
LauchpadFactory: [https://testnet.bscscan.com/address/0x0ad26d5cc37964e6620e090e3293506cf848f41e#code]




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



## Contribute Function: (Called by clicking on BUY button)
### parameters: _amount
    1. How much amount user is willing to exchange with ico tokens.
    2. This amount will be sent in any case. either BNB or Fee Token.
### Restrictions:
    1. Time should be greater than start time and less than end time.
    2. Check if whitelist is on, then only whitelist buyers can contribute.
    3. Total investment of the caller should be greater than minimum investment limit and should be greater than maximum investment limit.
    4. After investing _amount, total Raised amount should be less than or equal to hardcap.
### Description:
    1. add _amount to the total investment of the caller.
    2. 


## calculateUserTotalTokens(uint256 _amount): 
### paramters: _amount
    1. The amount of BNB or BUSD user want to excange.
### Description:
    1. This function will take amount of BNB or BUSD user want to exchange with ico token and returns the amount of ico tokens user will receive accordingly.
    2. add amount to the totalRaisedAmount to track that how much amount collected by launchpad yet.
    3. if this is users first contribution, then add user to the joinded users.

