using Reignition.Core.Enums;

namespace Reignition.Core.Entities;

public class Membership : BaseEntity
{
    public int UserId { get; set; }
    public int MembershipTypeId { get; set; }
    public DateTime StartDate { get; set; }
    public DateTime EndDate { get; set; }
    public MembershipStatus Status { get; set; } = MembershipStatus.Active;

    public User User { get; set; } = null!;
    public MembershipType MembershipType { get; set; } = null!;
}
