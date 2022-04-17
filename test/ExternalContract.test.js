const { IsoTwoTone } = require('@material-ui/icons');
const { expect } = require('chai');
const { ethers } = require('hardhat');

describe('Msg Value Library Test', async () => {
  before(async () => {
    // Deploying our library
    MsgValueLibraryFactory = await ethers.getContractFactory(
      'MsgValueToDecimalString'
    );
    LibraryInstance = await MsgValueLibraryFactory.deploy();
    [owner, addr1] = await ethers.getSigners();
    await LibraryInstance.deployed();
    console.log(
      'MsgValueToStr Library deployed to: ' + LibraryInstance.address
    );

    // Deploying our test contract
    ContractFactory = await ethers.getContractFactory(
      'ExternalContractExample',
      {
        libraries: {
          MsgValueToDecimalString: LibraryInstance.address,
        },
      }
    );
    ContractInstance = await ContractFactory.deploy();
    [owner, addr1] = await ethers.getSigners();
    await ContractInstance.deployed();
    ContractInstance.connect(owner);
    console.log('Contract deployed to: ' + ContractInstance.address);
  });

  // Testing out various values to make sure string is returned correctly
  it('Correctly calls the msgValueToString() function', async () => {
    let test = await ContractInstance.parseETHAmount({
      value: ethers.utils.parseEther('1.0'),
    });
    await test.wait();
    let strTest = await ContractInstance.getDecimalStr();
    expect(strTest).to.equal('1.0 ETH');

    test = await ContractInstance.parseETHAmount({
      value: ethers.utils.parseEther('0.01'),
    });
    strTest = await ContractInstance.getDecimalStr();
    expect(strTest).to.equal('0.01 ETH');

    test = await ContractInstance.parseETHAmount({
      value: ethers.utils.parseEther('12.87'),
    });
    strTest = await ContractInstance.getDecimalStr();
    expect(strTest).to.equal('12.87 ETH');

    test = await ContractInstance.parseETHAmount({
      value: ethers.utils.parseEther('0'),
    });
    expect(test).to.be.reverted;
  });
});
