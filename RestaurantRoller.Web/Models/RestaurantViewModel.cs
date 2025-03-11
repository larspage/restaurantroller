namespace RestaurantRoller.Web.Models
{
    /// <summary>
    /// View model for a single restaurant
    /// </summary>
    public class RestaurantViewModel
    {
        /// <summary>
        /// The name of the restaurant
        /// </summary>
        public string Name { get; set; } = string.Empty;
    }

    /// <summary>
    /// View model for a list of restaurants
    /// </summary>
    public class RestaurantListViewModel
    {
        /// <summary>
        /// The list of restaurants
        /// </summary>
        public List<RestaurantViewModel> Restaurants { get; set; } = new List<RestaurantViewModel>();
    }
} 