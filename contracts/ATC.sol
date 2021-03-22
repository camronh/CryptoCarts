pragma solidity ^0.7.0;



contract ATC {
    string public title;
    uint public price;
    address payable public procurer;
    enum State { OPEN, CLOSED }
    State public currState;
    DealStruct[] public deals; 
    
    
    struct DealStruct {
        address customer;
        string status;
        bool paid;
    }
    DealStruct dealStruct;
    
       
    modifier onlyCustomer() {
        require(msg.sender != procurer, "Only the customer can call this method");
        _;
    }
    
     modifier onlyProcurer() {
        require(msg.sender == procurer, "Only the procurer can call this method");
        _;
    }
    
    
    
    constructor (string memory _title, uint _price){
        title = _title;
        procurer = msg.sender;
        price = _price * 1000000000000000000;
        currState = State.OPEN;
    }
    
    
    function createDeal () public payable onlyCustomer returns(uint){
        require(currState == State.OPEN, "Auction Closed");
        require(msg.value == price, "Please pay the exact amount");
        // set the new instance
        dealStruct = DealStruct(msg.sender, "Pending", false);
        // push the auction address to auctions array
        deals.push(dealStruct);
        return(deals.length);
    }
    
     function markSuccessful(uint dealIndex) public onlyProcurer {
        require(deals[dealIndex].paid == false, "Already Paid out!!");
        deals[dealIndex].status = "Success!";
        
        // TRANFERS WHOLLE BANK
        
        payable(procurer).transfer(price);
        deals[dealIndex].paid = true;
        // procurer.transfer(address(this).balance);
        // currState = State.SUCCESS;
        
    }
    
    function markUnsuccessful(uint dealIndex) public onlyProcurer {
        require(deals[dealIndex].paid == false, "Already Paid out!!");
        deals[dealIndex].status = "Failed";
        payable(deals[dealIndex].customer).transfer(price);
        deals[dealIndex].paid = true;
    }
    
    function closeDrop() public onlyProcurer {
        require(currState == State.OPEN, "Drop already closed");
        currState = State.CLOSED;
    }
    
    function getBank() public onlyProcurer returns(uint) {
        return(deals.length * price);
    }
    
   
}
