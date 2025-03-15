using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantRoller.API.Data.Entities
{
    public class User
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string Username { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        [EmailAddress]
        public string Email { get; set; } = string.Empty;
        
        [MaxLength(50)]
        public string FirstName { get; set; } = string.Empty;
        
        [MaxLength(50)]
        public string LastName { get; set; } = string.Empty;
        
        // User's home address
        public int? HomeAddressId { get; set; }
        
        // User's work address
        public int? WorkAddressId { get; set; }
        
        // User's preferences
        public virtual ICollection<UserPreference> Preferences { get; set; } = new List<UserPreference>();
        
        // User's reviews
        public virtual ICollection<Review> Reviews { get; set; } = new List<Review>();
        
        // User's simplified ratings
        public virtual ICollection<UserRating> Ratings { get; set; } = new List<UserRating>();
        
        // User's favorite restaurants
        public virtual ICollection<UserFavorite> Favorites { get; set; } = new List<UserFavorite>();
        
        // User's restaurant visits
        public virtual ICollection<Visit> Visits { get; set; } = new List<Visit>();
        
        [Required]
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? LastLogin { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        // Navigation properties
        [ForeignKey("HomeAddressId")]
        public Address? HomeAddress { get; set; }
        
        [ForeignKey("WorkAddressId")]
        public Address? WorkAddress { get; set; }
    }
} 