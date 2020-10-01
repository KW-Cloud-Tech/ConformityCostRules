#!/bin/bash
# A simple script to get cost rule data from Cloud Conformity

echo "Which region is your conformity environment hosted in?"
read -r region

echo "Enter your api key: "
read -r apikey

# select which Conformity accounts to run against
if [ "$#" -eq  "0" ]
then
    echo "No accountid arguments specified, generating report across all accounts loaded in conformity"
    export accountid=(`curl -L -X GET \
        "https://$region-api.cloudconformity.com/v1/accounts" \
        -H "Content-Type: application/vnd.api+json" \
        -H "Authorization: ApiKey $apikey" \
        | jq -r '.data | map(.id) | join(",")'`)
	echo "Will generate report for the following accounts $accountid"
else #run against only specified accountids in argument
    export accountid=$1
	echo "Generating cost report for account $1"
fi

# print a list of accounts and their AWS account numbers
curl -L -X GET \
        "https://$region-api.cloudconformity.com/v1/accounts" \
        -H "Content-Type: application/vnd.api+json" \
        -H "Authorization: ApiKey $apikey" \
	| jq -r '.data[] | {"Conformity-ID" : .id, "AWSAccount" : .attributes | .["awsaccount-id"]} | keys_unsorted, map(.) | @csv' | awk 'NR==1 || NR%2==0'  >> AWS_AccountMapping.csv

# run the csv script based on selection and for each account
TIMESTAMP=`date +%Y-%m-%d_%H.%M.%S`
	curl -L -X GET \
		"https://$region-api.cloudconformity.com/v1/checks?accountIds=$accountid&page[size]=1000&filter[statuses]=FAILURE&filter[categories]=cost-optimisation" \
		-H "Content-Type: application/vnd.api+json" \
		-H "Authorization: ApiKey $apikey" \
		| jq -r '.data[] | select (.attributes.cost > 0 or .attributes.waste > 0) | {"account": .relationships.account.data.id, "resource": .attributes.resource, "rule": .relationships.rule.data.id, "message": .attributes.message, "cost": .attributes.cost, "waste": .attributes.waste } | keys_unsorted, map(.) | @csv' | awk 'NR==1 || NR%2==0'  >> CostRules_$TIMESTAMP.csv
