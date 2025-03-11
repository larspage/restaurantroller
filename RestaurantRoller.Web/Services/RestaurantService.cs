using RestaurantRoller.Web.Models;
using System.Text.Json;
using RestaurantRoller.Web.Logging;
using Serilog;

namespace RestaurantRoller.Web.Services
{
    /// <summary>
    /// Interface for restaurant service operations
    /// </summary>
    public interface IRestaurantService
    {
        /// <summary>
        /// Gets all restaurants asynchronously
        /// </summary>
        /// <returns>A list of restaurant names</returns>
        Task<List<string>> GetRestaurantsAsync();
        
        /// <summary>
        /// Gets a restaurant by ID asynchronously
        /// </summary>
        /// <param name="id">The restaurant ID</param>
        /// <returns>The restaurant name or empty string if not found</returns>
        Task<string> GetRestaurantByIdAsync(int id);
    }

    /// <summary>
    /// Implementation of the restaurant service that calls the API
    /// </summary>
    public class RestaurantService : IRestaurantService
    {
        private readonly HttpClient _httpClient;
        private readonly ILogger<RestaurantService> _logger;
        private readonly Serilog.ILogger _serilogLogger;
        private readonly JsonSerializerOptions _jsonOptions;

        /// <summary>
        /// Constructor for RestaurantService
        /// </summary>
        /// <param name="httpClient">HTTP client for API calls</param>
        /// <param name="configuration">Application configuration</param>
        /// <param name="logger">Logger instance</param>
        public RestaurantService(HttpClient httpClient, IConfiguration configuration, ILogger<RestaurantService> logger)
        {
            _httpClient = httpClient;
            _logger = logger;
            _serilogLogger = Log.ForContext<RestaurantService>();
            _jsonOptions = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        }

        /// <summary>
        /// Gets all restaurants asynchronously from the API
        /// </summary>
        /// <returns>A list of restaurant names</returns>
        public async Task<List<string>> GetRestaurantsAsync()
        {
            using (_serilogLogger.TimeMethod(nameof(GetRestaurantsAsync)))
            {
                try
                {
                    _logger.LogInformation("Fetching all restaurants from API");
                    var response = await _httpClient.GetAsync("api/restaurant");
                    response.EnsureSuccessStatusCode();
                    
                    var content = await response.Content.ReadAsStringAsync();
                    var restaurants = JsonSerializer.Deserialize<List<string>>(content, _jsonOptions);
                    
                    return restaurants ?? new List<string>();
                }
                catch (HttpRequestException ex)
                {
                    _logger.LogError(ex, "Error calling restaurant API");
                    throw;
                }
                catch (JsonException ex)
                {
                    _logger.LogError(ex, "Error deserializing restaurant data");
                    return new List<string>();
                }
            }
        }

        /// <summary>
        /// Gets a restaurant by ID asynchronously from the API
        /// </summary>
        /// <param name="id">The restaurant ID</param>
        /// <returns>The restaurant name or empty string if not found</returns>
        public async Task<string> GetRestaurantByIdAsync(int id)
        {
            using (_serilogLogger.TimeMethod(nameof(GetRestaurantByIdAsync)))
            {
                try
                {
                    _logger.LogInformation("Fetching restaurant with ID {Id} from API", id);
                    var response = await _httpClient.GetAsync($"api/restaurant/{id}");
                    
                    if (!response.IsSuccessStatusCode)
                    {
                        _logger.LogWarning("Restaurant with ID {Id} not found. Status code: {StatusCode}", 
                            id, response.StatusCode);
                        return string.Empty;
                    }
                    
                    var content = await response.Content.ReadAsStringAsync();
                    var restaurant = JsonSerializer.Deserialize<string>(content, _jsonOptions);
                    
                    return restaurant ?? string.Empty;
                }
                catch (HttpRequestException ex)
                {
                    _logger.LogError(ex, "Error calling restaurant API for ID {Id}", id);
                    throw;
                }
                catch (JsonException ex)
                {
                    _logger.LogError(ex, "Error deserializing restaurant data for ID {Id}", id);
                    return string.Empty;
                }
            }
        }
    }
} 