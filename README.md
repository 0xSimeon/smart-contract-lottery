# Proveably Random Raffle contracts 

# About 

This code is to create a proveably random smart contract lottery. 

# What does the project do?

1. Users can enter by paying for a ticket. 
   - The ticket fees are going to go to the winner during the draw. 
2. After X period of time (passed as param during deployment.), the lottery will automatically draw a winner.
   - This will be done programmatically. 
3. Using Chainlink VRF & Chainlink Automation
    - Chainlink VRF -> Randomness
    - Chainlink Automation -> Time-based Trigger. 

## Chores
1. Write deploy scripts. 
2. Write a helperConfig to set the configuration per chain. 
3. Write our tests.
      - Work on a local chain. 
      - Forked Testnet. 
      - Forked Mainnet.