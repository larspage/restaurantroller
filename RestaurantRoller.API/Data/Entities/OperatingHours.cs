using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantRoller.API.Data.Entities
{
    public class OperatingHours
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        public int RestaurantId { get; set; }
        
        [Required]
        public DayOfWeek DayOfWeek { get; set; }
        
        public TimeSpan OpenTime { get; set; }
        
        public TimeSpan CloseTime { get; set; }
        
        public bool IsClosed { get; set; }
        
        // Navigation property
        [ForeignKey("RestaurantId")]
        public Restaurant Restaurant { get; set; } = null!;
    }
} 