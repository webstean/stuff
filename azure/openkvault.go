package main

import (
    "context"
    "os"
    "fmt"
    "log"
    "os"
    "github.com/Azure/azure-sdk-for-go/profiles/latest/keyvault/keyvault"
    "github.com/Azure/go-autorest/autorest/azure/auth"
)

func doesEnvVariableExist(key string) bool {
    if _, ok := os.LookupEnv(key); ok {
        return true
    }
    return false
}

func azure_manage_identity() bool {
 
  // Create a new context
  ctx := context.Background()

  // Create a new managed identity credential
  cred, err := auth.NewManagedIdentityCredential("")
  if err != nil {
    fmt.Println("Failed to create a new managed identity credential:", err)
    return false
  }
  // managed identity
  return true
}

func main() {

    // Get environment
    vaultName := os.Getenv("KEY_VAULT_NAME")
    secretName := os.Getenv("SECRET_NAME")
    secretVersion := os.Getenv("SECRET_VERSION")

    authorizer, err := auth.NewAuthorizerFromEnvironment()
    if err != nil {
        log.Fatalf("failed to get authorizer: %v", err)
    }

    client := keyvault.New()
    client.Authorizer = authorizer

    secret, err := client.GetSecret(context.Background(), fmt.Sprintf("https://%s.vault.azure.net", vaultName), secretName, secretVersion)
    if err != nil {
        log.Fatalf("failed to get secret: %v", err)
    }

    fmt.Printf("secret value: %s\n", *secret.Value)
}
