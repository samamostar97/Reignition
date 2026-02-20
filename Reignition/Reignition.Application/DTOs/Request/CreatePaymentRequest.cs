using System.ComponentModel.DataAnnotations;
using Reignition.Core.Enums;

namespace Reignition.Application.DTOs.Request;

public class CreatePaymentRequest
{
    [Required(ErrorMessage = "Korisnik je obavezan.")]
    public int UserId { get; set; }

    public int? MembershipId { get; set; }

    [Required(ErrorMessage = "Iznos je obavezan.")]
    [Range(0.01, 99999.99, ErrorMessage = "Iznos mora biti između 0.01 i 99999.99.")]
    public decimal Amount { get; set; }

    [Required(ErrorMessage = "Način plaćanja je obavezan.")]
    public PaymentMethod PaymentMethod { get; set; }

    public DateTime? TransactionDate { get; set; }

    [StringLength(500, ErrorMessage = "Napomena ne smije imati više od 500 karaktera.")]
    public string? Note { get; set; }
}
