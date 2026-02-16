namespace Reignition.Core.Entities;

public class MembershipType : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int DurationInDays { get; set; }
    public decimal Price { get; set; }
    public bool IsActive { get; set; } = true;

    public ICollection<Membership> Memberships { get; set; } = new List<Membership>();
}
