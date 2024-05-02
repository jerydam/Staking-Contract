import { ethers } from "hardhat";
async function main() {
    // We get the contract to deploy
    const Staker = await ethers.deployContract("Staker");
    await Staker.waitForDeployment();
    console.log("Deploying Staker...");
    await Staker.deployed();
    console.log(  
        `Contribution System Factory was deployed to ${Staker.target}`
      );
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
    

    