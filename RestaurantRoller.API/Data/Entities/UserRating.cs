using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantRoller.API.Data.Entities
{
    public enum RatingType
    {
        Favorite = 5,
        Good = 4,
        Okay = 3,
        NotGreat = 2,
        NeverAgain = 1
    }

    public class UserRating
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        public int UserId { get; set; }
        
        [Required]
        public int RestaurantId { get; set; }
        
        [Required]
        public RatingType Rating { get; set; }
        
        public int? CategoryId { get; set; }
        
        [MaxLength(50)]
        public string Cuisine { get; set; } = string.Empty;
        
        [MaxLength(500)]
        public string Comment { get; set; } = string.Empty;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Navigation properties
        [ForeignKey("UserId")]
        public User User { get; set; } = null!;
        
        [ForeignKey("RestaurantId")]
        public Restaurant Restaurant { get; set; } = null!;
        
        [ForeignKey("CategoryId")]
        public Category? Category { get; set; }
    }
} 