pragma solidity ^0.7.0;


contract ATC {
    enum State { AWAITING_PAYMENT, FUNDS_ADDED, FAILED, SUCCESS, EXPIRED, COMPLETE }
    State public currState;
    address payable public customer;
    address payable public procurer;
    uint public price;
    string public product;
    // uint public bank = address(this).balance;
    
    constructor(string memory _product, uint _price) {
        procurer = msg.sender;
        price = _price;
        product = _product;
        currState = State.AWAITING_PAYMENT;
    }
    
      
    modifier onlyCustomer() {
        require(msg.sender == customer, "Only the customer can call this method");
        _;
    }
    
     modifier onlyProcurer() {
        require(msg.sender == procurer, "Only the procurer can call this method");
        _;
    }
    
    
    
    function deposit() public payable {
        require(currState == State.AWAITING_PAYMENT, "Already Paid!");
        require(msg.value == price, "Please send the exact price");
        customer = msg.sender;
        currState = State.FUNDS_ADDED;
    }
    
    function markSuccessful() public onlyProcurer {
        require(currState == State.FUNDS_ADDED, "Not paid yet");
        payable(procurer).transfer(address(this).balance);
        // procurer.transfer(address(this).balance);
        currState = State.SUCCESS;
    }
    
    function markUnsuccessful() public onlyProcurer {
        require(currState == State.FUNDS_ADDED, "Not paid yet");
        payable(customer).transfer(address(this).balance);
        currState = State.FAILED;
    }
    
    function getContractBank() public onlyProcurer returns(uint) {
        return(address(this).balance);
    }


    function getProductDetails() public returns(uint, string memory) {
        return(price, product);
    }
}