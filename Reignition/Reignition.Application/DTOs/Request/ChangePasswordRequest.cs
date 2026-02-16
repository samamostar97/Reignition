using System.ComponentModel.DataAnnotations;

namespace Reignition.Application.DTOs.Request;

public class ChangePasswordRequest
{
    [Required(ErrorMessage = "Trenutna lozinka je obavezna.")]
    public string CurrentPassword { get; set; } = string.Empty;

    [Required(ErrorMessage = "Nova lozinka je obavezna.")]
    [StringLength(100, MinimumLength = 6, ErrorMessage = "Nova lozinka mora imati najmanje 6 karaktera.")]
    public string NewPassword { get; set; } = string.Empty;
}
