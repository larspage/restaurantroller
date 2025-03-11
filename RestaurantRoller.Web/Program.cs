using RestaurantRoller.Web.Services;
using Serilog;

var builder = WebApplication.CreateBuilder(args);

// Configure Serilog from appsettings.json
builder.Host.UseSerilog((context, services, configuration) => configuration
    .ReadFrom.Configuration(context.Configuration)
    .ReadFrom.Services(services));

// Add services to the container.
builder.Services.AddControllersWithViews();

// Register HttpClient for API calls
builder.Services.AddHttpClient<IRestaurantService, RestaurantService>(client =>
{
    // Get the API base URL from configuration or use default
    var apiBaseUrl = builder.Configuration["ApiBaseUrl"] ?? "https://localhost:7001/";
    client.BaseAddress = new Uri(apiBaseUrl);
});

// Register the RestaurantService
builder.Services.AddScoped<IRestaurantService, RestaurantService>();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseStaticFiles();
app.UseRouting();

app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

try
{
    Log.Information("Starting RestaurantRoller Web");
    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "RestaurantRoller Web terminated unexpectedly");
}
finally
{
    Log.CloseAndFlush();
}
