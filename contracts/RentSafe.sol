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

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
// import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";



contract RentSafe is ERC1155 {

    address internal admin;
    uint256 public mon;
    uint256 public roy;
    uint256 public copies;

    struct Stake {
        uint256 id;
        address owner;
        address contrAdr;
        uint256 tid;
        bool vacant;
    }
    
    struct Offer{
        uint256 oid;
        address contrAdr; 
        uint256 id; 
        string title; 
        uint256 dayz;
        uint256 price;
        bool free;
    }
    struct Rental{
        uint256 rid;
        uint256 oid;
        address contrAdr; 
        uint256 id; 
        string title; 
        uint256 odate;
        uint256 xdate;
        uint256 price;
    }

    
    Offer[] public offers;
    uint256 internal o;
    Rental[] public rentals;
    uint256 internal r;
    Stake[] public stakes;
    uint256 s;
    mapping(address => mapping(address => mapping(uint256 => bool))) public staked;
    mapping(address => mapping(address => mapping(uint256 => uint256))) public stakerId;
    mapping(address => mapping(uint256 => uint256)) public offerId;
    mapping(address => mapping(uint256 => uint256)) public idByConId;
    mapping(uint256 => address) public userByoffer;
    mapping(address => uint256) public offerCount;
    mapping(uint256 => uint256) public rentalByoffer;
    mapping(address => uint256) public rentalCount;
    IERC721 public Token ;
    
    constructor(address _contract, string memory _title, uint256 _copies, uint256 mon_fees, uint256 roy_fees) ERC1155(_title) 
    {
        admin = msg.sender;
        mon = mon_fees;
        roy = roy_fees;
        copies = _copies;
        Token = IERC721(_contract);
        _setURI(_title);
    }
    
    function stake(address _contract,uint256 _id) public payable returns(bool){
        require(Token.ownerOf(_id) == msg.sender);
        Token.transferFrom(msg.sender,address(this),_id);
        staked[msg.sender][_contract][_id] = true;
        stakes.push(Stake(s,msg.sender,_contract,_id,false));
        idByConId[_contract][_id] = s;
        stakerId[msg.sender][_contract][_id] = s;
        s += 1;
        return true;
    } 
    function unstake(address _contract,uint256 _id) public payable returns(bool){
        require(staked[msg.sender][_contract][_id] == true);
        require(stakes[idByConId[_contract][_id]].vacant == false);
        staked[msg.sender][_contract][_id] = false;
        Token.transferFrom(address(this),payable(msg.sender),_id);
        return true;
    }
    function make_rentoffer(address _contract, uint256 _id, string memory _title, uint256 _days, uint256 _price) public payable returns(bool)
    {
        require(staked[msg.sender][_contract][_id] == true);
        require(stakes[idByConId[_contract][_id]].vacant == false);
        offers.push(Offer(r, _contract, _id, _title, _days, _price, true));
        userByoffer[o] = msg.sender;
        offerCount[msg.sender] += 1;
        offerId[_contract][_id] = o;
        o += 1;
        return true;
    }
    function pay_rentoffer(address _contract, uint256 _id, string memory _title, uint256 _odate, uint256 _xdate) public payable returns(bool)
    {
        require(staked[userByoffer[offerId[_contract][_id]]][_contract][_id] == true);
        require(stakes[idByConId[_contract][_id]].vacant == false);
        require(msg.value >= offers[offerId[_contract][_id]].price);
        stakes[idByConId[_contract][_id]].vacant = true;
        offers[offerId[_contract][_id]].free = false;
        rentals.push(Rental(r,offerId[_contract][_id],_contract,_id,_title,_odate,_xdate,offers[offerId[_contract][_id]].price));
        _mint(msg.sender, offerId[_contract][_id],1, "STC");
        r += 1;
        return true;
    }
    function return_offer(address _contract, uint256 _id) public payable returns(bool)
    {
        require(staked[userByoffer[offerId[_contract][_id]]][_contract][_id] == true);
        require(stakes[idByConId[_contract][_id]].vacant == true);
        stakes[idByConId[_contract][_id]].vacant = false;
        offers[offerId[_contract][_id]].free = true;
        _burn(msg.sender, offerId[_contract][_id],1);
        r += 1;
        return true;
    }

}
