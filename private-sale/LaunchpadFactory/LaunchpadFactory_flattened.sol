
// File: structs/LaunchpadStructs.sol


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




// File: interfaces/ILaunchpad.sol


pragma solidity ^0.8.2;


interface ILaunchpad {
    function initialize(
        LaunchpadStructs.LaunchpadInfo memory info,
        LaunchpadStructs.ClaimInfo memory userClaimInfo,
        LaunchpadStructs.DexInfo memory dexInfo,
        LaunchpadStructs.FeeSystem memory feeInfo,
        LaunchpadStructs.SettingAccount memory settingAccount,
        LaunchpadStructs.SocialLinks memory socialLinks,
        uint256 _maxLP,
        uint256 _penaltyFeePercent
    ) external;

    function getLaunchpadInfo()
        external
        view
        returns (LaunchpadStructs.LaunchpadReturnInfo memory);

    function getOwnerZoneInfo(
        address _user
    ) external view returns (LaunchpadStructs.OwnerZoneInfo memory);

    function getJoinedUsers()
    external
    view
    returns (address[] memory);
}

// File: LaunchpadFactory/Clones.sol


// OpenZeppelin Contracts (last updated v4.8.0) (proxy/Clones.sol)

pragma solidity ^0.8.0;

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
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

// File: interfaces/IVirtualERC20.sol




pragma solidity ^0.8.2;

interface IVirtualERC20 is IERC20 {
   function decimals() external view returns (uint8);
}
// File: @openzeppelin/contracts/utils/math/SafeMath.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// File: @openzeppelin/contracts/utils/Address.sol


// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}

// File: @openzeppelin/contracts/utils/Context.sol


// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;


/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// File: LaunchpadFactory/LaunchpadFactory.sol


pragma solidity ^0.8.17;









contract LaunchpadFactory is Ownable {
    using SafeMath for uint256;
    using Address for address payable;
    uint256 public constant ZOOM = 10000;

    uint256 public flatFee; // fee that will be calculated on each launchpad creation
    uint256 public penaltyFeePercent = 1000; // 10% // penalty that will be calculated on each emergency withdraw or cancellation the launchpad.
    address public superAccount;
    address public virtualLock;
    address payable public fundAddress; // address that will calculate all types of funds.
    address public implementation; // implementation of the launchpad. This will be used to clone the launchpad
    bool public isRenounced;
    ILaunchpad[] public allLaunchpads; // array that will store all launchpads created yet.
    mapping (address => ILaunchpad[]) private allLaunchpadsOf; // mapping to store all launchpads created by the user.

    event NewLaunchpad(address indexed launchpad);

    constructor(
        address _superAccount,
        address _virtualLock,
        address payable _fundAddress,
        address _implementation
    ) {
        require(
            _virtualLock != address(0) && _virtualLock != address(this),
            "LauchpadFactory: virtualLock"
        );
        require(
            _superAccount != address(0) && _superAccount != address(this),
            "LauchpadFactory: superAccount"
        );
        require(
            _fundAddress != address(0) && _fundAddress != address(this),
            "LauchpadFactory: fundAddress"
        );
        superAccount = _superAccount;
        fundAddress = _fundAddress;
        virtualLock = _virtualLock;
        implementation = _implementation;
    }

    function setSuperAccount(address _superAccount) public onlyOwner {
        require(!isRenounced, "Super Account renounced");
        superAccount = _superAccount;
    }

    function renounceSuperAccount() external onlyOwner {
        require(!isRenounced, "Super Account already Renounced");
        superAccount = address(0);
        isRenounced = true;
    }

    function setVirtualLock(address _virtualLock) public onlyOwner {
        virtualLock = _virtualLock;
    }

    function setFundAddress(address payable _fundAddress) public onlyOwner {
        fundAddress = _fundAddress;
    }

    function setFlatFee(uint256 _flatFee) public onlyOwner {
        flatFee = _flatFee;
    }

    function setPenalyFeePercent(uint256 _penaltyFeePercent) public onlyOwner {
        penaltyFeePercent = (_penaltyFeePercent) * 100; // due to ZOOM constant
    }

    function setImplementations(address _implementation) public onlyOwner {
        implementation = _implementation;
    }


    // this function is used to calcluate how many tokens deployer should have to approve to Deploy Launchpad to create a new launchpad.
    function calculateTokens(
        LaunchpadStructs.CalculateTokenInput memory input
    ) public view returns (uint256, uint256) {
        uint256 feeTokenDecimals = 18;
        if (input.feeToken != address(0)) {
            feeTokenDecimals = IVirtualERC20(input.feeToken).decimals();
        }

        uint256 totalPresaleTokens = (input.presaleRate.mul((input.hardCap))).div(10 ** feeTokenDecimals);

        uint256 totalFeeTokens = (totalPresaleTokens.mul(input.raisedTokenFeePercent)).div(ZOOM);

        uint256 totalRaisedFee = (input.hardCap.mul(input.raisedFeePercent)).div(ZOOM);
        uint256 netCap = input.hardCap.sub(totalRaisedFee);
        uint256 totalFeeTokensToAddLP = (netCap.mul(input.listingPercent)).div(ZOOM);

        uint256 totalLiquidityTokens = (totalFeeTokensToAddLP.mul(input.listingPrice)).div(10 ** feeTokenDecimals);

        uint256 result = totalPresaleTokens.add(totalFeeTokens).add(totalLiquidityTokens);
        return (result, totalLiquidityTokens);
    }

    // main function that will make clones on each time a deployer will want to create a new launchpad.
    function deployLaunchpad(
        LaunchpadStructs.LaunchpadInfo memory info,
        LaunchpadStructs.ClaimInfo memory claimInfo,
        LaunchpadStructs.DexInfo memory dexInfo,
        LaunchpadStructs.FeeSystem memory feeInfo,
        LaunchpadStructs.SocialLinks memory socialLinks
    ) external payable {
        require(
                superAccount != address(0) &&
                fundAddress != address(0),
            "LauchpadFactory: Can not create launchpad now!"
        );
        require(msg.value >= flatFee, "LauchpadFactory: Not enough fee!");
        require(info.whiteListBuyers.length > 0, "LanchpadFactory: Empty whitelist Array");

        LaunchpadStructs.SettingAccount memory settingAccount = LaunchpadStructs
            .SettingAccount(
                _msgSender(),
                superAccount,
                payable(fundAddress),
                virtualLock
            );

        IVirtualERC20 icoToken = IVirtualERC20(info.icoToken);
        uint256 feeTokenDecimals = 18;
        if (info.feeToken != address(0)) {
            feeTokenDecimals = IVirtualERC20(info.feeToken).decimals();
        }

        LaunchpadStructs.CalculateTokenInput memory input = LaunchpadStructs
            .CalculateTokenInput(
                info.feeToken,
                info.presaleRate,
                info.hardCap,
                feeInfo.raisedTokenFeePercent,
                feeInfo.raisedFeePercent,
                dexInfo.listingPercent,
                dexInfo.listingPrice
            );

        uint256 totalTokens;
        uint256 maxLP;

        (totalTokens, maxLP) = calculateTokens(input);

        // clone implementation
        address launchpad = Clones.clone(implementation);
        // initialize new cloned implementation
        ILaunchpad(launchpad).initialize(
            info,
            claimInfo,
            dexInfo,
            feeInfo,
            settingAccount,
            socialLinks,
            maxLP,
            penaltyFeePercent
        );

        if (msg.value > 0) {
            payable(fundAddress).transfer(msg.value);
        }

        if (totalTokens > 0) {
            IERC20 icoTokenErc20 = IERC20(info.icoToken);

            require(
                icoTokenErc20.balanceOf(_msgSender()) >= totalTokens,
                "LauchpadFactory: Insufficient Balance"
            );
            require(
                icoTokenErc20.allowance(_msgSender(), address(this)) >=
                    totalTokens,
                "LauchpadFactory: Insufficient Allowance"
            );

            require(
                icoToken.transferFrom(
                    _msgSender(),
                    address(launchpad),
                    totalTokens
                ),
                "LauchpadFactory: transfer failed"
            );
        }

        allLaunchpads.push(ILaunchpad(launchpad)); 
        allLaunchpadsOf[msg.sender].push(ILaunchpad(launchpad));


        emit NewLaunchpad(address(launchpad));
    }

    // total launchpads created yet on the platform
    function totalLaunchpads() external view returns (ILaunchpad[] memory launchpads){
        return allLaunchpads;
    }

    // total launchpads by user. This will be used for myContribution section
    function totalLaunchpadsByUser(address _user) external view returns (ILaunchpad[] memory launchpadsByUser){
        return allLaunchpadsOf[_user];
    }

}
