// SPDX-License-Identifier: GPL-3.0
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
//   
//                                                 
//      
//      
//
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//      @artist ::          stereoIII6.eth                                                                                                                                          //
//      @msg ::             stereoIII6.eth.chat                                                                                                                                     //
//      @github ::          stereoIII6                                                                                                                                              //
//                                                                                                                                                                                  //
//      @dev ::             stereoIII6.eth                                                                                                                                          //
//      @msg ::             stereoIII6.eth.chat                                                                                                                                     //
//      @github ::          stereoIII6                                                                                                                                              //
//                                                                                                                                                                                  //
//      @author ::          stereoIII6.eth                                                                                                                                          //
//      @msg ::             stereoIII6.eth.chat                                                                                                                                     //
//      @github ::          stereoIII6                                                                                                                                              //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
//                                                                                                                                                                                  //
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//      @title ::           safe contract                                                                                                                                           //
//      @description ::     Decentral Social Network Experiment                                                                                                                     //
//      @version ::         0.0.1                                                                                                                                                   //
//      @purpose ::         Bring real life into the Blockchain                                                                                                                     //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
//                                                                                                                                                                                  //
// // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // // //

pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
// import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./RentSafe.sol";

contract m {
    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (i = 0; i < 32 && _bytes32[i] != 0; i++) {
            bytesArray[i] = _bytes32[i];
        }
        return string(bytesArray);
    }
    event Log(uint256 indexed _a, bytes32 _log, address _adr, uint256 _tmstmp); 
    event Req(uint256 indexed _c, address _con, address _adm, uint256 _tmstmp); 
    struct RentalContracts 
    {
        uint256 id;
        address admin;
        address con;
        bytes32 title;
        uint256 copies;
        uint256 mon;
        uint256 roy;
        address conAdr;
    }
    struct Request
    {
        uint256 id;
        address admin;
        address con;
        bytes32 name;
        uint256 state;
        
    }
    mapping(address => mapping(uint256 => address)) internal consByUser;
    mapping(address => uint256) internal userCons;
    mapping(address => bool) internal isCon;
    mapping(uint256 => uint256) reqRes; // 0 = NULL, 1 = Pending, 2 = Approved, 3 = Declined
    mapping(address => uint256) conId;
    modifier isAdmin(address _adr)
    {
        require(_adr == v.admin0 || _adr == v.admin1);
        require(msg.sender == v.admin0  || msg.sender == v.admin1);
        _;
    }
    RentSafe public rentSafe;
}
library v {
    
    address internal constant admin0 = 0x823230d6458Cba58FFB8cb4D88Ba4DaCbF2C7263;
    address internal constant admin1 = 0x5fA621cf6B13640F882992373b1E86F6901dC8A5;
    uint256 internal constant digits = 10 ** 18;
       
}

contract deRental is m{
 
    
    using v for *;
    uint256 internal cons;
    uint256 internal logCount;
    uint256 internal requestCount;
    RentalContracts[] public rentals;
    Request[] internal requests;
    

    constructor() {

    }
    function createRentalContract(address _contract, bytes32 _title, uint256 copies, uint256 mon_fees, uint256 roy_fees) public payable returns(bool)
    {
        require(msg.value == 2 * v.digits);
        require(!isCon[_contract]);
        // require security token for specific contract
        string memory titler = bytes32ToString(_title);
        rentSafe = new RentSafe(_contract,titler,copies,mon_fees,roy_fees);
        address conAdr = address(rentSafe);
        rentals[cons] = RentalContracts(cons,msg.sender,_contract,_title,copies,mon_fees,roy_fees,conAdr);
        consByUser[msg.sender][userCons[msg.sender]] = _contract;
        userCons[msg.sender] += 1;
        cons += 1;
        emit Log(logCount, "created by", msg.sender, block.timestamp);
        logCount += 1;
        emit Log(logCount, "contract address", conAdr, block.timestamp);
        logCount += 1;
        return true;
    }
    function requestToken(bytes32 _name, address _contract, address _admin) public returns(bool) // security mechanism to prevent not project owners creating rentals
    {
        require(!isCon[_contract]); 
        reqRes[requestCount] = 1; 
        requests[requestCount] = Request(requestCount,_admin,_contract,_name,reqRes[requestCount]);
        emit Req(requestCount, _contract, msg.sender,block.timestamp);
        requestCount += 1;
        emit Log(logCount, "token requested", msg.sender, block.timestamp);
        logCount += 1;
        return true;
    }
    function submitToken(uint256 _req) isAdmin(msg.sender) public returns(bool)
    {
        require(reqRes[_req] == 1);
        reqRes[_req] = 2;
        requests[_req].state = 2;
        emit Log(logCount, "token submitted", msg.sender, block.timestamp);
        logCount += 1;
        return true;
    }

}
