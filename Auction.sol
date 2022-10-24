//SPDX-License-Identifier: UNLICENSE
pragma solidity >=0.8.7 <0.9.0;

contract Draco {

    struct Auction{
        uint id;
        address payable seller;
        string name;
        string description;
        uint min;
        uint bestOfferId;
        uint[] offerIds;
    }

    struct Offer{
        uint id;
        uint auctionId;
        address payable buyer;
        uint price;
    }

mapping(uint => Auction) public auctions;
mapping(uint => Offer) private offers;
mapping(address => uint[]) private auctionList;
mapping(address => uint[]) private offerList;

uint private newAuctionId = 1;
uint private newOfferId = 1;


//How to create Auction
function createAuction(string calldata _name, string calldata _description, uint _min) external{
//calldata: not its all fixed we can not change it and its cost efficient 

    require(_min>0,"Minimum must be greater than 0");
    uint[] memory offerIds = new uint[](0);

    auctions[newAuctionId] = Auction(newAuctionId, payable(msg.sender),_name,_description,_min,0,offerIds);
    auctionList[msg.sender].push(newAuctionId);
    newAuctionId++;
} 


//How to create a offer to any auction
function createOffer(uint _auctionId) external payable auctionExists(_auctionId){
    Auction storage auction = auctions[_auctionId];
    Offer storage bestOffer = offers[auction.bestOfferId];

    require(msg.value>=auction.min && msg.value>bestOffer.price, "msg.value must be greater than the min and the best offer");
    auction.bestOfferId = newOfferId;
    auction.offerIds.push(newOfferId);
    
    offers[newOfferId] = Offer(newOfferId,_auctionId,payable(msg.sender),msg.value);
    offerList[msg.sender].push(newOfferId);
    newOfferId++;
}

//Transcation
function Transcation(uint _auctionId) external auctionExists(_auctionId){
    Auction storage auction = auctions[_auctionId];
    Offer storage bestOffer = offers[auction.bestOfferId];

    for(uint i=0;i<auction.offerIds.length;i++){
        uint offerId = auction.offerIds[i];

        if(offerId!=auction.bestOfferId){
            Offer storage offer = offers[offerId];
            offer.buyer.transfer(offer.price);
        }
    }
    auction.seller.transfer(bestOffer.price);
}

//View all the auctions
function getAuctions() external view returns(Auction[] memory) {
    Auction[] memory _auctions = new Auction[](newAuctionId-1);

    for(uint i=1;i<newAuctionId;i++){
        _auctions[i-1]=auctions[i];
    }

    return _auctions;
}

//How many auctions made by an user
function getUserAuctions(address _user) external view returns(Auction[] memory){
    uint [] storage userAuctionsIds = auctionList[_user];
    Auction[] memory _auctions = new Auction[](userAuctionsIds.length);

    for(uint i=0;i<userAuctionsIds.length;i++){
        uint auctionId = userAuctionsIds[i];
        _auctions[i] = auctions[auctionId];
    }

    return _auctions;
}

//How many offers were made
function getUserOffers(address _user) external view returns(Offer[] memory){
    uint[] storage userOfferIds = offerList[_user];
    Offer[] memory _offers = new Offer[](userOfferIds.length);

    for(uint i=0;i<userOfferIds.length;i++){
        uint offerId = userOfferIds[i];
        _offers[i] = offers[offerId];
    }

    return _offers;
}

//Auction Existance
modifier auctionExists(uint _auctionId){
    require(_auctionId>0 && _auctionId<newAuctionId, "Auction does not exist");
    _;
}

}
