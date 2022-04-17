const hre = require('hardhat');

async function main() {
  const ContractFactory = await hre.ethers.getContractFactory(
    'MsgValueToDecimalString'
  );
  const MsgValueLibrary = await ContractFactory.deploy();

  await MsgValueLibrary.deployed();

  console.log('Deployed to:', MsgValueLibrary.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
