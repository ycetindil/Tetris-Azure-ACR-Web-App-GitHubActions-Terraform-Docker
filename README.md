# Tetris Application Deployed on Azure Web App Using GitHub Actions

This project sets up a CI/CD pipeline using GitHub Actions to deploy infrastructure using Terraform and deploy Tetris Application to that infrastructure.

## Setting Credentials

Terraform needs Azure Credentials to create the infrastructure. We need to provide these values in environment for Terraform to look up.
- ARM_SUBSCRIPTION_ID
- ARM_TENANT_ID
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET

To get these credentials we use this command in a terminal;
```
az ad sp create-for-rbac --sdk-auth --role="Contributor" --scopes="/subscriptions/<subscription_id>"
```

Terraform also needs GitHub Token to create the variables in GitHub repository. We provide the token securely by defining it in the GitHub Actions secrets as `GH_TOKEN`. We assign this value in the pipeline environment section to `GITHUB_TOKEN` with:
```
GITHUB_TOKEN: ${{ secrets.GH_TOKEN }}
```

`az login` uses `AZURE_CREDENTIALS` which is also defined as a repo secret.

## Notes

- Since GitHub Actions Pipeline uses an ephemeral agent we need to define a backend to keep our `terraform.tfstate`.
- To use later in the pipeline we define multiple `github_actions_variable`s.
- Since we have our Terraform configuration files in a dedicated folder, we need to define this path in the job environment for the steps which need to access to this folder to run.
- Web app needs credentials to access to the ACR.We configure the web app with the below code:
```
    - name: 'Set private registry authentication settings'
      run: az webapp config container set --name ${{ vars.WEB_APP_NAME }} --resource-group ${{ vars.RG_NAME }} --docker-registry-server-user ${{ vars.ACR_NAME }} --docker-registry-server-password ${{ secrets.ACR_PASSWORD }}
```