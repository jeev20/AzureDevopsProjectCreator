# AzureDevopsProjectCreator
This scripts creates a Azure DevOps project with required objects within the project.

Usage command : ```powershell .\AzureDevopsProjectCreator.ps1 -ProjectName "TestProject" -Description "This is a test project" -PAT "YOURPATSTRING" -organization "https://dev.azure.com/ORGANIZATION" ```

Read more about this in the UiPath Forum.

```mermaid height=559,auto
graph LR
    subgraph Initialize
        direction TB
        B[Set Arguments]
        C[Set Environment Variables]
        B --> C

        C --> E[Configure Azure CLI \n Auto download modules]
    end

    subgraph CreateProject_Function
        direction TB
        
        F[Set Default Configuration]
        G[Login to Azure DevOps]
        H[Create Project]
        I[Create Variable Group]
        J[Create Repositories]
        K[Create Build Pipelines]
        L[Set Pipeline Variables]
        M[Delete Orphan Repository]
        F --> G --> H --> I --> J --> K --> L --> M
    end

    subgraph Invoke
        direction TB
        T[CreateProject_Function]
    end

    Initialize --> CreateProject_Function
    CreateProject_Function --> Invoke
```
