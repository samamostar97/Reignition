using System.ComponentModel.DataAnnotations;

namespace Reignition.Application.DTOs.Request;

public class CreateMembershipRequest
{
    [Required(ErrorMessage = "Korisnik je obavezan.")]
    public int UserId { get; set; }

    [Required(ErrorMessage = "Tip članarine je obavezan.")]
    public int MembershipTypeId { get; set; }

    public DateTime? StartDate { get; set; }
}
