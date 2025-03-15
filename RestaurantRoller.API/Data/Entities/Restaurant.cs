using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantRoller.API.Data.Entities
{
    public class Restaurant
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(100)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(50)]
        public string Cuisine { get; set; } = string.Empty;
        
        [MaxLength(500)]
        public string Description { get; set; } = string.Empty;
        
        [MaxLength(20)]
        public string PhoneNumber { get; set; } = string.Empty;
        
        [MaxLength(255)]
        public string Website { get; set; } = string.Empty;
        
        // Price range (1-4, where 1 is least expensive, 4 is most expensive)
        public int PriceRange { get; set; } = 2;
        
        // Location information
        [MaxLength(200)]
        public string StreetAddress { get; set; } = string.Empty;
        
        [MaxLength(100)]
        public string City { get; set; } = string.Empty;
        
        [MaxLength(50)]
        public string State { get; set; } = string.Empty;
        
        [MaxLength(20)]
        public string ZipCode { get; set; } = string.Empty;
        
        // Geo coordinates for distance calculations
        [Column(TypeName = "decimal(9,6)")]
        public decimal Latitude { get; set; }
        
        [Column(TypeName = "decimal(9,6)")]
        public decimal Longitude { get; set; }
        
        // Ratings
        [Column(TypeName = "decimal(3,1)")]
        public decimal AverageRating { get; set; }
        
        public int RatingCount { get; set; }
        
        [Column(TypeName = "decimal(3,1)")]
        public decimal? GoogleRating { get; set; }
        
        [Column(TypeName = "decimal(3,1)")]
        public decimal? YelpRating { get; set; }
        
        // Status
        public bool IsActive { get; set; } = true;
        
        // Timestamps
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? LastVisited { get; set; }
        
        // Navigation properties
        public virtual ICollection<OperatingHours> OperatingHours { get; set; } = new List<OperatingHours>();
        
        public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
        
        public virtual ICollection<UserRating> UserRatings { get; set; } = new List<UserRating>();
        
        public virtual ICollection<RestaurantCategory> RestaurantCategories { get; set; } = new List<RestaurantCategory>();
        
        public virtual ICollection<Visit> Visits { get; set; } = new List<Visit>();
    }
} 