using System.ComponentModel.DataAnnotations;
using Reignition.Core.Enums;

namespace Reignition.Application.DTOs.Request;

public class UpdateUserRequest
{
    [StringLength(50, MinimumLength = 3, ErrorMessage = "Korisničko ime mora imati između 3 i 50 karaktera.")]
    public string? Username { get; set; }

    [StringLength(50, MinimumLength = 2, ErrorMessage = "Ime mora imati između 2 i 50 karaktera.")]
    public string? FirstName { get; set; }

    [StringLength(50, MinimumLength = 2, ErrorMessage = "Prezime mora imati između 2 i 50 karaktera.")]
    public string? LastName { get; set; }

    [EmailAddress(ErrorMessage = "Email format nije validan.")]
    public string? Email { get; set; }

    [Phone(ErrorMessage = "Broj telefona nije validan.")]
    public string? PhoneNumber { get; set; }

    public Role? Role { get; set; }

    public bool? IsActive { get; set; }
}
