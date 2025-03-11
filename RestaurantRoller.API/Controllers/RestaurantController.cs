using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using RestaurantRoller.API.Logging;
using Serilog;

namespace RestaurantRoller.API.Controllers
{
    /// <summary>
    /// API controller for managing restaurant data
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class RestaurantController : ControllerBase
    {
        private readonly ILogger<RestaurantController> _logger;
        private readonly Serilog.ILogger _serilogLogger;
        
        // In a real application, this would come from a database
        private static readonly string[] Restaurants = new[]
        {
            "Pizza Palace", "Burger Barn", "Taco Town", "Sushi Spot", "Pasta Place"
        };

        /// <summary>
        /// Constructor for RestaurantController
        /// </summary>
        /// <param name="logger">Logger instance</param>
        public RestaurantController(ILogger<RestaurantController> logger)
        {
            _logger = logger;
            _serilogLogger = Log.ForContext<RestaurantController>();
        }

        /// <summary>
        /// Gets all restaurants
        /// </summary>
        /// <returns>A list of restaurant names</returns>
        [HttpGet]
        [ProducesResponseType(StatusCodes.Status200OK)]
        public ActionResult<IEnumerable<string>> Get()
        {
            using (_serilogLogger.TimeMethod(nameof(Get)))
            {
                _logger.LogInformation("Getting all restaurants");
                return Ok(Restaurants);
            }
        }

        /// <summary>
        /// Gets a restaurant by ID
        /// </summary>
        /// <param name="id">The restaurant ID</param>
        /// <returns>The restaurant name</returns>
        [HttpGet("{id}")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public ActionResult<string> Get(int id)
        {
            using (_serilogLogger.TimeMethod(nameof(Get)))
            {
                _logger.LogInformation("Getting restaurant with ID: {Id}", id);
                
                if (id < 0 || id >= Restaurants.Length)
                {
                    _logger.LogWarning("Restaurant with ID {Id} not found", id);
                    return NotFound();
                }

                return Ok(Restaurants[id]);
            }
        }
    }
} 