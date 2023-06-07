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

VirtualLaunchpad: [https://testnet.bscscan.com/address/0xf326128955b64b06548d7e31ee249d917c0add4f#code]
VirtualLock: [https://testnet.bscscan.com/address/0x7df918618486267630a9cf8d2958e4aa94a77154#code]
LauchpadFactory: [https://testnet.bscscan.com/address/0x638384f891f2cc082aef99f4924d805541b4c60b#code]



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


## addWhiteListUsers(address[] memory _users):
### parameters:
    1. Array of addresses, which are going to be whilelist users.
### Description:
    1. This function will be called by whitelist users to add other whitelist users.
    2. Just to remind that, after adding any user into whitelist users, they will be capable to user owner's powers.

## removeWhiteListUsers(address[] memory _user):
### parameters:
    1. Array of addresses, which are going to be removed from whitelistusers.
### Description:
    1. This function removes the specified users from the whitelist.

## listOfWhiteListUsers():
### Description:
    1. This function returns the list of whitelist users in form of array o addresses.


## check():
### Description:
    1. This function checks that pair is created or not for the given tokens. i.e. ico tokens and fee token / BNB.
    2. This check is mendatory because if pair is already created, then we will not create launchpad for that tokens.

## getWhiteListBuyersCount():
### Description:
    1. this function will return total number of whitelis buyers.

## getAllWhiteListBuyers():
### Description:
    1. this function will return all whitelisted buyers addresses.

## cancelLaunchpad():
### Description:
    1. by calling this function launchpad will be cancelled.
    2. only whitelistusers (owner) is capable to do this.

## setClaimTime():
### Parameters:
    1. uint256 _listingTime: The time after which all the users will be able to withdraw their ico tokens.
    2. initially this time will be set at finalized time. But owner can change this later.

## setWhiteListPool: 
### Parameters: 
    1. uint256 _wlPool: 1 for whitelist and 0 for public.
### Description:
    1. Only owner is authorized.
    2. by using this function owner can set status of the lauchpad, either it will be whitelist or public.
    3. if set to whitelist, then only whitelist buyers can purchase ico token and if set to public anyone can come and purchase ico tokens.

## editLaunchpad(LaunchpadStructs.SocialLinks memory socialLinks):
### Parameters:
    1. structure which holds the social links record.
### Description:
    1. This function will be used to edit the launchpad.
    2. No other information will be changed after creation of the launchpad except social links.


## finalizeLaunchpad():
### Description:
    1. set state to 2. i.e. launchpad is finalized.
    2. calculate raisedFee.this will be calculated from raisedFeePercent. 
        Formula: totalRaisedFee = raisedAmount * raisedFeePercent / ZOOM. 
        (Divided by zoom becuase every percentage is passed after multiplied by 100 to avoid from divide be zero).
    3. if remains ico tokens after each calculation, then check if pool type is burn, burn the reamaining ico tokens else refund the reamining tokens.
    4. i. in case of BNB, transfer collected fee to fund address
        ii. in case of Fee token, transfer collected tokens as fee to the fund address
    5. in case of auto listing, following operations will be performed.
        i. approve icoTokensAddtoLP amount to router address.
        ii. add liquidity on the specified DEX.
        iii. if there is provided lpLockTime, then lock the LP tokens for specified time.

### Restrictions:
    1. current time should be greater than startTime.
    2. if this function is going to be called before end time, then raisedAmount should be reached to hardcap. Becuase there are two scenarios in which owner can finalize. i. when hardcap meet. ii. when end time has passed.
    3. if end time passed, then raised amount should be greater than softcap.

## claimCanceledTokens():
### Description:
    1. in case of cancellation of launchpad, transfer all the ico tokens from contract address to the caller.
    2. only whitelist user can call this method.

## emergencyWithdrawPool():
### Description:
    1. super account can withdraw any token or BNB from the contract at any time.
    2. Although this is wrong, but to avoid blocking of assets, this function is implemented.
    3. owner of launchpad will call the super account to perform this action.

## withdrawContribute():
### Description:
    1. This function will be called by the contributers after:
        i. launchpad cancelled. i.e. state = 3
        OR
        ii. raisedAmount didn't meet softCap and endTime has passed.
    2. update state data accordingly. i.e. rasied amount decreased by this user amount, totalSoldAmount also decreased by this amount and this user must be removed from the list of joined users. 
    3. transfer user contribution back to him, in both cases i.e. BNB / Fee Token.
### Restrictions:
    1. check that user already hasnot withdrawn his contribution.
    2. user must have some contribution to withdraw.


## emergencyWithDrawContribute():
### Description:
    1. penalty fee will be deducted from the contributer.
    2. state data must be set accordingly.
    3. transfer penalty fee to the fund address and remaining to caller in both cases. i.e. BNB / fee Tokens.
### Restrictions:
    1. call time should be greater than startTime and must be less than end time.
    2. user must have his contribution to withdraw
    3. user totalInvestment must exist.
    4. launchpad must be in running state.


## claimTokens():
### Description:
    1. calculate user's total claimable tokens.
    2. user claimable tokens must be greater than 0.
    3. update state data accordingly.
    4. transfer caller his claimable tokens.
### Restrictions:
    1. caller must not has claimed all the tokens.
    2. launchpad should be finalized.
    

## getUserClaimable(address _sender):
### Description:
    1. returns all the claimable tokens of specified address.

## getLaunchpadInfo():
### Description:
    1. this will return all the information of launchpad.

## getOwnerZoneInfo():
### Description:
    1. this will return all the information regarding to the owner of launchpad.

## getJoinedUsers():
### Description:
    1. this will return all the joined users addresses.