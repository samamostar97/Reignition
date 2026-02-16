using System.ComponentModel.DataAnnotations;

namespace Reignition.Application.DTOs.Request;

public class UpdateMembershipTypeRequest
{
    [StringLength(100, MinimumLength = 2, ErrorMessage = "Naziv mora imati između 2 i 100 karaktera.")]
    public string? Name { get; set; }

    [StringLength(500, ErrorMessage = "Opis može imati maksimalno 500 karaktera.")]
    public string? Description { get; set; }

    [Range(1, 730, ErrorMessage = "Trajanje mora biti između 1 i 730 dana.")]
    public int? DurationInDays { get; set; }

    [Range(0.01, 99999.99, ErrorMessage = "Cijena mora biti između 0.01 i 99999.99.")]
    public decimal? Price { get; set; }

    public bool? IsActive { get; set; }
}
