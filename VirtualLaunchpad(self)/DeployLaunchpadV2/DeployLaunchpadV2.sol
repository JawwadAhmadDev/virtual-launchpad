// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

// OpenZeppelin Contracts (last updated v4.8.0) (proxy/Clones.sol)

/**
 * @dev https://eips.ethereum.org/EIPS/eip-1167[EIP 1167] is a standard for
 * deploying minimal proxy contracts, also known as "clones".
 *
 * > To simply and cheaply clone contract functionality in an immutable way, this standard specifies
 * > a minimal bytecode implementation that delegates all calls to a known, fixed address.
 *
 * The library includes functions to deploy a proxy using either `create` (traditional deployment) or `create2`
 * (salted deterministic deployment). It also includes functions to predict the addresses of clones deployed using the
 * deterministic method.
 *
 * _Available since v3.4._
 */
library Clones {
    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create opcode, which should never revert.
     */
    function clone(address implementation) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create(0, 0x09, 0x37)
        }
        require(instance != address(0), "ERC1167: create failed");
    }

    /**
     * @dev Deploys and returns the address of a clone that mimics the behaviour of `implementation`.
     *
     * This function uses the create2 opcode and a `salt` to deterministically deploy
     * the clone. Using the same `implementation` and `salt` multiple time will revert, since
     * the clones cannot be deployed twice at the same address.
     */
    function cloneDeterministic(address implementation, bytes32 salt) internal returns (address instance) {
        /// @solidity memory-safe-assembly
        assembly {
            // Cleans the upper 96 bits of the `implementation` word, then packs the first 3 bytes
            // of the `implementation` address with the bytecode before the address.
            mstore(0x00, or(shr(0xe8, shl(0x60, implementation)), 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000))
            // Packs the remaining 17 bytes of `implementation` with the bytecode after the address.
            mstore(0x20, or(shl(0x78, implementation), 0x5af43d82803e903d91602b57fd5bf3))
            instance := create2(0, 0x09, 0x37, salt)
        }
        require(instance != address(0), "ERC1167: create2 failed");
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt,
        address deployer
    ) internal pure returns (address predicted) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40)
            mstore(add(ptr, 0x38), deployer)
            mstore(add(ptr, 0x24), 0x5af43d82803e903d91602b57fd5bf3ff)
            mstore(add(ptr, 0x14), implementation)
            mstore(ptr, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73)
            mstore(add(ptr, 0x58), salt)
            mstore(add(ptr, 0x78), keccak256(add(ptr, 0x0c), 0x37))
            predicted := keccak256(add(ptr, 0x43), 0x55)
        }
    }

    /**
     * @dev Computes the address of a clone deployed using {Clones-cloneDeterministic}.
     */
    function predictDeterministicAddress(
        address implementation,
        bytes32 salt
    ) internal view returns (address predicted) {
        return predictDeterministicAddress(implementation, salt, address(this));
    }
}

interface ILaunchpadV2 {
function initialize (LaunchpadStructs.LaunchpadInfo memory info, LaunchpadStructs.ClaimInfo memory userClaimInfo, LaunchpadStructs.TeamVestingInfo memory teamVestingInfo,LaunchpadStructs.DexInfo memory dexInfo, LaunchpadStructs.FeeSystem memory feeInfo, LaunchpadStructs.SettingAccount memory settingAccount, uint256 _maxLP) external;
}

interface IVirtualERC20 is IERC20 {
   function decimals() external view returns (uint8);
}
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "../structs/LaunchpadStructs.sol";
contract DeployLaunchpadV2 is Ownable {

    address public signer;
    address public superAccount;
    address public virtualLock;
    address payable public fundAddress;

    address[] public allLaunchpads;
    address public implementation;

    event NewLaunchpadV2(address indexed launchpad);

    uint256 public constant ZOOM = 10000;

    constructor(address _signer, address _superAccount, address _virtualLock, address payable _fundAddress, address _implementation){
        require(_signer != address(0) && _signer != address(this), 'signer');
        require(_virtualLock != address(0) && _virtualLock != address(this), 'virtualLock');
        require(_superAccount != address(0) && _superAccount != address(this), 'superAccount');
        require(_fundAddress != address(0) && _fundAddress != address(this), 'fundAddress');
        signer = _signer;
        superAccount = _superAccount;
        fundAddress = _fundAddress;
        virtualLock = _virtualLock;
        implementation = _implementation;
    }

    function setSigner(address _signer) public onlyOwner {
        signer = _signer;
    }

    function setSuperAccount(address _superAccount) public onlyOwner {
        superAccount = _superAccount;
    }

    function setVirtualLock(address _virtualLock) public onlyOwner {
        virtualLock = _virtualLock;
    }

    function setFundAddress(address payable _fundAddress) public onlyOwner {
        fundAddress = _fundAddress;
    }

    function setImplementations(address _implementation) public onlyOwner {
        implementation = _implementation;
    } 

    function calculateTokens(LaunchpadStructs.CalculateTokenInput memory input) private view returns (uint256, uint256) {
        uint256 feeTokenDecimals = 18;
        if (input.feeToken != address(0)) {
            feeTokenDecimals = IVirtualERC20(input.feeToken).decimals();
        }

        uint256 totalPresaleTokens = input.presaleRate*(input.hardCap)/(10 ** feeTokenDecimals);

        uint256 totalFeeTokens = totalPresaleTokens*(input.raisedTokenFeePercent)/(ZOOM);


        uint256 totalRaisedFee = input.hardCap*(input.raisedFeePercent)/(ZOOM);
        uint256 netCap = input.hardCap - (totalRaisedFee);
        uint256 totalFeeTokensToAddLP = netCap*(input.listingPercent)/(ZOOM);

        uint256 totalLiquidityTokens = totalFeeTokensToAddLP*(input.listingPrice)/(10 ** feeTokenDecimals);

        uint256 result = totalPresaleTokens+(totalFeeTokens)+(totalLiquidityTokens);
        return (result, totalLiquidityTokens);
    }

    function deployLaunchpad(LaunchpadStructs.LaunchpadInfo memory info, LaunchpadStructs.ClaimInfo memory claimInfo, LaunchpadStructs.TeamVestingInfo memory teamVestingInfo, LaunchpadStructs.DexInfo memory dexInfo, LaunchpadStructs.FeeSystem memory feeInfo) external payable {
        require(signer != address(0) && superAccount != address(0) && fundAddress != address(0), 'Can not create launchpad now!');
        require(msg.value >= feeInfo.initFee, 'Not enough fee!');


        LaunchpadStructs.SettingAccount memory settingAccount = LaunchpadStructs.SettingAccount(
            _msgSender(),
            signer,
            superAccount,
            payable(fundAddress),
            virtualLock
        );


        IVirtualERC20 icoToken = IVirtualERC20(info.icoToken);
        uint256 feeTokenDecimals = 18;
        if (info.feeToken != address(0)) {
            feeTokenDecimals = IVirtualERC20(info.feeToken).decimals();
        }

        LaunchpadStructs.CalculateTokenInput memory input = LaunchpadStructs.CalculateTokenInput(info.feeToken,
            info.presaleRate,
            info.hardCap,
            feeInfo.raisedTokenFeePercent,
            feeInfo.raisedFeePercent,
            dexInfo.listingPercent,
            dexInfo.listingPrice);

        uint256 totalTokens;
        uint256 maxLP;

        (totalTokens, maxLP) = calculateTokens(input);

        // clone implementation
        address launchpad = Clones.clone(implementation);
        // initialize new cloned implementation
        ILaunchpadV2(launchpad).initialize(info, claimInfo, teamVestingInfo, dexInfo, feeInfo, settingAccount, maxLP);
        // LaunchpadV2 launchpad = new LaunchpadV2(info, claimInfo, teamVestingInfo, dexInfo, feeInfo, settingAccount, maxLP);

        if (msg.value > 0) {
            payable(fundAddress).transfer(msg.value);
        }

        if (totalTokens > 0) {
            IERC20 icoTokenErc20 = IERC20(info.icoToken);

            require(icoTokenErc20.balanceOf(_msgSender()) >= totalTokens, 'Insufficient Balance');
            require(icoTokenErc20.allowance(_msgSender(), address(this)) >= totalTokens, 'Insufficient Allowance');

            require(icoToken.transferFrom(_msgSender(), address(launchpad), totalTokens),"transfer failed");
        }

        allLaunchpads.push(launchpad);
        emit NewLaunchpadV2(address(launchpad));
    }

}


