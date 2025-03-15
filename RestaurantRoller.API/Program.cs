using Serilog;
using Microsoft.OpenApi.Models;
using Microsoft.EntityFrameworkCore;
using RestaurantRoller.API.Data;
using MySqlConnector;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog from appsettings.json
builder.Host.UseSerilog((context, services, configuration) => configuration
    .ReadFrom.Configuration(context.Configuration)
    .ReadFrom.Services(services));

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c => 
{ 
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "RestaurantRoller API", Version = "v1" }); 
});

// Configure MySQL database
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
if (string.IsNullOrEmpty(connectionString))
{
    Log.Warning("Database connection string is missing or empty. Database features will not be available.");
}
else
{
    // Add DbContext
    builder.Services.AddDbContext<RestaurantDbContext>(options =>
        options.UseMySql(connectionString, ServerVersion.AutoDetect(connectionString)));

    // Register repository
    builder.Services.AddScoped<RestaurantRepository>();

    // Create database if it doesn't exist
    try
    {
        Log.Information("Attempting to create database if it doesn't exist...");
        var connection = new MySqlConnection(connectionString);
        connection.Open();
        
        var command = connection.CreateCommand();
        command.CommandText = $"CREATE DATABASE IF NOT EXISTS {connection.Database}";
        command.ExecuteNonQuery();
        
        Log.Information($"Database '{connection.Database}' created or verified successfully!");
        connection.Close();
    }
    catch (Exception ex)
    {
        Log.Error(ex, "An error occurred while creating the database");
    }
}

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger(); 
    app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "RestaurantRoller API v1"));
}

app.UseHttpsRedirection();
app.UseAuthorization();

app.MapControllers();

try
{
    Log.Information("Starting RestaurantRoller API");
    
    // Apply migrations at startup if database is configured
    if (!string.IsNullOrEmpty(connectionString))
    {
        try
        {
            using (var scope = app.Services.CreateScope())
            {
                var dbContext = scope.ServiceProvider.GetRequiredService<RestaurantDbContext>();
                dbContext.Database.Migrate();
            }
        }
        catch (Exception ex)
        {
            Log.Error(ex, "An error occurred while applying database migrations");
        }
    }
    
    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "RestaurantRoller API terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}
