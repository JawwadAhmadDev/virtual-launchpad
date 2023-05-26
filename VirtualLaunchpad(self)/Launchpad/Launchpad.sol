// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

// import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
//import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "../structs/LaunchpadStructs.sol";
import "../interfaces/IVirtualLock.sol";
import "../interfaces/IVirtualERC20.sol";

contract Launchpad is Pausable {
    //using SafeMath for uint256;
    using SafeERC20 for IVirtualERC20;
    using EnumerableSet for EnumerableSet.AddressSet;

    EnumerableSet.AddressSet private whiteListUsers;
    EnumerableSet.AddressSet private superAccounts;
    EnumerableSet.AddressSet private whiteListBuyers;

    // mapping(address => bool) public whiteListUsers;
    // mapping(address => bool) public superAccounts;

    address public launchpadOwner;

    modifier onlyLaunchpadOwner() {
        require(msg.sender == launchpadOwner, "launchpad: Only owner");
        _;
    }

    modifier onlyWhiteListUser() {
        require(
            whiteListUsers.contains(msg.sender),
            "launchpad: Only whiteListUsers"
        );
        _;
    }

    modifier onlySuperAccount() {
        require(superAccounts.contains(msg.sender), "launchpad: Only Super");
        _;
    }

    modifier onlyRunningPool() {
        require(state == 1, "launchpad: Not available pool");
        _;
    }

    // function adminWhiteListUsers(address _user, bool _whiteList) public onlySuperAccount {
    //     whiteListUsers[_user] = _whiteList;
    // }

    function addWhiteListUsers(
        address[] memory _user
    ) public onlyWhiteListUser {
        for (uint i = 0; i < _user.length; i++) {
            whiteListUsers.add(_user[i]);
        }
    }

    function removeWhiteListUsers(
        address[] memory _user
    ) public onlyWhiteListUser {
        for (uint i = 0; i < _user.length; i++) {
            whiteListUsers.remove(_user[i]);
        }
    }

    function listOfWhiteListUsers() public view returns (address[] memory) {
        return whiteListUsers.values();
    }

    function _check(
        address _tokenA,
        address _tokenB,
        address _routerAddress,
        address _factoryAddress
    ) internal view returns (bool) {
        address pair;
        IUniswapV2Router02 routerObj = IUniswapV2Router02(_routerAddress);
        IUniswapV2Factory factoryObj = IUniswapV2Factory(_factoryAddress);

        if (_tokenB == address(0)) {
            pair = factoryObj.getPair(address(_tokenA), routerObj.WETH());
        } else {
            pair = factoryObj.getPair(address(_tokenA), address(_tokenB));
        }
        if (pair == address(0)) {
            return true;
        }
        return IVirtualERC20(pair).totalSupply() == 0;
    }

    // function to check that pair is created or not yet for the given token.
    function check() external view returns (bool) {
        return
            _check(address(icoToken), feeToken, routerAddress, factoryAddress);
    }

    IVirtualERC20 public icoToken;
    address public feeToken; //BUSD, BNB
    uint256 public softCap;
    uint256 public hardCap;
    uint256 public presaleRate; // 1BNB or BUSD ~ presaleRate
    uint256 public minInvest;
    uint256 public maxInvest;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public poolType; //0 burn, 1 refund
    uint256 public whitelistPool; //0 public, 1 whitelist, 2 public anti bot
    // address public holdingToken;
    // uint256 public holdingTokenAmount;

    // contribute vesting
    // uint256 public cliffVesting; //First gap release after listing (minutes)
    // uint256 public lockAfterCliffVesting; //second gap release after cliff (minutes)
    uint256 public firstReleasePercent; // 0 is not vesting // initially 10000 will be stored
    uint256 public vestingPeriodEachCycle; //0 is not vesting
    uint256 public tokenReleaseEachCycle; //percent: 0 is not vesting

    //team vesting
    // uint256 public teamTotalVestingTokens; // if > 0, lock
    // uint256 public teamCliffVesting; //First gap release after listing (minutes)
    // uint256 public teamFirstReleasePercent; // 0 is not vesting
    // uint256 public teamVestingPeriodEachCycle; // 0 is not vesting
    // uint256 public teamTokenReleaseEachCycle; //percent: 0 is not vesting

    uint256 public listingTime; // Time at which funds will be / have listed to the DEX.

    uint256 public state; // 1 running||available, 2 finalize, 3 cancel
    uint256 public raisedAmount; // total Fee Tokens or BNBs launchpad collected yet.
    // address public signer;
    uint256 public constant ZOOM = 10_000;
    uint256 public penaltyFee = 1000; // 10%

    // dex
    bool public manualListing;
    address public factoryAddress;
    address public routerAddress;
    uint256 public listingPrice;
    uint256 public listingPercent; //1 => 10000
    uint256 public lpLockTime; //seconds

    // social information
    string public logoURL;
    string public description;
    string public websiteURL;
    string public facebookURL;
    string public twitterURL;
    string public githubURL;
    string public telegramURL;
    string public instagramURL;
    string public discordURL;
    string public redditURL;

    // lock
    IVirtualLock public virtualLock;
    uint256 public lpLockId;
    uint256 public teamLockId;

    // fee
    uint256 public raisedFeePercent; //BNB With Raised Amount
    uint256 public raisedTokenFeePercent;

    // raised
    address payable public fundAddress;
    uint256 public totalSoldTokens; // how much tokens of ICO tokens sold yet.

    address public deadAddress;
    uint256 public maxLiquidity = 0;

    // structure to hold the investment details of a specific user.
    struct JoinInfo {
        uint256 totalInvestment; // total amount of BNB or Fee token against which launchpad is created, user invested.
        uint256 claimedTokens;
        uint256 totalTokens;
        bool refund; // user has claimed his tokens or not. in both cases, emergencywithdraw or withdrawContribute.
    }

    mapping(address => JoinInfo) public joinInfos; // mapping to store join information against specific user
    EnumerableSet.AddressSet private _joinedUsers; // set of joined users. Which which users has contributions in this launchpad yet.

    event Invest(address investor, uint value, uint tokens);
    event Buy(
        uint256 indexed _saleId,
        uint256 indexed _quantity,
        uint256 indexed _price,
        address _buyer,
        address _seller
    );
    event UpdateSaleQuantity(
        uint256 indexed _saleId,
        address indexed _seller,
        uint256 indexed _quantity,
        uint256 _status
    );
    event UpdateSalePrice(
        uint256 indexed _saleId,
        address indexed _seller,
        uint256 indexed _price
    );
    event CancelListed(uint256 indexed _saleId, address indexed _receiver);
    event List(
        uint indexed _saleId,
        uint256 indexed _price,
        uint256 indexed _quantity,
        address _owner,
        uint256 _tokenId,
        uint256 status
    );
    event TokenClaimed(address _address, uint256 tokensClaimed);

    function setFundAddress(
        address payable _fundAddress
    ) public onlySuperAccount {
        fundAddress = _fundAddress;
    }

    // function setSigner(address _signer) public onlySuperAccount {
    //     signer = _signer;
    // }

    // super account is capable to change penalty fee for any launchpad.
    function setPenaltyFeePercent(uint256 _penaltyFee) public onlySuperAccount {
        penaltyFee = _penaltyFee * 100;
    }

    function setDex(address _factory, address _router) public onlySuperAccount {
        factoryAddress = _factory;
        routerAddress = _router;
    }

    constructor(
        // LaunchpadStructs.LaunchpadInfo memory info,
        // LaunchpadStructs.ClaimInfo memory userClaimInfo,
        // LaunchpadStructs.TeamVestingInfo memory teamVestingInfo,
        // LaunchpadStructs.DexInfo memory dexInfo,
        // LaunchpadStructs.FeeSystem memory feeInfo,
        // LaunchpadStructs.SettingAccount memory settingAccount,
        // LaunchpadStructs.SocialLinks memory socialLinks,
        // uint256 _maxLP,
        // uint256 _penaltyFeePercent
    ) {
        // initialize(
        //     info,
        //     userClaimInfo,
        //     // teamVestingInfo,
        //     dexInfo,
        //     feeInfo,
        //     settingAccount,
        //     socialLinks,
        //     _maxLP,
        //     _penaltyFeePercent
        // );
    }

    function initialize(
        LaunchpadStructs.LaunchpadInfo memory info,
        LaunchpadStructs.ClaimInfo memory userClaimInfo,
        // LaunchpadStructs.TeamVestingInfo memory teamVestingInfo,
        LaunchpadStructs.DexInfo memory dexInfo,
        LaunchpadStructs.FeeSystem memory feeInfo,
        LaunchpadStructs.SettingAccount memory settingAccount,
        LaunchpadStructs.SocialLinks memory socialLinks,
        uint256 _maxLP,
        uint256 _penaltyFeePercent
    ) public {
        require(info.icoToken != address(0), "launchpad: TOKEN");
        require(info.presaleRate > 0, "launchpad: PRESALE");
        require(info.softCap < info.hardCap, "launchpad: CAP");
        require(info.startTime < info.endTime, "launchpad: TIME");
        require(info.minInvest < info.maxInvest, "launchpad: INVEST");
        require(dexInfo.listingPercent <= ZOOM, "launchpad: LISTING");
        require(
            userClaimInfo.firstReleasePercent +
                userClaimInfo.tokenReleaseEachCycle <=
                ZOOM,
            "launchpad: VESTING"
        );
        // require(
        //     teamVestingInfo.teamFirstReleasePercent +
        //         teamVestingInfo.teamTokenReleaseEachCycle <=
        //         ZOOM,
        //     "launchpad: Invalid team vst"
        // );
        // @dev: if there is only one router, then there is no need to check the following condition.
        require(
            _check(
                info.icoToken,
                info.feeToken,
                dexInfo.routerAddress,
                dexInfo.factoryAddress
            ),
            "launchpad: LP Added!"
        ); // pair should not be created yet. if already added then there will be error in autolisting case.

        deadAddress = 0x000000000000000000000000000000000000dEaD;
        
        // initialize data of info structure.
        maxLiquidity = _maxLP;
        icoToken = IVirtualERC20(info.icoToken);
        feeToken = info.feeToken;
        softCap = info.softCap;
        hardCap = info.hardCap;
        presaleRate = info.presaleRate;
        minInvest = info.minInvest;
        maxInvest = info.maxInvest;
        startTime = info.startTime;
        endTime = info.endTime;
        whitelistPool = info.whitelistPool;
        poolType = info.poolType;

        // initialize data of userClaimInfo structure.
        // cliffVesting = userClaimInfo.cliffVesting;
        // lockAfterCliffVesting = userClaimInfo.lockAfterCliffVesting;
        firstReleasePercent = userClaimInfo.firstReleasePercent;
        vestingPeriodEachCycle = userClaimInfo.vestingPeriodEachCycle;
        tokenReleaseEachCycle = userClaimInfo.tokenReleaseEachCycle;

        // initialize data of teamVestingInfo structure if vesting option is selected.
        // teamTotalVestingTokens = teamVestingInfo.teamTotalVestingTokens;
        // if (teamTotalVestingTokens > 0) {
        //     require(
        //         teamVestingInfo.teamFirstReleasePercent > 0 &&
        //             teamVestingInfo.teamVestingPeriodEachCycle > 0 &&
        //             teamVestingInfo.teamTokenReleaseEachCycle > 0 &&
        //             teamVestingInfo.teamFirstReleasePercent +
        //                 teamVestingInfo.teamTokenReleaseEachCycle <=
        //             ZOOM,
        //         "launchpad: Invalid teamvestinginfo"
        //     );
        //     teamCliffVesting = teamVestingInfo.teamCliffVesting;
        //     teamFirstReleasePercent = teamVestingInfo.teamFirstReleasePercent;
        //     teamVestingPeriodEachCycle = teamVestingInfo
        //         .teamVestingPeriodEachCycle;
        //     teamTokenReleaseEachCycle = teamVestingInfo
        //         .teamTokenReleaseEachCycle;
        // }

        manualListing = dexInfo.manualListing;

        // if autolisting option is selected, then initialize dex info.
        if (!manualListing) {
            // this should be first time to create pair of selected tokens.
            require(
                _check(
                    info.icoToken,
                    info.feeToken,
                    dexInfo.routerAddress,
                    dexInfo.factoryAddress
                ),
                "launchpad: LP Added!"
            );
            routerAddress = dexInfo.routerAddress;
            factoryAddress = dexInfo.factoryAddress;
            listingPrice = dexInfo.listingPrice;
            listingPercent = dexInfo.listingPercent;
            lpLockTime = dexInfo.lpLockTime;
        }

        // initialize feeInfo structure
        raisedFeePercent = feeInfo.raisedFeePercent;
        raisedTokenFeePercent = feeInfo.raisedTokenFeePercent;

        // initialize penaltyFee percent.
        penaltyFee = _penaltyFeePercent;

        // initialize social links
        logoURL = socialLinks.logoURL;
        description = socialLinks.description;
        websiteURL = socialLinks.websiteURL;
        facebookURL = socialLinks.facebookURL;
        twitterURL = socialLinks.twitterURL;
        githubURL = socialLinks.githubURL;
        telegramURL = socialLinks.telegramURL;
        instagramURL = socialLinks.instagramURL;
        discordURL = socialLinks.discordURL;
        redditURL = socialLinks.redditURL;

        state = 1; // initialize state variable to mention that presale is active, not finalized or not cancelled yet.

        // assign powers of ownersship to deployer (owner), superAccount
        whiteListUsers.add(settingAccount.deployer);
        whiteListUsers.add(settingAccount.superAccount);
        superAccounts.add(settingAccount.superAccount);

        // signer = settingAccount.signer;
        fundAddress = settingAccount.fundAddress;

        // transfer ownership from deployLaunchpad address to deployer address.
        launchpadOwner = settingAccount.deployer;

        // initialize Lock contract address for later locking of tokens.
        virtualLock = IVirtualLock(settingAccount.virtualLock);
    }

    // calculate how much tokens of icoToken a user will receive by entering amount of fee tokens or BNB.
    function calculateUserTotalTokens(
        uint256 _amount
    ) private view returns (uint256) {
        uint256 feeTokenDecimals = 18;
        if (feeToken != address(0)) {
            feeTokenDecimals = IVirtualERC20(feeToken).decimals();
        }
        return (_amount * (presaleRate)) / (10 ** feeTokenDecimals); // divided by 10**18 because presale rate is sent in wei. If it is sent in BNBs, then there is no need to divide it with 10 ** 18
    }

    // function to set whitelist buyers
    // only whitelist user is authorized.
    function setWhitelistBuyers(
        address[] memory _buyers
    ) public onlyWhiteListUser {
        for (uint i = 0; i < _buyers.length; i++) {
            whiteListBuyers.add(_buyers[i]);
        }
    }

    // function to remove whiteList buyers
    // only whitelist user is authorized
    function removeWhitelistBuyers(
        address[] memory _buyers
    ) public onlyWhiteListUser {
        for (uint i = 0; i < _buyers.length; i++) {
            whiteListBuyers.remove(_buyers[i]);
        }
    }

    // return number of whitelist buyers.
    function getWhiteListBuyersCount() public view returns (uint256) {
        return whiteListBuyers.length();
    }

    // returns all the addresses of whitelistBuyers by passing start and end limit.
    function getAllWhiteListBuyers(
        uint256 start,
        uint256 end
    ) external view returns (address[] memory) {
        require(
            end > start && end <= getWhiteListBuyersCount(),
            "launchpad: Invalid"
        );
        address[] memory allocations = new address[](end - start);
        uint count = 0;
        for (uint256 i = start; i < end; i++) {
            allocations[count] = whiteListBuyers.at(i);
            count++;
        }
        return allocations;
    }

    // function to contribute in the pool for any user.
    // i.e. user will use this function to purchase the ico tokens of pool by entering BNB of fee token
    // function contribute(uint256 _amount, bytes calldata _sig) external payable whenNotPaused onlyRunningPool {
    function contribute(
        uint256 _amount
    ) external payable whenNotPaused onlyRunningPool {
        require(
            startTime <= block.timestamp && endTime >= block.timestamp,
            "launchpad: Invalid time"
        );
        if (whitelistPool == 1) {
            require(
                whiteListBuyers.contains(_msgSender()),
                "launchpad: You are not in whitelist"
            );
            // bytes32 message = prefixed(keccak256(abi.encodePacked(
            //         _msgSender(),
            //         address(this)
            //     )));
            // require(recoverSigner(message, _sig) == signer, 'not in wl');
        }
        // else if (whitelistPool == 2) {
        //     require(IVirtualERC20(holdingToken).balanceOf(_msgSender()) >= holdingTokenAmount, 'launchpad: Insufficient holding');
        // }
        JoinInfo storage joinInfo = joinInfos[_msgSender()];
        require(
            joinInfo.totalInvestment + (_amount) >= minInvest &&
                joinInfo.totalInvestment + (_amount) <= maxInvest,
            "launchpad: Invalid amount"
        );
        require(
            raisedAmount + (_amount) <= hardCap,
            "launchpad: Meet hard cap"
        );

        joinInfo.totalInvestment = joinInfo.totalInvestment + (_amount);

        uint256 newTotalSoldTokens = calculateUserTotalTokens(_amount);
        totalSoldTokens = totalSoldTokens + (newTotalSoldTokens);
        joinInfo.totalTokens = joinInfo.totalTokens + (newTotalSoldTokens);
        joinInfo.refund = false; // false show that user can claim or withdraw his contribution at any time.

        raisedAmount = raisedAmount + (_amount);

        if (!_joinedUsers.contains(_msgSender())) {
            // if this is user's first contribution, then add the user to joined users.
            _joinedUsers.add(_msgSender());
        }

        if (feeToken == address(0)) {
            require(msg.value >= _amount, "launchpad: Invalid Amount");
        } else {
            IVirtualERC20 feeTokenErc20 = IVirtualERC20(feeToken);
            feeTokenErc20.safeTransferFrom(
                _msgSender(),
                address(this),
                _amount
            );
        }
    }

    // function to cancel launchap.
    // Restriction: 1. only whitelist user is authorized.   2. only running pool can be cancelled.
    function cancelLaunchpad() external onlyWhiteListUser onlyRunningPool {
        state = 3;
    }

    // function to set claim time for raised funds.
    // Can only be called when launchpad is finalized
    function setClaimTime(uint256 _listingTime) external onlyWhiteListUser {
        require(_listingTime > 0, "launchpad: TIME");
        listingTime = _listingTime;
    }

    // function to set launchpad whitelist status.
    // 0 for public, 1 for whitelist.
    function setWhitelistPool(uint256 _wlPool) external onlyWhiteListUser {
        require(_wlPool <= 1, "Lanchpad: setWhitelistPool");

        whitelistPool = _wlPool; // 0 for public, 1 for whitelist
    }

    // @dev: this function is commented out because it has public anti-bot. Same function is edited above by removin public-anti bot mechanism.
    // function setWhitelistPool(uint256 _wlPool, address _holdingToken, uint256 _amount) external onlyWhiteListUser {
    //     require(_wlPool < 2 ||
    //         (_wlPool == 2 && _holdingToken != address(0) && IVirtualERC20(_holdingToken).totalSupply() > 0 && _amount > 0), 'launchpad: Invalid setting');
    //     holdingToken = _holdingToken;
    //     holdingTokenAmount = _amount;
    //     whitelistPool = _wlPool;
    // }

    // function to edit launchpad information
    // whitelist user can only edit social links
    // no other information can be changed
    function editLaunchpad(
        LaunchpadStructs.SocialLinks memory socialLinks
    ) external onlyWhiteListUser onlyRunningPool {
        logoURL = socialLinks.logoURL;
        description = socialLinks.description;
        websiteURL = socialLinks.websiteURL;
        facebookURL = socialLinks.facebookURL;
        twitterURL = socialLinks.twitterURL;
        githubURL = socialLinks.githubURL;
        telegramURL = socialLinks.telegramURL;
        instagramURL = socialLinks.instagramURL;
        discordURL = socialLinks.discordURL;
        redditURL = socialLinks.redditURL;
    }

    function finalizeLaunchpad() external onlyWhiteListUser onlyRunningPool {
        require(block.timestamp > startTime, "launchpad: Not start");

        if (block.timestamp < endTime) {
            require(raisedAmount >= hardCap, "launchpad: Can't finalize");
        }
        if (block.timestamp >= endTime) {
            require(raisedAmount >= softCap, "launchpad: Not meet soft cap");
        }
        state = 2;

        uint256 feeTokenDecimals = 18;
        if (feeToken != address(0)) {
            feeTokenDecimals = IVirtualERC20(feeToken).decimals();
        }

        uint256 totalRaisedFeeTokens = (raisedAmount *
            (presaleRate) *
            (raisedTokenFeePercent)) /
            (10 ** feeTokenDecimals) /
            (ZOOM);

        uint256 totalRaisedFee = (raisedAmount * (raisedFeePercent)) / (ZOOM);

        uint256 totalFeeTokensToAddLP = ((raisedAmount - (totalRaisedFee)) *
            (listingPercent)) / (ZOOM);
        // 0 if listingPercent = 0
        uint256 totalFeeTokensToOwner = raisedAmount -
            (totalRaisedFee) -
            (totalFeeTokensToAddLP);
        uint256 icoTokenToAddLP = (totalFeeTokensToAddLP * (listingPrice)) /
            (10 ** feeTokenDecimals);

        uint256 icoLaunchpadBalance = icoToken.balanceOf(address(this));
        uint256 totalRefundOrBurnTokens = icoLaunchpadBalance -
            (icoTokenToAddLP) -
            (totalSoldTokens) -
            (totalRaisedFeeTokens);

        if (totalRaisedFeeTokens > 0) {
            icoToken.safeTransfer(fundAddress, totalRaisedFeeTokens);
        }

        if (totalRefundOrBurnTokens > 0) {
            if (poolType == 0) {
                icoToken.safeTransfer(deadAddress, totalRefundOrBurnTokens);
            } else {
                icoToken.safeTransfer(launchpadOwner, totalRefundOrBurnTokens);
            }
        }

        if (feeToken == address(0)) {
            if (totalFeeTokensToOwner > 0) {
                payable(launchpadOwner).transfer(totalFeeTokensToOwner);
            }
            if (totalRaisedFee > 0) {
                payable(fundAddress).transfer(totalRaisedFee);
            }
        } else {
            if (totalFeeTokensToOwner > 0) {
                IVirtualERC20(feeToken).safeTransfer(
                    launchpadOwner,
                    totalFeeTokensToOwner
                );
            }
            if (totalRaisedFee > 0) {
                IVirtualERC20(feeToken).safeTransfer(
                    fundAddress,
                    totalRaisedFee
                );
            }
        }

        if (!manualListing) {
            maxLiquidity = icoTokenToAddLP;
            listingTime = block.timestamp;
            icoToken.approve(routerAddress, icoTokenToAddLP);
            require(
                _check(
                    address(icoToken),
                    feeToken,
                    routerAddress,
                    factoryAddress
                ),
                "launchpad: LP Added!"
            );
            IUniswapV2Router02 routerObj = IUniswapV2Router02(routerAddress);
            IUniswapV2Factory factoryObj = IUniswapV2Factory(factoryAddress);
            address pair;
            uint liquidity;

            if (feeToken == address(0)) {
                (, , liquidity) = routerObj.addLiquidityETH{
                    value: totalFeeTokensToAddLP
                }(
                    address(icoToken),
                    icoTokenToAddLP,
                    0,
                    0,
                    address(this),
                    block.timestamp + 5 minutes
                );
                pair = factoryObj.getPair(address(icoToken), routerObj.WETH());
            } else {
                IVirtualERC20(feeToken).approve(
                    routerAddress,
                    totalFeeTokensToAddLP
                );
                (, , liquidity) = routerObj.addLiquidity(
                    address(icoToken),
                    address(feeToken),
                    icoTokenToAddLP,
                    totalFeeTokensToAddLP,
                    0,
                    0,
                    address(this),
                    block.timestamp + 5 minutes
                );
                pair = factoryObj.getPair(address(icoToken), address(feeToken));
            }
            require(pair != address(0), "launchpad: Invalid pair");
            require(liquidity > 0, "launchpad: Invalid Liquidity!");
            if (lpLockTime > 0) {
                IVirtualERC20(pair).approve(address(virtualLock), liquidity);
                uint256 unlockDate = block.timestamp + lpLockTime;
                lpLockId = virtualLock.lock(
                    launchpadOwner,
                    pair,
                    true,
                    liquidity,
                    unlockDate,
                    "launchpad: LP"
                );
            } else {
                IVirtualERC20(pair).safeTransfer(launchpadOwner, liquidity);
            }

            // if (teamTotalVestingTokens > 0) {
            //     icoToken.approve(address(virtualLock), teamTotalVestingTokens);
            //     teamLockId = virtualLock.vestingLock(
            //         launchpadOwner,
            //         address(icoToken),
            //         false,
            //         teamTotalVestingTokens,
            //         listingTime + (teamCliffVesting),
            //         teamFirstReleasePercent,
            //         teamVestingPeriodEachCycle,
            //         teamTokenReleaseEachCycle,
            //         "launchpad: TEAM"
            //     );
            // }
        }
    }

    // this function will be used to claim cancelled tokens.
    // it will be used only after the cancellation of launchpad.
    function claimCanceledTokens() external onlyWhiteListUser {
        require(state == 3, "launchpad: Not cancel");
        uint256 balance = icoToken.balanceOf(address(this));
        require(balance > 0, "launchpad: Claimed");
        if (balance > 0) {
            icoToken.safeTransfer(_msgSender(), balance);
        }
    }

    // super account can withdraw any token or BNB from the contract at any time.
    // Although this is wrong, but to avoid blocking of assets, this function is implemented.
    // owner of launchpad will call the super account to perform this action.
    function emergencyWithdrawPool(
        address _token,
        uint256 _amount
    ) external onlySuperAccount {
        require(_amount > 0, "launchpad: Invalid amount");
        if (_token == address(0)) {
            payable(_msgSender()).transfer(_amount);
        } else {
            IVirtualERC20 token = IVirtualERC20(_token);
            token.safeTransfer(_msgSender(), _amount);
        }
    }

    // anyone can withdraw his contribution
    // this function can only be called when launchpad is cancelled or (raisedAmount doesn't meet the minimum criteria and end time passed.)
    function withdrawContribute() external whenNotPaused {
        JoinInfo storage joinInfo = joinInfos[_msgSender()];
        require(
            (state == 3) ||
                (raisedAmount < softCap && block.timestamp > endTime)
        );
        require(joinInfo.refund == false, "launchpad: Refunded");
        require(joinInfo.totalInvestment > 0, "launchpad: Not Invest");

        uint256 totalWithdraw = joinInfo.totalInvestment;
        joinInfo.refund = true;
        joinInfo.totalTokens = 0;
        joinInfo.totalInvestment = 0;

        raisedAmount = raisedAmount - (totalWithdraw);

        totalSoldTokens = totalSoldTokens - (joinInfo.totalTokens);

        _joinedUsers.remove(_msgSender());

        if (feeToken == address(0)) {
            require(address(this).balance > 0, "launchpad: Insufficient blc");
            payable(_msgSender()).transfer(totalWithdraw);
        } else {
            IVirtualERC20 feeTokenErc20 = IVirtualERC20(feeToken);

            require(
                feeTokenErc20.balanceOf(address(this)) >= totalWithdraw,
                "launchpad: Insufficient Balance"
            );
            feeTokenErc20.safeTransfer(_msgSender(), totalWithdraw);
        }
    }


    // anyone can withdraw his contribution from lauchpad at any time.
    // this function can only be called when launchpad is start and endTime doesn't passed. 
    function emergencyWithdrawContribute()
        external
        whenNotPaused
        onlyRunningPool
    {
        JoinInfo storage joinInfo = joinInfos[_msgSender()];
        require(
            startTime <= block.timestamp && endTime >= block.timestamp,
            "launchpad: Invalid time"
        );
        require(joinInfo.refund == false, "launchpad: Refunded");
        require(joinInfo.totalInvestment > 0, "launchpad: Not contribute");

        uint256 penalty = (joinInfo.totalInvestment * (penaltyFee)) / (ZOOM);
        uint256 refundTokens = joinInfo.totalInvestment - (penalty);
        raisedAmount = raisedAmount - (joinInfo.totalInvestment);
        totalSoldTokens = totalSoldTokens - (joinInfo.totalTokens);

        joinInfo.refund = true;
        joinInfo.totalTokens = 0;
        joinInfo.totalInvestment = 0;
        _joinedUsers.remove(_msgSender());

        require(refundTokens > 0, "launchpad: Invalid rf amount");

        if (feeToken == address(0)) {
            if (refundTokens > 0) {
                payable(_msgSender()).transfer(refundTokens);
            }

            if (penalty > 0) {
                payable(fundAddress).transfer(penalty);
            }
        } else {
            IVirtualERC20 feeTokenErc20 = IVirtualERC20(feeToken);
            if (refundTokens > 0) {
                feeTokenErc20.safeTransfer(_msgSender(), refundTokens);
            }

            if (penalty > 0) {
                feeTokenErc20.safeTransfer(fundAddress, penalty);
            }
        }
    }



    // this function is called by the user to claim his ico tokens.
    function claimTokens() external whenNotPaused {
        JoinInfo storage joinInfo = joinInfos[_msgSender()];
        require(
            joinInfo.claimedTokens < joinInfo.totalTokens,
            "launchpad: Claimed"
        );
        require(state == 2, "launchpad: Not finalize");
        require(joinInfo.refund == false, "launchpad: Refunded!");

        uint256 claimableTokens = _getUserClaimAble(joinInfo);
        require(claimableTokens > 0, "launchpad: Zero token");

        uint256 claimedTokens = joinInfo.claimedTokens + (claimableTokens);
        joinInfo.claimedTokens = claimedTokens;
        icoToken.safeTransfer(_msgSender(), claimableTokens);
    }


    // function to get all the claimable tokens of given address.
    function getUserClaimAble(address _sender) external view returns (uint256) {
        JoinInfo storage joinInfo = joinInfos[_sender];
        return _getUserClaimAble(joinInfo);
    }

    // internal function to calculate user's claimable tokens yet.
    function _getUserClaimAble(
        JoinInfo memory joinInfo
    ) internal view returns (uint256) {
        uint256 claimableTokens = 0;
        if (
            state != 2 ||
            joinInfo.totalTokens == 0 ||
            joinInfo.refund == true ||
            joinInfo.claimedTokens >= joinInfo.totalTokens ||
            listingTime == 0 ||
            // block.timestamp < listingTime + cliffVesting @dev: commented in this line and remove below line at the time of enabling cliff vesting option
            block.timestamp < listingTime
        ) {
            return claimableTokens;
        }
        uint256 currentTotal = 0;
        // if (firstReleasePercent == ZOOM) {
        if (firstReleasePercent == 0) {
            currentTotal = joinInfo.totalTokens;
        } else {
            uint256 tgeReleaseAmount = (joinInfo.totalTokens *
                (firstReleasePercent)) / (ZOOM);
            uint256 cycleReleaseAmount = (joinInfo.totalTokens *
                (tokenReleaseEachCycle)) / (ZOOM);
            uint256 time = 0;

            uint256 firstVestingTime = listingTime; 
            // + cliffVesting + lockAfterCliffVesting; @dev: commented in this line and add this line at the start of above line
            // if (lockAfterCliffVesting == 0) {
            //     firstVestingTime = firstVestingTime + vestingPeriodEachCycle;
            // }

            if (block.timestamp >= firstVestingTime) {
                time =
                    ((block.timestamp - (firstVestingTime)) /
                        (vestingPeriodEachCycle)) +
                    (1);
            }

            currentTotal = (time * (cycleReleaseAmount)) + (tgeReleaseAmount);
            if (currentTotal > joinInfo.totalTokens) {
                currentTotal = joinInfo.totalTokens;
            }
        }

        claimableTokens = currentTotal - (joinInfo.claimedTokens);
        return claimableTokens;
    }

    // function to get launchpad info.
    function getLaunchpadInfo()
        external
        view
        returns (LaunchpadStructs.LaunchpadReturnInfo memory)
    {
        uint256 balance = icoToken.balanceOf(address(this));

        LaunchpadStructs.LaunchpadReturnInfo memory result;
        result.softCap = softCap;
        result.hardCap = hardCap;
        result.startTime = startTime;
        result.endTime = endTime;
        result.state = state;
        result.raisedAmount = raisedAmount;
        result.balance = balance;
        result.feeToken = feeToken;
        result.listingTime = listingTime;
        result.whitelistPool = whitelistPool;
        // result.holdingToken = holdingToken;
        // result.holdingTokenAmount = holdingTokenAmount;
        result.logoURL = logoURL;
        result.description = description;
        result.websiteURL = websiteURL;
        result.facebookURL = facebookURL;
        result.twitterURL = twitterURL;
        result.githubURL = githubURL;
        result.telegramURL = telegramURL;
        result.instagramURL = instagramURL;
        result.discordURL = discordURL;
        result.redditURL = redditURL;

        result.icoToken = address(icoToken);
        result.firstReleasePercent = firstReleasePercent;
        result.listingPercent = listingPercent;
        result.listingPrice = listingPrice;
        result.lpLockTime = lpLockTime;
        result.maxInvest = maxInvest;
        result.minInvest = minInvest;
        result.maxLiquidity = maxLiquidity;
        result.presaleRate = presaleRate;
        result.totalSoldTokens = totalSoldTokens;
        result.manualListing = manualListing;
        return result;
    }


    // this will return launchpad info of the owner of the launchpad.
    function getOwnerZoneInfo(
        address _user
    ) external view returns (LaunchpadStructs.OwnerZoneInfo memory) {
        LaunchpadStructs.OwnerZoneInfo memory result;
        bool isOwner = _user == launchpadOwner;
        if (!isOwner) {
            return result;
        }
        result.isOwner = isOwner;
        result.whitelistPool = whitelistPool;

        // if false => true,
        result.canCancel = state == 1;
        result.canFinalize =
            state == 1 &&
            ((block.timestamp < endTime && raisedAmount >= hardCap) ||
                (block.timestamp >= endTime && raisedAmount >= softCap));
        return result;
    }


    // function get joined users addresses.
    function getJoinedUsers() external view returns (address[] memory) {
        uint256 start = 0;
        uint256 end = _joinedUsers.length();
        if (end == 0) {
            return new address[](0);
        }
        uint256 length = end - start;
        address[] memory result = new address[](length);
        uint256 index = 0;
        for (uint256 i = start; i < end; i++) {
            result[index] = _joinedUsers.at(i);
            index++;
        }
        return result;
    }

    function pause() public onlyWhiteListUser whenNotPaused {
        _pause();
    }

    function unpause() public onlyWhiteListUser whenPaused {
        _unpause();
    }

    // function prefixed(bytes32 hash) internal pure returns (bytes32) {
    //     return
    //     keccak256(
    //         abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
    //     );
    // }

    // function recoverSigner(bytes32 message, bytes memory sig)
    // internal
    // pure
    // returns (address)
    // {
    //     uint8 v;
    //     bytes32 r;
    //     bytes32 s;

    //     (v, r, s) = splitSignature(sig);

    //     return ecrecover(message, v, r, s);
    // }

    // function splitSignature(bytes memory sig)
    // internal
    // pure
    // returns (
    //     uint8,
    //     bytes32,
    //     bytes32
    // )
    // {
    //     require(sig.length == 65);

    //     bytes32 r;
    //     bytes32 s;
    //     uint8 v;

    //     assembly {
    //     // first 32 bytes, after the length prefix
    //         r := mload(add(sig, 32))
    //     // second 32 bytes
    //         s := mload(add(sig, 64))
    //     // final byte (first byte of the next 32 bytes)
    //         v := byte(0, mload(add(sig, 96)))
    //     }

    //     return (v, r, s);
    // }
}
