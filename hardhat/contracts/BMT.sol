// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract BMT {

    mapping(bytes32 => Proven) public BMTRegistry;

    /**
    * @dev register the chunk that you are storing as a BMT root
    * @param _BMTroot the root hash of the Binary Merkle Tree of all chunk that you are currently storing
    */
    function register(bytes32 _BMTroot) public {
        require(!BMTRegistry[_BMTroot].isRegistered);
        BMTRegistry[_BMTroot].isRegistered = true; 
    }

    struct Proven {
        bool isRegistered;
        bool isProven;
    }

    /**
    * @dev proof the posession of a chunk that was previously registered with a BMT root
    * @param _BMTroot the root hash of the Binary Merkle Tree that was previously registered
    * @param chunk the chunk that is part of the storage of which you are proving posession
    * @param hashes of the proof, shallowest-first
    */
    function proof(bytes32 _BMTroot, bytes32[4] memory chunk, bytes32[] memory hashes) public {
        require(BMTRegistry[_BMTroot].isRegistered, "BMT root not registered");
        bytes32 parentHash;
        for (uint i = 0; i < hashes.length; i++) {
            if(i == 0) {
                parentHash = keccak256(abi.encodePacked(chunkHash(chunk), hashes[i]));
            } else {
                parentHash = keccak256(abi.encodePacked(parentHash, hashes[i]));
            }
        }
        require(parentHash == _BMTroot, "Proof not correct");
        BMTRegistry[_BMTroot].isProven = true;
    }

    function chunkHash(bytes32[4] memory chunk) public pure returns(bytes32) {
        return keccak256(abi.encodePacked(
            chunk[0],
            chunk[1],
            chunk[2],
            chunk[3]
            ));
    }
}