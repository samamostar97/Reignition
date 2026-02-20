using Reignition.Core.Enums;

namespace Reignition.Application.DTOs.Request;

public class UpdatePaymentRequest
{
    public int? MembershipId { get; set; }
    public decimal? Amount { get; set; }
    public PaymentMethod? PaymentMethod { get; set; }
    public DateTime? TransactionDate { get; set; }
    public string? Note { get; set; }
    public PaymentStatus? Status { get; set; }
}
