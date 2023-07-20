# Foundry Fund Me

FundMe is a sample Smart Contract for crowd funding app.

## Requirements
  * [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
    * run `git --version` to check whether it's installed or not.
  * [Foundry](https://book.getfoundry.sh/getting-started/installation)
    * run `forge --version` to check whether it's installed or not.

## Quickstart

```bash
git clone https://github.com/kritarthpaliwal/foundry-fund-me.git
cd FoundryFundMe
forge build
```
## Usage

Deploy:

```
forge script scripts/DeployFundMe.s.sol
```
## Testing
```
forge test
```

or 

```
// Only run test functions matching the specified regex pattern.

forge test --match-test testFunctionName
```

or

```
forge test --fork-url $SEPOLIA_RPC_URL
```

## Gratitude
Special Thanks to [Patrick Collins](https://twitter.com/PatrickAlphaC) for his very helpful [course](https://www.youtube.com/watch?v=umepbfKp5rI&ab_channel=PatrickCollins) for Block Chain Development on YouTube


## License

[MIT](https://choosealicense.com/licenses/mit/)
