// SPDX-License-Identifier: BSD-3-Clause
pragma solidity ^0.8.10;


import "@solmate/auth/Owned.sol";
import "@lens/interfaces/ILensHub.sol";
import "@lens/libraries/DataTypes.sol";
import "@openzeppelin/interfaces/IERC721.sol";

contract LensNFTAccess is Owned {

    ILensHub lensHub;
    IERC721 public nftCollection;
    uint256 public profileId;

    error NotNFTOwner();
    event PostCreated(DataTypes.PostData);
    constructor(
        uint256 _profileId,
        address _collectionAddress,
        address _lensHubAddress
    ) Owned(msg.sender) {
        profileId = _profileId;
        lensHub = ILensHub(_lensHubAddress);
        nftCollection = IERC721(_collectionAddress);
    }

    function post
    (
        string calldata contentURI,
        address collectModule,
        bytes calldata collectModuleInitData,
        address referenceModule,
        bytes calldata referenceModuleInitData
    ) external {
        if(nftCollection.balanceOf(msg.sender) == 0) revert NotNFTOwner();

        DataTypes.PostData memory data = DataTypes.PostData(
            profileId,
            contentURI,
            collectModule,
            collectModuleInitData,
            referenceModule,
            referenceModuleInitData
        );

        lensHub.post(data);

        emit PostCreated(data);
        
    }

    function setProfileId(uint256 _profileId) public onlyOwner {
        profileId = _profileId;
    }

    function setCollectionAddress(address _collectionAddress) public onlyOwner {
        nftCollection = IERC721(_collectionAddress);
    }
}
