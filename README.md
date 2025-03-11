# MVC and API with Serilog Logging Template

A template for creating an ASP.NET Core MVC website with a separate WebAPI, both configured with Serilog logging and method timing capabilities.

## Features

- ASP.NET Core MVC website
- Separate ASP.NET Core WebAPI
- Serilog logging with file and console sinks
- Method timing with configuration toggle
- Structured logging with enrichers (Machine Name, Thread ID, Process ID)
- Clean separation of concerns

## Prerequisites

- .NET SDK (7.0, 8.0, or 9.0)
- Visual Studio, VS Code, or another .NET-compatible IDE

## Installation

To install this template:

```bash
dotnet new install /path/to/template/directory
```

## Usage

To create a new project using this template:

```bash
dotnet new mvcapilog -n YourProjectName
```

### Options

- `-f|--Framework`: Target framework (net7.0, net8.0, net9.0)

Example:
```bash
dotnet new mvcapilog -n YourProjectName -f net8.0
```

## Project Structure

```
YourProjectName/
├── YourProjectName.API/           # WebAPI project
│   ├── Controllers/               # API controllers
│   ├── Logging/                   # Logging utilities
│   └── Logs/                      # Log files directory
├── YourProjectName.Web/           # MVC website project
│   ├── Controllers/               # MVC controllers
│   ├── Models/                    # View models
│   ├── Views/                     # Razor views
│   ├── Services/                  # Services for API communication
│   ├── Logging/                   # Logging utilities
│   └── Logs/                      # Log files directory
└── YourProjectName.sln            # Solution file
```

## Configuration

### Method Timing

Method timing can be enabled/disabled in the appsettings.json files:

```json
"MethodTiming": {
  "IsMethodTimingEnabled": true
}
```

### Logging

Logging is configured in the appsettings.json files:

```json
"Serilog": {
  "MinimumLevel": {
    "Default": "Debug",
    "Override": {
      "Microsoft": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "WriteTo": [
    {
      "Name": "Console"
    },
    {
      "Name": "File",
      "Args": {
        "path": "Logs/log-.log",
        "rollingInterval": "Day"
      }
    }
  ],
  "Enrich": [ "FromLogContext", "WithMachineName", "WithThreadId", "WithProcessId" ]
}
```

## Running the Application

1. Start the API:
```bash
cd YourProjectName.API
dotnet run
```

2. Start the Web application:
```bash
cd YourProjectName.Web
dotnet run
```

3. Access the web application at https://localhost:5001

## License

[MIT](LICENSE) 