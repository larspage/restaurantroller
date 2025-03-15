using Microsoft.EntityFrameworkCore;
using RestaurantRoller.API.Data.Entities;

namespace RestaurantRoller.API.Data
{
    public class RestaurantDbContext : DbContext
    {
        public RestaurantDbContext(DbContextOptions<RestaurantDbContext> options) : base(options)
        {
        }

        public DbSet<Restaurant> Restaurants { get; set; } = null!;
        public DbSet<OperatingHours> OperatingHours { get; set; } = null!;
        public DbSet<Review> Reviews { get; set; } = null!;
        public DbSet<User> Users { get; set; } = null!;
        public DbSet<Address> Addresses { get; set; } = null!;
        public DbSet<UserPreference> UserPreferences { get; set; } = null!;
        public DbSet<UserFavorite> UserFavorites { get; set; } = null!;
        public DbSet<Category> Categories { get; set; } = null!;
        public DbSet<RestaurantCategory> RestaurantCategories { get; set; } = null!;
        public DbSet<Visit> Visits { get; set; } = null!;
        public DbSet<UserRating> UserRatings { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Configure relationships
            modelBuilder.Entity<User>()
                .HasOne(u => u.HomeAddress)
                .WithMany(a => a.UsersWithHomeAddress)
                .HasForeignKey(u => u.HomeAddressId)
                .OnDelete(DeleteBehavior.Restrict);

            modelBuilder.Entity<User>()
                .HasOne(u => u.WorkAddress)
                .WithMany(a => a.UsersWithWorkAddress)
                .HasForeignKey(u => u.WorkAddressId)
                .OnDelete(DeleteBehavior.Restrict);
                
            // Configure Category self-referencing relationship
            modelBuilder.Entity<Category>()
                .HasOne(c => c.ParentCategory)
                .WithMany(c => c.Subcategories)
                .HasForeignKey(c => c.ParentCategoryId)
                .OnDelete(DeleteBehavior.Restrict);

            // Seed some initial data
            SeedData(modelBuilder);
        }

        private void SeedData(ModelBuilder modelBuilder)
        {
            // Seed restaurants
            modelBuilder.Entity<Restaurant>().HasData(
                new Restaurant
                {
                    Id = 1,
                    Name = "Pasta Paradise",
                    Cuisine = "Italian",
                    Description = "Authentic Italian pasta and pizza in a cozy atmosphere.",
                    PhoneNumber = "(555) 123-4567",
                    Website = "https://pastaparadise.example.com",
                    StreetAddress = "123 Main St",
                    City = "Anytown",
                    State = "CA",
                    ZipCode = "90210",
                    Latitude = 34.0522m,
                    Longitude = -118.2437m,
                    AverageRating = 4.5m,
                    RatingCount = 120,
                    GoogleRating = 4.3m,
                    YelpRating = 4.2m,
                    PriceRange = 2,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Restaurant
                {
                    Id = 2,
                    Name = "Sushi Sensation",
                    Cuisine = "Japanese",
                    Description = "Fresh sushi and sashimi prepared by master chefs.",
                    PhoneNumber = "(555) 234-5678",
                    Website = "https://sushisensation.example.com",
                    StreetAddress = "456 Oak Ave",
                    City = "Anytown",
                    State = "CA",
                    ZipCode = "90210",
                    Latitude = 34.0548m,
                    Longitude = -118.2500m,
                    AverageRating = 4.8m,
                    RatingCount = 85,
                    GoogleRating = 4.7m,
                    YelpRating = 4.5m,
                    PriceRange = 3,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                },
                new Restaurant
                {
                    Id = 3,
                    Name = "Burger Bonanza",
                    Cuisine = "American",
                    Description = "Juicy burgers and crispy fries in a family-friendly setting.",
                    PhoneNumber = "(555) 345-6789",
                    Website = "https://burgerbonanza.example.com",
                    StreetAddress = "789 Elm Blvd",
                    City = "Anytown",
                    State = "CA",
                    ZipCode = "90210",
                    Latitude = 34.0575m,
                    Longitude = -118.2525m,
                    AverageRating = 4.2m,
                    RatingCount = 150,
                    GoogleRating = 4.0m,
                    YelpRating = 3.9m,
                    PriceRange = 1,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                }
            );

            // Seed categories
            modelBuilder.Entity<Category>().HasData(
                // Main cuisine categories
                new Category { Id = 1, Name = "Italian", Description = "Italian cuisine", IconName = "pizza", ColorCode = "#E51A4B", DisplayOrder = 1, IsActive = true },
                new Category { Id = 2, Name = "Japanese", Description = "Japanese cuisine", IconName = "sushi", ColorCode = "#D90B6E", DisplayOrder = 2, IsActive = true },
                new Category { Id = 3, Name = "American", Description = "American cuisine", IconName = "burger", ColorCode = "#F44336", DisplayOrder = 3, IsActive = true },
                new Category { Id = 4, Name = "Mexican", Description = "Mexican cuisine", IconName = "taco", ColorCode = "#FF9800", DisplayOrder = 4, IsActive = true },
                new Category { Id = 5, Name = "Chinese", Description = "Chinese cuisine", IconName = "noodles", ColorCode = "#FFC107", DisplayOrder = 5, IsActive = true }
            );
            
            // Seed restaurant categories
            modelBuilder.Entity<RestaurantCategory>().HasData(
                // Pasta Paradise
                new RestaurantCategory { Id = 1, RestaurantId = 1, CategoryId = 1, IsPrimary = true, CreatedAt = DateTime.UtcNow },
                
                // Sushi Sensation
                new RestaurantCategory { Id = 2, RestaurantId = 2, CategoryId = 2, IsPrimary = true, CreatedAt = DateTime.UtcNow },
                
                // Burger Bonanza
                new RestaurantCategory { Id = 3, RestaurantId = 3, CategoryId = 3, IsPrimary = true, CreatedAt = DateTime.UtcNow }
            );
        }
    }
} 