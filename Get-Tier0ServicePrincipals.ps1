# Set your app registration details
$tenantId = "838f6c73-507b-4674-b621-d8dd0009208d"
$appId = "89a0d0d0-4f6a-4a94-a935-7c22106b6800"
$appSecret = ""
$scope = "https://graph.microsoft.com/.default"

# Token endpoint
$tokenUrl = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"

# Prepare the token request body
$body = @{
    client_id     = $appId
    scope         = $scope
    client_secret = $appSecret
    grant_type    = "client_credentials"
}

# Get the access token
$tokenResponse = Invoke-RestMethod -Method Post -Uri $tokenUrl -ContentType "application/x-www-form-urlencoded" -Body $body
$accessToken = $tokenResponse.access_token

# Set the header with the access token
$headers = @{
    Authorization = "Bearer $accessToken"
}

# Now you can make API requests with the access token
# Example: Get service principals
$servicePrincipalsUrl = "https://graph.microsoft.com/v1.0/servicePrincipals"
$servicePrincipalsResponse = Invoke-RestMethod -Uri $servicePrincipalsUrl -Headers $headers -Method Get
$servicePrincipals = $servicePrincipalsResponse.value

# Output the service principals
$servicePrincipals

# Define the role assignment GUIDs and their corresponding names
$roleAssignments = @{
    "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9" = "Application.ReadWrite.All"
    "06b708a9-e830-4db3-a914-8e69da51d44f" = "AppRoleAssignment.ReadWrite.All"
    "19dbc75e-c2e2-444c-a770-ec69d8559fc7" = "Directory.ReadWrite.All"
    "62a82d76-70ea-41e2-9197-370581804d09" = "Group.ReadWrite.All"
    "dbaae8cf-10b5-4b86-a4a1-f871c94c6695" = "GroupMember.ReadWrite.All"
    "9e3f62cf-ca93-4989-b6ce-bf83c28f9fe8" = "RoleManagement.ReadWrite.Directory"
    "89c8469c-83ad-45f7-8ff2-6e3d4285709e" = "ServicePrincipalEndpoint.ReadWrite.All"
}

# Set the header with the access token
$headers = @{
    Authorization = "Bearer $accessToken"
}

# Specify the output file path
#$outputFilePath = "/home/dan/"

# Ensure the file is empty before starting
#if (Test-Path $outputFilePath) {
#    Clear-Content $outputFilePath
#}

foreach ($roleAssignment in $roleAssignments.Keys) {
    $escapedFilter = [System.Uri]::EscapeDataString("appRoleAssignments/any(x:x/id eq '$roleAssignment')")
    $servicePrincipalsUrl = "https://graph.microsoft.com/v1.0/servicePrincipals?$escapedFilter"
    $servicePrincipalsResponse = Invoke-RestMethod -Uri $servicePrincipalsUrl -Headers $headers -Method Get
    $servicePrincipals = $servicePrincipalsResponse.value

    foreach ($sp in $servicePrincipals) {
        $output = "Service Principal ID: $($sp.id)`r`n"
        $output += "Service Principal Name: $($sp.displayName)`r`n"
        $output += "App Role Assignments:`r`n"

        $appRoleAssignmentsUrl = "https://graph.microsoft.com/v1.0/servicePrincipals/$($sp.id)/appRoleAssignedTo"
        $appRoleAssignmentsResponse = Invoke-RestMethod -Uri $appRoleAssignmentsUrl -Headers $headers -Method Get
        $appRoleAssignments = $appRoleAssignmentsResponse.value

        foreach ($appRoleAssignment in $appRoleAssignments) {
            if ($roleAssignments.ContainsKey($appRoleAssignment.appRoleId)) {
                $roleName = $roleAssignments[$appRoleAssignment.appRoleId]
                $output += "`tRole ID: $($appRoleAssignment.appRoleId)`r`n"
                $output += "`tRole Name: $roleName`r`n"
                $output += "`tResource ID: $($appRoleAssignment.resourceId)`r`n"
                $output += "`tPrincipal ID: $($appRoleAssignment.principalId)`r`n"
            }
        }
        $output += "`r`n"

        # Write the output to the file
        Add-Content -Path "/home/dan/output.txt" -Value $output
    }
}

# Inform the user that the script has completed and the output file is ready
Write-Host "Script completed. Check the output file."