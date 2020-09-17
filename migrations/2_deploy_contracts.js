const TestERC20 = artifacts.require('TestERC20');

module.exports = async (deployer, network, accounts) => {
    await deployer.deploy(TestERC20);
}
