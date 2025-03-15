using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantRoller.API.Data.Entities
{
    public class UserPreference
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        public int UserId { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string PreferenceType { get; set; } = string.Empty;
        
        [Required]
        [MaxLength(100)]
        public string PreferenceValue { get; set; } = string.Empty;
        
        public int? CategoryId { get; set; }
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Navigation properties
        [ForeignKey("UserId")]
        public User User { get; set; } = null!;
        
        [ForeignKey("CategoryId")]
        public Category? Category { get; set; }
    }
} 