using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantRoller.API.Data.Entities
{
    public class Visit
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        public int RestaurantId { get; set; }
        
        public int? UserId { get; set; }
        
        [Required]
        public DateTime VisitDate { get; set; }
        
        [MaxLength(500)]
        public string Notes { get; set; } = string.Empty;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        // Navigation properties
        [ForeignKey("RestaurantId")]
        public Restaurant Restaurant { get; set; } = null!;
        
        [ForeignKey("UserId")]
        public User? User { get; set; }
    }
} 