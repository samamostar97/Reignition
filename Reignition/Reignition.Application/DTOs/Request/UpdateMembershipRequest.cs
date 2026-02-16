using Reignition.Core.Enums;

namespace Reignition.Application.DTOs.Request;

public class UpdateMembershipRequest
{
    public int? MembershipTypeId { get; set; }
    public DateTime? StartDate { get; set; }
    public MembershipStatus? Status { get; set; }
}
