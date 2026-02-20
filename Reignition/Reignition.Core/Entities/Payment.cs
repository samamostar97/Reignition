using Reignition.Core.Enums;

namespace Reignition.Core.Entities;

public class Payment : BaseEntity
{
    public int UserId { get; set; }
    public int? MembershipId { get; set; }
    public decimal Amount { get; set; }
    public PaymentMethod PaymentMethod { get; set; }
    public DateTime TransactionDate { get; set; }
    public string? Note { get; set; }
    public PaymentStatus Status { get; set; } = PaymentStatus.Completed;

    public User User { get; set; } = null!;
    public Membership? Membership { get; set; }
}
