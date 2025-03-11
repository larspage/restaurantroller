using Microsoft.AspNetCore.Mvc;
using RestaurantRoller.Web.Models;
using RestaurantRoller.Web.Services;
using RestaurantRoller.Web.Logging;
using Serilog;

namespace RestaurantRoller.Web.Controllers
{
    /// <summary>
    /// Controller for restaurant-related views
    /// </summary>
    public class RestaurantController : Controller
    {
        private readonly IRestaurantService _restaurantService;
        private readonly ILogger<RestaurantController> _logger;
        private readonly Serilog.ILogger _serilogLogger;

        /// <summary>
        /// Constructor for RestaurantController
        /// </summary>
        /// <param name="restaurantService">Service for restaurant operations</param>
        /// <param name="logger">Logger instance</param>
        public RestaurantController(IRestaurantService restaurantService, ILogger<RestaurantController> logger)
        {
            _restaurantService = restaurantService;
            _logger = logger;
            _serilogLogger = Log.ForContext<RestaurantController>();
        }

        /// <summary>
        /// Displays a list of all restaurants
        /// </summary>
        /// <returns>View with list of restaurants</returns>
        public async Task<IActionResult> Index()
        {
            using (_serilogLogger.TimeMethod(nameof(Index)))
            {
                try
                {
                    _logger.LogInformation("Retrieving list of restaurants for Index view");
                    var restaurants = await _restaurantService.GetRestaurantsAsync();
                    var viewModel = new RestaurantListViewModel
                    {
                        Restaurants = restaurants.Select(r => new RestaurantViewModel { Name = r }).ToList()
                    };
                    return View(viewModel);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error retrieving restaurants for Index view");
                    return View("Error");
                }
            }
        }

        /// <summary>
        /// Displays details for a specific restaurant
        /// </summary>
        /// <param name="id">The restaurant ID</param>
        /// <returns>View with restaurant details</returns>
        public async Task<IActionResult> Details(int id)
        {
            using (_serilogLogger.TimeMethod(nameof(Details)))
            {
                try
                {
                    _logger.LogInformation("Retrieving details for restaurant with ID: {Id}", id);
                    var restaurant = await _restaurantService.GetRestaurantByIdAsync(id);
                    if (string.IsNullOrEmpty(restaurant))
                    {
                        _logger.LogWarning("Restaurant with ID {Id} not found", id);
                        return NotFound();
                    }
                    
                    var viewModel = new RestaurantViewModel
                    {
                        Name = restaurant
                    };
                    return View(viewModel);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "Error retrieving details for restaurant with ID: {Id}", id);
                    return View("Error");
                }
            }
        }
    }
} 