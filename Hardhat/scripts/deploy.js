async function main() {
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const Exosphere = await ethers.getContractFactory("Exosphere");
  const exosphere = await Exosphere.deploy();

  console.log("Exoshpere address:", exosphere.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

// Exoshpere address: 0x6399019b9F79D340CE593EF6006B627CDB3808DD
