using System.ComponentModel.DataAnnotations;

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
        
        public decimal Rating { get; set; }
        
        [MaxLength(200)]
        public string Address { get; set; } = string.Empty;
        
        public bool IsActive { get; set; } = true;
        
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        
        public DateTime? LastVisited { get; set; }
    }
} 