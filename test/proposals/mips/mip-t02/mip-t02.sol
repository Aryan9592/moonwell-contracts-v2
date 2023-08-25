//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.19;

import "@forge-std/Test.sol";

import {MToken} from "@protocol/MToken.sol";
import {Configs} from "@test/proposals/Configs.sol";
import {ChainIds} from "@test/utils/ChainIds.sol";
import {Proposal} from "@test/proposals/proposalTypes/Proposal.sol";
import {Addresses} from "@test/proposals/Addresses.sol";
import {TimelockProposal} from "@test/proposals/proposalTypes/TimelockProposal.sol";
import {CrossChainProposal} from "@test/proposals/proposalTypes/CrossChainProposal.sol";
import {MultiRewardDistributor} from "@protocol/MultiRewardDistributor/MultiRewardDistributor.sol";

/// This MIP sets the price feeds for wstETH and cbETH.
contract mipt02 is Proposal, CrossChainProposal, ChainIds, Configs {
    string public constant name = "mip-t02";

    constructor() {
        _setNonce(2);
        string memory descriptionPath = string(
            abi.encodePacked("test/proposals/mips/", name, "/", name, ".md")
        );
        bytes memory proposalDescription = abi.encodePacked(
            vm.readFile(descriptionPath)
        );

        _setProposalDescription(proposalDescription);
    }

    function deploy(Addresses addresses, address) public override {}

    function afterDeploy(Addresses addresses, address) public override {}

    function afterDeploySetup(Addresses addresses) public override {}

    function build(Addresses addresses) public override {
        /// -------------- FEED CONFIGURATION --------------

        address moonwellDAI = addresses.getAddress("MOONWELL_DAI");
        address wormholeWELL = addresses.getAddress("WORMHOLE_WELL");
        address multiRewardDistributor = addresses.getAddress("MRD_PROXY");
        address owner = addresses.getAddress("TEMPORAL_GOVERNOR_GUARDIAN");

        _pushCrossChainAction(
            multiRewardDistributor,
            abi.encodeWithSignature(
                "_addEmissionConfig(address,address,address,uint256,uint256,uint256)",
                moonwellDAI,
                owner,
                wormholeWELL,
                0,
                1,
                1913951072
            ),
            "Temporal governor adds an emission config for DAI"
        );
    }

    function run(Addresses addresses, address) public override {
        _simulateCrossChainActions(addresses.getAddress("TEMPORAL_GOVERNOR"));
    }

    function printCalldata(Addresses addresses) public override {
        printActions(
            addresses.getAddress("TEMPORAL_GOVERNOR"),
            addresses.getAddress(
                "WORMHOLE_CORE",
                sendingChainIdToReceivingChainId[block.chainid]
            )
        );
    }

    function teardown(Addresses addresses, address) public pure override {}

    /// @notice assert that all the configurations are correctly set
    /// @dev this function is called after the proposal is executed to
    /// validate that all state transitions worked correctly
    function validate(Addresses addresses, address) public override {
        /* address chainlinkOracleAddress = addresses.getAddress(
            "CHAINLINK_ORACLE"
        );
        address wstETHFeed = addresses.getAddress("stETHETH_ORACLE");
        address cbETHFeed = addresses.getAddress("cbETHETH_ORACLE");

        ChainlinkOracle chainlinkOracle = ChainlinkOracle(
            chainlinkOracleAddress
        );

        assertEq(
            address(chainlinkOracle.getFeed("wstETH")),
            address(wstETHFeed)
        );

        assertEq(address(chainlinkOracle.getFeed("cbETH")), address(cbETHFeed)); */
    }
}
