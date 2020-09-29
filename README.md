# ConformityCostRules

A script to pull cost rule data from Conformity

## Usage

`$ ./CostRuleData <accountIDArgument>`

If left blank, the script will pull results for all your accounts. You can also list multiple specifc accounts.
eg:

`$ ./CostRuleData`

`$ ./CostRuleData acbds2347,sdlccn287`
  
You will be asked to enter the AWS region your Conformity instance is hosted in, eg:
us-west-2

You also enter the API key for your Conformity user.

The output is a csv file.

## Credit
Tom Ryan for helping test and edit
