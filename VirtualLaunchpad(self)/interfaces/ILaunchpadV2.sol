// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

import '../structs/LaunchpadStructs.sol';
interface ILaunchpadV2 {
    function initialize(
        LaunchpadStructs.LaunchpadInfo memory info,
        LaunchpadStructs.ClaimInfo memory userClaimInfo,
        LaunchpadStructs.TeamVestingInfo memory teamVestingInfo,
        LaunchpadStructs.DexInfo memory dexInfo,
        LaunchpadStructs.FeeSystem memory feeInfo,
        LaunchpadStructs.SettingAccount memory settingAccount,
        uint256 _maxLP
    ) external;
}
