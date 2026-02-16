using Reignition.Application.Common;
using Reignition.Core.Enums;

namespace Reignition.Application.Filters;

public class MembershipQueryFilter : PaginationRequest
{
    public int? UserId { get; set; }
    public int? MembershipTypeId { get; set; }
    public MembershipStatus? Status { get; set; }
}
