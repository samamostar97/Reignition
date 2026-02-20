using Reignition.Core.Enums;

namespace Reignition.Application.DTOs.Response;

public class PaymentResponse
{
    public int Id { get; set; }
    public int UserId { get; set; }
    public string UserFullName { get; set; } = string.Empty;
    public int? MembershipId { get; set; }
    public string? MembershipTypeName { get; set; }
    public decimal Amount { get; set; }
    public PaymentMethod PaymentMethod { get; set; }
    public DateTime TransactionDate { get; set; }
    public string? Note { get; set; }
    public PaymentStatus Status { get; set; }
    public DateTime CreatedAt { get; set; }
}
