// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LearningResourceMarketplace {
    // Structure to define a resource
    struct Resource {
        uint id;
        string title;
        string description;
        address payable seller;
        uint price;
        bool purchased;
    }

    // State variables
    uint public resourceCount = 0;
    mapping(uint => Resource) public resources;

    // Event to be emitted when a resource is created
    event ResourceCreated(
        uint id,
        string title,
        string description,
        address payable seller,
        uint price,
        bool purchased
    );

    // Event to be emitted when a resource is purchased
    event ResourcePurchased(
        uint id,
        string title,
        string description,
        address payable seller,
        address payable buyer,
        uint price,
        bool purchased
    );

    // Function to create a new resource
    function createResource(string memory _title, string memory _description, uint _price) public {
        // Require a valid title and description
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_description).length > 0, "Description cannot be empty");
        // Require a valid price
        require(_price > 0, "Price must be greater than zero");

        // Increment resource count
        resourceCount++;

        // Create the resource
        resources[resourceCount] = Resource(resourceCount, _title, _description, payable(msg.sender), _price, false);

        // Emit the event
        emit ResourceCreated(resourceCount, _title, _description, payable(msg.sender), _price, false);
    }

    // Function to purchase a resource
    function purchaseResource(uint _id) public payable {
        // Fetch the resource
        Resource memory _resource = resources[_id];
        // Fetch the seller
        address payable _seller = _resource.seller;

        // Make sure the resource is valid
        require(_resource.id > 0 && _resource.id <= resourceCount, "Resource does not exist");
        // Require that the correct amount is sent
        require(msg.value >= _resource.price, "Not enough Ether provided");
        // Require that the resource has not been purchased already
        require(!_resource.purchased, "Resource has already been purchased");
        // Require that the buyer is not the seller
        require(_seller != msg.sender, "Cannot purchase your own resource");

        // Transfer ownership to the buyer
        _resource.seller = payable(msg.sender);
        _resource.purchased = true;

        // Update the resource
        resources[_id] = _resource;

        // Pay the seller by sending them Ether
        _seller.transfer(msg.value);

        // Emit the event
        emit ResourcePurchased(_id, _resource.title, _resource.description, _seller, payable(msg.sender), _resource.price, true);
    }
}
