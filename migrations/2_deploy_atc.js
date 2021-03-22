const ATC = artifacts.require("ATC");

module.exports = function(deployer) {
  deployer.deploy(ATC, "PS5", 1);
};
