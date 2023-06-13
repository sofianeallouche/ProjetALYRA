    //on importe la librairie ethers
    const {ethers} = require('hardhat');
   
   //On importe les methodes expect et assert de la librairie chai
    const{expect, assert}=require('chai');
    
    describe("test voting",function(){
        // la variable qui contenir le  contract deployer 
        let deployedContract;
        // Avant chaque test on fera ce qui se suit
        beforeEach(async function(){
            // On recuepre les defferents address
            [this.owner,this.addr1, this.addr2]=await ethers.getSigners();
            //on recupere le contract 
            let contract = await ethers.getContractFactory("voting");
            // on affecte le contract deployé a la variable deployedContract declaree auparavant
            deployedContract =  await contract.deploy();
        })
    });
