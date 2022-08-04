// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;

import "forge-std/Test.sol";
import "forge-std/Vm.sol";
import "@lens/libraries/DataTypes.sol";
import '../src/LensNFTAccess.sol';
import '../src/TestNFT.sol';

contract LensNFTAccessTestcl is Test {
    uint256 public constant PROFILE_ID = 1408;
    LensNFTAccess lensNFTAccess;
    TestNFT nft1;
    TestNFT nft2;
    ILensHub lensHub = ILensHub(0xDb46d1Dc155634FbC732f92E853b10B288AD5a1d);

    address addressWithDAOProfile = 0x14306f86629E6bc885375a1f81611a4208316B2b;
    address user = address(3);

    function setUp() public {
        nft1 = new TestNFT('Name1', 'N1');
        nft2 = new TestNFT('Name2', 'N2');
        lensNFTAccess = new LensNFTAccess(PROFILE_ID, address(nft1), 0xDb46d1Dc155634FbC732f92E853b10B288AD5a1d);
        vm.prank(addressWithDAOProfile);
        lensHub.setDispatcher(PROFILE_ID, address(lensNFTAccess));
    }

    function testPostIfNFTOwner() public {
        DataTypes.ProfileStruct memory profile =  lensHub.getProfile(PROFILE_ID);
        nft1.mint(user, 1);
        vm.prank(user);

        lensNFTAccess.post(
            'aave.com', 
            0x23b9467334bEb345aAa6fd1545538F3d54436e96, // test module, everyone can collect
            abi.encode(false), 
            address(0), 
            abi.encode('')
        );

        assertEq(lensHub.getContentURI(PROFILE_ID, profile.pubCount+1), 'aave.com');
    }

    function testPostIfNotNFTOwner() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSignature("NotNFTOwner()"));
        lensNFTAccess.post(
            'aave.com', 
            0x23b9467334bEb345aAa6fd1545538F3d54436e96, // test module, everyone can collect
            abi.encode(false), 
            address(0), 
            abi.encode('')
        );
    }

    function testSetProfileIdIfOwner() public {
        uint256 dummyProfileId = 10;
        lensNFTAccess.setProfileId(dummyProfileId);
        assertEq(dummyProfileId, lensNFTAccess.profileId());
    }

     function testSetProfileIdNotIfOwner() public {
        vm.prank(user);
        vm.expectRevert('UNAUTHORIZED');
        lensNFTAccess.setProfileId(10);
    }

    function testSetCollectionAddressIfNotOwner() public {
        vm.prank(user);
        vm.expectRevert('UNAUTHORIZED');
        lensNFTAccess.setCollectionAddress(address(nft2));
    }

    function testSetCollectionAddressIfOwner() public {
        lensNFTAccess.setCollectionAddress(address(nft2));
        assertEq(address(nft2), address(lensNFTAccess.nftCollection()));
    }
}
