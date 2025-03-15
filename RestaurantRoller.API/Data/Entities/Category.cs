using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantRoller.API.Data.Entities
{
    public class Category
    {
        [Key]
        public int Id { get; set; }
        
        [Required]
        [MaxLength(50)]
        public string Name { get; set; } = string.Empty;
        
        [MaxLength(200)]
        public string Description { get; set; } = string.Empty;
        
        [MaxLength(50)]
        public string IconName { get; set; } = string.Empty;
        
        [MaxLength(20)]
        public string ColorCode { get; set; } = string.Empty;
        
        public int DisplayOrder { get; set; }
        
        public int? ParentCategoryId { get; set; }
        
        public bool IsActive { get; set; } = true;
        
        // Navigation properties
        [ForeignKey("ParentCategoryId")]
        public Category? ParentCategory { get; set; }
        
        public ICollection<Category> Subcategories { get; set; } = new List<Category>();
        public ICollection<RestaurantCategory> RestaurantCategories { get; set; } = new List<RestaurantCategory>();
        public ICollection<UserRating> UserRatings { get; set; } = new List<UserRating>();
    }
} 