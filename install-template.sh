#!/bin/bash

# Install the template locally
echo "Installing the MVC API Logging template locally..."
dotnet new uninstall MvcApiLoggingTemplate
dotnet new install $(dirname "$0")

echo "Template installed successfully!"
echo "You can now create a new project using:"
echo "dotnet new mvcapilog -n YourProjectName" 