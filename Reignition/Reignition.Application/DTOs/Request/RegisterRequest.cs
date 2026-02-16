using System.ComponentModel.DataAnnotations;

namespace Reignition.Application.DTOs.Request;

public class RegisterRequest
{
    [Required(ErrorMessage = "Korisničko ime je obavezno.")]
    [StringLength(50, MinimumLength = 3, ErrorMessage = "Korisničko ime mora imati između 3 i 50 karaktera.")]
    public string Username { get; set; } = string.Empty;

    [Required(ErrorMessage = "Ime je obavezno.")]
    [StringLength(50, MinimumLength = 2, ErrorMessage = "Ime mora imati između 2 i 50 karaktera.")]
    public string FirstName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Prezime je obavezno.")]
    [StringLength(50, MinimumLength = 2, ErrorMessage = "Prezime mora imati između 2 i 50 karaktera.")]
    public string LastName { get; set; } = string.Empty;

    [Required(ErrorMessage = "Email je obavezan.")]
    [EmailAddress(ErrorMessage = "Email format nije validan.")]
    public string Email { get; set; } = string.Empty;

    [Required(ErrorMessage = "Lozinka je obavezna.")]
    [StringLength(100, MinimumLength = 6, ErrorMessage = "Lozinka mora imati najmanje 6 karaktera.")]
    public string Password { get; set; } = string.Empty;

    [Phone(ErrorMessage = "Broj telefona nije validan.")]
    public string? PhoneNumber { get; set; }
}
