using Microsoft.EntityFrameworkCore;
using RestaurantRoller.API.Data.Entities;

namespace RestaurantRoller.API.Data
{
    public class RestaurantRepository
    {
        private readonly RestaurantDbContext _context;

        public RestaurantRepository(RestaurantDbContext context)
        {
            _context = context;
        }

        public async Task<IEnumerable<Restaurant>> GetAllRestaurantsAsync()
        {
            return await _context.Restaurants
                .Where(r => r.IsActive)
                .OrderBy(r => r.Name)
                .ToListAsync();
        }

        public async Task<Restaurant?> GetRestaurantByIdAsync(int id)
        {
            return await _context.Restaurants.FindAsync(id);
        }

        public async Task<Restaurant> AddRestaurantAsync(Restaurant restaurant)
        {
            _context.Restaurants.Add(restaurant);
            await _context.SaveChangesAsync();
            return restaurant;
        }

        public async Task<bool> UpdateRestaurantAsync(Restaurant restaurant)
        {
            _context.Entry(restaurant).State = EntityState.Modified;
            
            try
            {
                await _context.SaveChangesAsync();
                return true;
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!await RestaurantExists(restaurant.Id))
                {
                    return false;
                }
                throw;
            }
        }

        public async Task<bool> DeleteRestaurantAsync(int id)
        {
            var restaurant = await _context.Restaurants.FindAsync(id);
            if (restaurant == null)
            {
                return false;
            }

            // Soft delete
            restaurant.IsActive = false;
            await _context.SaveChangesAsync();
            return true;
        }

        public async Task<Restaurant?> GetRandomRestaurantAsync()
        {
            var count = await _context.Restaurants.CountAsync(r => r.IsActive);
            if (count == 0)
            {
                return null;
            }

            var random = new Random();
            var skip = random.Next(count);

            return await _context.Restaurants
                .Where(r => r.IsActive)
                .Skip(skip)
                .Take(1)
                .FirstOrDefaultAsync();
        }

        private async Task<bool> RestaurantExists(int id)
        {
            return await _context.Restaurants.AnyAsync(e => e.Id == id);
        }
    }
} 