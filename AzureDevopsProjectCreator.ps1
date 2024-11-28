param(
    [Parameter(Mandatory=$true)]
    [string]$ProjectName,

    [Parameter(Mandatory=$true)]
    [string]$Description,

    [Parameter(Mandatory=$true)]
    [string]$PAT,

    [Parameter(Mandatory=$true)]
    [string]$Organization
)

$env:AZURE_DEVOPS_EXT_PAT = $PAT
$ErrorActionPreference = 'SilentlyContinue'

# Configuration
az config set extension.use_dynamic_install=yes_without_prompt  


function CreateProject{
    # Set Default Configuration
    az devops configure -d organization="https://dev.azure.com/YourOrganization"
    az devops configure -d project=$ProjectName

    # Login to Azure DevOps
    Write-Output $env:AZURE_DEVOPS_EXT_PAT | az devops login 

    # Create Project
    az devops project create --name $ProjectName  --description $Description --process Basic --source-control  git --output table

    # Creating group library variables 
    az pipelines variable-group create --name BackupLocations  --variables RPA-Robot-Dev="PATHTOFOLDER" RPA-Robot-Prod="PATHTOFOLDER"

    # Creating repos within the project
    az repos create --name "Dispatcher" 
    az repos create --name "Performer" 
    az repos create --name "Utils" 

    # Creating Build Pipelines within the project - path can be specified accordingly
    az pipelines create --name "CI-Dispatcher" --description 'CI Pipeline for Dispatcher' --repository "Dispatcher" --branch main  --repository-type tfsgit --yml-path "AzureDevOpsPipelines/CI_Dispatcher.yml" --skip-first-run
    az pipelines create --name "CI-Performer" --description 'CI Pipeline for Performer' --repository "Performer" --branch main  --repository-type tfsgit --yml-path "AzureDevOpsPipelines/CI_Performer.yml" --skip-first-run

    # Creating Build Pipelines variables 
    az pipelines variable create --name ProjectBuildNumber --pipeline-name "CI-Dispatcher" --value "$[counter('', 1)]"
    az pipelines variable create --name ProjectBuildNumber --pipeline-name "CI-Performer" --value "$[counter('', 1)]"

    # Delete Orphan Repository
    $reposlist = az repos list | ConvertFrom-Json

    # Find the orphan repo
    foreach ($repo in $reposlist)
    {
    if ($repo.name -eq $ProjectName)
    {
        Write-Host "Deleting unwanted orphan repository"
        az repos delete --id $repo.id  --yes   # Delete the default repo and confirm
    }
    }
}

CreateProject